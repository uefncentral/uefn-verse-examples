# Quick Player Respawn
# Automatically respawns eliminated players at a fixed location instantly without delay. When a player is eliminated, they immediately respawn at the predefined coordinates instead of going through the 
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/respawn?ref=github

using { /Fortnite.com/Devices}
using { /Verse.org/Simulation}
using { /UnrealEngine.com/Temporary/Diagnostics}
using { /Fortnite.com/Teams}
using { /Verse.org/Simulation}
using { /Fortnite.com/Characters}
using { /Verse.org/Random}
using { /Fortnite.com/Game}
using { /Fortnite.com/FortPlayerUtilities}
using { /UnrealEngine.com/Temporary/SpatialMath}

quick_respawn := class(creative_device):
    respawnposition: vector3=vector3{X:= -831.887, Y:= 1896.257, Z:= -0.0}

    @editable
    ElimMachine : elimination_manager_device = elimination_manager_device{}

    OnBegin<override>()<suspends>:void=

        Print ("Device Started")
        Sleep(0.1)
        ElimMachine.EliminatedEvent.Subscribe(SelfEliminated)

    SelfEliminated(Agent:agent):void=
        Print("Eliminated Signal Reciveved")
        Agent.Respawn(respawnposition,rotation{})