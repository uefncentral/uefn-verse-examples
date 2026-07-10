# Plane Minigame
# Verse code for Plane Minigame - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/plane-minigame?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

plane_minigame := class(creative_device):

    @editable Plane1:vehicle_spawner_biplane_device = vehicle_spawner_biplane_device{}
    @editable Plane2:vehicle_spawner_biplane_device = vehicle_spawner_biplane_device{}

    @editable PlaneClass:class_and_team_selector_device = class_and_team_selector_device{}

    var InProgress:logic = false

    OnBegin<override>()<suspends>:void=
        Plane1.DestroyedEvent.Subscribe(Plane1Destroyed)
        Plane2.DestroyedEvent.Subscribe(Plane2Destroyed)

        Plane1.AgentExitsVehicleEvent.Subscribe(Plane1Exited)
        Plane2.AgentExitsVehicleEvent.Subscribe(Plane2Exited)

    StartMinigame():void=
        set InProgress = true
        spawn{MinigameLoop()}

    MinigameLoop()<suspends>:void=
        Plane1.RespawnVehicle()
        Plane2.RespawnVehicle()

        Players:=GetPlayspace().GetPlayers()
        if(Player1:=Players[0], Player2:=Players[1]):
            PlaneClass.ChangeClass(Player1)
            PlaneClass.ChangeClass(Player2)
            Sleep(0.75)
            Plane1.AssignDriver(Player1)
            Plane2.AssignDriver(Player2)

    Plane1Destroyed(Tuple:tuple()):void=
        if(InProgress = true):
            Players:=GetPlayspace().GetPlayers()
            if(Player2:=Players[1]):
                if(TaggedObject := GetCreativeObjectsWithTag(GameManagerTag{})[0]):
                    if(GameManager := game_manager[TaggedObject]):
                        GameManager.EndGame(Player2)  
                        set InProgress = false
                        Plane2.DestroyVehicle()
    
    Plane2Destroyed(Tuple:tuple()):void=
        if(InProgress = true):
            Players:=GetPlayspace().GetPlayers()
            if(Player1:=Players[0]):
                if(TaggedObject := GetCreativeObjectsWithTag(GameManagerTag{})[0]):
                    if(GameManager := game_manager[TaggedObject]):
                        GameManager.EndGame(Player1)
                        set InProgress = false
                        Plane1.DestroyVehicle()
        
    Plane1Exited(Agent:agent):void=
        if(InProgress = true):
            Players:=GetPlayspace().GetPlayers()
            if(Player1:=Players[0]):
                Plane1.AssignDriver(Player1)

    Plane2Exited(Agent:agent):void=
        if(InProgress = true):
            Players:=GetPlayspace().GetPlayers()
            if(Player2:=Players[1]):
                Plane2.AssignDriver(Player2)

    ResetMinigame():void=
        set InProgress = false