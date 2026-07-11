# Maze Minigame
# Verse code for Maze Minigame - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/maze-minigame?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Fortnite.com/Characters }

maze_minigame := class(creative_device):

    @editable Timer:timer_device = timer_device{}

    @editable Teleporter1:teleporter_device = teleporter_device{}
    @editable Teleporter2:teleporter_device = teleporter_device{}

    @editable Beacon1:beacon_device = beacon_device{}
    @editable Beacon2:beacon_device = beacon_device{}

    @editable Button1:button_device = button_device{}
    @editable Button2:button_device = button_device{}

    @editable FixedCamera:gameplay_camera_fixed_angle_device = gameplay_camera_fixed_angle_device{}
    @editable MazeClass:class_and_team_selector_device = class_and_team_selector_device{}

    @editable RoundTime:float = 150.0
    @editable RoundTimer:timer_device = timer_device{}

    var InProgress:logic = false

    RoundLoop()<suspends>:void=
        race:
            block:
                if(TaggedObject := GetCreativeObjectsWithTag(GameManagerTag{})[0], GameManager := game_manager[TaggedObject]):
                    GameManager.NewMinigameEvent.Await()
            block:
                RoundTimer.SetActiveDuration(RoundTime)
                RoundTimer.Start()
                Sleep(RoundTime)
                if(InProgress = true):
                    if(TaggedObject := GetCreativeObjectsWithTag(GameManagerTag{})[0]):
                        if(GameManager := game_manager[TaggedObject]):
                            GameManager.DrawGame()

    OnBegin<override>()<suspends>:void=
        Beacon1.Disable()
        Beacon2.Disable()

        Button1.InteractedWithEvent.Subscribe(OnButtonPressed)
        Button2.InteractedWithEvent.Subscribe(OnButtonPressed)

    StartMinigame():void=
        set InProgress = true

        Beacon1.Enable()
        Beacon2.Enable()

        Players:=GetPlayspace().GetPlayers()
        for(Player:Players):
            MazeClass.ChangeClass(Player)
            if(TaggedObject := GetCreativeObjectsWithTag(UtilsTag{})[0], UtilsSystem := utils_system[TaggedObject]):
                UtilsSystem.ClearPlayerItems(Player)
                if(FC:=Player.GetFortCharacter[]):
                    FC.PutInStasis(stasis_args{AllowTurning:=false, AllowFalling:=false, AllowEmotes:=false})

        if(Player1:=Players[0]):
            Teleporter1.Teleport(Player1)

        if(Player2:=Players[1]):
            Teleporter2.Teleport(Player2)

        spawn{CameraLoop()}
        spawn{RoundLoop()}
        
    CameraLoop()<suspends>:void=
        race:
            block:
                if(TaggedObject := GetCreativeObjectsWithTag(GameManagerTag{})[0], GameManager := game_manager[TaggedObject]):
                    GameManager.NewMinigameEvent.Await()
            block:
                Timer.Start()
                FixedCamera.AddToAll()
                Sleep(5.0)
                FixedCamera.RemoveFromAll()
                Beacon1.Disable()
                Beacon2.Disable()

                Players:=GetPlayspace().GetPlayers()
                for(Player:Players):
                    if(FC:=Player.GetFortCharacter[]):
                        FC.ReleaseFromStasis()
        
    OnButtonPressed(Agent:agent):void=
        if(TaggedObject := GetCreativeObjectsWithTag(GameManagerTag{})[0]):
            if(GameManager := game_manager[TaggedObject]):
                GameManager.EndGame(Agent)

    ResetMinigame():void=
        FixedCamera.RemoveFromAll()
        Beacon1.Disable()
        Beacon2.Disable()
        RoundTimer.Reset()
        set InProgress = false