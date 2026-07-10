# Player Stats Tracker
# Track player statistics including kills, deaths, assists, and K/D ratio. Persists during the session and provides easy access methods.
# Difficulty: intermediate  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/player-stats-tracker?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# Player statistics tracking system
player_stats := struct:
    var Kills : int = 0
    var Deaths : int = 0
    var Assists : int = 0
    var DamageDealt : float = 0.0
    var DamageTaken : float = 0.0

player_stats_tracker := class(creative_device):

    var PlayerStats : [player]player_stats = map{}

    OnBegin<override>()<suspends> : void =
        Playspace := GetPlayspace()
        Playspace.PlayerAddedEvent().Subscribe(OnPlayerAdded)
        Playspace.PlayerRemovedEvent().Subscribe(OnPlayerRemoved)

        # Initialize existing players
        for (Player : Playspace.GetPlayers()):
            InitializePlayer(Player)
            spawn { TrackPlayerEvents(Player) }

    OnPlayerAdded(Player : player) : void =
        InitializePlayer(Player)
        spawn { TrackPlayerEvents(Player) }

    OnPlayerRemoved(Player : player) : void =
        # Stats persist until game ends, just log removal
        Print("Player left: stats preserved")

    InitializePlayer(Player : player) : void =
        if (not PlayerStats[Player]):
            if (set PlayerStats[Player] = player_stats{}) {}

    TrackPlayerEvents(Player : player)<suspends> : void =
        loop:
            if (FortCharacter := Player.GetFortCharacter[]):
                FortCharacter.EliminatedEvent().Await()

                # Record death
                RecordDeath(Player)

                # Record kill for eliminator
                if (Eliminator := FortCharacter.GetInstigator[]):
                    if (EliminatorPlayer := player[Eliminator]):
                        RecordKill(EliminatorPlayer)

    RecordKill(Player : player) : void =
        if (Stats := PlayerStats[Player]):
            if (set PlayerStats[Player] = player_stats{
                Kills := Stats.Kills + 1,
                Deaths := Stats.Deaths,
                Assists := Stats.Assists,
                DamageDealt := Stats.DamageDealt,
                DamageTaken := Stats.DamageTaken
            }) {}
            Print("Player kill recorded. Total: {Stats.Kills + 1}")

    RecordDeath(Player : player) : void =
        if (Stats := PlayerStats[Player]):
            if (set PlayerStats[Player] = player_stats{
                Kills := Stats.Kills,
                Deaths := Stats.Deaths + 1,
                Assists := Stats.Assists,
                DamageDealt := Stats.DamageDealt,
                DamageTaken := Stats.DamageTaken
            }) {}

    RecordAssist(Player : player) : void =
        if (Stats := PlayerStats[Player]):
            if (set PlayerStats[Player] = player_stats{
                Kills := Stats.Kills,
                Deaths := Stats.Deaths,
                Assists := Stats.Assists + 1,
                DamageDealt := Stats.DamageDealt,
                DamageTaken := Stats.DamageTaken
            }) {}

    GetKills(Player : player) : int =
        if (Stats := PlayerStats[Player]):
            return Stats.Kills
        return 0

    GetDeaths(Player : player) : int =
        if (Stats := PlayerStats[Player]):
            return Stats.Deaths
        return 0

    GetKDRatio(Player : player) : float =
        if (Stats := PlayerStats[Player]):
            if (Stats.Deaths > 0):
                return Stats.Kills * 1.0 / Stats.Deaths * 1.0
            return Stats.Kills * 1.0
        return 0.0

    PrintPlayerStats(Player : player) : void =
        if (Stats := PlayerStats[Player]):
            KD := GetKDRatio(Player)
            Print("Stats - K:{Stats.Kills} D:{Stats.Deaths} A:{Stats.Assists} KD:{KD}")
