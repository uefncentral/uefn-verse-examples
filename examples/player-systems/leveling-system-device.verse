# Player Leveling System
# A persistent player progression system that tracks experience points and levels across game sessions. Players gain XP by interacting with triggers, level up automatically, and can customize their avat
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/leveling-system-device?ref=github


using { /Fortnite.com/UI }
using { /Fortnite.com/Devices }
using { /Verse.org/Assets }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

ModuleLevelingSystem<public> := module:

    persistable_agent_data<public> := class<final><persistable>:
        Level<public> : int
        Experience<public> : int
        AvatarIndex<public> : int

    agent_data<public> := class:
        var Level<public> : int = 1
        var Experience<public> : int = 0
        var bUpdateLevelBarUI<public> : logic = false
        var SelectedAvatarIndex<public> : int = 0

    trigger_experience_data<public> := class<concrete>:
        @editable
        ExperienceTrigger<public> : trigger_device = trigger_device{}
        @editable
        ExperienceAmount<public> : int = 0

        var MaybeMainDevice<public> : ?leveling_system_device = false

        OnTriggered<public>(MaybeAgent : ?agent):void=
            if (Agent := MaybeAgent?, MainDevice := MaybeMainDevice?):
                MainDevice.GrantExperience(Agent, ExperienceAmount)

    texture_selection_button_data<public> := class<concrete>:
        @editable
        ButtonDevice<public> : button_device = button_device{}

        var Index<public> : int = 0
        var MaybeMainDevice<public> : ?leveling_system_device = false

        OnInteractedWith<public>(Agent : agent):void=
            if (MainDevice := MaybeMainDevice?):
                MainDevice.OnAvatarSelected(Agent, Index)

    var PersistentAgentMap<public> : weak_map(player, persistable_agent_data) = map{}

    leveling_system_device<public> := class(creative_device):

        @editable
        PlayerSpawners : []player_spawner_device = array{}

        @editable
        TriggerExperiencesData : []trigger_experience_data = array{}

        @editable
        TextureSelectionButtonsData : []texture_selection_button_data = array{}

        @editable
        FirstLevelMaxExp<public>: int = 50

        @editable
        MaxExpIncreaseRatio<public> : float = 1.5

        @editable
        LevelBarFillDuration<public> : float = 4.0

        TextForUI<localizes>(InText : string) : message = "{InText}"
        DigitSize : vector2 = vector2{ X := 30.0, Y := 30.0 }

        var CanvasPerAgent<public> : [agent]canvas = map{}
        var AgentMap<public> : [agent]agent_data = map{}

        var bUIUpdateExists : logic = false

        OnBegin<override>()<suspends>:void=
            Print("OnBegin")

            for (Player : GetPlayspace().GetPlayers()):
                OnPlayerSpawned(Player)

            for (PlayerSpawner : PlayerSpawners):
                PlayerSpawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

            for (TriggerExperienceData : TriggerExperiencesData):
                set TriggerExperienceData.MaybeMainDevice = option{ Self }
                TriggerExperienceData.ExperienceTrigger.TriggeredEvent.Subscribe(TriggerExperienceData.OnTriggered)

            for (I := 0 .. TextureSelectionButtonsData.Length-1, TextureSelecionButtonData := TextureSelectionButtonsData[I]):
                set TextureSelecionButtonData.Index = I
                set TextureSelecionButtonData.MaybeMainDevice = option{ Self }
                TextureSelecionButtonData.ButtonDevice.InteractedWithEvent.Subscribe(TextureSelecionButtonData.OnInteractedWith)

            spawn{ AsyncUpdateLevelBarUI() }

        OnPlayerSpawned(Agent : agent):void=
            if (AgentData := AgentMap[Agent]):
            else:
                var bLoadDataSuccess : logic = false
                if (Player := player[Agent]):
                    if (PersistableAgentData := PersistentAgentMap[Player]):
                        if (set AgentMap[Agent] = AgentDataPersistentToTmp(PersistableAgentData)):
                            set bLoadDataSuccess = true

                if (bLoadDataSuccess = false):
                    if (set AgentMap[Agent] = agent_data{}){}

                if (AgentData := AgentMap[Agent], Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
                    Canvas := CreateLevelUI(AgentData)
                    PlayerUI.AddWidget(Canvas)

                    if (set CanvasPerAgent[Agent] = Canvas){}
                    OnAvatarSelected(Agent, AgentData.SelectedAvatarIndex)

        GrantExperience<public>(Agent : agent, ExperienceAmount : int):void=
            if (AgentData := AgentMap[Agent]):
                var bUpdateLevelText : logic = false

                set AgentData.Experience += ExperienceAmount
                loop:
                    if (AgentData.Experience > CalculateMaxExperienceForLevel(AgentData.Level)):
                        set AgentData.Level += 1
                        set bUpdateLevelText = true
                    else:
                        break

                if (Canvas := CanvasPerAgent[Agent], LevelBoxCanvas := canvas[Canvas.Slots[0].Widget]):
                    UpdateExperienceTexture(LevelBoxCanvas, AgentData.Experience, CalculateMaxExperienceForLevel(AgentData.Level))

                    if (bUpdateLevelText = true):
                        UpdateLevelTexture(LevelBoxCanvas, AgentData.Level)

                if (Player := player[Agent],
                set PersistentAgentMap[Player] = AgentDataTmpToPersistent(AgentData)){}

                set bUIUpdateExists = true
                set AgentData.bUpdateLevelBarUI = true

        AgentDataPersistentToTmp(PersistableAgentData : persistable_agent_data)<transacts>:agent_data=
            return agent_data
            {
                Level := PersistableAgentData.Level
                Experience := PersistableAgentData.Experience
                SelectedAvatarIndex := PersistableAgentData.AvatarIndex
            }

        AgentDataTmpToPersistent(AgentData : agent_data)<transacts>:persistable_agent_data=
            return persistable_agent_data
            {
                Level := AgentData.Level
                Experience := AgentData.Experience
                AvatarIndex := AgentData.SelectedAvatarIndex
            }

        CalculateMaxExperienceForLevel(Level : int)<transacts>:int=
            var ExperienceInt : int = 0
            if (ImExperienceInt := Int[FirstLevelMaxExp * Pow(Level*1.0, MaxExpIncreaseRatio)]):
                set ExperienceInt = ImExperienceInt
            return ExperienceInt

        GetAvatarTexture(Index : int)<transacts>:texture=
            case(Index):
                0 => Textures.T_Avatar1
                1 => Textures.T_Avatar2
                2 => Textures.T_Avatar3
                3 => Textures.T_Avatar4
                4 => Textures.T_Avatar5
                _ => Textures.T_Avatar1

        OnAvatarSelected<public>(Agent : agent, AvatarIndex : int):void=
            AvatarTextureBlockIndex := 5
            if (AgentData := AgentMap[Agent], AvatarTexture := GetAvatarTexture(AvatarIndex),
            Canvas := CanvasPerAgent[Agent], LevelBoxCanvas := canvas[Canvas.Slots[0].Widget],
            AvatarTextureBlock := texture_block[LevelBoxCanvas.Slots[AvatarTextureBlockIndex].Widget]):
                AvatarTextureBlock.SetImage(AvatarTexture)
                set AgentData.SelectedAvatarIndex = AvatarIndex
                if (Player := player[Agent],
                set PersistentAgentMap[Player] = AgentDataTmpToPersistent(AgentData)){}

        AsyncUpdateLevelBarUI()<suspends>:void=

            BGIndex := 3
            FGIndex := 4

            var LastTime : float = GetSimulationElapsedTime()
            loop:
                Sleep(0.0)

                CurrentTime := GetSimulationElapsedTime()
                DeltaTime := CurrentTime - LastTime
                set LastTime = CurrentTime

                if (bUIUpdateExists = true):
                    Players := GetPlayspace().GetPlayers()

                    var RemainingUpdates : int = 0
                    for (Player : Players, AgentData := AgentMap[Player], AgentData.bUpdateLevelBarUI = true,
                    Canvas := CanvasPerAgent[Player], LevelBoxCanvas := canvas[Canvas.Slots[0].Widget],
                    FGBlock := texture_block[LevelBoxCanvas.Slots[FGIndex].Widget],
                    BGBlock := texture_block[LevelBoxCanvas.Slots[BGIndex].Widget]):

                        FGBlockSize := FGBlock.GetDesiredSize()
                        BGBlockSize := BGBlock.GetDesiredSize()
                        CurrentExperienceRatioUI := FGBlockSize.X / BGBlockSize.X

                        PrevLevelMaxXP := CalculateMaxExperienceForLevel(AgentData.Level - 1) * 1.0
                        CurrentExperienceRatio := ((AgentData.Experience*1.0) - PrevLevelMaxXP) / ((CalculateMaxExperienceForLevel(AgentData.Level)*1.0) - PrevLevelMaxXP)
                        var TargetRatio : float = CurrentExperienceRatio

                        FGIncreaseRatio := 1.0 / (LevelBarFillDuration / DeltaTime)

                        var CurrentFGRatio : float = CurrentExperienceRatioUI + FGIncreaseRatio
                        var bMightContinue : logic = false

                        if (CurrentExperienceRatio < CurrentExperienceRatioUI):
                            set TargetRatio = 1.0
                            set bMightContinue = true

                            if (CurrentExperienceRatioUI >= 1.0):
                                set CurrentFGRatio = FGIncreaseRatio
                                set TargetRatio = CurrentExperienceRatio
                                set bMightContinue = false

                        if (CurrentFGRatio >= TargetRatio):
                            set CurrentFGRatio = TargetRatio
                            set AgentData.bUpdateLevelBarUI = bMightContinue

                        if (AgentData.bUpdateLevelBarUI = true):
                            set RemainingUpdates += 1

                        FGBlock.SetDesiredSize(vector2{ X := BGBlockSize.X * CurrentFGRatio, Y := BGBlockSize.Y })

                    if (RemainingUpdates = 0):
                        set bUIUpdateExists = false

        UpdateLevelTexture(MainCanvas : canvas, Level : int):void=
            LevelTextureSlotIndex := 1
            LevelNumberSlotIndex := 1

            if (LevelTextureCanvas := canvas[MainCanvas.Slots[LevelTextureSlotIndex].Widget],
            LevelTextureStackBox := stack_box[LevelTextureCanvas.Slots[0].Widget],
            LevelTextBlock := text_block[LevelTextureStackBox.Slots[LevelNumberSlotIndex].Widget]):
                LevelTextBlock.SetText(TextForUI("{Level}"))

        UpdateExperienceTexture(MainCanvas : canvas, Experience : int, MaxExperience : int):void=
            LevelTextureSlotIndex := 2

            if (ExperienceTextureCanvasSlot := MainCanvas.Slots[LevelTextureSlotIndex],
            ExperienceTextureCanvas := canvas[ExperienceTextureCanvasSlot.Widget],
            ExperienceTextureStackBox := stack_box[ExperienceTextureCanvas.Slots[0].Widget],
            ExperienceTextBlock := text_block[ExperienceTextureStackBox.Slots[0].Widget]):
                ExperienceTextBlock.SetText(TextForUI("{Experience}/{MaxExperience}"))

        CreateLevelUI(AgentData : agent_data):canvas=
            var CanvasSlots : []canvas_slot = array{}

            set CanvasSlots += array
            {
                CanvasSlot0 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.5, Y := 1.0 }, Maximum := vector2{ X := 0.5, Y := 1.0 } }
                    Offsets := margin{ Top := -80.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.5, Y := 1.0 }
                    ZOrder := 1
                    Widget := CreateLevelBox(AgentData)
            }

            Canvas : canvas = canvas:
                Slots := CanvasSlots

            return Canvas

        CreateLevelBox(AgentData : agent_data):canvas=
            var CanvasSlots : []canvas_slot = array{}

            BoxBGSizeX := 640.0

            BoxBGOriginalTransparentX := 1005.0
            BoxBGOriginalX := 1263.0
            BoxBGOriginalY := 207.0
            BoxBGYXRatio := BoxBGOriginalY / BoxBGOriginalX
            BoxBGSize : vector2 = vector2{ X := BoxBGSizeX, Y := BoxBGYXRatio * BoxBGSizeX }

            BoxBGTransparentRatio := BoxBGOriginalTransparentX / BoxBGOriginalX
            BarSizeX := BoxBGTransparentRatio * BoxBGSize.X
            set CanvasSlots += array
            {
                CanvasSlot0 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.0, Y := 0.0 }, Maximum := vector2{ X := 0.0, Y := 0.0 } }
                    Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.0, Y := 0.0 }
                    ZOrder := 2
                    Widget := texture_block{ DefaultImage := Textures.T_LevelBoxBG, DefaultDesiredSize := BoxBGSize }
            }

            set CanvasSlots += array
            {
                CanvasSlot1 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.0, Y := 0.5 }, Maximum := vector2{ X := 0.0, Y := 0.5 } }
                    Offsets := margin{ Top := -8.0, Left := 96.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.0, Y := 1.0 }
                    ZOrder := 2
                    Widget := CreateLevelTextureCanvas(AgentData.Level)
            }

            set CanvasSlots += array
            {
                CanvasSlot2 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 1.0, Y := 0.5 }, Maximum := vector2{ X := 1.0, Y := 0.5 } }
                    Offsets := margin{ Top := -8.0, Left := -32.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 1.0, Y := 1.0 }
                    ZOrder := 2
                    Widget := CreateExperienceTextureCanvas(AgentData.Experience, CalculateMaxExperienceForLevel(AgentData.Level))
            }

            set CanvasSlots += array
            {
                CanvasSlot3 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.0, Y := 0.0 }, Maximum := vector2{ X := 0.0, Y := 0.0 } }
                    Offsets := margin{ Top := 100.0, Left := 101.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.0, Y := 1.0 }
                    ZOrder := 0
                    Widget := texture_block{ DefaultImage := Textures.T_LevelBarBG, DefaultDesiredSize := vector2{ X := BarSizeX, Y := 40.0 } }
            }

            PrevLevelMaxXP := CalculateMaxExperienceForLevel(AgentData.Level-1)*1.0
            CurrentLevelMaxXP := CalculateMaxExperienceForLevel(AgentData.Level)*1.0
            FGRatio := ((AgentData.Experience*1.0) - PrevLevelMaxXP) / (CurrentLevelMaxXP - PrevLevelMaxXP)
            set CanvasSlots += array
            {
                CanvasSlot4 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.0, Y := 0.0 }, Maximum := vector2{ X := 0.0, Y := 0.0 } }
                    Offsets := margin{ Top := 100.0, Left := 101.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.0, Y := 1.0 }
                    ZOrder := 1
                    Widget := texture_block{ DefaultImage := Textures.T_LevelBar, DefaultDesiredSize := vector2{ X := FGRatio * BarSizeX, Y := 40.0 } }
            }

            set CanvasSlots += array
            {
                CanvasSlot5 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.0, Y := 0.5 }, Maximum := vector2{ X := 0.0, Y := 0.5 } }
                    Offsets := margin{ Top := -16.0, Left := 8.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.0, Y := 0.5 }
                    ZOrder := 2
                    Widget := texture_block{ DefaultImage := Textures.T_Avatar1, DefaultDesiredSize := vector2{ X := 80.0, Y := 80.0 } }
            }

            Canvas : canvas = canvas:
                Slots := CanvasSlots

            return Canvas

        CreateLevelTextureCanvas(Level : int):canvas=
            var CanvasSlots : []canvas_slot = array{}
            var StackBoxSlots : []stack_box_slot = array{}

            set StackBoxSlots += array
            {
                StackBoxSlot0 := stack_box_slot:
                    HorizontalAlignment := horizontal_alignment.Left
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Widget := texture_block{ DefaultImage := Textures.T_LevelText, DefaultDesiredSize := vector2{ X := DigitSize.X * 3, Y := DigitSize.Y } }
            }

            set StackBoxSlots += array
            {
                StackBoxSlot1 := stack_box_slot:
                    HorizontalAlignment := horizontal_alignment.Left
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{ Top := 2.0, Left := 8.0, Right := 0.0, Bottom := 0.0 }
                    Widget := text_block{ DefaultText := TextForUI("{Level}"), DefaultShadowColor := NamedColors.Black,
                    DefaultShadowOpacity := 1.0, DefaultShadowOffset := option{vector2{ X := 2.0, Y := 2.0 }}, DefaultTextColor := NamedColors.White }
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

        CreateExperienceTextureCanvas(Experience : int, MaxExperience : int):canvas=
            var CanvasSlots : []canvas_slot = array{}
            var StackBoxSlots : []stack_box_slot = array{}

            set StackBoxSlots += array
            {
                StackBoxSlot0 := stack_box_slot:
                    HorizontalAlignment := horizontal_alignment.Left
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{ Top := 2.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Widget := text_block{ DefaultText := TextForUI("{Experience}/{MaxExperience}"), DefaultShadowColor := NamedColors.Black,
                    DefaultShadowOpacity := 1.0, DefaultShadowOffset := option{vector2{ X := 2.0, Y := 2.0 }}, DefaultTextColor := NamedColors.White }
            }

            set StackBoxSlots += array
            {
                StackBoxSlot1 := stack_box_slot:
                    HorizontalAlignment := horizontal_alignment.Left
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{ Top := 0.0, Left := 8.0, Right := 0.0, Bottom := 0.0 }
                    Widget := texture_block{DefaultImage := Textures.T_XPText, DefaultDesiredSize := vector2{ X := DigitSize.X * 2.0, Y := DigitSize.Y }}
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
