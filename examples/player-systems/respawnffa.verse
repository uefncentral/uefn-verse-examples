# Instant Respawn FFA
# Creates a free-for-all game mode where players instantly respawn at random spawn locations when eliminated. The system uses an elimination manager to detect player deaths and automatically teleports t
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/respawnffa?ref=github

using { /Fortnite.com/FortPlayerUtilities }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/Devices }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }
 
IRespawnFFA := class(creative_device):
 
    @editable var SpawnsPad : []player_spawner_device = array{}
    @editable ElimManager : elimination_manager_device = elimination_manager_device{}
 
    SelfEliminated(Agent:agent):void=

            PadRandom := GetRandomInt(1,SpawnsPad.Length)
            if ( RandomInt := SpawnsPad[PadRandom-1] ): 
                Transform := RandomInt.GetTransform()
                Agent.Respawn(Transform.Translation, Transform.Rotation)

    OnBegin<override>()<suspends>:void=
      ElimManager.EliminatedEvent.Subscribe(SelfEliminated)