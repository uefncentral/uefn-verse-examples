# Random Teleporter System
# Creates a teleportation system that randomly sends players to one of multiple teleporter destinations when they enter a trigger zone. Uses a mutator zone as the trigger and an array of teleporter devi
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/madsmgrin-object-manipulation-scripts-random-teleporter?ref=github

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

random_teleporter := class(creative_device):

    @editable
    Teleporters: []teleporter_device = array{}

    #Could be changed to pretty much anything tbh. As long as there is a listenable Agent.
    @editable
    EnterRandomTeleporter: mutator_zone_device = mutator_zone_device{}

    OnBegin<override>()<suspends>:void=
        Print("@GrinernCreates Script Started")
        EnterRandomTeleporter.AgentEntersEvent.Subscribe(EnterEvent)

    EnterEvent(Agent:agent):void=
        var RandomTeleporter:int = GetRandomInt(1, 21) # CHANGE THIS TO THE NUMBER OF TELEPORTERS
        if(SelectedTeleporter := Teleporters[RandomTeleporter]):
            SelectedTeleporter.Teleport(Agent)