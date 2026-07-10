# Player Points Tracker
# A comprehensive points tracking system that manages player scores with persistent storage of current and highest values. It includes a custom queue data structure for managing player data and tracks e
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/arena-points-system?ref=github

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


queue<public>(t:type) := class:

    Elements<internal>:[]t = array{}

    Enqueue<public>(NewElement:t):queue(t)=

        queue(t){Elements := Elements + array{NewElement}}

    Dequeue<public>()<decides><transacts>:tuple(queue(t),t)=

        FirstElement := Front[]

        (queue(t){Elements := Elements.RemoveElement[0]}, FirstElement)

    Size<public>()<transacts>:int=

        Elements.Length

    IsEmpty<public>()<decides><transacts>:void=

        Size() = 0

    Front<public>()<decides><transacts>:t=

        Elements[0]

    Rear<public>()<decides><transacts>:t=

        Elements[Elements.Length - 1]

CreateQueue<public><constructor>(InitialElements:[]t where t:type) := queue(t):

    Elements := InitialElements


TextForUI2<localizes> : message = "--"


player_stat := class<final><persistable>:

    CurrentValue:int = 0

    HighestValue:int = 0


    SetHighestValue(NewValue:int)<transacts>:int=
        if (NewValue > HighestValue):
            NewValue
        else:
            HighestValue

player_stats_table := class<final><persistable>:

    Version:int = 0

    Score:player_stat = player_stat{}

MakeUpdatedPlayerStat<constructor>(OldStats:player_stat, NewValue:int)<transacts> := player_stat:
    CurrentValue := NewValue
    HighestValue := OldStats.SetHighestValue(NewValue)

MakePlayerStatsTable<constructor>(OldTable:player_stats_table)<transacts> := player_stats_table:
    Version := OldTable.Version
    Score := OldTable.Score

var PlayerStatsMap:weak_map(player, player_stats_table) = map{}

stat_type := class<computes><abstract>:
    DebugString()<transacts>:string


StatType := module:

    score_stat<public> := class<computes>(stat_type):
        DebugString<override>()<transacts>:string = "Score"

    Score<public>:score_stat = score_stat{}

player_stats_manager := class():

    GetPlayerStats(Agent:agent)<decides><transacts>:player_stats_table=
        var PlayerStats:player_stats_table = player_stats_table{}
        if:
            Player := player[Agent]
            PlayerStatsTable := PlayerStatsMap[Player]
            set PlayerStats = MakePlayerStatsTable(PlayerStatsTable)
        PlayerStats

    InitializeAllPlayers(Players:[]player):void =
        for (Player : Players):
            InitializePlayer(Player)

    InitializePlayer(Player:player):void=
        Print("Creating a map for a player")
        if:
            not PlayerStatsMap[Player]
            set PlayerStatsMap[Player] = player_stats_table{}

    RecordPlayerStat(Agent:agent, Stat:stat_type, ?Score:int = 0):void=
        if:
            Player := player[Agent]
            PlayerStatsTable := PlayerStatsMap[Player]
            if(Stat.DebugString() = StatType.Score.DebugString()):
                ScoreStat := PlayerStatsTable.Score

                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Score := MakeUpdatedPlayerStat(ScoreStat, Score)


PointsDevice := class(creative_device):

    @editable PlayerSpawners : []player_spawner_device = array{}

    @editable ElimManager : elimination_manager_device = elimination_manager_device{}

    PlayerStatsManager:player_stats_manager = player_stats_manager{}

    var Custom_Player_Map: [player]Custom_Player2 = map{}


    OnBegin<override>()<suspends>:void=
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerLeft)
        ElimManager.EliminationEvent.Subscribe(OnElim)
        InitSpawners()
        InitPlayers()
        AllPlayers := GetPlayspace().GetPlayers()
        PlayerStatsManager.InitializeAllPlayers(AllPlayers)

    InitSpawners():void=
        for(Spawner:PlayerSpawners):
            Spawner.SpawnedEvent.Subscribe(OnSpawn)

    OnSpawn(PlayerJoining:agent):void=
        if(Player := player[PlayerJoining]):
            if(PlayerExists := Custom_Player_Map[Player]):
            else:     
                CustomPlayer := Custom_Player2{Player := Player}
                option. set  Custom_Player_Map[Player] = CustomPlayer
                CustomPlayer.AddUiToPlayer()
                PlayerStatsManager.InitializePlayer(Player)
                if:
                    CurrentPlayerStats := PlayerStatsManager.GetPlayerStats[PlayerJoining]
                    CurrentScore := CurrentPlayerStats.Score.CurrentValue
                then:
                    CustomPlayer.UpdateUIInt(CurrentScore)


    InitPlayers():void=
        for(Player: GetPlayspace().GetPlayers()):
            OnSpawn(Player)   
        
    AddScore(Agent:agent):void=
        Print("Adding score")
        if:
            CurrentPlayerStats := PlayerStatsManager.GetPlayerStats[Agent]
            CurrentScore := CurrentPlayerStats.Score.CurrentValue
        then:
            PlayerStatsManager.RecordPlayerStat(Agent, StatType.Score, ?Score := CurrentScore + 15)
            

    OnElim(MaybeAgent : ?agent):void=
        if(Agent := MaybeAgent?):
            if(Player := player[Agent]):
                if(CustomPlayer := Custom_Player_Map[Player]):
                    AddScore(Agent)
                    if:
                        CurrentPlayerStats := PlayerStatsManager.GetPlayerStats[Agent]
                        CurrentScore := CurrentPlayerStats.Score.CurrentValue
                    then:
                        CustomPlayer.UpdateUIInt(CurrentScore)
                        spawn:
                            CustomPlayer.AchivmentAnimation(Agent)
                        




    OnPlayerLeft(PlayerLeaving : agent):void=
        var NewMap : [player]Custom_Player2 = map{}
        if(Player := player[PlayerLeaving]):
        for(Key -> Value : Custom_Player_Map, Key <> PlayerLeaving):
            set NewMap = ConcatenateMaps(NewMap, map{Key => Value})
        set Custom_Player_Map = NewMap     
        Print("Player Removed")


