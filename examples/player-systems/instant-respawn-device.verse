# Random Respawn System
# This device automatically respawns eliminated players at random spawn locations throughout the map. When a player is eliminated, the system selects a random player spawner from the configured array an
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/instant-respawn-device?ref=github

using { /Fortnite.com/FortPlayerUtilities }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/Devices }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }
 
RespawnDevice := class(creative_device):
 
    @editable
    var Spawns : []player_spawner_device = array{}
 
    OnBegin<override>()<suspends>:void=
        for ( Player : GetPlayspace().GetPlayers() ):
            if ( Character := Player.GetFortCharacter[] ):
                Character.EliminatedEvent().Subscribe(OnEliminated)
 
 
        GetPlayspace().PlayerAddedEvent().Subscribe(OnUserAdded)
 
    OnUserAdded(User: player): void =
        if ( Player := agent[User] ):
            if ( Character := Player.GetFortCharacter[] ):
                Character.EliminatedEvent().Subscribe(OnEliminated)
 
    OnEliminated(Result: elimination_result): void =
        if ( Eliminated := Result.EliminatedCharacter, Player := Eliminated.GetAgent[] ):
            Random := GetRandomInt(1,Spawns.Length)
            if ( Spawn := Spawns[Random-1] ): 
                Transform := Spawn.GetTransform()
                Player.Respawn(Transform.Translation, Transform.Rotation)