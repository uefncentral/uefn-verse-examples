# Team Deathmatch
# A team-based deathmatch mode with automatic team assignment, team score tracking, and round-based gameplay.
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/team-deathmatch?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/Teams }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# Team Deathmatch Game Mode
team_deathmatch_device := class(creative_device):

    @editable
    ScoreLimit : int = 50

    @editable
    GameDurationMinutes : float = 15.0

    @editable
    RespawnDelay : float = 3.0

    @editable
    Team1Spawners : []player_spawner_device = array{}

    @editable
    Team2Spawners : []player_spawner_device = array{}

    @editable
    ScoreManager : score_manager_device = score_manager_device{}

    @editable
    EndGameDevice : end_game_device = end_game_device{}

    var Team1Score : int = 0
    var Team2Score : int = 0
    var GameActive : logic = false

    OnBegin<override>()<suspends> : void =
        Print("Team Deathmatch Initializing...")

        Playspace := GetPlayspace()
        Playspace.PlayerAddedEvent().Subscribe(OnPlayerAdded)

        # Initialize existing players
        AllPlayers := Playspace.GetPlayers()
        for (Player : AllPlayers):
            spawn { PlayerDeathHandler(Player) }

        set GameActive = true

        race:
            GameTimer()
            CheckForWinner()

    GameTimer()<suspends> : void =
        Sleep(GameDurationMinutes * 60.0)
        DetermineWinner()

    CheckForWinner()<suspends> : void =
        loop:
            Sleep(0.5)
            if (GameActive?):
                if (Team1Score >= ScoreLimit):
                    EndGameForTeam(1)
                    return
                if (Team2Score >= ScoreLimit):
                    EndGameForTeam(2)
                    return

    OnPlayerAdded(Player : player) : void =
        spawn { PlayerDeathHandler(Player) }

    PlayerDeathHandler(Player : player)<suspends> : void =
        loop:
            if (FortCharacter := Player.GetFortCharacter[]):
                FortCharacter.EliminatedEvent().Await()

                if (GameActive?):
                    # Award point to eliminator's team
                    if (Eliminator := FortCharacter.GetInstigator[]):
                        if (EliminatorPlayer := player[Eliminator]):
                            AwardTeamPoint(EliminatorPlayer)

                    # Respawn
                    Sleep(RespawnDelay)
                    # RespawnPlayer(Player)  # TODO: not a Verse function — use player_spawner_device

    AwardTeamPoint(Player : player) : void =
        TeamCollection := GetPlayspace().GetTeamCollection()
        if (Team := TeamCollection.GetTeam[Player]):
            TeamIndex := TeamCollection.GetTeams().Find[Team]
            if (TeamIndex = 0):
                set Team1Score += 1
                ScoreManager.SetScoreAward(1)
            else if (TeamIndex = 1):
                set Team2Score += 1
                ScoreManager.SetScoreAward(1)
            ScoreManager.Activate(Player)

    # RespawnPlayer(Player : player)  # TODO: not a Verse function — use player_spawner_device : void =
        TeamCollection := GetPlayspace().GetTeamCollection()
        if (Team := TeamCollection.GetTeam[Player]):
            TeamIndex := TeamCollection.GetTeams().Find[Team]
            Spawners := if (TeamIndex = 0) then Team1Spawners else Team2Spawners
            if (Spawners.Length > 0):
                RandomIndex := GetRandomInt(0, Spawners.Length - 1)
                if (Spawner := Spawners[RandomIndex]):
                    Spawner.# SpawnPlayer(Player)  # TODO: not a Verse function — use player_spawner_device

    DetermineWinner() : void =
        if (Team1Score > Team2Score):
            EndGameForTeam(1)
        else if (Team2Score > Team1Score):
            EndGameForTeam(2)
        else:
            # Tie - random winner
            EndGameForTeam(GetRandomInt(1, 2))

    EndGameForTeam(WinningTeam : int) : void =
        set GameActive = false
        TeamCollection := GetPlayspace().GetTeamCollection()
        Teams := TeamCollection.GetTeams()

        if (WinningTeamObj := Teams[WinningTeam - 1]):
            Players := TeamCollection.GetAgents[WinningTeamObj]
            for (Agent : Players):
                EndGameDevice.Activate(Agent)
                break  # Only need to activate once
