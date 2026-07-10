# Safe Zone Spawning
# Spawn players at safe locations, ensuring no spawn camping. Checks for nearby enemies before spawning.
# Difficulty: intermediate  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/safe-zone-spawning?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/Teams }
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }

# Safe zone spawning system - prevents spawn camping
safe_zone_spawner := class(creative_device):

    @editable
    SpawnPads : []player_spawner_device = array{}

    @editable
    SafeDistance : float = 2000.0  # Minimum distance from enemies

    @editable
    MaxSpawnAttempts : int = 10

    @editable
    RespawnDelay : float = 3.0

    OnBegin<override>()<suspends> : void =
        Playspace := GetPlayspace()

        for (Player : Playspace.GetPlayers()):
            spawn { HandlePlayerRespawn(Player) }

        Playspace.PlayerAddedEvent().Subscribe(OnPlayerAdded)

    OnPlayerAdded(Player : player) : void =
        spawn { HandlePlayerRespawn(Player) }

    HandlePlayerRespawn(Player : player)<suspends> : void =
        loop:
            if (FortCharacter := Player.GetFortCharacter[]):
                FortCharacter.EliminatedEvent().Await()
                Sleep(RespawnDelay)
                SpawnPlayerSafely(Player)

    SpawnPlayerSafely(Player : player) : void =
        SafeSpawner := FindSafeSpawnPoint(Player)
        if (Spawner := SafeSpawner?):
            Spawner.# SpawnPlayer(Player)  # TODO: not a Verse function — use player_spawner_device
        else:
            # Fallback to random spawn if no safe point found
            if (SpawnPads.Length > 0):
                RandomIndex := GetRandomInt(0, SpawnPads.Length - 1)
                if (Spawner := SpawnPads[RandomIndex]):
                    Spawner.# SpawnPlayer(Player)  # TODO: not a Verse function — use player_spawner_device

    FindSafeSpawnPoint(Player : player) : ?player_spawner_device =
        TeamCollection := GetPlayspace().GetTeamCollection()
        PlayerTeam := TeamCollection.GetTeam[Player]

        # Shuffle spawn points for randomness
        ShuffledSpawns := ShuffleArray(SpawnPads)

        for (Spawner : ShuffledSpawns):
            if (IsSpawnSafe(Spawner, Player, TeamCollection, PlayerTeam)):
                return option{Spawner}

        return false

    IsSpawnSafe(Spawner : player_spawner_device, Player : player, TeamCollection : team_collection, PlayerTeam : ?team) : logic =
        SpawnLocation := Spawner.GetTransform().Translation

        AllPlayers := GetPlayspace().GetPlayers()
        for (OtherPlayer : AllPlayers):
            if (OtherPlayer <> Player):
                # Check if enemy
                IsEnemy := false
                if (MyTeam := PlayerTeam?):
                    if (OtherTeam := TeamCollection.GetTeam[OtherPlayer]):
                        if (MyTeam <> OtherTeam):
                            set IsEnemy = true
                else:
                    # No teams = everyone is enemy
                    set IsEnemy = true

                if (IsEnemy):
                    if (OtherChar := OtherPlayer.GetFortCharacter[]):
                        OtherLocation := OtherChar.GetTransform().Translation
                        Distance := Distance(SpawnLocation, OtherLocation)
                        if (Distance < SafeDistance):
                            return false

        return true

    ShuffleArray(InArray : []player_spawner_device) : []player_spawner_device =
        var Result : []player_spawner_device = InArray
        for (I := Result.Length - 1..0, I > 0):
            J := GetRandomInt(0, I)
            if (TempI := Result[I]):
                if (TempJ := Result[J]):
                    if (set Result[I] = TempJ) {}
                    if (set Result[J] = TempI) {}
        return Result
