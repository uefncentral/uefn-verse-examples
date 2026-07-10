# FNCS Points System
# A competitive scoring system that tracks player eliminations and awards points per kill, with a configurable goal target (default 100 points). Players earn points for eliminations and the system manag
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/fncss?ref=github

using { /Fortnite.com/UI }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Verse.org/Simulation }
using { /Verse.org/Colors }
using { /Verse.org/Assets }
using { /Verse.org/Simulation/Tags }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

StringToMessagee<localizes>(S : string):message = "{S}"

TextForUI<localizes> : message = ""

FNCSScript := class(creative_device):

    @editable GoalPoints : int = 100

    @editable TriggerDevice : trigger_device = trigger_device{}

    @editable WinningPlayerTriggerDevice : trigger_device = trigger_device{}

    @editable PlayerSpawners : []player_spawner_device = array{}

    @editable ElimManager : elimination_manager_device = elimination_manager_device{}

    PointsPerKill : int = 5

    var Custom_Player_Map: [player]Custom_Player = map{}

    OnBegin<override>()<suspends>:void=
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerLeft)
        ElimManager.EliminationEvent.Subscribe(OnElim)
        InitSpawners()
        InitPlayers()

    InitSpawners():void=
        for(Spawner:PlayerSpawners):
            Spawner.SpawnedEvent.Subscribe(OnSpawn)

    OnSpawn(PlayerJoining:agent):void=
        if(Player := player[PlayerJoining]):
            if(PlayerExists := Custom_Player_Map[Player]):
            else:     
                CustomPlayer := Custom_Player{Player := Player}
                option. set  Custom_Player_Map[Player] = CustomPlayer
                CustomPlayer.AddUiToPlayer()

    InitPlayers():void=
        for(Player: GetPlayspace().GetPlayers()):
            OnSpawn(Player)   

    OnElim(MaybeAgent : ?agent):void=
        if(Agent := MaybeAgent?):
            if(Player := player[Agent]):
                if(CustomPlayer := Custom_Player_Map[Player]):
                    CustomPlayer.UpdateUIInt(PointsPerKill)
                    if(CustomPlayer.PlayerPoints = PointsPerKill):
                        Image0 := CustomPlayer.Image_0
                        Image0.SetImage(FNCSPoints.FNCSPointsGraphic)
                    if(CustomPlayer.PlayerPoints >= GoalPoints):
                        TriggerDevice.Trigger()
                        WinningPlayerTriggerDevice.Trigger(Agent)
                    spawn:
                        CustomPlayer.AchivmentAnimation(Agent)
                UpdatePoints(Agent)

    UpdatePoints(Agent : agent):void={}

    OnPlayerLeft(PlayerLeaving : agent):void=
        var NewMap : [player]Custom_Player = map{}
        if(Player := player[PlayerLeaving]):
        for(Key -> Value : Custom_Player_Map, Key <> PlayerLeaving):
            set NewMap = ConcatenateMaps(NewMap, map{Key => Value})
        set Custom_Player_Map = NewMap

Custom_Player := class<unique>:

    
    var MainCanvas : canvas = canvas{}

    var XValue : float = 1.2
    var End : logic = false

    var Image_0 : texture_block = texture_block:
        DefaultImage := FNCSPoints.FNCSZeroPoints
        DefaultTint := color{R := 1.0, G := 1.0, B := 1.0}
        DefaultDesiredSize := vector2{X := 70.0,Y := 70.0}
    
    var UEFN_TextBlock_C_0 : text_block = text_block:
        DefaultText := TextForUI
        DefaultTextColor := color{R := 1.0, G := 0.8, B := 0.0}
        DefaultTextOpacity := 1.0
        DefaultShadowOffset := option{vector2{X := 0.0,Y := 0.0}}
        DefaultShadowColor := color{R := 1.0, G := 1.0, B := 1.0}
        DefaultShadowOpacity := 1.0
    
    var Image_1 : texture_block = texture_block:
        DefaultImage := FNCSPoints.EliminationPopUpFNCS
        DefaultTint := color{R := 1.0, G := 1.0, B := 1.0}
        DefaultDesiredSize := vector2{X := 200.0,Y := 80.0}

    Player : agent

    S2M0<localizes>(value:string)<computes> : message = "{value}"

    var PlayerPoints : int = 0
    
    UpdateUIInt(Value:int):void=
        set PlayerPoints += Value
        UEFN_TextBlock_C_0.SetText(S2M("{PlayerPoints}"))

    AddUiToPlayer():void=
        if(PlayerUI := GetPlayerUI[player[Player]]):
            Canvas := CreateUI() 
            PlayerUI.AddWidget(Canvas)

    CreateUI():canvas=
        Overlay := overlay:
            Slots := array:
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Left
                    VerticalAlignment := vertical_alignment.Top
                    Padding := margin:
                        Top := 0.0
                        Right := 0.0
                        Bottom := 0.0
                        Left := 0.0
                    Widget := Image_0
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin:
                        Top := 0.0
                        Right := 0.0
                        Bottom := 0.0
                        Left := 0.0
                    Widget := UEFN_TextBlock_C_0
        var NewCanvas : canvas = canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors:
                        Minimum := vector2{X := 0.0,Y := 0.5}
                        Maximum := vector2{X := 0.0,Y := 0.5}
                    Offsets := margin:
                        Top := 0.0
                        Right := 0.0
                        Bottom := 0.0
                        Left := 0.0
                    SizeToContent := true
                    Alignment := vector2{X := 1.2,Y := 0.512}
                    ZOrder := 0
                    Widget := Image_1
                canvas_slot:
                    Anchors := anchors:
                        Minimum := vector2{X := 0.4,Y := 1.0}
                        Maximum := vector2{X := 0.4,Y := 1.0}
                    Offsets := margin:
                        Top := 0.0
                        Right := 0.0
                        Bottom := 0.0
                        Left := 0.0
                    SizeToContent := true
                    Alignment := vector2{X := 0.5,Y := 2.2}
                    ZOrder := 0
                    Widget := Overlay
        set MainCanvas = NewCanvas
        return NewCanvas

    AchivmentAnimation(Agent : agent)<suspends>:void=
        Print("AnimationStart")
        if(XValue = 1.2):
            for(I := 0..14):
                Sleep(0.0)
                set XValue -= 0.08
                UpdateUI(Agent)
            Print("FirsLoopDone")
            Sleep(1.0)
            for(I := 0..14):
                Sleep(0.0)
                set XValue += 0.08
                UpdateUI(Agent)
            Print("SecondLoopDone")
        else:
            Sleep(1.0)
            AchivmentAnimation(Agent)
        
    UpdateUI(Agent :agent):void=
        Image1 := Image_1
        Image1.SetVisibility(widget_visibility.Hidden)
        MainCanvas.RemoveWidget(Image1)
        Image1.SetVisibility(widget_visibility.Visible)
        MainCanvas.AddWidget(
            canvas_slot:
                Anchors := anchors:
                    Minimum := vector2{X := 0.0,Y := 0.5}
                    Maximum := vector2{X := 0.0,Y := 0.5}
                Offsets := margin:
                    Top := 0.0
                    Right := 0.0
                    Bottom := 0.0
                    Left := 0.0
                SizeToContent := true
                Alignment := vector2{X := XValue,Y := 0.512}
                ZOrder := 0
                Widget := Image1
        )