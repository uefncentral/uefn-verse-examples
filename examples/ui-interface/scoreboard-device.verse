# Scoreboard Device
# Verse code for Scoreboard Device - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/scoreboard-device?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /Fortnite.com/Characters }

using { /Verse.org/Simulation }
using { /Verse.org/Colors }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }

custom_scoreboard_device := class(creative_device):

    @editable
    ScoreManager:score_manager_device = score_manager_device{}

    @editable
    MaxScoresToShow:int = 3

    @editable
    AutomaticClosingTime:float = 5.0

    @editable
    OptShowScoreboardTrigger:?trigger_device = false

    @editable
    OptHideScoreboardTrigger:?trigger_device = false

    @editable
    HeaderBackgroundColor:color = MakeColorFromHex("0075BDFF")

    @editable
    BodyBackgroundColor:color = MakeColorFromHex("919191FF")

    @editable
    SelfTextColor:color = NamedColors.Gold

    var ScoreboardPerAgent:[agent]widget = map{}

    # String to Message
    ScoreboardStringToMessage<localizes>(value:string) : message = "{value}"
    ScoreboardAgentToMessage<localizes>(value:agent) : message = "{value}"
    
    OnBegin<override>()<suspends>:void=
      Print("begin")
    ShowScoreboard(Agent:?agent)<suspends>:void=
        UnsortedPlayers := for(Player : GetPlayspace().GetPlayers()):
            PlayersScore := ScoreManager.GetCurrentScore(Player)
            agent_int_grouping{Agent := Player, Value := PlayersScore}

        SortedPlayers := Sort(UnsortedPlayers, false, CompareAgentInts)

        for(Player : GetPlayspace().GetPlayers()):
            AddScoreboard(Player, SortedPlayers)
        spawn{AwaitAutomaticClosing()}
        

    AwaitAutomaticClosing()<suspends>:void=
        Sleep(AutomaticClosingTime)
        HideScoreboard(false)
    HideScoreboard(Agent:?agent):void=
        for(Player->Canvas : ScoreboardPerAgent):
            Canvas.SetVisibility(widget_visibility.Hidden)
            Print("hiding")


    AddScoreboard(Agent:agent, SortedPlayerScores:[]agent_int_grouping)<suspends>:void=
 
        if:
            PlayerUI := GetPlayerUI[player[Agent]]
        then:
            RemoveUI(Agent)
            Sleep(0.1)
            Canvas := CreateScoreboard(Agent, SortedPlayerScores)
            PlayerUI.AddWidget(Canvas)
        

            if(set ScoreboardPerAgent[Agent] = Canvas){}
            

    RemoveUI(Agent:agent):void=
        if:
            PlayerUI := GetPlayerUI[player[Agent]]
            Canvas := ScoreboardPerAgent[Agent]
        then:
            Canvas.SetVisibility(widget_visibility.Hidden)

    CreateScoreboard(Agent:agent, SortedPlayerScores:[]agent_int_grouping):widget=
            HeaderPlacementTextBlock := text_block:
            DefaultTextColor := NamedColors.White
            DefaultShadowColor := NamedColors.Black
            DefaultShadowOffset := option{vector2{X := 2.0, Y := 2.0}}
            DefaultText := ScoreboardStringToMessage("#")
        HeaderPlacementTextBlock.SetShadowOpacity(1.0)

        HeaderPlayerTextBlock := text_block:
            DefaultTextColor := NamedColors.White
            DefaultShadowColor := NamedColors.Black
            DefaultShadowOffset := option{vector2{X := 2.0, Y := 2.0}}
            DefaultText := ScoreboardStringToMessage("PLAYER")
        HeaderPlayerTextBlock.SetShadowOpacity(1.0)

        HeaderScoreTextBlock := text_block:
            DefaultTextColor := NamedColors.White
            DefaultShadowColor := NamedColors.Black
            DefaultShadowOffset := option{vector2{X := 2.0, Y := 2.0}}
            DefaultText := ScoreboardStringToMessage("SCORE")
        HeaderScoreTextBlock.SetShadowOpacity(1.0)

        # Create Header
        HeaderStackBox := stack_box:
            Orientation := orientation.Horizontal
            Slots := array:
                # Placement Column
                stack_box_slot:
                    Padding := margin{Left := 5.0, Top := 5.0, Right := 5.0, Bottom := 5.0}
                    Widget := overlay:
                        Slots := array:
                            overlay_slot:
                                Widget := color_block:
                                    DefaultDesiredSize := vector2{X := 100.0, Y := 60.0}
                                    DefaultColor := HeaderBackgroundColor
                            overlay_slot:
                                Widget := HeaderPlacementTextBlock
                # Player Column
                stack_box_slot:
                    Padding := margin{Left := 5.0, Top := 5.0, Right := 5.0, Bottom := 5.0}
                    Widget := overlay:
                        Slots := array:
                            overlay_slot:
                                Widget := color_block:
                                    DefaultDesiredSize := vector2{X := 350.0, Y := 60.0}
                                    DefaultColor := HeaderBackgroundColor
                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Left
                                Padding := margin{Left := 10.0}
                                Widget := HeaderPlayerTextBlock
                # Score Column
                stack_box_slot:
                    Padding := margin{Left := 5.0, Top := 5.0, Right := 5.0, Bottom := 5.0}
                    Widget := overlay:
                        Slots := array:
                            overlay_slot:
                                Widget := color_block:
                                    DefaultDesiredSize := vector2{X := 150.0, Y := 60.0}
                                    DefaultColor := HeaderBackgroundColor
                            overlay_slot:
                                Widget := HeaderScoreTextBlock

        ScoreboardStackBox := stack_box:
            Orientation := orientation.Vertical
            Slots := array:
                stack_box_slot:
                    Widget := HeaderStackBox

        # Add top 3 players
        var InTopThree:logic = false
        for(Index->PlayerScore : SortedPlayerScores, Index < MaxScoresToShow):
            if(PlayerScore.Agent = Agent):
                set InTopThree = true

            IsSelf := PlayerScore.Agent = Agent and true or false

            BodyStackBoxSlot := CreateBody(PlayerScore.Agent, Index+1, PlayerScore.Value, IsSelf)
            ScoreboardStackBox.AddWidget(BodyStackBoxSlot)

        # If not in the top 3 show their score and placement as well
        if(not InTopThree?):
            for(Index->PlayerScore : SortedPlayerScores, PlayerScore.Agent = Agent):
                BodyStackBoxSlot := CreateBody(PlayerScore.Agent, Index+1, PlayerScore.Value, true)
                ScoreboardStackBox.AddWidget(BodyStackBoxSlot)
      
        MyCanvas := canvas:
            Slots := array:
                # Background
                canvas_slot:
                    Anchors := anchors{Minimum:=vector2{X:=0.0,Y:=0.0},Maximum:=vector2{X:=1.0,Y:=1.0}}
                    Offsets := margin{Left := 0.0, Top := 0.0}
                    Widget := color_block:
                        DefaultColor := NamedColors.Black
                        DefaultOpacity := 0.5
                # Scoreboard
                canvas_slot:
                    Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                    Offsets := margin{Left := 0.0, Top := 0.0}
                    Alignment := vector2{X:=0.5,Y:=0.5}
                    SizeToContent := true
                    Widget := ScoreboardStackBox

        return MyCanvas

    CreateBody(Agent:agent, Placement:int, Score:int, IsSelf:logic):stack_box_slot=
        PlayerTextColor := IsSelf? and SelfTextColor or NamedColors.White
        BodyStackBox := stack_box:
            Orientation := orientation.Horizontal
            Slots := array:
                # Placement Column
                stack_box_slot:
                    Padding := margin{Left := 5.0, Top := 5.0, Right := 5.0, Bottom := 5.0}
                    Widget := overlay:
                        Slots := array:
                            overlay_slot:
                                Widget := color_block:
                                    DefaultDesiredSize := vector2{X := 100.0, Y := 60.0}
                                    DefaultColor := BodyBackgroundColor
                            overlay_slot:
                                Widget := text_block:
                                    DefaultTextColor := PlayerTextColor
                                    DefaultText := ScoreboardStringToMessage("{Placement}")
                # Player Column
                stack_box_slot:
                    Padding := margin{Left := 5.0, Top := 5.0, Right := 5.0, Bottom := 5.0}
                    Widget := overlay:
                        Slots := array:
                            overlay_slot:
                                Widget := color_block:
                                    DefaultDesiredSize := vector2{X := 350.0, Y := 60.0}
                                    DefaultColor := BodyBackgroundColor
                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Left
                                Padding := margin{Left := 10.0}
                                Widget := text_block:
                                    DefaultTextColor := PlayerTextColor
                                    DefaultText := ScoreboardAgentToMessage(Agent)
                # Score Column
                stack_box_slot:
                    Padding := margin{Left := 5.0, Top := 5.0, Right := 5.0, Bottom := 5.0}
                    Widget := overlay:
                        Slots := array:
                            overlay_slot:
                                Widget := color_block:
                                    DefaultDesiredSize := vector2{X := 150.0, Y := 60.0}
                                    DefaultColor := BodyBackgroundColor
                            overlay_slot:
                                Widget := text_block:
                                    DefaultTextColor := PlayerTextColor
                                    DefaultText := ScoreboardStringToMessage("{Score}")

        return BodyStackBoxSlot := stack_box_slot:
            Widget := BodyStackBox

# Sorting
agent_int_grouping:= struct:
    Agent:agent
    Value:int

# Array Sorting
Sort(Items : []t, IsAscending : logic, Comparer: type{_(:t, :t)<transacts> : int} where t : type)<transacts> : []t = 
    if (Items.Length > 1, Pivot := Items[Floor(Items.Length/2)]):
        Left := for(Item : Items, Comparer(Item, Pivot) < 0) do Item 
        Middle := for(Item : Items, Comparer(Item, Pivot) = 0) do Item
        Right := for(Item : Items, Comparer(Item, Pivot) > 0) do Item
        if(IsAscending?):
            Sort(Left, IsAscending, Comparer) + Middle + Sort(Right, IsAscending, Comparer)
        else: 
            Sort(Right, IsAscending, Comparer) + Middle + Sort(Left, IsAscending, Comparer)
    else:    
        Items

CompareAgentInts(A : agent_int_grouping, B : agent_int_grouping)<transacts>: int =
    if(A.Value < B.Value) then -1
    else if(A.Value > B.Value) then 1
    else 0
