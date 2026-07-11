# Player Progress Bar System
# A customizable ranking and progress tracking system that displays player scores with visual progress bars and effects. The system manages multiple rank tiers with configurable colors, score thresholds
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/level-manager?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/Colors }
using { /Verse.org/Colors/NamedColors }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation/Tags }
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /Verse.org/Assets }
using { player_class }
using { helpers.MyUtils }
using {helpers.Array.Sortting}

style := enum{Style1, Style2}
hovertype := enum{Head, Back}
counttype := enum{Score, Percentage}
displaytype := enum{Pill, Box}

rank := class<concrete><unique>:
    @editable Name:string = "Name"
    @editable ScoreMax:int = 0
    @editable BarColor:color = color{}
    @editable HeadHoverVFX:visual_effect_powerup_device = visual_effect_powerup_device{}

settings := class<concrete><unique>:
    @editable var ProgressBar:progressbar_settings = progressbar_settings{}

progressbar_settings := class<concrete><unique>:
    @editable var Style:style = style.Style1
    @editable var BarColor:color = color{}
    @editable var CountType:counttype = counttype.Score
    @editable var DisplayType:displaytype = displaytype.Pill
    @editable var TotalScore:logic = true
    @editable var SmoothUpdate:logic = true

level_manager := class(creative_device):

    var PlayerManager<public>:player_manager = player_manager{}
    var StatsManager : stats_manager = stats_manager{}

    var CanvasPerPlayer:[agent]?canvas = map{}
    var ProgressBarPerPlayer:[agent]?progress_bar = map{}
    var RankPerPlayer:[agent]?widget = map{}
    var RankTextPerPlayer:[agent]?text_block = map{}
    var RankProgressPerPlayer:[agent]?text_block = map{}

    @editable var Settings:settings = settings{}
    @editable var Ranks:[]rank = array{}

    var XPBonus : int = 1

    PillTexture:texture = _Textures.PBar
    PillStyle2Texture:texture = _Textures.PBarStyle2

    var RankTextBlock: text_block =text_block{DefaultTextColor:=MakeColorFromSRGBValues(255,255,255), DefaultShadowColor:= color{R:=0.0, G:=0.0, B:=0.0}, DefaultShadowOffset:=option{vector2{X:=1.0, Y:=1.0}}}
    var LevelTextBlock: text_block =text_block{DefaultTextColor:=MakeColorFromSRGBValues(210,210,210), DefaultShadowColor:= color{R:=0.0, G:=0.0, B:=0.0}, DefaultShadowOffset:=option{vector2{X:=1.0, Y:=1.0}}, DefaultJustification:=text_justification.Left}
    var DoubleLevelTextBlock: text_block =text_block{DefaultTextColor:=MakeColorFromSRGBValues(210,210,210), DefaultShadowColor:= color{R:=0.0, G:=0.0, B:=0.0}, DefaultShadowOffset:=option{vector2{X:=1.0, Y:=1.0}}, DefaultJustification:=text_justification.Left}
    var ProgressTextBlock: text_block =text_block{DefaultTextColor:=MakeColorFromSRGBValues(210,210,210), DefaultShadowColor:= color{R:=0.0, G:=0.0, B:=0.0}, DefaultShadowOffset:=option{vector2{X:=1.0, Y:=1.0}}, DefaultJustification:=text_justification.Left}
    var XPBonusTextBlock: text_block =text_block{DefaultTextColor:=MakeColorFromSRGBValues(255,255,255), DefaultShadowColor:= color{R:=0.0, G:=0.0, B:=0.0}, DefaultShadowOffset:=option{vector2{X:=1.0, Y:=1.0}}}
    var LevelIncreaseTextBlock: text_block =text_block{DefaultTextColor:=MakeColorFromSRGBValues(255,255,255), DefaultShadowColor:= color{R:=0.0, G:=0.0, B:=0.0}, DefaultShadowOffset:=option{vector2{X:=1.0, Y:=1.0}}}
    var LevelUPTextBlock: text_block =text_block{DefaultTextColor:=Yellow, DefaultShadowColor:= Black, DefaultShadowOffset:=option{vector2{X:=1.0, Y:=1.0}}}

    AddScore(Agent:agent, Value:int, CheckRankUp:logic)<suspends>:void=
        Score:=StatsManager.GetStat("Score", Agent)
        OldRank:=GetRank(Agent)

        # if(Score+Value < 1):
        #     StatsManager.SetStat(Agent, "Score", 1)
        # else:
        StatsManager.AddStat(Agent, "Score", Value)
            
        NewRank:=GetRank(Agent)
        Scores:=StatsManager.GetStat("Score", Agent)
        Print("New Score = {Scores}")

        if(CheckRankUp = true):
            Sleep(1.5)
            spawn. CheckForRankUp(Agent, OldRank, NewRank)
            
        Sleep(1.5)
        UpdateRankHUD(Agent)
        spawn. AnimateXP(Agent,Value)

    UpdateRankHUD(Agent:agent):void=
        if(Index:=PlayersArray.Find[Agent]):
            Score:= StatsManager.GetStat("Score", Agent)
            Rank:rank = GetRank(Agent)
            PreviousRank:rank = GetPreviosRank(Agent)
            MaxRank:=GetMaxRank()

            PreviousRankGoal:=PreviousRank.ScoreMax*1.0
            RankGoal:=Rank.ScoreMax*1.0
            Calc:=(Score*1.0-PreviousRankGoal)/(RankGoal-PreviousRankGoal)

            if(RoundedCalc:=Round[Calc*100]):
                UpdateProgressBar(Agent, Calc)
                SetCurrentScore(Agent,Rank)

            if(Score*1.0 = RankGoal):
                NextRank := GetNextRank(Agent)
                GetRankTexture(Agent,NextRank)
                UpdateProgressBar(Agent, 0.0)
                SetCurrentScore(Agent,NextRank)

            AllPlayerInfoss := PlayerManager.GetPlayers()
            for (API : AllPlayerInfoss):
                if (API.AgentRef = Agent):
                    set XPBonus = API.XPBonus 
                    XPBonusTextBlock.SetText(I2M(XPBonus))
        else:
            Print("ERROR: Player Not Found in Player Array")
   
    GetRank(Agent:agent):rank =
        AllPlayerInfoss := PlayerManager.GetPlayers()
                
        var LowestRank:rank = rank{}
        MaxRank:=GetMaxRank()
        Score:=StatsManager.GetStat("Score", Agent)
        set LowestRank=MaxRank
        SortedRanks:=Sort(Ranks, true, CompareLevels)
        for(Rank:SortedRanks):
            if(Score <= Rank.ScoreMax):
                return Rank
                    
        return LowestRank

    GetNextRank(Agent:agent):rank=
        SortedRanks:=Sort(Ranks, true, CompareLevels)
        CurrentRank:=GetRank(Agent)
        if(Index:=SortedRanks.Find[CurrentRank]):
            if(NextRank:=SortedRanks[Index+1]):
                return NextRank

        return rank{}
    

    GetPreviosRank(Agent:agent):rank=
        SortedRanks:=Sort(Ranks, true, CompareLevels)
        CurrentRank:=GetRank(Agent)
        if(Index:=SortedRanks.Find[CurrentRank]):
            if(Index > 0):
                if(PreviousRank:=SortedRanks[Index-1]):
                    return PreviousRank

        return rank{}

    GetMaxRank():rank=
        SortedRanks:=Sort(Ranks, true, CompareLevels)
        if(MaxRank:=SortedRanks[SortedRanks.Length-1]):
            return MaxRank

        return rank{}

    var PlayersArray:[]agent = array{}

    MessageFromString<localizes>(InValue:string)<transacts>:message = "{InValue}"

    @editable DebugLevelButton : button_device = button_device{}

    OnDebugLevelButtonInteracted(A:agent):void=
        spawn. OnDebugLevelButtonInteractedSus(A)    

    OnDebugLevelButtonInteractedSus(Agent:agent)<suspends>:void=
        Score:=StatsManager.GetStat("Score", Agent)
        OldRank:=GetRank(Agent)

        # if(Score+Value < 1):
        #     StatsManager.SetStat(Agent, "Score", 1)
        # else:
        StatsManager.AddStat(Agent, "Score", 100)
            
        NewRank:=GetRank(Agent)
        Scores:=StatsManager.GetStat("Score", Agent)
        Print("New Score = {Scores}")

        Sleep(1.5)
        spawn. CheckForRankUp(Agent, OldRank, NewRank)
            
        Sleep(1.5)
        UpdateRankHUD(Agent)
        spawn. AnimateXP(Agent,100)

    OnBegin<override>()<suspends>:void=

        DebugLevelButton.InteractedWithEvent.Subscribe(OnDebugLevelButtonInteracted)

        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerRemoved)

        SpawnPadPoints:=GetCreativeObjectsWithTag(SpawnPadTag{})

        for(SpawnPads:SpawnPadPoints, SpawnPad:=player_spawner_device[SpawnPads]):
            SpawnPad.SpawnedEvent.Subscribe(OnPlayerSpawned)

    OnPlayerSpawned(Agent:agent):void=
        if:
            PlayerObj := player[Agent]
        then:
            if(PlayerExists:=PlayersArray.Find[Agent]):
                UpdateHoveringsRanks(Agent, rank{ScoreMax:=0}, GetRank(Agent))
                return
            else:
                set PlayersArray = PlayersArray + array{Agent}
                AssignUI(Agent)
                spawn{UpdatePlayerScore(Agent)}

    AssignUI(Agent:agent):void=
        Vals:=MakeUI(Agent)
        PlayerCanvas:=Vals(0)
        PlayerProgressBar:=Vals(1)
        PlayerRankText:=Vals(3)
        PlayerProgressText:=Vals(3)
        if(PlayerUI:=GetPlayerUI[player[Agent]]):
            PlayerUI.AddWidget(PlayerCanvas)
            XPBonusTextBlock.SetText(I2M(1))
            LevelIncreaseTextBlock.SetText(S2M("  "))
            LevelUPTextBlock.SetText(S2M("  "))
            if:
                set CanvasPerPlayer[Agent] = option{PlayerCanvas}
                set ProgressBarPerPlayer[Agent] = option{PlayerProgressBar}
                set RankTextPerPlayer[Agent] = option{PlayerRankText}
                set RankProgressPerPlayer[Agent] = option{PlayerProgressText}
    
    I2M<localizes>(S:int):message="x{S}"
    S2M<localizes>(S:string):message="{S}"
    LevelMessage<localizes>(S:int):message="{S}"
    ProgressMessage<localizes>(S:int):message="{S}"

    MakeUI(Agent:agent):tuple(canvas, progress_bar, text_block, text_block)=
        var ProgressBar:progress_bar = progress_bar{Orientation:=RightToLeft, Size:=vector2{X:=0.0, Y:=0.0}}
        RankTexture:=GetRankTexture(Agent,GetRank(Agent))
        SavedProgress :=  SetCurrentScore(Agent,GetRank(Agent))
        var Canvas:canvas = canvas{}

        RankTextBlock.SetShadowOpacity(0.2)
        LevelTextBlock.SetShadowOpacity(0.2)
        DoubleLevelTextBlock.SetShadowOpacity(0.2)
        ProgressTextBlock.SetShadowOpacity(0.2)
        XPBonusTextBlock.SetShadowOpacity(0.2)
        LevelIncreaseTextBlock.SetShadowOpacity(0.2)
        LevelUPTextBlock.SetShadowOpacity(1.0)

        set ProgressBar = MakeProgressBar(0.0, LeftToRight, vector2{X:=270.0, Y:=30.0}, MakeColorFromSRGBValues(241, 41, 41), Settings.ProgressBar.BarColor, Settings.ProgressBar.SmoothUpdate)
        ProgressBarWidget:=ProgressBar.GetWidget()
        PillTextureBlock:=texture_block{DefaultImage:=PillStyle2Texture, DefaultTint:=Settings.ProgressBar.BarColor, DefaultDesiredSize:=vector2{X:=275.0, Y:=40.0}}
        HexOverlay:=overlay:
            Slots:=array:
                overlay_slot:
                    Widget:=ProgressBarWidget
                    HorizontalAlignment:=horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Center
                    Padding:=margin{Left:=52.0, Top:=0.0, Right:=0.0, Bottom:=0.0}
                overlay_slot:
                    Widget:=PillTextureBlock
                    HorizontalAlignment:=horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Center
                    Padding:=margin{Left:=52.0, Top:=0.0, Right:=0.0, Bottom:=0.0}
                overlay_slot:
                    Widget:=texture_block{DefaultImage:=_Textures.HexLvlNum,DefaultDesiredSize:=vector2{X:=85.0,Y:=100.0}}
                    HorizontalAlignment:=horizontal_alignment.Left
                    VerticalAlignment:=vertical_alignment.Top
                overlay_slot:
                    Widget:=LevelTextBlock
                    HorizontalAlignment:=horizontal_alignment.Left
                    VerticalAlignment:=vertical_alignment.Center
                    Padding:=margin{Left:=35.25, Top:=0.0, Right:=0.0, Bottom:=0.0}
                overlay_slot:
                    Widget:=DoubleLevelTextBlock
                    HorizontalAlignment:=horizontal_alignment.Left
                    VerticalAlignment:=vertical_alignment.Center
                    Padding:=margin{Left:=25.0, Top:=0.0, Right:=0.0, Bottom:=0.0}
                overlay_slot:
                    Widget:=XPBonusTextBlock
                    HorizontalAlignment:=horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Center
                    Padding:=margin{Left:=0.0, Top:=0.0, Right:=-220.0, Bottom:=0.0}
                overlay_slot:
                    Widget:=LevelIncreaseTextBlock
                    HorizontalAlignment:=horizontal_alignment.Right
                    VerticalAlignment:=vertical_alignment.Top
                    Padding:=margin{Left:=0.0, Top:=-10.0, Right:=-30.0, Bottom:=0.0}
                overlay_slot:
                    Widget:=LevelUPTextBlock
                    HorizontalAlignment:=horizontal_alignment.Left
                    VerticalAlignment:=vertical_alignment.Top
                    Padding:=margin{Left:=-30.0, Top:=-40.0, Right:=0.0, Bottom:=0.0}

        HexStackBox:=stack_box:
            Orientation:=orientation.Horizontal
            Slots:=array:
                stack_box_slot:
                    Widget:=HexOverlay
                    HorizontalAlignment:=horizontal_alignment.Fill
                    VerticalAlignment:=vertical_alignment.Fill

        set Canvas=canvas:
            Slots:=array:
                canvas_slot:
                    Widget:=HexStackBox
                    SizeToContent:=true
                    Anchors:=anchors{Minimum:=vector2{X:=0.0425, Y:=0.77}, Maximum:=vector2{X:=0.0425, Y:=0.77}}
                    Alignment:=vector2{X:=0.0, Y:=0.5}
                    Offsets:=margin{Left:=0.0, Top:=-10.0, Right:=0.0, Bottom:=0.0}
                    ZOrder:=1

        return(Canvas, ProgressBar, RankTextBlock, ProgressTextBlock)

    ToggleHoveringRanks():void=
        AllPlayers:=GetPlayspace().GetPlayers()
        for(Player:AllPlayers):
            UpdateHoveringsRanks(Player, rank{ScoreMax:=0}, GetRank(Player))

    UpdateProgressBar(Agent:agent, Value:float):void=
        if(PlayerProgressBar:=ProgressBarPerPlayer[Agent]?):
            Rank:=GetRank(Agent)
            PlayerProgressBar.SetProgress(Value)
            PlayerProgressBar.SetFrontColor(Rank.BarColor)

    GetRankTexture(Agent:agent,Rank:rank):void=
        if(Index:=Ranks.Find[Rank]):
            Print("GetRankTexture: {Index}")
            LevelPis := StatsManager.GetStat("Level",Agent)
            if(LevelPis <= 9):
                LevelTextBlock.SetText(LevelMessage(Index+1))
                StatsManager.SetStat(Agent,"Level",Index+1)
                if (CurrentRank := Ranks[LevelPis+1]):
                    UpdateHoveringsRanks(Agent,Rank,CurrentRank)
                DoubleLevelTextBlock.SetVisibility(widget_visibility.Collapsed)
                LevelTextBlock.SetVisibility(widget_visibility.Visible)
            else:
                DoubleLevelTextBlock.SetText(LevelMessage(Index+1))
                StatsManager.SetStat(Agent,"Level",Index+1)
                if (CurrentRank := Ranks[LevelPis+1]):
                    UpdateHoveringsRanks(Agent,Rank,CurrentRank)
                DoubleLevelTextBlock.SetVisibility(widget_visibility.Visible)
                LevelTextBlock.SetVisibility(widget_visibility.Collapsed)

    UpdateHoveringsRanks(Agent:agent, OldRank:rank, NewRank:rank):void=
        NewRank.HeadHoverVFX.Pickup(Agent)

    CheckForRankUp(Agent:agent, OldRank:rank, NewRank:rank)<suspends>:void=
        if(OldRank <> NewRank): #Rank Up
            UpdateHoveringsRanks(Agent, OldRank, NewRank)
            Sleep(1.5)
            LevelUPTextBlock.SetText(S2M("LEVEL UP!"))
            Sleep(2.5)
            LevelUPTextBlock.SetText(S2M("  "))

    SetCurrentScore(Agent:agent,Rank:rank):void=
        if(Index:=Ranks.Find[Rank]):
            Print("GetRankTexture: {Index}")
            Score:= StatsManager.GetStat("Score", Agent)
            
            var Text:string = "{Score}/{Rank.ScoreMax}"
            ProgressTextBlock.SetText(S2M(Text))

    UpdatePlayerScore(Agent:agent)<suspends>:void=
        if(PlayerObj := player[Agent]):
            UpdateRankHUD(Agent)
            UpdateHoveringsRanks(Agent, rank{ScoreMax:=0}, GetRank(Agent))

    OnPlayerRemoved(Player:player):void=
        if(Agent:=agent[Player]):
            if(Index:=PlayersArray.Find[Agent]):
                if(TempArray:=PlayersArray.RemoveElement[Index]):
                    set PlayersArray = TempArray

    AnimateXP(A:agent,Amount:int)<suspends>: void ={
        var StartTime: float = GetSimulationElapsedTime()
        var CurrentTime: float = StartTime
        var WidgetToChange : widget = text_block{}
        var PlayerCanvas : canvas = canvas{}

        if (Canvas := CanvasPerPlayer[A]?):
            set PlayerCanvas = Canvas


        TimeWillTake := 0.5
        FinalLocation := 50.0
        

        loop{
            set CurrentTime = GetSimulationElapsedTime()
            Progress := (CurrentTime - StartTime)/TimeWillTake
            NewLocation := FinalLocation* Progress
            NewOpacity := 0.1*Progress

            WidgetToChange.SetVisibility(widget_visibility.Hidden)
            PlayerCanvas.RemoveWidget(WidgetToChange)
            WTA := text_block{DefaultText := S2M("+{Amount}XP"), DefaultTextOpacity:= 1.0, DefaultTextColor := NamedColors.White, DefaultShadowOffset := option{vector2{X:=1.0, Y:=1.0}}}
            WTA.SetShadowOpacity(1.0)
            if (Progress >= 1.0){
                Print("Progress 1")
                Print("Remove Widget")
                PlayerCanvas.RemoveWidget(WTA)
                WTA.SetVisibility(widget_visibility.Hidden)
                WTA.SetVisibility(widget_visibility.Visible)
                LevelIncreaseTextBlock.SetText(S2M("+{Amount}XP"))
                Sleep(1.5)
                LevelIncreaseTextBlock.SetText(S2M("  "))
                break
            }

            
            cvs := canvas_slot:
                Anchors := anchors{Minimum := vector2{X := 0.202951, Y := 0.726749}, Maximum := vector2{X := 0.202951, Y := 0.726749}}
                Offsets := margin{Top :=0.0, Left := -200.0+NewLocation, Right := 0.0, Bottom := 0.0}
                Alignment := vector2{X := 0.5, Y := 0.5}

                Widget := WTA

            set WidgetToChange = WTA
            PlayerCanvas.AddWidget(cvs)
            WTA.SetVisibility(widget_visibility.Hidden)
            WTA.SetVisibility(widget_visibility.Visible)

            Sleep(0.0)
        }
    }