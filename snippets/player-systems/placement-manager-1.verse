# Player Ranking System
# A competitive ranking system that tracks player scores through eliminations and deaths, displaying progress bars and rank information with customizable visual effects. Players advance through configur
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/placement-manager-1?ref=github

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

PlacementManagerTag:= class(tag){}
SpawnPadTag := class(tag){}

style := enum{Style1, Style2}
hovertype := enum{Head, Back}
counttype := enum{Score, Percentage}
displaytype := enum{Pill, Box}

rank := class<concrete><unique>:
    @editable Name:string = "Name"
    @editable ScoreMax:int = 0
    @editable BarColor:color = color{}
    @editable RankUpBanner:hud_message_device = hud_message_device{}
    @editable RankDownBanner:hud_message_device = hud_message_device{}
    @editable HeadHoverVFX:visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable BackHoverVFX:visual_effect_powerup_device = visual_effect_powerup_device{}

settings := class<concrete><unique>:
    @editable var ProgressBar:progressbar_settings = progressbar_settings{}

    @editable var DoPointsOnElim:logic = true
    @editable var PointsOnElim:int = 50

    @editable var DoPointsOnDeath:logic = true
    @editable var PointsOnDeath:int = -50

    @editable var HoverType:hovertype = hovertype.Back

progressbar_settings := class<concrete><unique>:
    @editable var Style:style = style.Style2
    @editable var BarColor:color = color{}
    @editable var CountType:counttype = counttype.Percentage
    @editable var DisplayType:displaytype = displaytype.Box
    @editable var TotalScore:logic = true
    @editable var SmoothUpdate:logic = true

