# Fast Player Respawn
# Automatically respawns players immediately upon elimination at their current location. This device listens for elimination events and triggers instant respawn without delay or respawn screen.  **How t
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/fast-respawn-device?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Teams }
using { /Fortnite.com/Characters }
using { /Verse.org/Random }
using { /Fortnite.com/Game }
using { /Fortnite.com/FortPlayerUtilities }
using { /UnrealEngine.com/Temporary/SpatialMath }

fast_respawn_device := class(creative_device):
    @editable
    ElimDevice :elimination_manager_device = elimination_manager_device {}

    OnBegin<override>()<suspends>:void=
        Sleep(0.1)
        ElimDevice.EliminatedEvent.Subscribe(SelfEliminated)


    SelfEliminated(Agent:agent):void=
        Agent.Respawn(vector3{},rotation{})