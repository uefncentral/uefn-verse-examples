# Quick Time Hit System
# A resource gathering mini-game system that creates quick-time events when players interact with props. Players must hit timing windows to successfully collect resources and receive rewards through ite
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/quick-time-hit-device?ref=github


using { /Fortnite.com/UI }
using { /Fortnite.com/Devices }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

ModuleQTHit<public> := module:

    resource_prop_data := class<concrete>:
        @editable
        PropManipulator : prop_manipulator_device = prop_manipulator_device{}

        @editable
        TriggerVolume : volume_device = volume_device{}

        @editable
        ItemGranter : item_granter_device = item_granter_device{}

        @editable
        HitChance : type{F:float where 0.0 <= F, F <= 1.0} = 0.5

        @editable
        HitPieceNavigateSeconds : float = 3.0

        var MaybeMainDevice : ?quick_time_hit_device = false

        Init<public>(MainDevice : quick_time_hit_device):void=
            set MaybeMainDevice = option{ MainDevice }

            PropManipulator.DamagedEvent.Subscribe(OnPropDamaged)
            TriggerVolume.AgentEntersEvent.Subscribe(OnAgentEntered)
            TriggerVolume.AgentExitsEvent.Subscribe(MainDevice.OnAgentExited)

        OnPropDamaged(Agent : agent):void=
            if (MainDevice := MaybeMainDevice?, HitChanceF := float[HitChance]):
                MainDevice.OnPropDamaged(Agent, ItemGranter, HitChanceF)

        OnAgentEntered(Agent : agent):void=
            if (MainDevice := MaybeMainDevice?, HitChanceF := float[HitChance]):
                MainDevice.OnAgentEntered(Agent, HitChanceF, HitPieceNavigateSeconds)

    agent_data := class:
        var MaybeCanvas : ?canvas = false
        var HitState : int = -1
        var HitPieceNavigateSeconds : float = 0.0
        var CurrentHitPieceOffset : float = 0.0

    quick_time_hit_device := class(creative_device):

        @editable
        ResourcePropsData : []resource_prop_data = array{}

        var AgentMap : [agent]agent_data = map{}

        BlockSize : vector2 = vector2{ X := 512.0, Y := 40.0 }
        HitPieceWidth : float = 8.0

        OnBegin<override>()<suspends>:void=
            Print("OnBegin")

            for (ResourcePropData : ResourcePropsData):
                ResourcePropData.Init(Self)

            spawn{ AsyncHitTick() }

        OnPropDamaged(Agent : agent, ItemGranter : item_granter_device, HitChance : float):void=
            if (AgentData := AgentMap[Agent]):
                Offset := AgentData.CurrentHitPieceOffset

                MinOffset := BlockSize.X/2.0 - BlockSize.X*(HitChance/2.0)
                MaxOffset := BlockSize.X/2.0 + BlockSize.X*(HitChance/2.0)

                if ((Offset+HitPieceWidth >= MinOffset) and (Offset <= MaxOffset)):
                    ItemGranter.GrantItem(Agent)

        OnAgentEntered(Agent : agent, HitChance : float, HitPieceNavigateSeconds : float):void=
            if (Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
                Canvas := CreateCanvas(HitChance)
                PlayerUI.AddWidget(Canvas)

                if (set AgentMap[Agent] = agent_data{ MaybeCanvas := option{Canvas},
                HitState := 0, HitPieceNavigateSeconds := HitPieceNavigateSeconds }){}

        OnAgentExited(Agent : agent):void=
            if (Player := player[Agent], PlayerUI := GetPlayerUI[Player], AgentData := AgentMap[Agent],
            Canvas := AgentData.MaybeCanvas?):
                PlayerUI.RemoveWidget(Canvas)

                set AgentData.MaybeCanvas = false
                set AgentData.HitState = -1
                set AgentData.HitPieceNavigateSeconds = 0.0

        AsyncHitTick()<suspends>:void=

            var LastTime : float = GetSimulationElapsedTime()
            loop:
                Sleep(0.0)

                CurrentTime := GetSimulationElapsedTime()
                DeltaTime := CurrentTime - LastTime
                set LastTime = CurrentTime

                Players := GetPlayspace().GetPlayers()
                for (Player : Players, AgentData := AgentMap[Player], Canvas := AgentData.MaybeCanvas?,
                InnerCanvas := canvas[Canvas.Slots[0].Widget],
                HitPieceBlock := color_block[InnerCanvas.Slots[InnerCanvas.Slots.Length-1].Widget]):

                    StepRatio := DeltaTime / AgentData.HitPieceNavigateSeconds
                    StepSize := (BlockSize.X - HitPieceWidth) * StepRatio
                    StepSign := if (AgentData.HitState = 0)
                    then 1.0
                    else -1.0

                    CurrentOffset := AgentData.CurrentHitPieceOffset

                    HitPieceBlock.SetVisibility(widget_visibility.Collapsed)
                    InnerCanvas.RemoveWidget(HitPieceBlock)
                    HitPieceBlock.SetVisibility(widget_visibility.Visible)

                    var NewOffset : float = CurrentOffset + (StepSize * StepSign)

                    if (NewOffset >= (BlockSize.X-HitPieceWidth), AgentData.HitState = 0):
                        set AgentData.HitState = 1
                        set NewOffset = (BlockSize.X-HitPieceWidth)

                    else if (NewOffset <= 0.0, AgentData.HitState = 1):
                        set AgentData.HitState = 0
                        set NewOffset = 0.0

                    set AgentData.CurrentHitPieceOffset = NewOffset

                    CanvasSlot := canvas_slot:
                        Anchors := anchors{ Minimum := vector2{ X := 0.0, Y := 0.0}, Maximum := vector2{ X := 0.0, Y := 0.0} }
                        Offsets := margin{ Top := 0.0, Left := NewOffset, Right := 0.0, Bottom := 0.0 }
                        Alignment := vector2{ X := 0.0, Y := 0.0}
                        ZOrder := 2
                        SizeToContent := true
                        Widget := HitPieceBlock

                    InnerCanvas.AddWidget(CanvasSlot)

        CreateCanvas(HitChance : float):canvas=
            var CanvasSlots : []canvas_slot = array{}

            set CanvasSlots += array
            {
                CanvasSlot0 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.6, Y := 1.0}, Maximum := vector2{ X := 0.6, Y := 1.0} }
                    Offsets := margin{ Top := -112.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.5, Y := 1.0 }
                    ZOrder := 1
                    SizeToContent := true
                    Widget := CreateCanvasHitBar(HitChance)
            }

            Canvas : canvas = canvas:
                Slots := CanvasSlots

            return Canvas

        CreateCanvasHitBar(HitChance : float):canvas=
            var CanvasSlots : []canvas_slot = array{}

            set CanvasSlots += array
            {
                CanvasSlot0 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.0, Y := 0.0}, Maximum := vector2{ X := 0.0, Y := 0.0} }
                    Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.0, Y := 0.0 }
                    ZOrder := 1
                    SizeToContent := true
                    Widget := texture_block{ DefaultDesiredSize := BlockSize, DefaultImage := Textures.T_QTH_BG }
            }

            set CanvasSlots += array
            {
                CanvasSlot1 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.0, Y := 0.0}, Maximum := vector2{ X := 0.0, Y := 0.0} }
                    Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.0, Y := 0.0 }
                    ZOrder := 1
                    SizeToContent := true
                    Widget := texture_block{ DefaultDesiredSize := BlockSize, DefaultImage := Textures.T_QTH_MG }
            }

            set CanvasSlots += array
            {
                CanvasSlot2 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.5, Y := 0.0}, Maximum := vector2{ X := 0.5, Y := 0.0} }
                    Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.5, Y := 0.0 }
                    ZOrder := 1
                    SizeToContent := true
                    Widget := texture_block{ DefaultDesiredSize := vector2{ X := HitChance*BlockSize.X, Y := BlockSize.Y },
                    DefaultImage := Textures.T_QTH_FG }
            }

            set CanvasSlots += array
            {
                CanvasSlot3 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.0, Y := 0.0}, Maximum := vector2{ X := 0.0, Y := 0.0} }
                    Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.0, Y := 0.0 }
                    ZOrder := 2
                    SizeToContent := true
                    Widget := color_block{ DefaultDesiredSize := vector2{ X := HitPieceWidth, Y := BlockSize.Y },
                    DefaultColor := NamedColors.White }
            }

            Canvas : canvas = canvas:
                Slots := CanvasSlots

            return Canvas