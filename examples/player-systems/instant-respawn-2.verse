# Instant Respawn 2
# Verse code for Instant Respawn 2 - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/instant-respawn-2?ref=github

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
    @editable
    TeleporterTeam3 : teleporter_device = teleporter_device{}
    @editable
    TeleporterTeam4 : teleporter_device = teleporter_device{}
    @editable
    TeleporterTeam5 : teleporter_device = teleporter_device{}
    @editable
    TeleporterTeam6 : teleporter_device = teleporter_device{}
    @editable
    TeleporterTeam7 : teleporter_device = teleporter_device{}
    @editable
    TeleporterTeam8 : teleporter_device = teleporter_device{}
    @editable
    TeleporterTeam9 : teleporter_device = teleporter_device{}
    @editable
    TeleporterTeam10 : teleporter_device = teleporter_device{}
    @editable
    TeleporterTeam11 : teleporter_device = teleporter_device{}
    @editable
    TeleporterTeam12 : teleporter_device = teleporter_device{}
    @editable
    TeleporterTeam13 : teleporter_device = teleporter_device{}
    @editable
    TeleporterTeam14 : teleporter_device = teleporter_device{}

    NowRespawn(Agent: agent)<suspends>:void=
        Sleep(0.1)
        Agent.Respawn(respawnposition, rotation{})
        TeleporterTeam1 .Teleport(Agent)
        TeleporterTeam2 .Teleport(Agent)
        TeleporterTeam3 .Teleport(Agent)
        TeleporterTeam4 .Teleport(Agent)
        TeleporterTeam5 .Teleport(Agent)
        TeleporterTeam6 .Teleport(Agent)
        TeleporterTeam7 .Teleport(Agent)
        TeleporterTeam8 .Teleport(Agent)
        TeleporterTeam9 .Teleport(Agent)
        TeleporterTeam10 .Teleport(Agent)
        TeleporterTeam11 .Teleport(Agent)
        TeleporterTeam12 .Teleport(Agent)
        TeleporterTeam13 .Teleport(Agent)
        TeleporterTeam14 .Teleport(Agent)
    SelfEliminated(Agent:agent):void=
        spawn{NowRespawn(Agent)}
 
    OnBegin<override>()<suspends>:void=
        ElimMachine.EliminatedEvent.Subscribe(SelfEliminated)
