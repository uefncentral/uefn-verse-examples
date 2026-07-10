# Tycoon Game System
# A comprehensive tycoon-style game framework that manages player resources (money, diamonds, rebirths), purchasing systems, and persistent data storage. Players can click objects to earn resources, pur
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/tycoon-main-device-1?ref=github

<#
using { /Fortnite.com/UI }
using { /Fortnite.com/Devices }
using { /Verse.org/Colors }
using { /Verse.org/Assets }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }

TycoonModule := module:

    var PersistentAgentMap : weak_map(player, persistable_agent_data) = map{}

    resource_type := enum:
        Money,
        Diamond,
        Rebirth

    persistable_agent_data := class<final><persistable>:
        Money : float
        Diamond : float
        Rebirth : int
        BestSeconds : float
        LastPlaySeconds : float
        PurchasedIndexes : []int

    agent_data := class:
        var Money : float = 0.0
        var Diamond : float = 0.0
        var Rebirth : int = 0
        var GameStartSeconds : float = 0.0
        var BestSeconds : float = -1.0

        var MaybeOwnedBase : ?base_data = false
        var MaybeCanvas : ?canvas = false

        var PurchasedIndexes : []int = array{}
        var PurchasablesLength : int = 0

    clicker_data := class<concrete>:
        @editable
        PropManipulator : prop_manipulator_device = prop_manipulator_device{}

        @editable
        SFXClicker : audio_player_device = audio_player_device{}

        @editable
        MoneyPerHit : int = 0

        @editable
        DiamondPerHit : int = 0

    purchase_data := class<concrete>:
        @editable
        PriceMoney : int = 0
    
        @editable
        PriceDiamond : int = 0

        @editable
        RebirthRequirement : int = 0

        @editable
        MoneyIncomePerSecond : int = 0

        @editable
        DiamondIncomePerSecond : int = 0        

        @editable
        ClaimerVolume : volume_device = volume_device{}

        @editable
        MaybeClicker : ?clicker_data = false

        @editable
        CreativeProps : []creative_prop = array{}

        @editable
        PurchasesToOpen : []int = array{}

        var ClaimerFirstZ : float = 0.0
        var MaybeMainDevice : ?tycoon_main_device = false
        var MaybeBaseData : ?base_data = false
        var Index : int = -1

        Init(MainDevice : tycoon_main_device, BaseData : base_data, InIndex : int):void=
            InitInner(MainDevice, BaseData, InIndex)

            ClaimerVolume.AgentEntersEvent.Subscribe(OnVolumeEntered)

        InitFirstPurchase(MainDevice : tycoon_main_device, BaseData : base_data, InIndex : int):void=
            InitInner(MainDevice, BaseData, InIndex)

            ClaimerVolume.AgentEntersEvent.Subscribe(OnFirstPurchaseVolumeEntered)

        InitInner(MainDevice : tycoon_main_device, BaseData : base_data, InIndex : int):void=
            set MaybeMainDevice = option{ MainDevice }
            set MaybeBaseData = option{ BaseData }
            set Index = InIndex

            set ClaimerFirstZ = ClaimerVolume.GetTransform().Translation.Z

            if (Clicker := MaybeClicker?):
                Clicker.PropManipulator.DamagedEvent.Subscribe(OnClickerHit)

        OnVolumeEntered(Agent : agent):void=
            if (MainDevice := MaybeMainDevice?, BaseData := MaybeBaseData?):
                MainDevice.TryPurchase(Agent, BaseData, Self)

        OnFirstPurchaseVolumeEntered(Agent : agent):void=
            if (MainDevice := MaybeMainDevice?, BaseData := MaybeBaseData?):
                MainDevice.TryBaseClaim(Agent, BaseData, Self)

        OnClickerHit(Agent : agent):void=
            if (MainDevice := MaybeMainDevice?, BaseData := MaybeBaseData?, Clicker := MaybeClicker?):
                MainDevice.OnClickerHit(Agent, BaseData, Clicker)

    base_data := class<concrete>:
        @editable
        Purchases : []purchase_data = array{}

        var MaybeOwnerAgent : ?agent = false
        var MaybeMainDevice : ?tycoon_main_device = false

        Init(MainDevice : tycoon_main_device):void=
            set MaybeMainDevice = option{ MainDevice }
            var Index : int = 0

            if (BaseFirstPurchase := Purchases[0]):
                BaseFirstPurchase.InitFirstPurchase(MainDevice, Self, Index)
                set Index += 1

            for (I := 1 .. Purchases.Length-1, Purchase := Purchases[I]):
                Purchase.Init(MainDevice, Self, Index)
                set Index += 1

    tycoon_main_device := class(creative_device):

        @editable
        IncomeIncreasePercentagePerRebirth : float = 0.05

        @editable
        bUseSaveForBase : logic = true        

        @editable
        MoveOnZ : float = 1500.0

        @editable
        GameStartTeleporter : teleporter_device = teleporter_device{}

        @editable
        SFXClaim : audio_player_device = audio_player_device{}
        @editable
        SFXGameComplete : audio_player_device = audio_player_device{}

        @editable
        PlayerSpawners : []player_spawner_device = array{}

        @editable
        Bases : []base_data = array{}

        TextForUI<localizes>(Text : string) : message = "{Text}"

        var AgentMap : [agent]agent_data = map{}

        OnBegin<override>()<suspends>:void=
            Print("OnBegin")

            GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerLeft)

            for (PlayerSpawner : PlayerSpawners):
                PlayerSpawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

            for (Base : Bases):
                Base.Init(Self)

                for (Purchase : Base.Purchases):
                    MoveProps(Purchase, false)

                if (FirstPurchase := Base.Purchases[0]):
                    OpenClaimerOfPurchase(FirstPurchase)

            spawn{ AsyncTickPerSecond() }

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
                    CountPurchasables(AgentData)

                    Canvas := CreateCanvas()
                    PlayerUI.AddWidget(Canvas)

                    set AgentData.MaybeCanvas = option{ Canvas }

                    UpdateResourceUI(Canvas, resource_type.Money, AbbreviateNumberText(AgentData.Money*1.0))
                    UpdateResourceUI(Canvas, resource_type.Diamond, AbbreviateNumberText(AgentData.Diamond*1.0))
                    UpdateResourceUI(Canvas, resource_type.Rebirth, AbbreviateNumberText(AgentData.Rebirth*1.0))

        CountPurchasables(AgentData : agent_data):void=
            set AgentData.PurchasablesLength = 0

            if (Base0 := Bases[0]):                
                for (Purchase : Base0.Purchases):
                    if (Purchase.RebirthRequirement <= AgentData.Rebirth):
                        set AgentData.PurchasablesLength += 1
            Print("Purchasables Length: {AgentData.PurchasablesLength}")

        AgentDataTmpToPersistent(AgentData: agent_data)<transacts>:persistable_agent_data=
            CurrentTime := GetSimulationElapsedTime()            
            persistable_agent_data
            {
                Money := AgentData.Money
                Diamond := AgentData.Diamond
                Rebirth := AgentData.Rebirth
                BestSeconds := AgentData.BestSeconds
                LastPlaySeconds := CurrentTime - AgentData.GameStartSeconds
                PurchasedIndexes := AgentData.PurchasedIndexes
            }

        AgentDataPersistentToTmp(PersistableAgentData : persistable_agent_data)<transacts>:agent_data=
            agent_data
            {
                Money := PersistableAgentData.Money
                Diamond := PersistableAgentData.Diamond
                Rebirth := PersistableAgentData.Rebirth
                BestSeconds := PersistableAgentData.BestSeconds
                PurchasedIndexes := PersistableAgentData.PurchasedIndexes
            }

        OnPlayerLeft(Agent : agent):void=
            if (AgentData := AgentMap[Agent], BaseData := AgentData.MaybeOwnedBase?):
                SaveData(Agent)
                ResetBase(AgentData, BaseData)

                for (Purchase : BaseData.Purchases):                    
                    HideClaimerOfPurchase(Purchase)

                if (FirstPurchase := BaseData.Purchases[0]):
                    OpenClaimerOfPurchase(FirstPurchase)

        OnClickerHit(Agent : agent, BaseData : base_data, Clicker : clicker_data):void=
            if (OwnerAgent := BaseData.MaybeOwnerAgent?):
                if (OwnerAgent <> Agent):
                    Print("Error: Only the Owner Can Click!")
                    return

            if (AgentData := AgentMap[Agent], (Clicker.MoneyPerHit > 0 or Clicker.DiamondPerHit > 0)):
                Clicker.SFXClicker.Play(Agent)

                if (Clicker.MoneyPerHit > 0):
                    UpdateResource(AgentData, resource_type.Money, Clicker.MoneyPerHit*1.0)

                if (Clicker.DiamondPerHit > 0):
                    UpdateResource(AgentData, resource_type.Diamond, Clicker.DiamondPerHit*1.0)

                SaveData(Agent)

        TryPurchase(Agent : agent, BaseData : base_data, PurchaseData : purchase_data):void=
            if (OwnerAgent := BaseData.MaybeOwnerAgent?, OwnerAgentData := AgentMap[OwnerAgent]):
                if (OwnerAgent <> Agent):
                    Print("Error: Only the Owner Can Purchase!")
                    return

                if (FoundIndex := OwnerAgentData.PurchasedIndexes.Find[PurchaseData.Index]):
                    Print("Error: Already Purchased!")
                    return

                TryPurchaseInner(OwnerAgent, OwnerAgentData, BaseData, PurchaseData)

        TryBaseClaim(Agent : agent, BaseData : base_data, PurchaseData : purchase_data):void=
            if (OwnerAgent := BaseData.MaybeOwnerAgent?):
                Print("Error: Already Has An Owner!")
                return

            if (AgentData := AgentMap[Agent]):

                if (OwnedBase := AgentData.MaybeOwnedBase?):
                    Print("Error: Already Has A Base!")
                    return

                LastPlaySeconds : float = if (Player := player[Agent], PersistableAgentData := PersistentAgentMap[Player])
                then PersistableAgentData.LastPlaySeconds
                else 0.0

                OldPurchasedIndexes : []int = AgentData.PurchasedIndexes
                set AgentData.PurchasedIndexes = array{}
                bPurchased := TryPurchaseInner(Agent, AgentData, BaseData, PurchaseData)
                if (bPurchased = true):
                    set BaseData.MaybeOwnerAgent = option{ Agent }
                    set AgentData.MaybeOwnedBase = option{ BaseData }

                    set AgentData.GameStartSeconds = GetSimulationElapsedTime() - LastPlaySeconds

                    if (bUseSaveForBase = true):
                        for (OldPurchasedIndex : OldPurchasedIndexes, Purchase := BaseData.Purchases[OldPurchasedIndex]):
                            if (OldPurchasedIndex <> 0):
                                PurchaseInner(Agent, AgentData, BaseData, Purchase)

                        SaveData(Agent)

        TryPurchaseInner(Agent : agent, AgentData : agent_data, BaseData : base_data, PurchaseData : purchase_data):logic=
            if (AgentData.Money < PurchaseData.PriceMoney*1.0 or AgentData.Diamond < PurchaseData.PriceDiamond*1.0 or
            AgentData.Rebirth < PurchaseData.RebirthRequirement):
                var StringToLog : string = "Error: Not Enough Resources!, OwnedMoney: {AgentData.Money}, PriceMoney: {PurchaseData.PriceMoney}, "
                set StringToLog += "OwnedDiamond: {AgentData.Diamond}, PriceDiamond: {PurchaseData.PriceDiamond}, OwnedRebirth: "
                set StringToLog += "{AgentData.Rebirth}, RequiredRebirth: {PurchaseData.RebirthRequirement}"
                Print(StringToLog)
                return false

            SFXClaim.Play(Agent)

            set AgentData.Money -= PurchaseData.PriceMoney*1.0
            set AgentData.Diamond -= PurchaseData.PriceDiamond*1.0

            PurchaseInner(Agent, AgentData, BaseData, PurchaseData)

            return true

        PurchaseInner(Agent : agent, AgentData : agent_data, BaseData : base_data, PurchaseData : purchase_data):void=
            MoveProps(PurchaseData, true)

            set AgentData.PurchasedIndexes += array{ PurchaseData.Index }

            for (PurchaseIndexToOpen : PurchaseData.PurchasesToOpen, PurchaseToOpen := BaseData.Purchases[PurchaseIndexToOpen]):
                OpenClaimerOfPurchase(PurchaseToOpen)

            SaveData(Agent)
            CheckGameEnd(Agent, AgentData, BaseData)

        CheckGameEnd(Agent : agent, AgentData : agent_data, BaseData : base_data):void=
            if (AgentData.PurchasedIndexes.Length < AgentData.PurchasablesLength):
                return

            spawn{ AsyncGameEnd(Agent, AgentData, BaseData) }

        ResetBase(AgentData : agent_data, BaseData : base_data):void=
            set BaseData.MaybeOwnerAgent = false
            set AgentData.MaybeOwnedBase = false

            for (PurchasedIndex : AgentData.PurchasedIndexes, Purchase := BaseData.Purchases[PurchasedIndex]):
                MoveProps(Purchase, false)

            for (Purchase : BaseData.Purchases):
                HideClaimerOfPurchase(Purchase)

            if (FirstPurchase := BaseData.Purchases[0]):
                OpenClaimerOfPurchase(FirstPurchase)

        MoveProps(PurchaseData : purchase_data, bMoveUp : logic):void=
            SignedMoveOnZ : float = if (bMoveUp = true)
            then MoveOnZ
            else -MoveOnZ
    
            for (CreativeProp : PurchaseData.CreativeProps):
                Transform := CreativeProp.GetTransform()
                var Location : vector3 = Transform.Translation
                set Location.Z += SignedMoveOnZ
                if (CreativeProp.TeleportTo[Location, Transform.Rotation]){}
    
            if (Clicker := PurchaseData.MaybeClicker?):
                Transform := Clicker.PropManipulator.GetTransform()
                var Location : vector3 = Transform.Translation
                set Location.Z += SignedMoveOnZ

                if (Clicker.PropManipulator.TeleportTo[Location, Transform.Rotation]){}

            var ClaimerLoc : vector3 = PurchaseData.ClaimerVolume.GetTransform().Translation
            set ClaimerLoc.Z = PurchaseData.ClaimerFirstZ - MoveOnZ
            if (PurchaseData.ClaimerVolume.TeleportTo[ClaimerLoc, IdentityRotation()]){}

        OpenClaimerOfPurchase(PurchaseData : purchase_data):void=
            var ClaimerLoc : vector3 = PurchaseData.ClaimerVolume.GetTransform().Translation
            set ClaimerLoc.Z = PurchaseData.ClaimerFirstZ

            if (PurchaseData.ClaimerVolume.TeleportTo[ClaimerLoc, IdentityRotation()]){}

        HideClaimerOfPurchase(PurchaseData : purchase_data):void=
            var ClaimerLoc : vector3 = PurchaseData.ClaimerVolume.GetTransform().Translation
            set ClaimerLoc.Z = PurchaseData.ClaimerFirstZ - MoveOnZ

            if (PurchaseData.ClaimerVolume.TeleportTo[ClaimerLoc, IdentityRotation()]){}

        AsyncGameEnd(Agent : agent, AgentData : agent_data, BaseData : base_data)<suspends>:void=
            CurrentPlayTime := GetSimulationElapsedTime() - AgentData.GameStartSeconds            

            if (AgentData.BestSeconds < 0.0 or AgentData.BestSeconds > CurrentPlayTime):
                set AgentData.BestSeconds = CurrentPlayTime
            
            UpdateResource(AgentData, resource_type.Rebirth, 1.0)

            SFXGameComplete.Play(Agent)

            if (Canvas := AgentData.MaybeCanvas?, CurrentTimeInt  := Int[CurrentPlayTime]):
                ShowGameEndCanvas(Canvas, GetFormattedTimeString(CurrentTimeInt))

            SleepSecondsBeforeGameReset := 5.0
            Sleep(SleepSecondsBeforeGameReset)

            ResetBase(AgentData, BaseData)

            CountPurchasables(AgentData)
            set AgentData.PurchasedIndexes = array{}
            set AgentData.Money = 0.0
            set AgentData.Diamond = 0.0

            if (Canvas := AgentData.MaybeCanvas?):
                HideGameEndCanvas(Canvas)

                UpdateResourceUI(Canvas, resource_type.Money, "0")
                UpdateResourceUI(Canvas, resource_type.Diamond, "0")

            set AgentData.GameStartSeconds = GetSimulationElapsedTime()
            SaveData(Agent)

            GameStartTeleporter.Teleport(Agent)            

        AsyncTickPerSecond()<suspends>:void=
            loop:
                Sleep(1.0)

                Players := GetPlayspace().GetPlayers()
                for (Player : Players, AgentData := AgentMap[Player], OwnedBase := AgentData.MaybeOwnedBase?,
                Canvas := AgentData.MaybeCanvas?):

                    var TotalMoneyIncomePerSecond : int = 0
                    var TotalDiamondIncomePerSecond : int = 0
                    for (PurchasedIndex : AgentData.PurchasedIndexes, Purchase := OwnedBase.Purchases[PurchasedIndex]):
                        set TotalMoneyIncomePerSecond += Purchase.MoneyIncomePerSecond
                        set TotalDiamondIncomePerSecond += Purchase.DiamondIncomePerSecond

                    if (TotalMoneyIncomePerSecond > 0):
                        UpdateResource(AgentData, resource_type.Money, TotalMoneyIncomePerSecond*1.0)

                    if (TotalDiamondIncomePerSecond > 0):
                        UpdateResource(AgentData, resource_type.Diamond, TotalDiamondIncomePerSecond*1.0)

                    SaveData(Player)

        SaveData(Agent : agent):void=
            if (Player := player[Agent], AgentData := AgentMap[Agent]):
                if (set PersistentAgentMap[Player] = AgentDataTmpToPersistent(AgentData)){}

        FloatToString<public>(Number : float, DigitsAfterDecimalPoint : int)<transacts>:string=
            var PrecisionMultiplier : float = 1.0
            for (I := 0..DigitsAfterDecimalPoint-1):
                set PrecisionMultiplier = PrecisionMultiplier * 10.0

            if (DigitsAfterDecimalPoint <= 10, NumberOnlyIntPart := Int[Number], NumberIntPart := Int[NumberOnlyIntPart * PrecisionMultiplier],
            NumberWholeAsInt := Int[Number * PrecisionMultiplier], NumberFractionAsInt := NumberWholeAsInt - NumberIntPart,
            FractionalPart := Number - NumberOnlyIntPart*1.0):
                var LeadingZeroes : int = 0
                var MultipliedFractional : float = FractionalPart
                if (MultipliedFractional > 0.0):
                    loop:
                        set MultipliedFractional = MultipliedFractional * 10.0
                            if (MultipliedFractional >= 1.0 or NumberFractionAsInt = 0):
                                break
                        set LeadingZeroes = LeadingZeroes + 1
            
                var CombinedString : string = "{NumberOnlyIntPart}."
                loop:
                    if (LeadingZeroes = 0 or NumberFractionAsInt = 0):
                        break
                    set CombinedString += "0"
                    set LeadingZeroes = LeadingZeroes - 1
                set CombinedString += "{NumberFractionAsInt}"
                return CombinedString
            return "NaN"

        GetFormattedTimeString(TimeInSecs : int)<transacts>:string=
            var FormattedTimeString : string = ""
            HourTime : float = (TimeInSecs*1.0) / (60.0*60.0)
            if (FlooredHourTime := Floor[HourTime]):
                if (FlooredHourTime > 0):
                    if (FlooredHourTime < 10):
                        set FormattedTimeString += "0"
                    set FormattedTimeString += ToString(FlooredHourTime) + ":"
    
                RemainedMinutesTime : float = HourTime - (FlooredHourTime * 1.0)
    
                MinuteTime : float = RemainedMinutesTime * 60.0
                if (FlooredMinuteTime := Floor[MinuteTime]):
                    if (FlooredMinuteTime < 10):
                        set FormattedTimeString += "0" + ToString(FlooredMinuteTime) + ":"
                    else:
                        set FormattedTimeString += ToString(FlooredMinuteTime) + ":"
    
                    RemainedSecondsTime : float = MinuteTime - (FlooredMinuteTime*1.0)
    
                    SecondsTime : float = RemainedSecondsTime * 60.0
                    if (FlooredSecondsTime := Floor[SecondsTime]):
                        if (FlooredSecondsTime < 10):
                            set FormattedTimeString += "0" + ToString(FlooredSecondsTime)
                        else:
                            set FormattedTimeString += ToString(FlooredSecondsTime)
    
            return FormattedTimeString

        AbbreviateNumberText<public>(Number : float)<transacts>:string=
            var ResultText : string = ToString(Number)    
        
            Abbreviations : []tuple(float,string) = array
            {
                (1000.0, "K"),
                (1000000.0, "M"),
                (1000000000.0, "B"),
                (1000000000000.0, "T"),
                (1000000000000000.0, "Qa"),
                (1000000000000000000.0, "Qi")
            }
        
            AbbreviationCount : int = Abbreviations.Length-1
            var CurrBackIndex : int = AbbreviationCount
            for(i:=0..AbbreviationCount):
                if(CurrTuple := Abbreviations[CurrBackIndex]):
                    if(Abs(Number) >= CurrTuple(0)):
                        RoundedNumber : float = Number / CurrTuple(0)
                        set ResultText = FloatToString(RoundedNumber, 1) + CurrTuple(1)
                        return ResultText
                set CurrBackIndex -= 1
        
            if(CeiledValue := Ceil[Number]):
                set ResultText = ToString(CeiledValue)
            return ResultText

        GetTextureOfResourceType(ResourceType : resource_type):texture=
            case(ResourceType):
                resource_type.Money => Textures.T_MoneyUI
                resource_type.Diamond => Textures.T_DiamondUI
                resource_type.Rebirth => Textures.T_Rebirth

        EnumToInt(ResourceType : resource_type):int=
            case(ResourceType):
                resource_type.Money => 0
                resource_type.Diamond => 1
                resource_type.Rebirth => 2

        UpdateResource(AgentData : agent_data, ResourceType : resource_type, UpdateAmount : float):void=
            var StringToSet : string = ""

            var IncreasedUpdateAmount : float = UpdateAmount
            if (ResourceType = resource_type.Money or ResourceType = resource_type.Diamond):
                set IncreasedUpdateAmount += IncreasedUpdateAmount*IncomeIncreasePercentagePerRebirth*AgentData.Rebirth

            case(ResourceType):
                resource_type.Money =>
                    set AgentData.Money += IncreasedUpdateAmount
                    set StringToSet = AbbreviateNumberText(AgentData.Money*1.0)

                resource_type.Diamond =>
                    set AgentData.Diamond += IncreasedUpdateAmount
                    set StringToSet = AbbreviateNumberText(AgentData.Diamond*1.0)

                resource_type.Rebirth =>
                    if (UpdateAmountInt := Int[UpdateAmount]):
                        set AgentData.Rebirth += UpdateAmountInt
                    set StringToSet = AbbreviateNumberText(AgentData.Rebirth*1.0)

            if (Canvas := AgentData.MaybeCanvas?):
                UpdateResourceUI(Canvas, ResourceType, StringToSet)

        UpdateResourceUI(Canvas : canvas, ResourceType : resource_type, StringToSet : string):void=
            ResourceCanvasIndex := EnumToInt(ResourceType)
            TextBlockIndex := 1

            if (ResourceCanvas := canvas[Canvas.Slots[ResourceCanvasIndex].Widget],
            TextBlock := text_block[ResourceCanvas.Slots[TextBlockIndex].Widget]):
                TextBlock.SetText(TextForUI(StringToSet))

        ShowGameEndCanvas(Canvas : canvas, StringToSet : string):void=
            GameEndCanvasIndex : int = 3
            GameEndTextIndex := 1

            if (GameEndCanvas := canvas[Canvas.Slots[GameEndCanvasIndex].Widget],
            GameEndText := text_block[GameEndCanvas.Slots[GameEndTextIndex].Widget]):
                GameEndCanvas.SetVisibility(widget_visibility.Visible)
                GameEndText.SetText(TextForUI(StringToSet))

        HideGameEndCanvas(Canvas : canvas):void=
            GameEndCanvasIndex : int = 3
            if (GameEndCanvasSlot := Canvas.Slots[GameEndCanvasIndex]):
                GameEndCanvasSlot.Widget.SetVisibility(widget_visibility.Collapsed)

        CreateCanvas():canvas=
            var CanvasSlots : []canvas_slot = array{}

            SubCanvasesData : []tuple(resource_type, float) = array
            {
                (resource_type.Money, 0.395), (resource_type.Diamond, 0.5), (resource_type.Rebirth, 0.605)
            }

            for (SubCanvasData : SubCanvasesData):
                ResourceType : resource_type = SubCanvasData(0)
                AnchorY : float = SubCanvasData(1)

                set CanvasSlots += array
                {
                    canvas_slot:
                        Anchors := anchors{ Minimum := vector2{ X := 0.0, Y := AnchorY }, Maximum := vector2{ X := 0.0, Y := AnchorY } }
                        Offsets := margin{ Top := 0.0, Left := 16.0, Right := 0.0, Bottom := 0.0 }
                        Alignment := vector2{ X := 0.0, Y := 0.5 }
                        SizeToContent := true
                        ZOrder := 0
                        Widget := CreateResourceCanvas(ResourceType)
                }

            set CanvasSlots += array
            {
                canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.5, Y := 0.2 }, Maximum := vector2{ X := 0.5, Y := 0.2 } }
                    Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.5, Y := 0.0 }
                    SizeToContent := true
                    ZOrder := 0
                    Widget := CreateGameEndCanvas()
            }
            if (LastCanvasSlot := CanvasSlots[CanvasSlots.Length-1]):
                LastCanvasSlot.Widget.SetVisibility(widget_visibility.Collapsed)

            Canvas := canvas:
                Slots := CanvasSlots

            return Canvas

        CreateGameEndCanvas():canvas=
            var CanvasSlots : []canvas_slot = array{}

            Vector2Zero := vector2{ X := 0.0, Y := 0.0 }

            set CanvasSlots += array
            {
                CanvasSlot0 := canvas_slot:
                    Anchors := anchors{ Minimum := Vector2Zero, Maximum := Vector2Zero }
                    Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := Vector2Zero
                    SizeToContent := true
                    ZOrder := 0
                    Widget := texture_block{ DefaultImage := Textures.T_VictoryUI, DefaultDesiredSize := vector2{ X := 483.5, Y := 313.0 } }
            }

            set CanvasSlots += array
            {
                CanvasSlot1 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.5, Y := 1.0 }, Maximum := vector2{ X := 0.5, Y := 1.0 } }
                    Offsets := margin{ Top := 16.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.5, Y := 0.0 }
                    SizeToContent := true
                    ZOrder := 0
                    Widget := text_block{ DefaultText := TextForUI("00:00:00"), DefaultShadowColor := NamedColors.Black,
                    DefaultShadowOpacity := 1.0, DefaultShadowOffset := option{ vector2{ X := 2.0, Y := 2.0 }}, DefaultTextColor := NamedColors.White }
            }

            Canvas := canvas:
                Slots := CanvasSlots

            return Canvas

        CreateResourceCanvas(ResourceType : resource_type):canvas=
            Texture := GetTextureOfResourceType(ResourceType)

            var CanvasSlots : []canvas_slot = array{}

            Vector2Zero := vector2{ X := 0.0, Y := 0.0 }

            set CanvasSlots += array
            {
                CanvasSlot0 := canvas_slot:
                    Anchors := anchors{ Minimum := Vector2Zero, Maximum := Vector2Zero }
                    Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := Vector2Zero
                    SizeToContent := true
                    ZOrder := 0
                    Widget := texture_block{ DefaultImage := Texture, DefaultDesiredSize := vector2{ X := 326.0, Y := 100.0 } }
            }

            set CanvasSlots += array
            {
                CanvasSlot1 := canvas_slot:
                    Anchors := anchors{ Minimum := Vector2Zero, Maximum := Vector2Zero }
                    Offsets := margin{ Top := 28.0, Left := 110.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := Vector2Zero
                    SizeToContent := true
                    ZOrder := 0
                    Widget := text_block{ DefaultText := TextForUI("0"), DefaultShadowColor := NamedColors.Black,
                    DefaultShadowOpacity := 1.0, DefaultShadowOffset := option{ vector2{ X := 2.0, Y := 2.0 }}, DefaultTextColor := NamedColors.White }
            }

            Canvas := canvas:
                Slots := CanvasSlots

            return Canvas
#>