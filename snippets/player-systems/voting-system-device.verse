# Map Location Voting System
# Creates an interactive voting interface where players can vote for different map locations (Summit, Echo, Cove, Peak, Forge) within a time limit. The system displays voting options with custom texture
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/voting-system-device?ref=github


using { /Fortnite.com/UI }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Assets }
using { /Verse.org/Colors }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }

ModuleVotingSystem<public> := module:

    int_param_container := class:
        IntegerParam<public> : int
        MainDevice<public> : voting_system_device

        ButtonClick<public>(WidgetMessage : widget_message):void=
            MainDevice.OnVoteClicked(WidgetMessage, IntegerParam)

    voting_system_device := class(creative_device):

        @editable
        VoteStartTrigger : trigger_device = trigger_device{}

        @editable
        VoteDurationSeconds : int = 10

        @editable
        Teleporters : []teleporter_device = array{}

        TextForUI<localizes>(InText : string) : message = "{InText}"

        # (FROZEN PAWN): Fill this tuple array with the desired
        # location texture - location name
        # IMPORTANT: !Teleporters must match the tuple data here!
        VotesData : []tuple(texture, string) = array
        {
            (Textures.T_VoteSummit, "SUMMIT"),
            (Textures.T_VoteEcho, "ECHO"),
            (Textures.T_VoteCove, "COVE"),
            (Textures.T_VotePeak, "PEAK"),
            (Textures.T_VoteForge, "FORGE")
        }

        var CanvasPerPlayer : [player]canvas = map{}
        var CastedVotes : []int = array{}
        var CastedVotePerAgent : [agent]int = map{}
        var CurrentVoteTeleporters : []teleporter_device = array{}
        var bVoteAlive : logic = false

        OnBegin<override>()<suspends>:void=
            Print("OnBegin")

            VoteStartTrigger.TriggeredEvent.Subscribe(OnVoteStartTriggered)

        GetFormattedTimeString(TimeInSecs : int)<transacts>:string=
            var FormattedTimeString : string = ""

            MinuteTime := (TimeInSecs *1.0) / 60.0
            if (FlooredMinuteTime := Floor[MinuteTime]):

                if (FlooredMinuteTime < 10):
                    set FormattedTimeString += "0"
                set FormattedTimeString += "{FlooredMinuteTime}:"

                RemainingSecondsTime := MinuteTime - (FlooredMinuteTime*1.0)
                SecondsTime := RemainingSecondsTime * 60.0
                if (FlooredSecondsTime := Floor[SecondsTime]):

                    if (FlooredSecondsTime < 10):
                        set FormattedTimeString += "0"
                    set FormattedTimeString += "{FlooredSecondsTime}"

            return FormattedTimeString

        OnVoteStartTriggered(MaybeAgent : ?agent):void=
            if (bVoteAlive = true):
                return

            set bVoteAlive = true
            var Indexes : []int = array{}
            for (I := 0..VotesData.Length-1):
                set Indexes += array{ I }

            ShuffledIndexes := Shuffle(Indexes)
            VotesToSelect := 3

            var SelectedVotesData : []tuple(texture, string) = array{}
            set CanvasPerPlayer = map{}
            set CurrentVoteTeleporters = array{}
            set CastedVotes = array{}

            for (I := 1..VotesToSelect, Index := ShuffledIndexes[I-1], VoteData := VotesData[Index], Teleporter := Teleporters[Index]):
                set SelectedVotesData += array{ (VoteData(0), VoteData(1)) }
                set CurrentVoteTeleporters += array{ Teleporter }
                set CastedVotes += array{ 0 }

            Players := GetPlayspace().GetPlayers()
            for (Player : Players, PlayerUI := GetPlayerUI[Player]):
                Canvas := CreateCanvasVote(SelectedVotesData)
                PlayerUI.AddWidget(Canvas, player_ui_slot{ InputMode := ui_input_mode.All })

                if (set CanvasPerPlayer[Player] = Canvas){}
                if (set CastedVotePerAgent[Player] = -1){}

            spawn{ AsyncCountdown(CurrentVoteTeleporters, SelectedVotesData) }

        OnExitClicked(WidgetMessage : widget_message):void=
            if (Canvas := CanvasPerPlayer[WidgetMessage.Player], PlayerUI := GetPlayerUI[WidgetMessage.Player]):
                PlayerUI.RemoveWidget(Canvas)

        OnVoteClicked(WidgetMessage : widget_message, VoteIndex : int):void=

            if (OldVoteIndex := CastedVotePerAgent[WidgetMessage.Player],
            set CastedVotes[OldVoteIndex] -= 1){}

            if (set CastedVotePerAgent[WidgetMessage.Player] = VoteIndex){}
            if (set CastedVotes[VoteIndex] += 1){}

            for (Canvas : CanvasPerPlayer):
                UpdateVoteCounts(Canvas)

        UpdateVoteCounts(VoteCanvas : canvas):void=
            if (VoteCanvasInner := canvas[VoteCanvas.Slots[0].Widget],
            VoteWindowsCanvas := canvas[stack_box[VoteCanvasInner.Slots[0].Widget].Slots[1].Widget],
            VoteWindowsStackBoxSlots := stack_box[VoteWindowsCanvas.Slots[0].Widget].Slots):

                for (I := 0..VoteWindowsStackBoxSlots.Length-1,
                VoteWindowTextBlock := text_block[canvas[VoteWindowsStackBoxSlots[I].Widget].Slots[3].Widget],
                CastedVote := CastedVotes[I]):
                    VoteWindowTextBlock.SetText(TextForUI("{CastedVote}"))

        AsyncCountdown(VoteTeleporters : []teleporter_device, SelectedVotesData : []tuple(texture, string))<suspends>:void=
            var RemainingSeconds : int = VoteDurationSeconds
            loop:
                Sleep(1.0)

                set RemainingSeconds -= 1
                if (RemainingSeconds = -1):
                    break

                Players := GetPlayspace().GetPlayers()
                for (Player : Players, Canvas := CanvasPerPlayer[Player], VoteCanvasInner := canvas[Canvas.Slots[0].Widget],
                CountdownCanvas := canvas[stack_box[VoteCanvasInner.Slots[0].Widget].Slots[0].Widget],
                CountdownTextBlock := text_block[CountdownCanvas.Slots[2].Widget]):
                    CountdownTextBlock.SetText(TextForUI(GetFormattedTimeString(RemainingSeconds)))

            Players2 := GetPlayspace().GetPlayers()
            for (Player : Players2, PlayerUI := GetPlayerUI[Player], Canvas := CanvasPerPlayer[Player]):
                PlayerUI.RemoveWidget(Canvas)

            var MaxVote : int = -1
            for (CastedVote : CastedVotes):
                if (CastedVote > MaxVote):
                    set MaxVote = CastedVote

            var MaxVoteIndexes : []int = array{}
            for (I := 0 .. CastedVotes.Length-1, CastedVote := CastedVotes[I]):
                if (CastedVote = MaxVote):
                    set MaxVoteIndexes += array{ I }

            set MaxVoteIndexes = Shuffle(MaxVoteIndexes)
            if (MaxVoteIndex := MaxVoteIndexes[0], VoteTeleporter := VoteTeleporters[MaxVoteIndex]):

                for (Player : Players2):
                    VoteTeleporter.Teleport(Player)

            set bVoteAlive = false

        CreateCanvasVote(VoteDataTuples : []tuple(texture, string)):canvas=
            var CanvasSlots : []canvas_slot = array{}

            set CanvasSlots += array
            {
                CanvasSlot0 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.5, Y := 0.5 }, Maximum := vector2{ X := 0.5, Y := 0.5 } }
                    Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.5, Y := 0.5 }
                    ZOrder := 1
                    SizeToContent := true
                    Widget := CreateCanvasVoteInner(VoteDataTuples)
            }

            Canvas : canvas = canvas:
                Slots := CanvasSlots

            return Canvas

        CreateCanvasVoteInner(VoteDataTuples : []tuple(texture, string)):canvas=
            var CanvasSlots : []canvas_slot = array{}
            var StackBoxSlots : []stack_box_slot = array{}

            set StackBoxSlots += array
            {
                StackBoxSlot0 := stack_box_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Widget := CreateCanvasCountdown(VoteDurationSeconds)
            }

            set StackBoxSlots += array
            {
                StackBoxSlot1 := stack_box_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{ Top := 48.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Widget := CreateCanvasVoteWindows(VoteDataTuples)
            }

            set StackBoxSlots += array
            {
                StackBoxSlot2 := stack_box_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{ Top := 48.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Widget := button_regular{ DefaultText := TextForUI("EXIT") }
            }
            if (ButtonRegular := button_regular[StackBoxSlots[StackBoxSlots.Length-1].Widget]):
                ButtonRegular.OnClick().Subscribe(OnExitClicked)

            set CanvasSlots += array
            {
                CanvasSlot0 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.0, Y := 0.0 }, Maximum := vector2{ X := 0.0, Y := 0.0 } }
                    Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.0, Y := 0.0 }
                    ZOrder := 1
                    SizeToContent := true
                    Widget := stack_box:
                        Orientation := orientation.Vertical
                            Slots := StackBoxSlots
            }
            
            Canvas : canvas = canvas:
                Slots := CanvasSlots

            return Canvas

        CreateCanvasCountdown(DurationSeconds : int):canvas=
            var CanvasSlots : []canvas_slot = array{}

            WindowSize := vector2{ X := 360.0, Y := 100.0 }
            set CanvasSlots += array
            {
                CanvasSlot0 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.0, Y := 0.0 }, Maximum := vector2{ X := 0.0, Y := 0.0 } }
                    Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.0, Y := 0.0 }
                    ZOrder := 1
                    SizeToContent := true
                    Widget := texture_block{ DefaultImage := Textures.T_VoteWindow, DefaultDesiredSize := WindowSize }
            }

            set CanvasSlots += array
            {
                CanvasSlot1 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.5, Y := 0.0 }, Maximum := vector2{ X := 0.5, Y := 0.0 } }
                    Offsets := margin{ Top := 10.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.5, Y := 0.0 }
                    ZOrder := 1
                    SizeToContent := true
                    Widget := text_block{ DefaultText := TextForUI("Vote For a Map"), DefaultShadowColor := NamedColors.Black,
                    DefaultShadowOpacity := 1.0, DefaultShadowOffset := option{vector2{ X := 2.0, Y := 2.0 }}, DefaultTextColor := NamedColors.White }
            }

            set CanvasSlots += array
            {
                CanvasSlot2 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.5, Y := 1.0 }, Maximum := vector2{ X := 0.5, Y := 1.0 } }
                    Offsets := margin{ Top := -14.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.5, Y := 1.0 }
                    ZOrder := 1
                    SizeToContent := true
                    Widget := text_block{ DefaultText := TextForUI(GetFormattedTimeString(DurationSeconds)), DefaultShadowColor := NamedColors.Black,
                    DefaultShadowOpacity := 1.0, DefaultShadowOffset := option{vector2{ X := 2.0, Y := 2.0 }}, DefaultTextColor := NamedColors.White }
            }

            Canvas : canvas = canvas:
                Slots := CanvasSlots

            return Canvas

        CreateCanvasVoteWindows(VoteDataTuples : []tuple(texture, string)):canvas=
            var CanvasSlots : []canvas_slot = array{}
            var StackBoxSlots : []stack_box_slot = array{}

            for (VoteIndex := 0..VoteDataTuples.Length-1, VoteDataTuple := VoteDataTuples[VoteIndex]):
                VoteTexture : texture = VoteDataTuple(0)
                VoteString : string = VoteDataTuple(1)

                LeftOffset : float = if (VoteIndex = 0)
                then 0.0
                else 32.0

                set StackBoxSlots += array
                {
                    StackBoxSlot0 := stack_box_slot:
                        HorizontalAlignment := horizontal_alignment.Left
                        VerticalAlignment := vertical_alignment.Center
                        Padding := margin{ Top := 0.0, Left := LeftOffset, Right := 0.0, Bottom := 0.0 }
                        Widget := CreateCanvasVoteWindow(VoteTexture, VoteString, VoteIndex)
                }

            set CanvasSlots += array
            {
                CanvasSlot0 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.0, Y := 0.0 }, Maximum := vector2{ X := 0.0, Y := 0.0 } }
                    Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.0, Y := 0.0 }
                    ZOrder := 1
                    SizeToContent := true
                    Widget := stack_box:
                        Orientation := orientation.Horizontal
                            Slots := StackBoxSlots
            }
            
            Canvas : canvas = canvas:
                Slots := CanvasSlots

            return Canvas

        CreateCanvasVoteWindow(VoteImage : texture, VoteString : string, VoteIndex : int):canvas=
            var CanvasSlots : []canvas_slot = array{}

            WindowSize := vector2{ X := 390.0, Y := 580.0 }
            set CanvasSlots += array
            {
                CanvasSlot0 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.0, Y := 0.0 }, Maximum := vector2{ X := 0.0, Y := 0.0 } }
                    Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.0, Y := 0.0 }
                    ZOrder := 1
                    SizeToContent := true
                    Widget := texture_block{ DefaultImage := Textures.T_VoteWindow, DefaultDesiredSize := WindowSize }
            }

            ImageSize := vector2{ X := 370.0, Y := 460.0 }
            set CanvasSlots += array
            {
                CanvasSlot1 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.5, Y := 0.0 }, Maximum := vector2{ X := 0.5, Y := 0.0 } }
                    Offsets := margin{ Top := 14.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.5, Y := 0.0 }
                    ZOrder := 1
                    SizeToContent := true
                    Widget := texture_block{ DefaultImage := VoteImage, DefaultDesiredSize := ImageSize }
            }

            set CanvasSlots += array
            {
                CanvasSlot2 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.5, Y := 1.0 }, Maximum := vector2{ X := 0.5, Y := 1.0 } }
                    Offsets := margin{ Top := -16.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.5, Y := 1.0 }
                    ZOrder := 1
                    SizeToContent := true
                    Widget := button_regular{ DefaultText := TextForUI(VoteString) }
            }
            if (ButtonRegular := button_regular[CanvasSlots[CanvasSlots.Length-1].Widget]):
                ButtonRegular.OnClick().Subscribe(int_param_container{ IntegerParam := VoteIndex, MainDevice := Self}.ButtonClick )

            set CanvasSlots += array
            {
                CanvasSlot3 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 1.0, Y := 0.0 }, Maximum := vector2{ X := 1.0, Y := 0.0 } }
                    Offsets := margin{ Top := 20.0, Left := -18.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 1.0, Y := 0.0 }
                    ZOrder := 1
                    SizeToContent := true
                    Widget := text_block{ DefaultText := TextForUI("0"), DefaultShadowColor := NamedColors.Black,
                    DefaultShadowOpacity := 1.0, DefaultShadowOffset := option{vector2{ X := 2.0, Y := 2.0 }}, DefaultTextColor := NamedColors.White }
            }

            Canvas : canvas = canvas:
                Slots := CanvasSlots

            return Canvas