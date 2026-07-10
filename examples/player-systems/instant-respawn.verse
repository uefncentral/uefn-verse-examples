# Instant Respawn
# Verse code for Instant Respawn - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/instant-respawn?ref=github

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
    TeleporterTeam1 : teleporter_device = teleporter_device{}
    @editable
    TeleporterTeam2 : teleporter_device = teleporter_device{}
 
    NowRespawn(Agent: agent)<suspends>:void=
        Sleep(0.1)
        Agent.Respawn(respawnposition, rotation{})
        TeleporterTeam1 .Teleport(Agent)
        TeleporterTeam2 .Teleport(Agent)
 
    SelfEliminated(Agent:agent):void=
        spawn{NowRespawn(Agent)}
 
    OnBegin<override>()<suspends>:void=
        ElimMachine.EliminatedEvent.Subscribe(SelfEliminated)
