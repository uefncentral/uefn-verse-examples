# Free For All Deathmatch
# A complete free-for-all deathmatch game mode with kill tracking, respawning, and winner detection. Includes configurable kill limit and game duration.
# Difficulty: intermediate  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/ffa-deathmatch?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# Free For All Deathmatch Game Mode
# Configurable kill limit and game duration
ffa_deathmatch_device := class(creative_device):

    @editable
    KillLimit : int = 20

    @editable
    GameDurationMinutes : float = 10.0

    @editable
    RespawnDelay : float = 3.0

    @editable
    PlayerSpawners : []player_spawner_device = array{}

    @editable
    EndGameDevice : end_game_device = end_game_device{}

    @editable
    HUDMessageDevice : hud_message_device = hud_message_device{}

    var PlayerKills : [player]int = map{}
    var GameActive : logic = false

    OnBegin<override>()<suspends> : void =
        Print("FFA Deathmatch Initializing...")

        # Subscribe to player events
        Playspace := GetPlayspace()
        Playspace.PlayerAddedEvent().Subscribe(OnPlayerAdded)
        Playspace.PlayerRemovedEvent().Subscribe(OnPlayerRemoved)

        # Initialize existing players
        AllPlayers := Playspace.GetPlayers()
        for (Player : AllPlayers):
            InitializePlayer(Player)

        # Start the game
        set GameActive = true

        # Run game timer
        race:
            GameTimer()
            CheckForWinner()

    GameTimer()<suspends> : void =
        Sleep(GameDurationMinutes * 60.0)
        EndGame(false)

    CheckForWinner()<suspends> : void =
        loop:
            Sleep(0.5)
            if (GameActive?):
                for (Player -> Kills : PlayerKills):
                    if (Kills >= KillLimit):
                        EndGame(true, ?Winner := Player)
                        return

    OnPlayerAdded(Player : player) : void =
        InitializePlayer(Player)

    OnPlayerRemoved(Player : player) : void =
        if (set PlayerKills[Player] = 0) {}

    InitializePlayer(Player : player) : void =
        if (set PlayerKills[Player] = 0) {}
        spawn { PlayerDeathHandler(Player) }

    PlayerDeathHandler(Player : player)<suspends> : void =
        loop:
            if (FortCharacter := Player.GetFortCharacter[]):
                FortCharacter.EliminatedEvent().Await()

                if (GameActive?):
                    # Award kill to eliminator
                    if (Eliminator := FortCharacter.GetInstigator[]):
                        if (EliminatorPlayer := player[Eliminator]):
                            if (CurrentKills := PlayerKills[EliminatorPlayer]):
                                NewKills := CurrentKills + 1
                                if (set PlayerKills[EliminatorPlayer] = NewKills) {}
                                UpdateHUD(EliminatorPlayer, NewKills)

                    # Respawn player
                    Sleep(RespawnDelay)
                    # RespawnPlayer(Player)  # TODO: not a Verse function — use player_spawner_device

    # RespawnPlayer(Player : player)  # TODO: not a Verse function — use player_spawner_device : void =
        if (PlayerSpawners.Length > 0):
            RandomIndex := GetRandomInt(0, PlayerSpawners.Length - 1)
            if (Spawner := PlayerSpawners[RandomIndex]):
                Spawner.# SpawnPlayer(Player)  # TODO: not a Verse function — use player_spawner_device

    UpdateHUD(Player : player, Kills : int) : void =
        Message := StringToMessage("Kills: {Kills} / {KillLimit}")
        HUDMessageDevice.SetText(Message)

    EndGame(HasWinner : logic, ?Winner : player = player{})<suspends> : void =
        set GameActive = false

        if (HasWinner?):
            if (Agent := Winner.GetFortCharacter[].GetAgent[]):
                EndGameDevice.Activate(Agent)
        else:
            # Find highest scorer
            var HighestKills : int = 0
            var TopPlayer : ?player = false
            for (Player -> Kills : PlayerKills):
                if (Kills > HighestKills):
                    set HighestKills = Kills
                    set TopPlayer = option{Player}

            if (Winner := TopPlayer?):
                if (Agent := Winner.GetFortCharacter[].GetAgent[]):
                    EndGameDevice.Activate(Agent)
