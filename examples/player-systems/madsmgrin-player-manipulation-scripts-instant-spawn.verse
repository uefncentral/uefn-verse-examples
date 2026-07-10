# Instant Player Respawn
# Automatically respawns eliminated players instantly at a specified location with minimal delay. The system listens for elimination events and immediately teleports the eliminated player back to a pred
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/madsmgrin-player-manipulation-scripts-instant-spawn?ref=github

using { /Fortnite.com/Characters }
using { /Fortnite.com/UI }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/Colors }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/Game }

#    _______ .______    __  .__   __.  _______ .______   .__   __.     ______ .______    _______     ___   .___________. _______     _____.
#   /  _____||   _  \  |  | |  \ |  | |   ____||   _  \  |  \ |  |    /      ||   _  \  |   ____|   /   \  |           ||   ____|   /     |
#  |  |  __  |  |_)  | |  | |   \|  | |  |__   |  |_)  | |   \|  |   |  ,----'|  |_)  | |  |__     /  ^  \ `---|  |----`|  |__     |   (--`
#  |  | |_ | |      /  |  | |  . `  | |   __|  |      /  |  . `  |   |  |     |      /  |   __|   /  /_\  \    |  |     |   __|     \   \  
#  |  |__| | |  |\  \-.|  | |  |\   | |  |____ |  |\  \-.|  |\   |   |  `----.|  |\  \-.|  |____ /  _____  \   |  |     |  |____  .--)   | 
#   \______| | _| `.__||__| |__| \__| |_______|| _| `.__||__| \__|    \______|| _| `.__||_______/__/     \__\  |__|     |_______| |_____/  
                                                                                                                                         
#Discord: @Grinern
#Twitter: @GrinernCreates
#Youtube: @GrinernCreates

instant_spawn := class(creative_device):

    respawnposition: vector3=vector3{X:=0.0,Y:=0.0,Z:=0.0} # Change this to the actual respawn point coordinates.

    @editable
    ElimManager: elimination_manager_device = elimination_manager_device{}

    OnBegin<override>()<suspends>:void=
        Print("@GrinernCreates Script Started")
        ElimManager.EliminatedEvent.Subscribe(OnEliminated)

    OnEliminated(Agent:agent):void=
        spawn:
            RespawnEvent(Agent)

    RespawnEvent(Agent:agent)<suspends>:void=
        Sleep(0.1)
        Agent.Respawn(respawnposition,rotation{})