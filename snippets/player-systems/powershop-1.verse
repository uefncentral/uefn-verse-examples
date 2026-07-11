# Superpower Shop System
# A customizable in-game shop system that allows players to purchase various superpowers and stat upgrades using in-game currency. The system supports different purchase types including health increases
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/powershop-1?ref=github


using { /Fortnite.com/UI }
using { /Fortnite.com/Game }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Colors }
using { /Verse.org/Random }
using { /Verse.org/Assets }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }

SuperPowerShopModule := module:

    MsgPowerupValue<localizes> : message = "This value will be interpret differently based on the purchase type."
    MsgPriceScaler<localizes> : message = "Works only if bOneTimePurchase is set to false."

    custom_game_action_causer := class(game_action_causer){}

    purchase_type := enum:
        HPIncrease,
        DamageAmplify,
        ShieldIncrease,
        HPRegen,
        ShieldRegen,
        CriticalChance,
        CriticalStrikeDamage,
        Empty

    purchase_data := class<concrete>:
        @editable
        PurchaseType : purchase_type = purchase_type.Empty

        @editable:
            ToolTip := MsgPowerupValue
        PowerupValue : float = 0.0

        @editable
        PurchasePrice : type { X:int where X >= 0 } = 0

        @editable
        bOneTimePurchase : logic = true

        @editable:
            ToolTip := MsgPriceScaler
        PriceScalerAfterEachPurchase : type { X:float where X >= 0.0 } = 0.0

    agent_data1 := class:
        var MaxHP : float = 100.0
        var MaxShield : float = 100.0
        var HPRegen : float = 0.0
        var ShieldRegen : float = 0.0
        var DamageAmplify : float = 0.0
        var CriticalChance : float = 0.0
        var CriticalStrikeDamageMultiplier : float = 0.0
        var bShopOpen : logic = false
        var MaybeShopCanvas : ?canvas = false
        var CurrentPageIndex : int = 0

        var Purchases : []int = array{}

    superpower_shop_device := class(creative_device): 

        @editable
        BaseCriticalStrikeDamageMultiplier : float = 1.5

        @editable
        GoldConditionalButton : conditional_button_device = conditional_button_device{}

        @editable
        ShopOpenButtons : []button_device = array{}

        @editable
        ShopPurchases : []purchase_data = array{}

        @editable
        PlayerSpawners : []player_spawner_device = array{}

        TextForUI4<localizes>(Text : string) : message = "{Text}"
        PurchasePerPage : int = 3

        var AgentMap : [agent]agent_data1 = map{}

        OnBegin<override>()<suspends>:void=
            Print("OnBegin")

            for (Player : GetPlayspace().GetPlayers()):
                OnPlayerSpawned(Player)

            for (PlayerSpawner : PlayerSpawners):
                PlayerSpawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

            for (ShopOpenButton : ShopOpenButtons):
                ShopOpenButton.InteractedWithEvent.Subscribe(OnShopOpen)

            spawn{ AsyncTickPerSecond() }

        AsyncTickPerSecond()<suspends>:void=
            loop:
                Sleep(1.0)

                Players := GetPlayspace().GetPlayers()
                for (Player : Players, AgentData := AgentMap[Player], FC := Player.GetFortCharacter[]):

                    if (AgentData.HPRegen > 0.0, FC.GetHealth() > 0.0):
                        FC.SetHealth(FC.GetHealth() + AgentData.HPRegen)

                    if (AgentData.ShieldRegen > 0.0):
                        FC.SetShield(FC.GetShield()+AgentData.ShieldRegen)

        OnPlayerSpawned(Agent : agent):void=
            if (not AgentMap[Agent]):
                AgentData := agent_data1{}
                set AgentData.CriticalStrikeDamageMultiplier = BaseCriticalStrikeDamageMultiplier

                for (I := 1 .. ShopPurchases.Length):
                    set AgentData.Purchases += array{ 0 }

                if (set AgentMap[Agent] = AgentData){}
                if (FortCharacter := Agent.GetFortCharacter[]):
                    FortCharacter.DamagedEvent().Subscribe(OnPlayerDamaged)
                    FortCharacter.DamagedShieldEvent().Subscribe(OnPlayerDamaged)

            if (AgentData := AgentMap[Agent], FortCharacter := Agent.GetFortCharacter[]):
                FortCharacter.SetMaxHealth(AgentData.MaxHP)
                FortCharacter.SetMaxShield(AgentData.MaxShield)
                FortCharacter.SetHealth(AgentData.MaxHP)
                FortCharacter.SetShield(AgentData.MaxShield)

        OnPlayerDamaged(DamageResult : damage_result):void=
            if (DamageSource := custom_game_action_causer[DamageResult.Source?]):
                return

            if (InstigatorAgent := DamageResult.Instigator?.GetInstigatorAgent[],
            InstigatorFC := InstigatorAgent.GetFortCharacter[],
            TargetFortCharacter := fort_character[DamageResult.Target],
            TargetFortCharacter.GetHealth() > 0.0,
            InstigatorAgentData := AgentMap[InstigatorAgent]):

                var DamageToSend : float = DamageResult.Amount * InstigatorAgentData.DamageAmplify

                CritChance := GetRandomFloat(0.01, 1.0)
                if (InstigatorAgentData.CriticalChance >= CritChance):
                    set DamageToSend = ((DamageResult.Amount + DamageToSend) * InstigatorAgentData.CriticalStrikeDamageMultiplier) - DamageResult.Amount

                CustomGameActionCauser := custom_game_action_causer{}
                DamageArgs := damage_args{ Instigator := DamageResult.Instigator,
                Source := option{CustomGameActionCauser}, Amount := DamageToSend }
                TargetFortCharacter.Damage(DamageArgs)

        EnumToTexture(PurchaseType : purchase_type)<transacts>:texture=
            case(PurchaseType):
                purchase_type.HPIncrease => PowerShop.T_HealthIncrease
                purchase_type.DamageAmplify => PowerShop.T_DamageIncrease
                purchase_type.ShieldIncrease => PowerShop.T_ShieldIncrease
                purchase_type.HPRegen => PowerShop.T_HealthRegen
                purchase_type.ShieldRegen => PowerShop.T_ShieldRegen
                purchase_type.CriticalChance => PowerShop.T_CriticalChance
                purchase_type.CriticalStrikeDamage => PowerShop.T_CriticalStrikeDamage
                purchase_type.Empty => PowerShop.T_HealthIncrease

        CalculateMaxPages()<transacts>:int=
            MaxPages : int = if (Num := Ceil[(ShopPurchases.Length*1.0) / (PurchasePerPage*1.0)])
            then Num
            else -1

            return MaxPages

        GenerateFrameStrings(PowerupValue : float, PurchasePrice : int, PurchaseType : purchase_type,
        bPurchased : logic, bPurchaseOnce : logic):tuple(string , string)=
            var PVInt : int = if (Num := Int[PowerupValue])
            then Num
            else -1

            var PVIntFraction : int = 0
            if (PVM100Int := Int[PowerupValue*100.0]):
                set PVIntFraction = PVM100Int - PVInt*100

            var PriceString : string = "{PVInt}."
            if (PVIntFraction < 10):
                set PriceString += "0"
            set PriceString += "{PVIntFraction}"

            var AdditionalCharacter : string = ""
            if (PurchaseType = purchase_type.CriticalChance):
                set AdditionalCharacter = "%"
            else if (PurchaseType = purchase_type.DamageAmplify):
                set AdditionalCharacter = "X"

            PurchaseString : string = if (PurchaseType <> purchase_type.Empty)
            then "{PurchasePrice}💰: +" + AdditionalCharacter + PriceString
            else ""

            var ButtonString : string = ""
            if (PurchaseType <> purchase_type.Empty):
                set ButtonString = if (bPurchased = true, bPurchaseOnce = true)
                then "PURCHASED"
                else "PURCHASE"

            return (PurchaseString, ButtonString)

        OnShopOpen(Agent : agent):void=
            if (AgentData := AgentMap[Agent], AgentData.bShopOpen = false,
            Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
                set AgentData.bShopOpen = true
                set AgentData.CurrentPageIndex = 0

                ShopCanvas := CreateShopCanvas()
                set AgentData.MaybeShopCanvas = option{ ShopCanvas }
                UpdatePurchaseFrames(Agent)

                PlayerUI.AddWidget(ShopCanvas, player_ui_slot{ InputMode := ui_input_mode.All })

        OnPagePrevClicked(WidgetMessage : widget_message):void=
            if (AgentData := AgentMap[WidgetMessage.Player], AgentData.CurrentPageIndex > 0):
                set AgentData.CurrentPageIndex -= 1
                UpdatePurchaseFrames(WidgetMessage.Player)

        OnPageNextClicked(WidgetMessage : widget_message):void=
            if (AgentData := AgentMap[WidgetMessage.Player], AgentData.CurrentPageIndex < CalculateMaxPages()-1):
                set AgentData.CurrentPageIndex += 1
                UpdatePurchaseFrames(WidgetMessage.Player)

        OnPageCloseClicked(WidgetMessage : widget_message):void=
            if (AgentData := AgentMap[WidgetMessage.Player], PlayerUI := GetPlayerUI[WidgetMessage.Player],
            ShopCanvas := AgentData.MaybeShopCanvas?):
                set AgentData.bShopOpen = false
                set AgentData.MaybeShopCanvas = false

                PlayerUI.RemoveWidget(ShopCanvas)

        OnPurchaseClicked0(WidgetMessage : widget_message):void=
            OnPurchaseClicked(WidgetMessage, 0)

        OnPurchaseClicked1(WidgetMessage : widget_message):void=
            OnPurchaseClicked(WidgetMessage, 1)

        OnPurchaseClicked2(WidgetMessage : widget_message):void=
            OnPurchaseClicked(WidgetMessage, 2)

        OnPurchaseClicked(WidgetMessage : widget_message, PurchaseIndex : int):void=
            if (AgentData := AgentMap[WidgetMessage.Player], ShopCanvas := AgentData.MaybeShopCanvas?):

                TotalPurchaseIndex := (AgentData.CurrentPageIndex * PurchasePerPage) + PurchaseIndex
                if (PurchaseData := ShopPurchases[TotalPurchaseIndex], CastedPrice := int[PurchaseData.PurchasePrice],
                PriceScaler := float[PurchaseData.PriceScalerAfterEachPurchase]):

                    if (PurchaseData.PurchaseType = purchase_type.Empty):
                        Print("Error: Empty Purchase!")
                        return

                    if (PurchaseData.bOneTimePurchase = true, AgentData.Purchases[TotalPurchaseIndex] <> 0):
                        Print("Error: Already Purchased!")
                        return

                    PurchaseCount : int = if (Num := AgentData.Purchases[TotalPurchaseIndex])
                    then Num
                    else 0

                    OwnedGold := GoldConditionalButton.GetItemCount(WidgetMessage.Player, 0)
                    AdditionalPrice : int = if (Num := Int[CastedPrice*PurchaseCount*PriceScaler])
                    then Num
                    else 0

                    Price := CastedPrice + AdditionalPrice

                    if (OwnedGold < Price):
                        Print("Error: Not Enough Gold!")
                        return

                    Print("Purchase Successful.")

                    GoldConditionalButton.SetItemCountRequired(0, Price)
                    GoldConditionalButton.Activate(WidgetMessage.Player)
                    GoldConditionalButton.SetItemCountRequired(0, 1)

                    if (set AgentData.Purchases[TotalPurchaseIndex] += 1){}

                    case(PurchaseData.PurchaseType):
                        purchase_type.HPIncrease => set AgentData.MaxHP += PurchaseData.PowerupValue
                        purchase_type.DamageAmplify => set AgentData.DamageAmplify += PurchaseData.PowerupValue
                        purchase_type.ShieldIncrease => set AgentData.MaxShield += PurchaseData.PowerupValue
                        purchase_type.HPRegen => set AgentData.HPRegen += PurchaseData.PowerupValue
                        purchase_type.ShieldRegen => set AgentData.ShieldRegen += PurchaseData.PowerupValue
                        purchase_type.CriticalChance => set AgentData.CriticalChance += PurchaseData.PowerupValue
                        purchase_type.CriticalStrikeDamage => set AgentData.CriticalStrikeDamageMultiplier += PurchaseData.PowerupValue
                        purchase_type.Empty => # (FROZEN PAWN): Empty On Purpose

                    if (FC := WidgetMessage.Player.GetFortCharacter[]):
                        FC.SetMaxHealth(AgentData.MaxHP)
                        FC.SetMaxShield(AgentData.MaxShield)

                    UpdatePurchaseFrames(WidgetMessage.Player)

        UpdatePurchaseFrames(Agent : agent):void=

            PageTextIndex : int = 4
            PurchaseFrameStartIndex : int = 5

            if (AgentData := AgentMap[Agent], ShopCanvas := AgentData.MaybeShopCanvas?,
            ShopCanvasInner := canvas[ShopCanvas.Slots[0].Widget],
            PageTextBlock := text_block[ShopCanvasInner.Slots[PageTextIndex].Widget]):

                PageTextBlock.SetText(TextForUI4("{AgentData.CurrentPageIndex+1}/{CalculateMaxPages()}"))

                FrameTextIndex := 0
                FrameTextureIndex := 1
                FrameButtonIndex := 2

                for (I := 0 .. PurchasePerPage-1,
                PurchaseFrameCanvas := canvas[ShopCanvasInner.Slots[PurchaseFrameStartIndex+I].Widget],
                TextBlock := text_block[PurchaseFrameCanvas.Slots[FrameTextIndex].Widget],
                TextureBlock := texture_block[PurchaseFrameCanvas.Slots[FrameTextureIndex].Widget],
                ButtonRegular := button_regular[PurchaseFrameCanvas.Slots[FrameButtonIndex].Widget]):

                    var PowerupValue : float = 0.0
                    var PurchaseType : purchase_type = purchase_type.Empty
                    var bPurchaseOnce : logic = true
                    var PriceScaler : float = 0.0
                    var CastedPrice : int = 0
                    if (PurchaseData := ShopPurchases[(AgentData.CurrentPageIndex*PurchasePerPage) + I]):
                        set PowerupValue = PurchaseData.PowerupValue
                        set PurchaseType = PurchaseData.PurchaseType
                        set bPurchaseOnce = PurchaseData.bOneTimePurchase

                        if (ImmPriceScaler := float[PurchaseData.PriceScalerAfterEachPurchase]):
                            set PriceScaler = ImmPriceScaler

                        if (ImmCastedPrice := int[PurchaseData.PurchasePrice]):
                            set CastedPrice = ImmCastedPrice

                    PurchaseCount : int = if (Num := AgentData.Purchases[(AgentData.CurrentPageIndex*PurchasePerPage) + I])
                    then Num
                    else 0

                    AdditionalPrice : int = if (Num := Int[CastedPrice*PurchaseCount*PriceScaler])
                    then Num
                    else 0

                    Price := CastedPrice + AdditionalPrice
                    bPurchased : logic = logic{ PurchaseCount >= 1 }

                    StringsTuple := GenerateFrameStrings(PowerupValue, Price, PurchaseType, bPurchased, bPurchaseOnce)
                    PurchaseString : string = StringsTuple(0)
                    ButtonString : string = StringsTuple(1)

                    TextBlock.SetText(TextForUI4(PurchaseString))
                    ButtonRegular.SetText(TextForUI4(ButtonString))

                    TextureBlock.SetImage(EnumToTexture(PurchaseType))

                    Visibility : widget_visibility = if (PurchaseType = purchase_type.Empty)
                    then widget_visibility.Hidden
                    else widget_visibility.Visible

                    TextBlock.SetVisibility(Visibility)
                    ButtonRegular.SetVisibility(Visibility)
                    TextureBlock.SetVisibility(Visibility)

        CreateShopCanvas():canvas=
            var CanvasSlots : []canvas_slot = array{}

            set CanvasSlots += array
            {
                canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.5, Y := 0.5 }, Maximum := vector2{ X := 0.5, Y := 0.5 } }
                    Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.5, Y := 0.5 }
                    SizeToContent := true
                    Widget := CreateShopCanvasInner()
            }

            Canvas : canvas = canvas:
                Slots := CanvasSlots

            return Canvas

        CreateShopCanvasInner():canvas=
            var CanvasSlots : []canvas_slot = array{}

            MaxPages := CalculateMaxPages()

            BGSize := vector2{ X := 1280.0, Y := 720.0 }
            set CanvasSlots += array
            {
                CanvasSlot0 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.0, Y := 0.0 }, Maximum := vector2{ X := 0.0, Y := 0.0 } }
                    Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.0, Y := 0.0 }
                    SizeToContent := true
                    Widget := texture_block{ DefaultImage := PowerShop.T_ShopBG, DefaultDesiredSize := BGSize }
            }

            var PageButtonString : string = ""
            WhiteSpaceCount := 14
            for (I := 1 .. WhiteSpaceCount):
                set PageButtonString += " "
            set PageButtonString += "\n"
            for (I := 1 .. WhiteSpaceCount):
                set PageButtonString += " "
            set CanvasSlots += array
            {
                CanvasSlot1 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.0, Y := 1.0 }, Maximum := vector2{ X := 0.0, Y := 1.0 } }
                    Offsets := margin{ Top := -26.0, Left := 76.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.0, Y := 1.0 }
                    SizeToContent := true
                    Widget := button_regular{ DefaultText := TextForUI4(PageButtonString) }
            }
            if (ButtonRegular := button_regular[CanvasSlots[CanvasSlots.Length-1].Widget]):
                ButtonRegular.OnClick().Subscribe(OnPagePrevClicked)

            set CanvasSlots += array
            {
                CanvasSlot2 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 1.0, Y := 1.0 }, Maximum := vector2{ X := 1.0, Y := 1.0 } }
                    Offsets := margin{ Top := -26.0, Left := -76.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 1.0, Y := 1.0 }
                    SizeToContent := true
                    Widget := button_regular{ DefaultText := TextForUI4(PageButtonString) }
            }
            if (ButtonRegular := button_regular[CanvasSlots[CanvasSlots.Length-1].Widget]):
                ButtonRegular.OnClick().Subscribe(OnPageNextClicked)

            var CloseButtonString : string = ""
            WhiteSpaceCount2 := 12
            for (I := 1 .. WhiteSpaceCount2):
                set CloseButtonString += " "
            set CloseButtonString += "\n"
            for (I := 1 .. WhiteSpaceCount2):
                set CloseButtonString += " "
            set CanvasSlots += array
            {
                CanvasSlot3 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 1.0, Y := 0.0 }, Maximum := vector2{ X := 1.0, Y := 0.0 } }
                    Offsets := margin{ Top := 12.0, Left := -76.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 1.0, Y := 0.0 }
                    SizeToContent := true
                    Widget := button_regular{ DefaultText := TextForUI4(CloseButtonString) }
            }
            if (ButtonRegular := button_regular[CanvasSlots[CanvasSlots.Length-1].Widget]):
                ButtonRegular.OnClick().Subscribe(OnPageCloseClicked)

            set CanvasSlots += array
            {
                CanvasSlot4 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.5, Y := 1.0 }, Maximum := vector2{ X := 0.5, Y := 1.0 } }
                    Offsets := margin{ Top := -68.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.5, Y := 1.0 }
                    SizeToContent := true
                    Widget := text_block{ DefaultText := TextForUI4("1/{MaxPages}"), DefaultShadowColor := NamedColors.Black,
                    DefaultShadowOpacity := 1.0, DefaultShadowOffset := option{ vector2{ X := 2.0, Y := 2.0 }}, DefaultTextColor := NamedColors.White }
            }

            for (I := 0 .. PurchasePerPage-1):

                XAnchorOffset : float = if (I = 1)
                then 0.0
                else 0.325

                XAnchorOffsetSign : float = if (I = 0)
                then -1.0
                else 1.0

                TotalXAnchorOffset := XAnchorOffset * XAnchorOffsetSign

                set CanvasSlots += array
                {
                    CanvasSlot5 := canvas_slot:
                        Anchors := anchors{ Minimum := vector2{ X := 0.5+TotalXAnchorOffset, Y := 0.45 }, Maximum := vector2{ X := 0.5+TotalXAnchorOffset, Y := 0.45 } }
                        Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                        Alignment := vector2{ X := 0.5, Y := 0.5 }
                        SizeToContent := true
                        Widget := CreateFrameCanvas(0.0, 0, purchase_type.Empty, false, false, I)
                }

            Canvas : canvas = canvas:
                Slots := CanvasSlots

            return Canvas

        CreateFrameCanvas(PowerupValue : float, PurchasePrice : int, PurchaseType : purchase_type,
        bPurchased : logic, bPurchaseOnce : logic, FrameIndex : int):canvas=
            var CanvasSlots : []canvas_slot = array{}

            StringsTuple := GenerateFrameStrings(PowerupValue, PurchasePrice, PurchaseType, bPurchased, bPurchaseOnce)
            PurchaseString : string = StringsTuple(0)
            ButtonString : string = StringsTuple(1)

            FrameTextureSize := vector2{ X := 192.0, Y := 192.0 }

            set CanvasSlots += array
            {
                canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.5, Y := 0.5 }, Maximum := vector2{ X := 0.5, Y := 0.5 } }
                    Offsets := margin{ Top := -(FrameTextureSize.Y/2.0 + 46.0), Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.5, Y := 1.0 }
                    SizeToContent := true
                    Widget := text_block{ DefaultText := TextForUI4(PurchaseString), DefaultShadowColor := NamedColors.Black,
                    DefaultShadowOpacity := 1.0, DefaultShadowOffset := option{ vector2{ X := 2.0, Y := 2.0 }}, DefaultTextColor := NamedColors.White }
            }

            set CanvasSlots += array
            {
                canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.5, Y := 0.5 }, Maximum := vector2{ X := 0.5, Y := 0.5 } }
                    Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.5, Y := 0.5 }
                    SizeToContent := true
                    Widget := texture_block{ DefaultImage := EnumToTexture(PurchaseType), DefaultDesiredSize := FrameTextureSize }
            }

            set CanvasSlots += array
            {
                canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.5, Y := 0.5 }, Maximum := vector2{ X := 0.5, Y := 0.5 } }
                    Offsets := margin{ Top := (FrameTextureSize.Y/2.0 + 72.0), Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.5, Y := 0.0 }
                    SizeToContent := true
                    Widget := button_regular{ DefaultText := TextForUI4(ButtonString) }
            }
            if (ButtonRegular := button_regular[CanvasSlots[CanvasSlots.Length-1].Widget]):
                if (FrameIndex = 0):
                    ButtonRegular.OnClick().Subscribe(OnPurchaseClicked0)
                else if (FrameIndex = 1):
                    ButtonRegular.OnClick().Subscribe(OnPurchaseClicked1)
                else if (FrameIndex = 2):
                    ButtonRegular.OnClick().Subscribe(OnPurchaseClicked2)

            Canvas : canvas = canvas:
                Slots := CanvasSlots

            return Canvas