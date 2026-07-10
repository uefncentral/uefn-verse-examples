# Boat Minigame
# Verse code for Boat Minigame - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/boat-minigame?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

boat_minigame := class(creative_device):

    @editable Boat1:vehicle_spawner_boat_device = vehicle_spawner_boat_device{}
    @editable Boat2:vehicle_spawner_boat_device = vehicle_spawner_boat_device{}

    var InProgress:logic = false

    OnBegin<override>()<suspends>:void=
        Boat1.DestroyedEvent.Subscribe(Boat1Destroyed)
        Boat2.DestroyedEvent.Subscribe(Boat2Destroyed)

        Boat1.AgentExitsVehicleEvent.Subscribe(Boat1Exited)
        Boat2.AgentExitsVehicleEvent.Subscribe(Boat2Exited)

    StartMinigame():void=
        set InProgress = true
        spawn{MinigameLoop()}

    MinigameLoop()<suspends>:void=
        Boat1.RespawnVehicle()
        Boat2.RespawnVehicle()

        Players:=GetPlayspace().GetPlayers()
        if(Player1:=Players[0], Player2:=Players[1]):
            Sleep(0.75)
            Boat1.AssignDriver(Player1)
            Boat2.AssignDriver(Player2)

    Boat1Destroyed(Tuple:tuple()):void=
        if(InProgress = true):
            Players:=GetPlayspace().GetPlayers()
            if(Player2:=Players[1]):
                if(TaggedObject := GetCreativeObjectsWithTag(GameManagerTag{})[0]):
                    if(GameManager := game_manager[TaggedObject]):
                        GameManager.EndGame(Player2)  
                        set InProgress = false
                        Boat1.DestroyVehicle()
                        Boat2.DestroyVehicle()
    
    Boat2Destroyed(Tuple:tuple()):void=
        if(InProgress = true):
            Players:=GetPlayspace().GetPlayers()
            if(Player1:=Players[0]):
                if(TaggedObject := GetCreativeObjectsWithTag(GameManagerTag{})[0]):
                    if(GameManager := game_manager[TaggedObject]):
                        GameManager.EndGame(Player1)
                        set InProgress = false
                        Boat1.DestroyVehicle()
                        Boat2.DestroyVehicle()
        
    Boat1Exited(Agent:agent):void=
        if(InProgress = true):
            Players:=GetPlayspace().GetPlayers()
            if(Player2:=Players[1]):
                if(TaggedObject := GetCreativeObjectsWithTag(GameManagerTag{})[0]):
                    if(GameManager := game_manager[TaggedObject]):
                        GameManager.EndGame(Player2)  
                        set InProgress = false
                        Boat1.DestroyVehicle()
                        Boat2.DestroyVehicle()

    Boat2Exited(Agent:agent):void=
        if(InProgress = true):
            Players:=GetPlayspace().GetPlayers()
            if(Player1:=Players[0]):
                if(TaggedObject := GetCreativeObjectsWithTag(GameManagerTag{})[0]):
                    if(GameManager := game_manager[TaggedObject]):
                        GameManager.EndGame(Player1)
                        set InProgress = false
                        Boat1.DestroyVehicle()
                        Boat2.DestroyVehicle()

    ResetMinigame():void=
        Boat1.DestroyVehicle()
        Boat2.DestroyVehicle()

        set InProgress = false