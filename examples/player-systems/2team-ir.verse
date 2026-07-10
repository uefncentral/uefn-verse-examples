# 2team Ir
# Verse code for 2team Ir - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/2team-ir?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using {/Fortnite.com/Teams}
using {/Verse.org/Simulation}
using {/Fortnite.com/Characters}
using {/Verse.org/Random}
using {/Fortnite.com/Game}
using {/Fortnite.com/FortPlayerUtilities}
using {/UnrealEngine.com/Temporary/SpatialMath}

InstantRespawn := class(creative_device):

    respawnposition: vector3=vector3{X:= 250.00, Y:= 0.01, Z:= 161.9}

    @editable
    ElimMachine : elimination_manager_device = elimination_manager_device{}
    @editable
    ElimMachine2 : elimination_manager_device = elimination_manager_device{}
    @editable
    TeleporterTeam1 : teleporter_device = teleporter_device{}
    @editable
    TeleporterTeam2 : teleporter_device = teleporter_device{}

    NowRespawn(Agent: agent)<suspends>:void=
        Sleep(0.1)
        Agent.Respawn(respawnposition, rotation{})
        TeleporterTeam1 .Teleport(Agent)
       

    NowRespawn2(Agent: agent)<suspends>:void=
            Sleep(0.1)
            Agent.Respawn(respawnposition, rotation{})
            TeleporterTeam2 .Teleport(Agent)

    SelfEliminated(Agent:agent):void=
        spawn{NowRespawn(Agent)}

    OnBegin<override>()<suspends>:void=
        ElimMachine.EliminatedEvent.Subscribe(SelfEliminated)
        ElimMachine2.EliminatedEvent.Subscribe(SelfEliminated)