placement_manager := class(creative_device):
    var CanvasPerPlayer:[agent]?canvas = map{}
    var ProgressBarPerPlayer:[agent]?progress_bar = map{}
    var RankPerPlayer:[agent]?widget = map{}
    var RankTextPerPlayer:[agent]?text_block = map{}
    var RankProgressPerPlayer:[agent]?text_block = map{}

    @editable var Settings:settings = settings{}
    @editable var Ranks:[]rank = array{}

    @editable RankTextList:[]hud_message_device = array{}

    # Put your Materials here, in the order of ranks
    Materials:[]material = array:
        UI_Ranks.B1
        UI_Ranks.B2
        UI_Ranks.B3
        UI_Ranks.S1
        UI_Ranks.S2
        UI_Ranks.S3
        UI_Ranks.G1
        UI_Ranks.G2
        UI_Ranks.G3
        UI_Ranks.P1
        UI_Ranks.P2
        UI_Ranks.P3
        UI_Ranks.D1
        UI_Ranks.D2
        UI_Ranks.D3
        UI_Ranks.E
        UI_Ranks.C
        UI_Ranks.U

    # Put your Textures here, in the order of ranks
    Textures:[]texture = array:
        UI_Ranks.Bronze1
        UI_Ranks.Bronze2
        UI_Ranks.Bronze3
        UI_Ranks.Silver1
        UI_Ranks.Silver2
        UI_Ranks.Silver3
        UI_Ranks.Gold1
        UI_Ranks.Gold2
        UI_Ranks.Gold3
        UI_Ranks.Plat1
        UI_Ranks.Plat2
        UI_Ranks.Plat3
        UI_Ranks.Diamond1
        UI_Ranks.Diamond2
        UI_Ranks.Diamond3
        UI_Ranks.Elite
        UI_Ranks.Champion
        UI_Ranks.Unreal
    
    PillTexture:texture = PBar
    PillStyle2Texture:texture = PBarStyle2

    AddScore(Agent:agent, Value:int, CheckRankUp:logic):void=
        if(TaggedObject := GetCreativeObjectsWithTag(StatsManagerTag{})[0], StatsManager := stats_manager[TaggedObject]):
            Score:=StatsManager.GetStat(StatType.Score, Agent)
            OldRank:=GetRank(Agent)

            if(Score+Value < 1):
                StatsManager.SetStat(Agent, StatType.Score, 1)
            else:
                StatsManager.AddStat(Agent, StatType.Score, Value)
                
            NewRank:=GetRank(Agent)

            if(CheckRankUp = true):
                CheckForRankUp(Agent, OldRank, NewRank)

            UpdateRankHUD(Agent)

            if(TaggedObject1 := GetCreativeObjectsWithTag(LeaderboardManagerTag{})[0], LeaderboardManager := leaderboard_manager[TaggedObject1], TaggedObject2 := GetCreativeObjectsWithTag(StatboardManagerTag{})[0], StatboardManager := statboard_manager[TaggedObject2]):
                LeaderboardManager.UpdateLeaderboard()
                StatboardManager.UpdateAgentStatboard(Agent)
            else:
                Print("ERROR: No Tag on Leaderboard Manager or Statboard Manager")

    PlayerKill(Agent:agent):void=
        if(Settings.DoPointsOnElim = false):
            return

        OldRank := GetRank(Agent)
        AddScore(Agent, Settings.PointsOnElim, false)
        NewRank := GetRank(Agent)
        UpdateRankHUD(Agent)
        CheckForRankUp(Agent, OldRank, NewRank)
        
    PlayerDeath(Agent:agent):void=
        if(Settings.DoPointsOnDeath = false):
            return

        OldRank := GetRank(Agent)
        AddScore(Agent, Settings.PointsOnDeath, false)
        NewRank := GetRank(Agent)
        UpdateRankHUD(Agent)
        CheckForRankUp(Agent, OldRank, NewRank)        

    UpdateRankHUD(Agent:agent):void=
        if(TaggedObject := GetCreativeObjectsWithTag(StatsManagerTag{})[0], StatsManager := stats_manager[TaggedObject]):
            if(Index:=PlayersArray.Find[Agent]):
                if(RankTextHUD:=RankTextList[Index]):
                    var Text:string = ""
                    var ScoreText:string = ""
                    
                    Score:= StatsManager.GetStat(StatType.Score, Agent)
                    Rank:rank = GetRank(Agent)
                    PreviousRank:rank = GetPreviosRank(Agent)
                    MaxRank:=GetMaxRank()

                    PreviousRankGoal:=PreviousRank.ScoreMax*1.0
                    RankGoal:=Rank.ScoreMax*1.0
                    Calc:=(Score*1.0-PreviousRankGoal)/(RankGoal-PreviousRankGoal)

                    if(RoundedCalc:=Round[Calc*100]):
                        if(Rank = MaxRank):
                            if(Settings.ProgressBar.CountType = counttype.Score):
                                if(Settings.ProgressBar.TotalScore = true):
                                    set Text = "{Rank.Name} ({Score})"
                                    set ScoreText = "{Score}"
                                else:
                                    set Text = "{Rank.Name} ({Score})"
                                    set ScoreText = "{Score}"
                            else:
                                set Text = "{Rank.Name}"
                                set ScoreText = " "

                            UpdateProgressBar(Agent, 1.0)
                        else:
                            if(Settings.ProgressBar.CountType = counttype.Score):
                                if(Settings.ProgressBar.TotalScore = true):
                                    set Text = "{Rank.Name} ({Score}/{Rank.ScoreMax})"
                                    set ScoreText = "{Score}/{Rank.ScoreMax}"
                                else:
                                    set Text = "{Rank.Name} ({Score - PreviousRank.ScoreMax}/{Rank.ScoreMax - PreviousRank.ScoreMax})"
                                    set ScoreText = "{Score - PreviousRank.ScoreMax}/{Rank.ScoreMax - PreviousRank.ScoreMax}"
                            else:
                                set Text = "{Rank.Name}  ({RoundedCalc}%)"
                                set ScoreText = "{RoundedCalc}%"

                            UpdateProgressBar(Agent, Calc)

                    UpdateRankImage(Agent)
                    if(Settings.ProgressBar.Style = style.Style1):
                        RankTextHUD.SetText(MessageFromString(Text))
                        RankTextHUD.Show(Agent)
                    else:
                        if(RankText:=RankTextPerPlayer[Agent]?, RankProgress:=RankProgressPerPlayer[Agent]?):
                            RankText.SetText(MessageFromString(Rank.Name))
                            RankProgress.SetText(MessageFromString(ScoreText))
                else:
                    Print("ERROR: Rank Text Not Found in Array")
            else:
                Print("ERROR: Player Not Found in Array 2")
        else:
            Print("ERROR: No Tag on Statboard Manager")

    CheckForRankUp(Agent:agent, OldRank:rank, NewRank:rank):void=
        if(OldRank <> NewRank): #Rank Up
            UpdateHoveringsRanks(Agent, OldRank, NewRank)

            if(OldRank.ScoreMax < NewRank.ScoreMax):
                NewRank.RankUpBanner.Show(Agent)
            else:
                NewRank.RankDownBanner.Show(Agent)

            UpdateRankHUD(Agent)

    UpdateHoveringsRanks(Agent:agent, OldRank:rank, NewRank:rank):void=
        if(Settings.HoverType = hovertype.Head):
            NewRank.HeadHoverVFX.Pickup(Agent)
        else:
            NewRank.BackHoverVFX.Pickup(Agent)
    
    GetRank(Agent:agent):rank =
        var LowestRank:rank = rank{}
        MaxRank:=GetMaxRank()
        if(TaggedObject := GetCreativeObjectsWithTag(StatsManagerTag{})[0], StatsManager := stats_manager[TaggedObject]):
            Score:=StatsManager.GetStat(StatType.Score, Agent)
            set LowestRank=MaxRank
            SortedRanks:=Sort(Ranks, true, CompareRanks)
            for(Rank:SortedRanks):
                if(Score <= Rank.ScoreMax):
                    return Rank
                    
        return LowestRank

    GetPreviosRank(Agent:agent):rank=
        SortedRanks:=Sort(Ranks, true, CompareRanks)
        CurrentRank:=GetRank(Agent)
        if(Index:=SortedRanks.Find[CurrentRank]):
            if(Index > 0):
                if(PreviousRank:=SortedRanks[Index-1]):
                    return PreviousRank

        return rank{}

    GetMaxRank():rank=
        SortedRanks:=Sort(Ranks, true, CompareRanks)
        if(MaxRank:=SortedRanks[SortedRanks.Length-1]):
            return MaxRank

        return rank{}

    GetRankTexture(Rank:rank):widget=
        if(Index:=Ranks.Find[Rank], Texture:=Textures[Index]):
            return texture_block:
                DefaultImage:=Texture
                DefaultDesiredSize:=vector2{X:=75.0, Y:=75.0}
        else:
            return color_block:
                DefaultColor:=NamedColors.White
                DefaultDesiredSize:=vector2{X:=75.0, Y:=75.0}

    var PlayersArray:[]agent = array{}

    MessageFromString<localizes>(InValue:string)<transacts>:message = "{InValue}"

    OnBegin<override>()<suspends>:void=
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
                if(TaggedObject:=GetCreativeObjectsWithTag(LeaderboardManagerTag{})[0]):
                    if(LeaderboardManager:=leaderboard_manager[TaggedObject]):
                        LeaderboardManager.UpdateLeaderboard()
                        AssignUI(Agent)
                        spawn{UpdatePlayerScore(Agent)}
                else:
                    Print("ERROR: No Tag on Leaderboard Manager")

    AssignUI(Agent:agent):void=
        Vals:=MakeUI(Agent)
        PlayerCanvas:=Vals(0)
        PlayerProgressBar:=Vals(1)
        PlayerRank:=Vals(2)
        PlayerRankText:=Vals(3)
        PlayerProgressText:=Vals(4)
        if(PlayerUI:=GetPlayerUI[player[Agent]]):
            PlayerUI.AddWidget(PlayerCanvas)
            if:
                set CanvasPerPlayer[Agent] = option{PlayerCanvas}
                set ProgressBarPerPlayer[Agent] = option{PlayerProgressBar}
                set RankPerPlayer[Agent] = option{PlayerRank}
                set RankTextPerPlayer[Agent] = option{PlayerRankText}
                set RankProgressPerPlayer[Agent] = option{PlayerProgressText}


    MakeUI(Agent:agent):tuple(canvas, progress_bar, widget, text_block, text_block)=
        var ProgressBar:progress_bar = progress_bar{Orientation:=RightToLeft, Size:=vector2{X:=0.0, Y:=0.0}}
        RankTexture:=GetRankTexture(GetRank(Agent))
        var Canvas:canvas = canvas{}

        RankTextBlock:=text_block{DefaultText:=MessageFromString(""), DefaultTextColor:=MakeColorFromSRGBValues(255,255,255), DefaultShadowColor:= color{R:=0.0, G:=0.0, B:=0.0}, DefaultShadowOffset:=option{vector2{X:=1.0, Y:=1.0}}}
        ProgressTextBlock:=text_block{DefaultText:=MessageFromString(""), DefaultTextColor:=MakeColorFromSRGBValues(210,210,210), DefaultShadowColor:= color{R:=0.0, G:=0.0, B:=0.0}, DefaultShadowOffset:=option{vector2{X:=1.0, Y:=1.0}}, DefaultJustification:=text_justification.Left}
        RankTextBlock.SetShadowOpacity(0.2)
        ProgressTextBlock.SetShadowOpacity(0.2)

        if(Settings.ProgressBar.Style = style.Style1):
            set ProgressBar = MakeProgressBar(0.0, LeftToRight, vector2{X:=269.0, Y:=15.0}, MakeColorFromSRGBValues(241, 41, 41), Settings.ProgressBar.BarColor, Settings.ProgressBar.SmoothUpdate)
            ProgressBarWidget:=ProgressBar.GetWidget()
            PillTextureBlock:=texture_block{DefaultImage:=PillTexture, DefaultTint:=Settings.ProgressBar.BarColor, DefaultDesiredSize:=vector2{X:=275.0, Y:=20.0}}

            if(Settings.ProgressBar.DisplayType = displaytype.Pill):
                set Canvas=canvas:
                    Slots:=array:
                        canvas_slot:
                            Widget:=ProgressBarWidget
                            SizeToContent:=true
                            Anchors:=anchors{Minimum:=vector2{X:=0.0, Y:=1.0}, Maximum:=vector2{X:=0.0, Y:=1.0}}
                            Offsets:=margin{Left:=340.0, Top:=-176.0, Right:=0.0, Bottom:=0.0}
                            Alignment:=vector2{X:=0.5, Y:=0.5}
                        canvas_slot:
                            Widget:=RankTexture
                            SizeToContent:=true
                            Anchors:=anchors{Minimum:=vector2{X:=0.0, Y:=1.0}, Maximum:=vector2{X:=0.0, Y:=1.0}}
                            Offsets:=margin{Left:=145.0, Top:=-190.0, Right:=0.0, Bottom:=0.0}
                            Alignment:=vector2{X:=0.5, Y:=0.5}
                        canvas_slot:
                            Widget:=PillTextureBlock
                            SizeToContent:=true
                            Anchors:=anchors{Minimum:=vector2{X:=0.0, Y:=1.0}, Maximum:=vector2{X:=0.0, Y:=1.0}}
                            Offsets:=margin{Left:=340.0, Top:=-176.0, Right:=0.0, Bottom:=0.0}
                            Alignment:=vector2{X:=0.5, Y:=0.5}
                            ZOrder:=1
            else:
                set Canvas=canvas:
                    Slots:=array:
                        canvas_slot:
                            Widget:=ProgressBarWidget
                            SizeToContent:=true
                            Anchors:=anchors{Minimum:=vector2{X:=0.0, Y:=1.0}, Maximum:=vector2{X:=0.0, Y:=1.0}}
                            Offsets:=margin{Left:=340.0, Top:=-176.0, Right:=0.0, Bottom:=0.0}
                            Alignment:=vector2{X:=0.5, Y:=0.5}
                        canvas_slot:
                            Widget:=RankTexture
                            SizeToContent:=true
                            Anchors:=anchors{Minimum:=vector2{X:=0.0, Y:=1.0}, Maximum:=vector2{X:=0.0, Y:=1.0}}
                            Offsets:=margin{Left:=145.0, Top:=-190.0, Right:=0.0, Bottom:=0.0}
                            Alignment:=vector2{X:=0.5, Y:=0.5}   
                        canvas_slot:
                            Widget:=color_block{DefaultColor:=Settings.ProgressBar.BarColor, DefaultDesiredSize:=vector2{X:=275.0, Y:=21.5}}
                            SizeToContent:=true
                            Anchors:=anchors{Minimum:=vector2{X:=0.0, Y:=1.0}, Maximum:=vector2{X:=0.0, Y:=1.0}}
                            Offsets:=margin{Left:=340.0, Top:=-176.0, Right:=0.0, Bottom:=0.0}
                            Alignment:=vector2{X:=0.5, Y:=0.5}
        else:
            set ProgressBar = MakeProgressBar(0.0, LeftToRight, vector2{X:=269.0, Y:=27.5}, MakeColorFromSRGBValues(241, 41, 41), Settings.ProgressBar.BarColor, Settings.ProgressBar.SmoothUpdate)
            Position:=vector2{X:=318.0, Y:=-176.0}
            RankPosition:=vector2{X:=133.0, Y:=-190.0}
            ProgressBarWidget:=ProgressBar.GetWidget()
            PillTextureBlock:=texture_block{DefaultImage:=PillStyle2Texture, DefaultTint:=Settings.ProgressBar.BarColor, DefaultDesiredSize:=vector2{X:=ProgressBar.Size.X+8.0, Y:=ProgressBar.Size.Y+10.0}}
            
            if(Settings.ProgressBar.DisplayType = displaytype.Pill):
                set Canvas=canvas:
                    Slots:=array:
                        canvas_slot:
                            Widget:=ProgressBarWidget
                            SizeToContent:=true
                            Anchors:=anchors{Minimum:=vector2{X:=0.0, Y:=1.0}, Maximum:=vector2{X:=0.0, Y:=1.0}}
                            Offsets:=margin{Left:=Position.X, Top:=Position.Y, Right:=0.0, Bottom:=0.0}
                            Alignment:=vector2{X:=0.5, Y:=0.5}
                        canvas_slot:
                            Widget:=RankTexture
                            SizeToContent:=true
                            Anchors:=anchors{Minimum:=vector2{X:=0.0, Y:=1.0}, Maximum:=vector2{X:=0.0, Y:=1.0}}
                            Offsets:=margin{Left:=RankPosition.X, Top:=RankPosition.Y, Right:=0.0, Bottom:=0.0}
                            Alignment:=vector2{X:=0.5, Y:=0.5}
                        canvas_slot:
                            Widget:=PillTextureBlock
                            SizeToContent:=true
                            Anchors:=anchors{Minimum:=vector2{X:=0.0, Y:=1.0}, Maximum:=vector2{X:=0.0, Y:=1.0}}
                            Offsets:=margin{Left:=Position.X, Top:=Position.Y, Right:=0.0, Bottom:=0.0}
                            Alignment:=vector2{X:=0.5, Y:=0.5}
                            ZOrder:=2
                        canvas_slot:
                            Widget:=ProgressTextBlock
                            Anchors:=anchors{Minimum:=vector2{X:=0.0, Y:=1.0}, Maximum:=vector2{X:=0.0, Y:=1.0}}
                            Offsets:=margin{Left:=Position.X, Top:=Position.Y+0.5, Right:=0.0, Bottom:=0.0}
                            Alignment:=vector2{X:=0.5, Y:=0.5}
                            ZOrder:=1
                        canvas_slot:
                            Widget:=RankTextBlock
                            Anchors:=anchors{Minimum:=vector2{X:=0.0, Y:=1.0}, Maximum:=vector2{X:=0.0, Y:=1.0}}
                            Offsets:=margin{Left:=Position.X-(ProgressBar.Size.X/2.0)-2.0, Top:=Position.Y-33.0, Right:=0.0, Bottom:=0.0}
                            Alignment:=vector2{X:=0.0, Y:=0.5}
                            ZOrder:=1
            else:
                set Canvas=canvas:
                    Slots:=array:
                        canvas_slot:
                            Widget:=ProgressBarWidget
                            SizeToContent:=true
                            Anchors:=anchors{Minimum:=vector2{X:=0.0, Y:=1.0}, Maximum:=vector2{X:=0.0, Y:=1.0}}
                            Offsets:=margin{Left:=Position.X-0.5, Top:=Position.Y, Right:=0.0, Bottom:=0.0}
                            Alignment:=vector2{X:=0.5, Y:=0.5}
                        canvas_slot:
                            Widget:=RankTexture
                            SizeToContent:=true
                            Anchors:=anchors{Minimum:=vector2{X:=0.0, Y:=1.0}, Maximum:=vector2{X:=0.0, Y:=1.0}}
                            Offsets:=margin{Left:=RankPosition.X, Top:=RankPosition.Y, Right:=0.0, Bottom:=0.0}
                            Alignment:=vector2{X:=0.5, Y:=0.5}   
                        canvas_slot:
                            Widget:=color_block{DefaultColor:=Settings.ProgressBar.BarColor, DefaultDesiredSize:=vector2{X:=ProgressBar.Size.X+5.0, Y:=ProgressBar.Size.Y+5.0}}
                            SizeToContent:=true
                            Anchors:=anchors{Minimum:=vector2{X:=0.0, Y:=1.0}, Maximum:=vector2{X:=0.0, Y:=1.0}}
                            Offsets:=margin{Left:=Position.X, Top:=Position.Y, Right:=0.0, Bottom:=0.0}
                            Alignment:=vector2{X:=0.5, Y:=0.5}
                        canvas_slot:
                            Widget:=ProgressTextBlock
                            Anchors:=anchors{Minimum:=vector2{X:=0.0, Y:=1.0}, Maximum:=vector2{X:=0.0, Y:=1.0}}
                            Offsets:=margin{Left:=Position.X, Top:=Position.Y+0.5, Right:=0.0, Bottom:=0.0}
                            Alignment:=vector2{X:=0.5, Y:=0.5}
                            ZOrder:=1
                        canvas_slot:
                            Widget:=RankTextBlock
                            Anchors:=anchors{Minimum:=vector2{X:=0.0, Y:=1.0}, Maximum:=vector2{X:=0.0, Y:=1.0}}
                            Offsets:=margin{Left:=Position.X-(ProgressBar.Size.X/2.0)-2.0, Top:=Position.Y-33.0, Right:=0.0, Bottom:=0.0}
                            Alignment:=vector2{X:=0.0, Y:=0.5}
                            ZOrder:=1

        return(Canvas, ProgressBar, RankTexture, RankTextBlock, ProgressTextBlock)

    UpdateProgressBar(Agent:agent, Value:float):void=
        if(PlayerProgressBar:=ProgressBarPerPlayer[Agent]?):
            Rank:=GetRank(Agent)
            PlayerProgressBar.SetProgress(Value)
            PlayerProgressBar.SetFrontColor(Rank.BarColor)

    UpdateRankImage(Agent:agent):void=
        if(PlayerRankTexture:=RankPerPlayer[Agent]?):
            RankWidget:=GetRankTexture(GetRank(Agent))
            if(TextureBlock:=texture_block[PlayerRankTexture], RankTextureBlock:=texture_block[RankWidget]):
                TextureBlock.SetImage(RankTextureBlock.GetImage())

    UpdatePlayerScore(Agent:agent)<suspends>:void=
        if(PlayerObj := player[Agent]):
            UpdateRankHUD(Agent)
            UpdateHoveringsRanks(Agent, rank{ScoreMax:=0}, GetRank(Agent))

    OnPlayerRemoved(Player:player):void=
        if(Agent:=agent[Player]):
            if(Index:=PlayersArray.Find[Agent]):
                if(TempArray:=PlayersArray.RemoveElement[Index]):
                    set PlayersArray = TempArray

    #SHOWCASE FUNCTIONS - FEEL FREE TO DELETE

    TogglePointsOnElim():void=
        if(Settings.DoPointsOnElim = true):
            set Settings.DoPointsOnElim = false
        else:
            set Settings.DoPointsOnElim = true

    TogglePointsOnDeath():void=
        if(Settings.DoPointsOnDeath = true):
            set Settings.DoPointsOnDeath = false
        else:
            set Settings.DoPointsOnDeath = true

    ToggleHoveringRanks():void=
        if(Settings.HoverType = hovertype.Head):
            set Settings.HoverType = hovertype.Back
            AllPlayers:=GetPlayspace().GetPlayers()
            for(Player:AllPlayers):
                UpdateHoveringsRanks(Player, rank{ScoreMax:=0}, GetRank(Player))
        else:
            set Settings.HoverType = hovertype.Head
            AllPlayers:=GetPlayspace().GetPlayers()
            for(Player:AllPlayers):
                UpdateHoveringsRanks(Player, rank{ScoreMax:=0}, GetRank(Player))

    ToggleProgressBarStyle():void=
        if(Settings.ProgressBar.Style = style.Style1):
            set Settings.ProgressBar.Style = style.Style2
            AllPlayers:=GetPlayspace().GetPlayers()
            for(Player:AllPlayers):
                if(PlayerCanvas:=CanvasPerPlayer[Player]?, PlayeUI:=GetPlayerUI[Player]):
                    PlayeUI.RemoveWidget(PlayerCanvas)
                    AssignUI(Player)
                    UpdateRankHUD(Player)
                    if(Index:=PlayersArray.Find[Player]):
                        if(RankTextHUD:=RankTextList[Index]):
                            RankTextHUD.SetText(MessageFromString(" "))
                            RankTextHUD.Show(Player)
        else:
            set Settings.ProgressBar.Style = style.Style1
            AllPlayers:=GetPlayspace().GetPlayers()
            for(Player:AllPlayers):
                if(PlayerCanvas:=CanvasPerPlayer[Player]?, PlayeUI:=GetPlayerUI[Player]):
                    PlayeUI.RemoveWidget(PlayerCanvas)
                    AssignUI(Player)
                    UpdateRankHUD(Player)

    ToggleTotalScore():void=
        if(Settings.ProgressBar.TotalScore = true):
            set Settings.ProgressBar.TotalScore = false
            AllPlayers:=GetPlayspace().GetPlayers()
            for(Player:AllPlayers):
                UpdateRankHUD(Player)
        else:
            set Settings.ProgressBar.TotalScore = true
            AllPlayers:=GetPlayspace().GetPlayers()
            for(Player:AllPlayers):
                UpdateRankHUD(Player)

    ToggleProgressBarType():void=
        if(Settings.ProgressBar.DisplayType = displaytype.Pill):
            set Settings.ProgressBar.DisplayType = displaytype.Box
            AllPlayers:=GetPlayspace().GetPlayers()
            for(Player:AllPlayers):
                if(PlayerCanvas:=CanvasPerPlayer[Player]?, PlayeUI:=GetPlayerUI[Player]):
                    PlayeUI.RemoveWidget(PlayerCanvas)
                    AssignUI(Player)
                    UpdateRankHUD(Player)
        else:
            set Settings.ProgressBar.DisplayType = displaytype.Pill
            AllPlayers:=GetPlayspace().GetPlayers()
            for(Player:AllPlayers):
                if(PlayerCanvas:=CanvasPerPlayer[Player]?, PlayeUI:=GetPlayerUI[Player]):
                    PlayeUI.RemoveWidget(PlayerCanvas)
                    AssignUI(Player)
                    UpdateRankHUD(Player)

    ToggleProgressBarCount():void=
        if(Settings.ProgressBar.CountType = counttype.Score):
            set Settings.ProgressBar.CountType = counttype.Percentage
            AllPlayers:=GetPlayspace().GetPlayers()
            for(Player:AllPlayers):
                UpdateRankHUD(Player)
        else:
            set Settings.ProgressBar.CountType = counttype.Score
            AllPlayers:=GetPlayspace().GetPlayers()
            for(Player:AllPlayers):
                UpdateRankHUD(Player)

    ToggleProgressBarSmooth():void=
        if(Settings.ProgressBar.SmoothUpdate = true):
            set Settings.ProgressBar.SmoothUpdate = false
        else:
            set Settings.ProgressBar.SmoothUpdate = true