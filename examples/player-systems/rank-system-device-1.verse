# Player Rank System
# A comprehensive ranking system that tracks player points through trigger interactions and displays visual rank progression with multiple tiers from Unranked to Unreal. The system includes persistent d
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/rank-system-device-1?ref=github


using { /Verse.org/Assets }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }
using { /Fortnite.com/UI }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }

RankSystemModule := module:

    var PersistentAgentMap : weak_map(player, persistable_agent_data) = map{}

    persistable_agent_data := class<final><persistable>:
        Points : int = 0

    agent_data := class:
        var Points : int = 0

        var PointRatios : []float = array
        {
            0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.0
        }
        var LatestPointIndex : int = 0
        var LatestPointIndexUI : int = 0

        var MaybeCanvas : ?canvas = false

    PointRatiosLen : int = 8

    point_data := class<concrete>:
        @editable
        PointTrigger : trigger_device = trigger_device{}

        @editable
        Points : int = 0

        var MaybeMainDevice : ?rank_system_device = false
        OnPointTriggered(MaybeAgent : ?agent):void=
            if (MainDevice := MaybeMainDevice?, Agent := MaybeAgent?):
                MainDevice.UpdatePoints(Agent, Points)

    rank := enum:
        Unranked,
        Bronze1,
        Bronze2,
        Bronze3,
        Silver1,
        Silver2,
        Silver3,
        Gold1,
        Gold2,
        Gold3,
        Platinum1,
        Platinum2,
        Platinum3,
        Diamond1,
        Diamond2,
        Diamond3,
        Elite,
        Champion,
        Unreal

    rank_system_device := class(creative_device):

        @editable
        PlayerSpawners : []player_spawner_device = array{}

        @editable
        PointsData : []point_data = array{}

        @editable
        RankBarFillDuration : float = 4.0

        @editable
        FillBarColorR : type { _X:int where 0 <= _X, _X <= 255 } = 0
        @editable
        FillBarColorG : type { _X:int where 0 <= _X, _X <= 255 } = 0
        @editable
        FillBarColorB : type { _X:int where 0 <= _X, _X <= 255 } = 0

        @editable
        UnrankedPointsToFinish : type { _X:int where 1 <= _X } = 1
        @editable
        Bronze1PointsToFinish : type { _X:int where 1 <= _X } = 1
        @editable
        Bronze2PointsToFinish : type { _X:int where 1 <= _X } = 1
        @editable
        Bronze3PointsToFinish : type { _X:int where 1 <= _X } = 1
        @editable
        Silver1PointsToFinish : type { _X:int where 1 <= _X } = 1
        @editable
        Silver2PointsToFinish : type { _X:int where 1 <= _X } = 1
        @editable
        Silver3PointsToFinish : type { _X:int where 1 <= _X } = 1
        @editable
        Gold1PointsToFinish : type { _X:int where 1 <= _X } = 1
        @editable
        Gold2PointsToFinish : type { _X:int where 1 <= _X } = 1
        @editable
        Gold3PointsToFinish : type { _X:int where 1 <= _X } = 1
        @editable
        Platinum1PointsToFinish : type { _X:int where 1 <= _X } = 1
        @editable
        Platinum2PointsToFinish : type { _X:int where 1 <= _X } = 1
        @editable
        Platinum3PointsToFinish : type { _X:int where 1 <= _X } = 1
        @editable
        Diamond1PointsToFinish : type { _X:int where 1 <= _X } = 1
        @editable
        Diamond2PointsToFinish : type { _X:int where 1 <= _X } = 1
        @editable
        Diamond3PointsToFinish : type { _X:int where 1 <= _X } = 1
        @editable
        ElitePointsToFinish : type { _X:int where 1 <= _X } = 1
        @editable
        ChampionPointsToFinish : type { _X:int where 1 <= _X } = 1
        @editable
        UnrealPointsToFinish : type { _X:int where 1 <= _X } = 1

        @editable
        OnRankUpgraded : trigger_device = trigger_device{}
        @editable
        OnRankDowngraded : trigger_device = trigger_device{}

        @editable
        bUseSave : logic = true

        RankNames : []string = array
        {
            "Unranked",
            "Bronze 1", "Bronze 2", "Bronze 3",
            "Silver 1", "Silver 2", "Silver 3",
            "Gold 1", "Gold 2", "Gold 3",
            "Platinum 1", "Platinum 2", "Platinum 3",
            "Diamond 1", "Diamond 2", "Diamond 3",
            "Elite",
            "Champion",
            "Unreal"
        }

        RankColors : []color = array
        {
            MakeColorFromSRGBValues(120, 120, 120), # Unranked
            MakeColorFromSRGBValues(210, 125, 50),  # Bronze1
            MakeColorFromSRGBValues(210, 125, 50),  # Bronze2
            MakeColorFromSRGBValues(210, 125, 50),  # Bronze3
            MakeColorFromSRGBValues(130, 130, 150), # Silver1
            MakeColorFromSRGBValues(130, 130, 150), # Silver2
            MakeColorFromSRGBValues(130, 130, 150), # Silver3
            MakeColorFromSRGBValues(240, 180, 50),  # Gold1
            MakeColorFromSRGBValues(240, 180, 50),  # Gold2
            MakeColorFromSRGBValues(240, 180, 50),  # Gold3
            MakeColorFromSRGBValues(150, 225, 210), # Platinum1
            MakeColorFromSRGBValues(150, 225, 210), # Platinum2
            MakeColorFromSRGBValues(150, 225, 210), # Platinum3
            MakeColorFromSRGBValues(100, 180, 255), # Diamond1
            MakeColorFromSRGBValues(100, 180, 255), # Diamond2
            MakeColorFromSRGBValues(100, 180, 255), # Diamond3
            MakeColorFromSRGBValues(85, 135, 120),  # Elite
            MakeColorFromSRGBValues(220, 60, 45),   # Champion
            MakeColorFromSRGBValues(150, 225, 255)  # Unreal
        }

        Ranks : []rank = array
        {
            rank.Unranked,
            rank.Bronze1, rank.Bronze2, rank.Bronze3,
            rank.Silver1, rank.Silver2, rank.Silver3,
            rank.Gold1, rank.Gold2, rank.Gold3,
            rank.Platinum1, rank.Platinum2, rank.Platinum3,
            rank.Diamond1, rank.Diamond2, rank.Diamond3,
            rank.Elite,
            rank.Champion,
            rank.Unreal
        }

        TextForUI<localizes>(InText : string) : message = "{InText}"

        var RankStartPoints : []int = array{}
        var PointsToFinish : []int = array{}
        var AgentMap : [agent]agent_data = map{}

        OnBegin<override>()<suspends>:void=
            Print("OnBegin")

            set PointsToFinish = array { UnrankedPointsToFinish,
            Bronze1PointsToFinish, Bronze2PointsToFinish, Bronze3PointsToFinish,
            Silver1PointsToFinish, Silver2PointsToFinish, Silver3PointsToFinish,
            Gold1PointsToFinish, Gold2PointsToFinish, Gold3PointsToFinish,
            Platinum1PointsToFinish, Platinum2PointsToFinish, Platinum3PointsToFinish,
            Diamond1PointsToFinish, Diamond2PointsToFinish, Diamond3PointsToFinish,
            ElitePointsToFinish,
            ChampionPointsToFinish,
            UnrealPointsToFinish }

            set RankStartPoints = array{ 0 }
            for (I := 1 .. EnumToInt(rank.Unreal)):

                var TotalPointsToFinish : int = 0
                for (J := 0 .. I-1, PointToFinish := PointsToFinish[J]):
                    set TotalPointsToFinish += PointToFinish

                set RankStartPoints += array{ TotalPointsToFinish }

            for (Player : GetPlayspace().GetPlayers()):
                OnPlayerSpawned(Player)

            for (PlayerSpawner : PlayerSpawners):
                PlayerSpawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

            for (PointData : PointsData):
                set PointData.MaybeMainDevice = option{ Self }
                PointData.PointTrigger.TriggeredEvent.Subscribe(PointData.OnPointTriggered)

            spawn { AsyncUpdateRankBarUI() }

        UpdatePoints(Agent : agent, Points : int, ?OverrideRankChange : int = 0):void=
            Print("UpdatePoints: {Points}")

            if (AgentData := AgentMap[Agent]):
                var NewPoints : int = AgentData.Points + Points
                if (NewPoints < 0):
                    set NewPoints = 0

                var RankChange : int = OverrideRankChange

                PreviousRankIndex : int = GetRankIndexFromPoints(AgentData.Points)
                RankIndex : int = GetRankIndexFromPoints(NewPoints)

                set AgentData.Points = NewPoints
                if (bUseSave = true, Player := player[Agent]):
                    if (set PersistentAgentMap[Player] = AgentDataTmpToPersistent(AgentData)){}

                if (PreviousRankIndex <> RankIndex):                    

                    if (RankIndex > PreviousRankIndex):                        
                        OnRankUpgraded.Trigger(Agent)
                        set RankChange = 1

                    else if (RankIndex < PreviousRankIndex):
                        OnRankDowngraded.Trigger(Agent)
                        set RankChange = -1

                RankImageIndex := 1
                RankTextIndex := 5
                PercentageTextIndex := 4
                if (Canvas := AgentData.MaybeCanvas?, RankCanvas := canvas[Canvas.Slots[0].Widget],
                RankTextureBlock := texture_block[RankCanvas.Slots[RankImageIndex].Widget],
                RankTextBlock := text_block[RankCanvas.Slots[RankTextIndex].Widget],
                PercentageText := text_block[RankCanvas.Slots[PercentageTextIndex].Widget],
                RankStartPoint := RankStartPoints[RankIndex],
                NextRankStartPoint := RankStartPoint + PointsToFinish[RankIndex]):
                    Print("Access Branch")

                    # (frozenpawn): Update the percentage text.
                    PrevRankMaxPoint := RankStartPoint*1.0
                    RankMaxPoint := NextRankStartPoint*1.0
                    CurrentPointsRatio := (AgentData.Points*1.0 - PrevRankMaxPoint) / (RankMaxPoint - PrevRankMaxPoint)
                    ClampedRatio := Clamp(CurrentPointsRatio, 0.0, 1.0)

                    # NOTE(frozenpawn): Rank change case.
                    if (OverrideRankChange = 0):
                        if (RankChange = 1):
                            if (set AgentData.PointRatios[AgentData.LatestPointIndex] = 1.0){}

                            set AgentData.LatestPointIndex += 1
                            if (AgentData.LatestPointIndex >= PointRatiosLen):
                                set AgentData.LatestPointIndex = 0

                            if (set AgentData.PointRatios[AgentData.LatestPointIndex] = 0.01){}

                        else if (RankChange = -1):
                            if (set AgentData.PointRatios[AgentData.LatestPointIndex] = -0.01){}

                            set AgentData.LatestPointIndex += 1
                            if (AgentData.LatestPointIndex >= PointRatiosLen):
                                set AgentData.LatestPointIndex = 0

                            if (set AgentData.PointRatios[AgentData.LatestPointIndex] = -1.0){}

                        if (RankChange <> 0):
                            set AgentData.LatestPointIndex += 1
                            if (AgentData.LatestPointIndex >= PointRatiosLen):
                                set AgentData.LatestPointIndex = 0

                        # NOTE(frozenpawn): Usual point change.
                        Sign : float = Sgn(Points)*1.0
                        if (set AgentData.PointRatios[AgentData.LatestPointIndex] = Sign*ClampedRatio){}

                        set AgentData.LatestPointIndex += 1
                        if (AgentData.LatestPointIndex >= PointRatiosLen):
                            set AgentData.LatestPointIndex = 0

                    if (CurrentPointsPercentage := Int[CurrentPointsRatio*100.0]):
                        Clamped := Clamp(CurrentPointsPercentage, 0, 100)
                        PercentageText.SetText(TextForUI("%{Clamped}"))

                    # (frozenpawn): If rank has been changed, update the rank text and image.
                    if (RankChange <> 0, Rank := Ranks[RankIndex],
                    RankName := RankNames[RankIndex]):
                        RankTextureBlock.SetImage(EnumToTexture(Rank))
                        RankTextBlock.SetText(TextForUI(RankName))

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

                if (Player := player[Agent], PlayerUI := GetPlayerUI[Player], AgentData := AgentMap[Agent]):
                    CustomCanvas := CreateCanvas()
                    PlayerUI.AddWidget(CustomCanvas)

                    set AgentData.MaybeCanvas = option{ CustomCanvas }
                    if (AgentData.Points > 0):
                        UpdatePoints(Agent, 0, ?OverrideRankChange := 1)
                        
                        RankBarBGIndex := 2
                        RankBarFGIndex := 3
                        RankIndex : int = GetRankIndexFromPoints(AgentData.Points)

                        if (RankCanvas := canvas[CustomCanvas.Slots[0].Widget],
                        BGBlock := texture_block[RankCanvas.Slots[RankBarBGIndex].Widget],
                        FGBlock := color_block[RankCanvas.Slots[RankBarFGIndex].Widget],
                        RankStartPoint := RankStartPoints[RankIndex],
                        NextRankStartPoint := RankStartPoint + PointsToFinish[RankIndex]):

                            PrevRankMaxPoint := RankStartPoint*1.0
                            RankMaxPoint := NextRankStartPoint*1.0
                            CurrentPointsRatio := (AgentData.Points*1.0 - PrevRankMaxPoint) / (RankMaxPoint - PrevRankMaxPoint)
                            ClampedRatio := Clamp(CurrentPointsRatio, 0.0, 1.0)

                            FGBlockSize := FGBlock.GetDesiredSize()
                            BGBlockSizeY := BGBlock.GetDesiredSize().Y
                            FGBlock.SetDesiredSize(vector2{ X := FGBlockSize.X, Y := BGBlockSizeY * ClampedRatio })

        AgentDataPersistentToTmp(PersistableAgentData : persistable_agent_data)<transacts>:agent_data=
            return agent_data
            {
                Points := PersistableAgentData.Points
            }

        AgentDataTmpToPersistent(AgentData : agent_data)<transacts>:persistable_agent_data=
            return persistable_agent_data
            {
                Points := AgentData.Points
            }

        GetRankIndexFromPoints(Points : int)<transacts>:int=
            for (Index := EnumToInt(rank.Bronze1) .. EnumToInt(rank.Unreal), StartPoint := RankStartPoints[Index]):
                if (Points < StartPoint):
                    return (Index-1)

            return EnumToInt(rank.Unreal)

        AsyncUpdateRankBarUI()<suspends>:void=

            RankBarBGIndex := 2
            RankBarFGIndex := 3

            var LastTime : float = GetSimulationElapsedTime()
            loop:
                Sleep(0.0)

                CurrentTime := GetSimulationElapsedTime()
                DeltaTime := CurrentTime - LastTime
                set LastTime = CurrentTime

                Players := GetPlayspace().GetPlayers()
                for (Player : Players, AgentData := AgentMap[Player],
                AgentData.LatestPointIndex <> AgentData.LatestPointIndexUI,
                Canvas := AgentData.MaybeCanvas?, RankCanvas := canvas[Canvas.Slots[0].Widget],
                BGBlock := texture_block[RankCanvas.Slots[RankBarBGIndex].Widget],
                FGBlock := color_block[RankCanvas.Slots[RankBarFGIndex].Widget],
                RankIndex := GetRankIndexFromPoints(AgentData.Points),
                RankStartPoint := RankStartPoints[RankIndex],
                NextRankStartPoint := RankStartPoint + PointsToFinish[RankIndex]):

                    FGBlockSize := FGBlock.GetDesiredSize()
                    BGBlockSizeY := BGBlock.GetDesiredSize().Y
                    CurrentPointsRatioUI := FGBlockSize.Y / BGBlockSizeY
                    
                    PrevRankMaxPoint := RankStartPoint*1.0
                    RankMaxPoint := NextRankStartPoint*1.0

                    FGIncreaseRatio := 1.0 / (RankBarFillDuration / DeltaTime)

                    var Sign : float = 1.0
                    var TargetRatio : float = CurrentPointsRatioUI
                    if (PointRatio := AgentData.PointRatios[AgentData.LatestPointIndexUI]):
                        set Sign = Sgn(PointRatio)
                        set TargetRatio = Abs(PointRatio)

                    var CurrentFGRatio : float = CurrentPointsRatioUI + (FGIncreaseRatio*Sign)
                    if ((Sign >= 0.0 and CurrentFGRatio >= TargetRatio) or (Sign < 0.0 and CurrentFGRatio <= TargetRatio)):
                        set CurrentFGRatio = TargetRatio
                        set AgentData.LatestPointIndexUI += 1

                        if (AgentData.LatestPointIndexUI >= PointRatiosLen):
                            set AgentData.LatestPointIndexUI = 0

                        if (AgentData.LatestPointIndexUI = AgentData.LatestPointIndex):
                            CurrentPointsRatio := (AgentData.Points*1.0 - PrevRankMaxPoint) / (RankMaxPoint - PrevRankMaxPoint)
                            set CurrentFGRatio = CurrentPointsRatio

                    ClampedCurrentFGRatio := Clamp(CurrentFGRatio, 0.0, 1.0)
                    FGBlock.SetDesiredSize(vector2{ X := FGBlockSize.X, Y := BGBlockSizeY * ClampedCurrentFGRatio })

        EnumToTexture(Rank : rank)<transacts>:texture=
            case(Rank):
                rank.Unranked => Textures.T_Unranked
                rank.Bronze1 => Textures.T_Bronze1
                rank.Bronze2 => Textures.T_Bronze2
                rank.Bronze3 => Textures.T_Bronze3
                rank.Silver1 => Textures.T_Silver1
                rank.Silver2 => Textures.T_Silver2
                rank.Silver3 => Textures.T_Silver3
                rank.Gold1 => Textures.T_Gold1
                rank.Gold2 => Textures.T_Gold2
                rank.Gold3 => Textures.T_Gold3
                rank.Platinum1 => Textures.T_Plat1
                rank.Platinum2 => Textures.T_Plat2
                rank.Platinum3 => Textures.T_Plat3
                rank.Diamond1 => Textures.T_Diamond1
                rank.Diamond2 => Textures.T_Diamond2
                rank.Diamond3 => Textures.T_Diamond3
                rank.Elite => Textures.T_Elite
                rank.Champion => Textures.T_Champion
                rank.Unreal => Textures.T_Unreal

        EnumToInt(Rank : rank)<transacts>:int=
            case(Rank):
                rank.Unranked => 0
                rank.Bronze1 => 1
                rank.Bronze2 => 2
                rank.Bronze3 => 3
                rank.Silver1 => 4
                rank.Silver2 => 5
                rank.Silver3 => 6
                rank.Gold1 => 7
                rank.Gold2 => 8
                rank.Gold3 => 9
                rank.Platinum1 => 10
                rank.Platinum2 => 11
                rank.Platinum3 => 12
                rank.Diamond1 => 13
                rank.Diamond2 => 14
                rank.Diamond3 => 15
                rank.Elite => 16
                rank.Champion => 17
                rank.Unreal => 18

        EnumToString(Rank : rank)<transacts>:string=
            var RankName : string = "NaN"
            if (ImRankName := RankNames[EnumToInt(Rank)]):
                set RankName = ImRankName

            return RankName

        CreateCanvas():canvas=
            var CanvasSlots : []canvas_slot = array{}

            set CanvasSlots += array
            {
                CanvasSlot0 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{}, Maximum := vector2{} }
                    Offsets := margin{ Top := 16.0, Left := 16.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{}
                    ZOrder := 0
                    SizeToContent := true
                    Widget := CreateRankCanvas()
            }

            Canvas := canvas:
                Slots := CanvasSlots
            return Canvas

        CreateRankCanvas():canvas=
            var CanvasSlots : []canvas_slot = array{}

            RankBGSize := vector2{ X := 252.0, Y := 300.0 }
            RankIconSize := vector2{ X := 160.0, Y := 160.0 }
            RankBarSize := vector2{ X := 40.0, Y := 286.0 }

            Anchors := anchors{ Minimum := vector2{ X := 0.0, Y := 1.0 }, Maximum := vector2{ X := 0.0, Y := 1.0 } }

            RankIconOffsets := vector2{ X := 60.0, Y := -120.0 }
            RankBarOffsets := vector2{ X := 0.0, Y := -8.0 }
            PercentageTextOffsets := vector2{ X := 136.0, Y := -68.0 }
            RankTextOffsets := vector2{ X := 140.0, Y := -32.0 }

            ImageAlignment := vector2{ X := 0.0, Y := 1.0 }
            TextAlignment := vector2{ X := 0.5, Y := 1.0 }

            # (frozenpawn): RankBG.
            set CanvasSlots += array
            {
                CanvasSlot0 := canvas_slot:
                    Anchors := Anchors
                    Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := ImageAlignment
                    ZOrder := 2
                    SizeToContent := true
                    Widget := texture_block{ DefaultImage := Textures.T_RankBG, DefaultDesiredSize := RankBGSize }
            }

            # (frozenpawn): RankIcon.
            set CanvasSlots += array
            {
                CanvasSlot1 := canvas_slot:
                    Anchors := Anchors
                    Offsets := margin{ Top := RankIconOffsets.Y, Left := RankIconOffsets.X, Right := 0.0, Bottom := 0.0 }
                    Alignment := ImageAlignment
                    ZOrder := 3
                    SizeToContent := true
                    Widget := texture_block{ DefaultImage := Textures.T_Unranked, DefaultDesiredSize := RankIconSize }
            }

            # (frozenpawn): RankBarBG.
            set CanvasSlots += array
            {
                CanvasSlot2 := canvas_slot:
                    Anchors := Anchors
                    Offsets := margin{ Top := RankBarOffsets.Y, Left := RankBarOffsets.X, Right := 0.0, Bottom := 0.0 }
                    Alignment := ImageAlignment
                    ZOrder := 0
                    SizeToContent := true
                    Widget := texture_block{ DefaultImage := Textures.T_RankBarBG, DefaultDesiredSize := RankBarSize }
            }

            # (frozenpawn): RankBarFG.
            set CanvasSlots += array
            {
                CanvasSlot3 := canvas_slot:
                    Anchors := Anchors
                    Offsets := margin{ Top := RankBarOffsets.Y, Left := RankBarOffsets.X, Right := 0.0, Bottom := 0.0 }
                    Alignment := ImageAlignment
                    ZOrder := 1
                    SizeToContent := true
                    Widget := color_block{ DefaultColor := MakeColorFromSRGBValues(FillBarColorR, FillBarColorG, FillBarColorB),
                    DefaultDesiredSize := vector2{ X := RankBarSize.X, Y := 0.0 } }
            }

            # (frozenpawn): Percentage Text.
            set CanvasSlots += array
            {
                CanvasSlot4 := canvas_slot:
                    Anchors := Anchors
                    Offsets := margin{ Top := PercentageTextOffsets.Y, Left := PercentageTextOffsets.X, Right := 0.0, Bottom := 0.0 }
                    Alignment := TextAlignment
                    ZOrder := 3
                    SizeToContent := true
                    Widget := text_block{ DefaultText := TextForUI("%0"), DefaultTextColor := NamedColors.White }
            }

            # (frozenpawn): Rank Text.
            set CanvasSlots += array
            {
                CanvasSlot5 := canvas_slot:
                    Anchors := Anchors
                    Offsets := margin{ Top := RankTextOffsets.Y, Left := RankTextOffsets.X, Right := 0.0, Bottom := 0.0 }
                    Alignment := TextAlignment
                    ZOrder := 3
                    SizeToContent := true
                    Widget := text_block{ DefaultText := TextForUI("{EnumToString(rank.Unranked)}"), DefaultTextColor := NamedColors.White }
            }

            Canvas := canvas:
                Slots := CanvasSlots
            return Canvas