Custom_Player2 := class<unique>:

    MyFloat : []float = array{0.08,0.16,0.24,0.32,0.40,0.48,0.56,0.64,0.72,0.80,0.88,0.96,1.04,1.12,1.20}

    var HypeNumber : int =0
    
    var MainCanvas : canvas = canvas{}

    var XValue : float = 1.2
    var End : logic = false

    var Image_0 : texture_block = texture_block:
        DefaultImage := ArenaAssets.EmptyArenaPoints
        DefaultTint := color{R := 1.0, G := 1.0, B := 1.0}
        DefaultDesiredSize := vector2{X := 125.0,Y := 60.0}
    
    var UEFN_TextBlock_C_0 : text_block = text_block:
        DefaultText := TextForUI2
        DefaultTextColor := color{R := 1.0, G := 1.0, B := 1.0}
        DefaultTextOpacity := 1.0
        DefaultShadowOffset := option{vector2{X := 0.0,Y := 0.0}}
        DefaultShadowColor := color{R := 1.0, G := 1.0, B := 1.0}
        DefaultShadowOpacity := 1.0
    
    var Image_1 : texture_block = texture_block:
        DefaultImage := ArenaAssets.EliminationPopUpArenaWith1kill
        DefaultTint := color{R := 1.0, G := 1.0, B := 1.0}
        DefaultDesiredSize := vector2{X := 200.0,Y := 80.0}


    Player : agent

    S2M<localizes>(value:string)<computes> : message = "{value}"


    var Hype : int = 0
    

    HypeCalculation(TestHype : int):void=
        if(TestHype < 100, TestHype > 0):
            TenthHype := 0
            set HypeNumber = TenthHype
        else if( 200 > TestHype >= 100):
            TenthHype := 1
            set HypeNumber = TenthHype
        else if( 300 > TestHype >= 200):
            TenthHype := 2
            set HypeNumber = TenthHype
        else if(400 > TestHype >= 300):
            TenthHype := 3
            set HypeNumber = TenthHype
        else if(500 > TestHype >= 400):
            TenthHype := 4
            set HypeNumber = TenthHype
        else if(600 > TestHype >= 500):
            TenthHype := 5
            set HypeNumber = TenthHype
        else if(700 > TestHype >= 600):
            TenthHype := 6
            set HypeNumber = TenthHype
        else if(800 > TestHype >= 700):
            TenthHype := 7
            set HypeNumber = TenthHype
        else if(900 > TestHype >= 800):
            TenthHype := 8
            set HypeNumber = TenthHype
        else if(1000 > TestHype >= 900):
            TenthHype := 9
            set HypeNumber = TenthHype


    UpdateUIInt(Value:int):void=
        set Hype = Value
        if(Hype = 0):
            UEFN_TextBlock_C_0.SetText(S2M("--"))
        else if(Hype > 999):
            if(RoundedHype := Round[1.0 * Hype / 1000.0]):
                PrintValue(RoundedHype, 0)
                if(Hype <= 9999):
                    if(TestHype := (Round[1.0 * Hype / 10.0] - RoundedHype * 100)*10):
                        HypeCalculation(TestHype)
                        PrintValue(RoundedHype, HypeNumber)
                else if(Hype > 9999, Hype < 100000):
                    if(TestHype := Round[1.0 * Hype / 100.0]):
                        HypeCalculation(TestHype)
                        PrintValue(RoundedHype, HypeNumber)
        else:
            UEFN_TextBlock_C_0.SetText(S2M("{Hype}"))



    PrintValue(RoundedHypeInt : int , TenthHypeInt : int ):void=
        UEFN_TextBlock_C_0.SetText(S2M("{RoundedHypeInt}.{TenthHypeInt}K"))

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
                        Left := 15.0
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
                    Alignment := vector2{X := 0.5,Y := 2.5}
                    ZOrder := 0
                    Widget := Overlay
        set MainCanvas = NewCanvas
        return NewCanvas

    AchivmentAnimation(Agent : agent)<suspends>:void=
        MyAnimQ := CreateQueue()
        NewQ := MyAnimQ.Enqueue("RunAnim")
        Print("AnimationStart")
        MySize := NewQ.Size()
        if(MySize = 1):
            for(I := 0..14):
                Sleep(0.0)
                set XValue -= 0.08
                UpdateUI(Agent)
            Sleep(1.0)
            for(I := 0..14):
                Sleep(0.0)
                set XValue += 0.08
                UpdateUI(Agent)
            if(NewQ.Dequeue[]):
                Print("Dequeue")


        
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