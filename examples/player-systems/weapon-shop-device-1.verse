# Interactive Weapon Shop UI
# Creates a comprehensive weapon purchasing system with a visual UI displaying different weapon categories (pistols, SMGs, rifles, shotguns, snipers, heavy weapons) organized by type with custom texture
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/weapon-shop-device-1?ref=github


using { /Fortnite.com/UI }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Colors }
using { /Verse.org/Assets }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }

WeaponShopModule := module:

    # IMPORTANT(frozenpawn): SWAP THESE TEXTURES WITH YOUR OWN, IF YOU WANT TO CHANGE.
    SideArmTextures : []texture = array
    {
        Textures.T_Pistol_BasicGun,
        Textures.T_Pistol_Deagle,
        Textures.T_Pistol_Goldgun,
        Textures.T_Pistol_OldRevolver,
        Textures.T_Pistol_Revolver
    }

    SMGTextures : []texture = array
    {
        Textures.T_Smg_HeistedBlink,
        Textures.T_Smg_Submachine
    }

    ShotgunTextures : []texture = array
    {        
        Textures.T_Shotgun_pump,
        Textures.T_Shotgun_Tactical
    }

    RifleTextures : []texture = array
    {        
        Textures.T_Rifle_Assault,
        Textures.T_Rifle_M4a1,
        Textures.T_Rifle_m4a4,
        Textures.T_Rifle_Scar
    }

    SniperTextures : []texture = array
    {
        Textures.T_Sniper_Awm,
        Textures.T_Sniper_SkAwm
    }

    HeavyTextures : []texture = array
    {
        Textures.T_Heavy_BombLauncher,
        Textures.T_Heavy_Rpg
    }

    ShieldTexture : texture = Textures.T_Shield_Icon
    HealthTexture : texture = Textures.T_Health_Icon
    # -----------------------------------------------

    item_type := enum:
        SideArm,
        SMG,
        Rifle,
        Shotgun,
        Sniper,
        Heavy

    agent_data := class:
        var bShopOnDisplay : logic = false
        var MaybeShopCanvas : ?canvas = false
        var PurchasedCells : []tuple(int,int) = array{}

        var RowIndex : int = 0
        var ColIndex : int = 0

    item_data := class<concrete>:
        @editable
        Price : type {_X:int where _X >= 0} = 0
        @editable
        UITextureSizeRatioX : type {_X:float where _X >= 0.0} = 1.0
        @editable
        UITextureSizeRatioY : type {_X:float where _X >= 0.0} = 1.0
        @editable
        ItemGranterIndex : type {_X:int where _X >= 0} = 0

        var UITexture : texture = Textures.T_Pistol_BasicGun

    weapon_shop_device := class(creative_device):        

        @editable
        ShopItemGranter : item_granter_device = item_granter_device{}

        @editable
        SideArm1 : item_data = item_data{}
        @editable
        SideArm2 : item_data = item_data{}
        @editable
        SideArm3 : item_data = item_data{}
        @editable
        SideArm4 : item_data = item_data{}
        @editable
        SideArm5 : item_data = item_data{}

        @editable
        SMG1 : item_data = item_data{}
        @editable
        SMG2 : item_data = item_data{}

        @editable
        Shotgun1 : item_data = item_data{}
        @editable
        Shotgun2 : item_data = item_data{}

        @editable
        Rifle1 : item_data = item_data{}
        @editable
        Rifle2 : item_data = item_data{}
        @editable
        Rifle3 : item_data = item_data{}
        @editable
        Rifle4 : item_data = item_data{}

        @editable
        Sniper1 : item_data = item_data{}
        @editable
        Sniper2 : item_data = item_data{}

        @editable
        Heavy1 : item_data = item_data{}
        @editable
        Heavy2 : item_data = item_data{}        

        @editable
        ShieldPrice : type {_X:int where _X >= 0} = 0
        @editable
        ShieldAmount : type {_X:int where _X >= 0} = 0
        @editable
        ShieldIconSizeRatioX : type {_X:float where _X >= 0.0} = 1.0
        @editable
        ShieldIconSizeRatioY : type {_X:float where _X >= 0.0} = 1.0

        @editable
        HealthPrice : type {_X:int where _X >= 0} = 0
        @editable
        HealthAmount : type {_X:int where _X >= 0} = 0
        @editable
        HealthIconSizeRatioX : type {_X:float where _X >= 0.0} = 1.0
        @editable
        HealthIconSizeRatioY : type {_X:float where _X >= 0.0} = 1.0

        @editable
        ShopDisplayTriggerForAll : trigger_device = trigger_device{}
        @editable
        ShopDisplayTriggerPerAgent : trigger_device = trigger_device{}
        @editable
        ShopDisplaySeconds : type {_X:int where _X >= 1} = 60

        @editable
        UISizeRatio : type {_X:float where _X >= 0.0, _X <= 1.0} = 0.45

        @editable
        InputUp : input_trigger_device = input_trigger_device{}
        @editable
        InputDown : input_trigger_device = input_trigger_device{}
        @editable
        InputRight : input_trigger_device = input_trigger_device{}
        @editable
        InputLeft : input_trigger_device = input_trigger_device{}
        @editable
        InputPurchase : input_trigger_device = input_trigger_device{}
        @editable
        InputShopExit : input_trigger_device = input_trigger_device{}

        @editable
        UITraverseSound : audio_player_device = audio_player_device{}
        @editable
        PurchaseSound : audio_player_device = audio_player_device{}

        @editable
        GoldConditionalButtonToCount : conditional_button_device = conditional_button_device{}
        @editable
        GoldConditionalButtonToSpend : conditional_button_device = conditional_button_device{}

        @editable
        ShopTimer : timer_device = timer_device{}

        TextForUI<localizes>(Text : string) : message = "{Text}"
        ColCount : int = 5
        FirstRowCount : int = 5
        InBetweenRowCount : int = 4
        LastRowCount : int = 2
        PurchasedOpacity : float = 0.75
        ShowOpacity : float = 0.5
        HideOpacity : float = 0.0

        var SideArms : []item_data = array{}
        var SMGs : []item_data = array{}
        var Shotguns : []item_data = array{}
        var Rifles : []item_data = array{}
        var Snipers : []item_data = array{}
        var Heavies : []item_data = array{}
        var ShieldArr : []item_data = array{}
        var HealthArr : []item_data = array{}

        var AgentMap : [agent]agent_data = map{}

        OnBegin<override>()<suspends>:void=
            Print("OnBegin")

            set SideArms = array{ SideArm1, SideArm2, SideArm3, SideArm4, SideArm5 }
            set SMGs = array{ SMG1, SMG2 }
            set Shotguns = array{ Shotgun1, Shotgun2 }
            set Rifles = array{ Rifle1, Rifle2, Rifle3, Rifle4 }
            set Snipers = array{ Sniper1, Sniper2 }
            set Heavies = array{ Heavy1, Heavy2 }
            set ShieldArr = array
            {
                item_data
                {
                    Price := ShieldPrice, UITextureSizeRatioX := ShieldIconSizeRatioX,
                    UITextureSizeRatioY := ShieldIconSizeRatioY, ItemGranterIndex := 0
                }
            }
            set HealthArr = array
            {
                item_data
                {
                    Price := HealthPrice, UITextureSizeRatioX := HealthIconSizeRatioX,
                    UITextureSizeRatioY := HealthIconSizeRatioY, ItemGranterIndex := 0
                }
            }

            if (set ShieldArr[0].UITexture = ShieldTexture){}
            if (set HealthArr[0].UITexture = HealthTexture){}

            var ItemDataLen : int = SideArms.Length
            for (I := 0 .. ItemDataLen-1, UITexture := SideArmTextures[I], ItemData := SideArms[I]):
                set ItemData.UITexture = UITexture

            set ItemDataLen = SMGs.Length
            for (I := 0 .. ItemDataLen-1, UITexture := SMGTextures[I], ItemData := SMGs[I]):
                set ItemData.UITexture = UITexture

            set ItemDataLen = Shotguns.Length
            for (I := 0 .. ItemDataLen-1, UITexture := ShotgunTextures[I], ItemData := Shotguns[I]):
                set ItemData.UITexture = UITexture

            set ItemDataLen = Rifles.Length
            for (I := 0 .. ItemDataLen-1, UITexture := RifleTextures[I], ItemData := Rifles[I]):
                set ItemData.UITexture = UITexture

            set ItemDataLen = Snipers.Length
            for (I := 0 .. ItemDataLen-1, UITexture := SniperTextures[I], ItemData := Snipers[I]):
                set ItemData.UITexture = UITexture

            set ItemDataLen = Heavies.Length
            for (I := 0 .. ItemDataLen-1, UITexture := HeavyTextures[I], ItemData := Heavies[I]):
                set ItemData.UITexture = UITexture

            ShopDisplayTriggerForAll.TriggeredEvent.Subscribe(OnShopDisplayTriggeredForAll)
            ShopDisplayTriggerPerAgent.TriggeredEvent.Subscribe(OnShopDisplayTriggeredPerAgent)        

            InputUp.PressedEvent.Subscribe(OnPressedUp)
            InputDown.PressedEvent.Subscribe(OnPressedDown)
            InputRight.PressedEvent.Subscribe(OnPressedRight)
            InputLeft.PressedEvent.Subscribe(OnPressedLeft)
            InputPurchase.PressedEvent.Subscribe(OnPressedPurchase)
            InputShopExit.PressedEvent.Subscribe(OnPressedExit)

            ShopTimer.SetMaxDuration(ShopDisplaySeconds*1.0)

        OnPressedExit(Agent : agent):void=
            Print("OnPressedExit")

            if (Player := player[Agent]):
                ShopClose(Player)

        OnPressedPurchase(Agent : agent):void=
            Print("OnPressedPurchase")

            if (AgentData := AgentMap[Agent]):

                # (frozenpawn): Can't purchase if purchased before.
                var bPurchasedBefore : logic = false
                for (PurchasedCell : AgentData.PurchasedCells,
                PurchasedCell(0) = AgentData.RowIndex, PurchasedCell(1) = AgentData.ColIndex):
                    set bPurchasedBefore = true

                if (bPurchasedBefore = true):
                    return

                # (frozenpawn): Check for enough gold.
                ItemData := RowColToItemData(AgentData.RowIndex, AgentData.ColIndex)
                GoldCount := GoldConditionalButtonToCount.GetItemCount(Agent, 0)
                if (ItemData.Price > GoldCount):
                    return

                # (frozenpawn): Spend the gold.
                GoldConditionalButtonToSpend.SetItemCountRequired(0, ItemData.Price)
                GoldConditionalButtonToSpend.Activate(Agent)

                # (frozenpawn): Mark the ui cell as purchased.
                if (ShopCanvas := AgentData.MaybeShopCanvas?):
                    MarkCell(ShopCanvas, AgentData.RowIndex, AgentData.ColIndex, true)

                # (frozenpawn): Grant the item.
                # Handle the edge case for health and shield.
                if (AgentData.ColIndex = ColCount-1):                    
                    if (FC := Agent.GetFortCharacter[]):

                        # (frozenpawn): Increase shield.
                        if (AgentData.RowIndex = 0):
                            CurShield := FC.GetMaxShield()
                            FC.SetMaxShield(CurShield + ShieldAmount*1.0)
                            FC.SetShield(CurShield + ShieldAmount*1.0)

                        # (frozenpawn): Increase health.
                        else:
                            CurHealth := FC.GetMaxHealth()
                            FC.SetMaxHealth(CurHealth + HealthAmount*1.0)
                            FC.SetHealth(CurHealth + HealthAmount*1.0)

                else:
                    ShopItemGranter.GrantItemIndex(Agent, ItemData.ItemGranterIndex)

                # (frozenpawn): Save the cell as purchased.
                set AgentData.PurchasedCells += array{ (AgentData.RowIndex, AgentData.ColIndex) }

                PurchaseSound.Play(Agent)

        OnPressedUp(Agent : agent):void=
            Print("OnPressedUp")
            OnPressedDirection(Agent, -1, 0)

        OnPressedDown(Agent : agent):void=
            Print("OnPressedDown")
            OnPressedDirection(Agent, 1, 0)

        OnPressedRight(Agent : agent):void=
            Print("OnPressedRight")
            OnPressedDirection(Agent, 0, 1)

        OnPressedLeft(Agent : agent):void=
            Print("OnPressedLeft")
            OnPressedDirection(Agent, 0, -1)

        OnPressedDirection(Agent : agent, RowChange : int, ColChange : int):void=
            Print("OnPressedDirection")

            if (AgentData := AgentMap[Agent], AgentData.bShopOnDisplay = true,
            ShopCanvas := AgentData.MaybeShopCanvas?):

                UITraverseSound.Play(Agent)

                # (frozenpawn): Hide the old.
                SetColorBlockValue(ShopCanvas, AgentData.RowIndex, AgentData.ColIndex, HideOpacity, false)

                var CurrentRowCount : int = InBetweenRowCount
                if (AgentData.ColIndex = 0):
                    set CurrentRowCount = FirstRowCount
                else if (AgentData.ColIndex = ColCount-1):
                    set CurrentRowCount = LastRowCount

                var NewRowIndex : int = AgentData.RowIndex + RowChange
                var NewColIndex : int = AgentData.ColIndex + ColChange

                if (ColChange = 0):
                    if (NewRowIndex < 0):
                        set NewRowIndex = CurrentRowCount-1

                    else if (NewRowIndex >= CurrentRowCount):
                        set NewRowIndex = 0

                else if (RowChange = 0):
                    if (NewColIndex < 0):
                        set NewColIndex = ColCount-1

                    else if (NewColIndex >= ColCount):
                        set NewColIndex = 0

                    # (frozenpawn): Edge case for the first col and last col.
                    # The first col has one more row. The last col has only two rows.
                    if (AgentData.ColIndex = 0):
                        if (ColChange = 1 and AgentData.RowIndex >= InBetweenRowCount):
                            set NewRowIndex = InBetweenRowCount-1

                        else if (ColChange = -1 and AgentData.RowIndex >= LastRowCount):
                            set NewRowIndex = LastRowCount-1

                    # (frozenpawn): First two rows goes to the first row.
                    # Last two rows goes to the last row.
                    if ((AgentData.ColIndex = ColCount-2 and ColChange = 1) or (AgentData.ColIndex = 0 and ColChange = -1)):
                        set NewRowIndex = if (AgentData.RowIndex <= 1)
                        then 0
                        else 1

                    else if (AgentData.ColIndex = ColCount-2 and AgentData.RowIndex >= LastRowCount and
                    ColChange = 1):
                        set NewRowIndex = LastRowCount-1

                Print("RowCol: {AgentData.RowIndex}, {AgentData.ColIndex} | NewRowCol: {NewRowIndex}, {NewColIndex}")
                set AgentData.RowIndex = NewRowIndex
                set AgentData.ColIndex = NewColIndex                

                # (frozenpawn): Show the new.
                SetColorBlockValue(ShopCanvas, AgentData.RowIndex, AgentData.ColIndex, ShowOpacity, false)

        OnShopDisplayTriggeredForAll(MaybeAgent : ?agent):void=
            Print("OnShopDisplayTriggeredForAll")

            for (Player : GetPlayspace().GetPlayers()):
                OnShopDisplayTriggeredPerAgent(option{Player})

        OnShopDisplayTriggeredPerAgent(MaybeAgent : ?agent):void=
            Print("OnShopDisplayTriggeredPerAgent")

            if (Agent := MaybeAgent?, Player := player[Agent]):                

                # (frozenpawn): Instantiation of the shop canvas.
                if (not AgentMap[Player]):
                    AgentData := agent_data{}
                    ShopCanvas := CreateShopCanvas()

                    set AgentData.MaybeShopCanvas = option{ ShopCanvas }
                    if (set AgentMap[Player] = AgentData){}

                if (AgentData := AgentMap[Player], AgentData.bShopOnDisplay = false,
                ShopCanvas := AgentData.MaybeShopCanvas?, PlayerUI := GetPlayerUI[Player]):
                    PlayerUI.AddWidget(ShopCanvas)
                    set AgentData.bShopOnDisplay = true

                    SetColorBlockValue(ShopCanvas, AgentData.RowIndex, AgentData.ColIndex, ShowOpacity, false)

                    InputUp.Register(Agent)
                    InputDown.Register(Agent)
                    InputRight.Register(Agent)
                    InputLeft.Register(Agent)
                    InputPurchase.Register(Agent)
                    InputShopExit.Register(Agent)

                if (FC := Agent.GetFortCharacter[]):
                    FC.PutInStasis(stasis_args{})

                ShopTimer.Start(Agent)
                spawn{ LateShopClose(Player) }

        # (frozenpawn): Close the shop after the determined seconds.
        LateShopClose(Player : player)<suspends>:void=
            Print("LateShopClose")

            Sleep(ShopDisplaySeconds*1.0)
            ShopClose(Player)

        ShopClose(Player : player):void=
            Print("ShopClose")

            ShopTimer.Reset(Player)

            if (AgentData := AgentMap[Player], AgentData.bShopOnDisplay = true,
            PlayerUI := GetPlayerUI[Player], ShopCanvas := AgentData.MaybeShopCanvas?):
                PlayerUI.RemoveWidget(ShopCanvas)
                set AgentData.bShopOnDisplay = false

                # (frozenpawn): Unmark all cells.
                # All rows of all columns except the last column.
                for (ColIndex := 0 .. ColCount-2):
                    for (RowIndex := 0 .. InBetweenRowCount-1):
                        MarkCell(ShopCanvas, RowIndex, ColIndex, false)

                # (frozenpawn): Last column.
                for (RowIndex := 0 .. LastRowCount-1):
                    MarkCell(ShopCanvas, RowIndex, ColCount-1, false)

                # (frozenpawn): Last row of the first column.
                MarkCell(ShopCanvas, FirstRowCount-1, 0, false)                
                set AgentData.PurchasedCells = array{}

                InputUp.Unregister(Player)
                InputDown.Unregister(Player)
                InputRight.Unregister(Player)
                InputLeft.Unregister(Player)
                InputPurchase.Unregister(Player)
                InputShopExit.Unregister(Player)

                set AgentData.RowIndex = 0
                set AgentData.ColIndex = 0

                if (FC := Player.GetFortCharacter[]):
                    FC.ReleaseFromStasis()

        MarkCell(ShopCanvas : canvas, RowIndex : int, ColIndex : int, bPurchase : logic):void=
            Print("MarkCell")

            if (ShopCanvasInner := canvas[ShopCanvas.Slots[0].Widget]):
                SlotIndex := RowColToSlot(RowIndex, ColIndex)

                var OpacityToSet : float = PurchasedOpacity
                var TextToSet : string = "OWNED"

                if (bPurchase = false):
                    set OpacityToSet = 0.0
                    ItemData := RowColToItemData(RowIndex, ColIndex)
                    set TextToSet = "💲{ItemData.Price}"

                var RowIndexDecreaseAmount : int = 0
                if ((ColIndex = 1 and RowIndex > 1) or (ColIndex = 3 and RowIndex > 1)):
                    set RowIndexDecreaseAmount = 2
                else if (ColIndex = ColCount-1 and RowIndex > 0):
                    set RowIndexDecreaseAmount = 1

                ActualRowIndex := RowIndex-RowIndexDecreaseAmount

                # (frozenpawn): '+1' for the ColCanvas Slots, because the first one is the title.
                TextBlockIndex := 2
                ColorBlockIndex := 3                
                if (ColCanvas := canvas[ShopCanvasInner.Slots[SlotIndex].Widget],
                CellCanvas := canvas[ColCanvas.Slots[ActualRowIndex+1].Widget],
                TextBlock := text_block[CellCanvas.Slots[TextBlockIndex].Widget],
                ColorBlock := color_block[CellCanvas.Slots[ColorBlockIndex].Widget],
                ConvertedOpacityValue := type {_X:float where 0.000000 <= _X, _X <= 1.000000}[OpacityToSet]):

                    TextBlock.SetText(TextForUI(TextToSet))
                    ColorBlock.SetOpacity(ConvertedOpacityValue)

        SetColorBlockValue(ShopCanvas : canvas, RowIndex : int, ColIndex : int, OpacityValue : float, bEnforce : logic):void=
            Print("SetColorBlockValue")

            if (ShopCanvasInner := canvas[ShopCanvas.Slots[0].Widget]):
                SlotIndex := RowColToSlot(RowIndex, ColIndex)

                var RowIndexDecreaseAmount : int = 0
                if ((ColIndex = 1 and RowIndex > 1) or (ColIndex = 3 and RowIndex > 1)):
                    set RowIndexDecreaseAmount = 2
                else if (ColIndex = ColCount-1 and RowIndex > 0):
                    set RowIndexDecreaseAmount = 1

                ActualRowIndex := RowIndex-RowIndexDecreaseAmount

                # (frozenpawn): '+1' for the ColCanvas Slots, because the first one is the title.
                ColorBlockIndex := 3
                if (ColCanvas := canvas[ShopCanvasInner.Slots[SlotIndex].Widget],
                CellCanvas := canvas[ColCanvas.Slots[ActualRowIndex+1].Widget],
                ColorBlock := color_block[CellCanvas.Slots[ColorBlockIndex].Widget],
                ConvertedOpacityValue := type {_X:float where 0.000000 <= _X, _X <= 1.000000}[OpacityValue]):
                    Print("Cell ActualRow, Col: {ActualRowIndex}, {ColIndex}")

                    ActiveOpacity := ColorBlock.GetOpacity()
                    var bSetOpacity : logic = true

                    # (frozenpawn): Making sure purhcased opacity only changes when enforced.
                    if (IsAlmostEqual[ActiveOpacity, PurchasedOpacity, 0.01]):
                        set bSetOpacity = bEnforce

                    if (bSetOpacity = true):
                        ColorBlock.SetOpacity(ConvertedOpacityValue)

        RowColToSlot(RowIndex : int, ColIndex : int):int=
            Print("RowColToSlot")
            # ColumnIndex | SlotIndex
            # 0 | 0
            # 1 | 1 - 2 (Increase if RowIndex > 1)
            # 2 | 3
            # 3 | 4 - 5 (Increase if RowIndex > 1)
            # 4 | 6 - 7 (Increase if RowIndex > 0)

            var SlotIndex : int = -1

            SlotBaseIndexes : []int = array
            { 0, 1, 3, 4, 6 }            

            if (SlotBaseIndex := SlotBaseIndexes[ColIndex]):
                set SlotIndex = SlotBaseIndex

            if ((ColIndex = 1 and RowIndex > 1) or (ColIndex = 3 and RowIndex > 1) or
            (ColIndex = 4 and RowIndex > 0)):
                set SlotIndex += 1            

            Print("RowCol: {RowIndex}, {ColIndex} | SlotIndex: {SlotIndex}")
            return SlotIndex

        RowColToItemData(RowIndex : int, ColIndex : int):item_data=
            Print("RowColToItemData: {RowIndex}, {ColIndex}")
            # ColumnIndex | Array
            # 0 | SideArms
            # 1 | SMGs - Shotguns (Increase if RowIndex > 1)
            # 2 | Rifles
            # 3 | Snipers - Heavies (Increase if RowIndex > 1)
            # 4 | ShieldArr - HealthArr (Increase if RowIndex > 0)

            var ItemData  : item_data = item_data{}

            if (ColIndex = 0):
                if (ImmItemData := SideArms[RowIndex]):
                    Print("SideArms {RowIndex}")
                    set ItemData = ImmItemData

            else if (ColIndex = 1):
                if (RowIndex <= 1):
                    if (ImmItemData := SMGs[RowIndex]):
                        Print("SMGs {RowIndex}")
                        set ItemData = ImmItemData

                else:
                    if (ImmItemData := Shotguns[RowIndex-2]):
                        Print("Shotguns {RowIndex-2}")
                        set ItemData = ImmItemData

            else if (ColIndex = 2):
                if (ImmItemData := Rifles[RowIndex]):
                    Print("Rifles {RowIndex}")
                    set ItemData = ImmItemData

            else if (ColIndex = 3):
                if (RowIndex <= 1):
                    if (ImmItemData := Snipers[RowIndex]):
                        Print("Snipers {RowIndex}")
                        set ItemData = ImmItemData

                else:
                    if (ImmItemData := Heavies[RowIndex-2]):
                        Print("Heavies {RowIndex-2}")
                        set ItemData = ImmItemData

            else if (ColIndex = 4):
                if (RowIndex <= 0):
                    if (ImmItemData := ShieldArr[RowIndex]):
                        Print("Shield")
                        set ItemData = ImmItemData

                else:
                    if (ImmItemData := HealthArr[RowIndex-1]):
                        Print("Health")
                        set ItemData = ImmItemData

            return ItemData

        CreateShopCanvas():canvas=
            Print("CreateShopCanvas")

            var CanvasSlots : []canvas_slot = array{}

            set CanvasSlots += array
            {
                CanvasSlot0 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.5, Y := 0.5 }, Maximum := vector2{ X := 0.5, Y := 0.5 }}
                    Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.5, Y := 0.5 }
                    SizeToContent := true
                    ZOrder := 1
                    Widget := CreateShopCanvasInner()
            }

            Canvas := canvas:
                Slots := CanvasSlots

            return Canvas

        CreateShopCanvasInner():canvas=
            Print("CreateShopCanvasInner")

            # (frozenpawn): Takin the first column (side arms column) as the target height.
            # Then resizing all the others to match that height.

            TitleY := 22.0

            VerticalSpaceBetweenSlots := 4.0
            VerticalSpaceWithTitle := 8.0

            SMGShotgun_BaseSlotSize := vector2{ X := 512.0, Y := 309.0 }
            Rifle_BaseSlotSize := vector2{ X := 615.0, Y := 345.0 }
            SniperHeavy_BaseSlotSize := vector2{ X := 715.0, Y := 330.0 }
            ShieldHealth_BaseSlotSize := vector2{ X := 353.0, Y := 673.0 }

            SideArm_BaseSlotSize := vector2{ X := 352.0, Y := 276.0 }
            SideArm_Ratio := UISizeRatio
            SideArm_SlotSize := vector2{ X := SideArm_BaseSlotSize.X*SideArm_Ratio,
            Y := SideArm_BaseSlotSize.Y*SideArm_Ratio }

            SideArmCount := 5
            SideArmColumnHeight := (SideArmCount * SideArm_SlotSize.Y) +
            (SideArmCount * VerticalSpaceBetweenSlots) + TitleY

            SMGCount := 2
            ShotgunCount := 2
            SMGShotgunCount := SMGCount+ShotgunCount
            SMGShotgunColumnHeightWithoutSlots := SMGShotgunCount*VerticalSpaceBetweenSlots +
            2*TitleY + VerticalSpaceWithTitle
            SMGShotgunSlotY := (SideArmColumnHeight - SMGShotgunColumnHeightWithoutSlots) / (SMGShotgunCount*1.0)

            RifleCount := 4
            RifleColumnHeightWithoutSlots := RifleCount*VerticalSpaceBetweenSlots +
            TitleY
            RifleSlotY := (SideArmColumnHeight - RifleColumnHeightWithoutSlots) / (RifleCount*1.0)

            SniperCount := 2
            HeavyCount := 2
            SniperHeavyCount := SniperCount+HeavyCount
            SniperHeavyColumnHeightWithoutSlots := SniperHeavyCount*VerticalSpaceBetweenSlots +
            2*TitleY + VerticalSpaceWithTitle
            SniperHeavySlotY := (SideArmColumnHeight - SniperHeavyColumnHeightWithoutSlots) / (SniperHeavyCount*1.0)

            ShieldHealthCount := 2
            ShieldHealthColumnHeightWithoutSlots := ShieldHealthCount*VerticalSpaceBetweenSlots +
            2*TitleY + VerticalSpaceWithTitle
            ShieldHealthSlotY := (SideArmColumnHeight - ShieldHealthColumnHeightWithoutSlots) / (ShieldHealthCount*1.0)

            # (frozenpawn): Calculate the actual size for all the columns.
            SMGShotgun_Ratio := SMGShotgunSlotY / SMGShotgun_BaseSlotSize.Y
            SMGShotgun_SlotSize := vector2{ X :=  SMGShotgun_Ratio*SMGShotgun_BaseSlotSize.X, Y := SMGShotgunSlotY }

            Rifle_Ratio := RifleSlotY / Rifle_BaseSlotSize.Y
            Rifle_SlotSize := vector2{ X := Rifle_Ratio*Rifle_BaseSlotSize.X, Y := RifleSlotY }

            SniperHeavy_Ratio := SniperHeavySlotY / SniperHeavy_BaseSlotSize.Y
            SniperHeavy_SlotSize := vector2{ X :=  SniperHeavy_Ratio*SniperHeavy_BaseSlotSize.X, Y := SniperHeavySlotY }

            ShieldHealth_Ratio := ShieldHealthSlotY / ShieldHealth_BaseSlotSize.Y
            ShieldHealth_SlotSize := vector2{ X :=  ShieldHealth_Ratio*ShieldHealth_BaseSlotSize.X, Y := ShieldHealthSlotY }

            WidthBetweenColumns := 40.0
            var CanvasSlots : []canvas_slot = array{}

            # (frozenpawn): Create the column for side arms.
            var CumulativeLeftOffset : float = 0.0
            set CanvasSlots += array
            {
                CanvasSlot0 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.0, Y := 0.0 }, Maximum := vector2{ X := 0.0, Y := 0.0 } }
                    Offsets := margin{ Top := 0.0, Left := CumulativeLeftOffset, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.0, Y := 0.0 }
                    SizeToContent := true
                    ZOrder := 1
                    Widget := CreateShopColumnCanvas(SideArms, Textures.T_SidearmTitle,
                    TitleY, Textures.T_Sidearm_BG, SideArm_SlotSize, VerticalSpaceBetweenSlots)
            }

            # (frozenpawn): Create column for smg, then shotgun (need half size)
            SMGShotgunHalfHeight := TitleY + SMGCount*VerticalSpaceBetweenSlots + VerticalSpaceWithTitle +
            SMGCount*SMGShotgun_SlotSize.Y

            set CumulativeLeftOffset += WidthBetweenColumns + SideArm_SlotSize.X            
            set CanvasSlots += array
            {
                CanvasSlot1 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.0, Y := 0.0 }, Maximum := vector2{ X := 0.0, Y := 0.0 } }
                    Offsets := margin{ Top := 0.0, Left := CumulativeLeftOffset, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.0, Y := 0.0 }
                    SizeToContent := true
                    ZOrder := 1
                    Widget := CreateShopColumnCanvas(SMGs, Textures.T_SmgTitle,
                    TitleY, Textures.T_Smgs_BG, SMGShotgun_SlotSize, VerticalSpaceBetweenSlots)
            }
            set CanvasSlots += array
            {
                CanvasSlot2 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.0, Y := 0.0 }, Maximum := vector2{ X := 0.0, Y := 0.0 } }
                    Offsets := margin{ Top := SMGShotgunHalfHeight, Left := CumulativeLeftOffset, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.0, Y := 0.0 }
                    SizeToContent := true
                    ZOrder := 1
                    Widget := CreateShopColumnCanvas(Shotguns, Textures.T_ShotgunTitle,
                    TitleY, Textures.T_Shotgun_BG, SMGShotgun_SlotSize, VerticalSpaceBetweenSlots)
            }

            # (frozenpawn): Create column for rifle
            set CumulativeLeftOffset += WidthBetweenColumns + SMGShotgun_SlotSize.X
            set CanvasSlots += array
            {
                CanvasSlot3 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.0, Y := 0.0 }, Maximum := vector2{ X := 0.0, Y := 0.0 } }
                    Offsets := margin{ Top := 0.0, Left := CumulativeLeftOffset, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.0, Y := 0.0 }
                    SizeToContent := true
                    ZOrder := 1
                    Widget := CreateShopColumnCanvas(Rifles, Textures.T_RiflesTitle,
                    TitleY, Textures.T_Rifles_BG, Rifle_SlotSize, VerticalSpaceBetweenSlots)
            }

            # (frozenpawn): Create column for snpier, then heavy (need half size)
            SniperHeavyHalfHeight := TitleY + SniperCount*VerticalSpaceBetweenSlots + VerticalSpaceWithTitle +
            SniperCount*SniperHeavy_SlotSize.Y

            set CumulativeLeftOffset += WidthBetweenColumns + Rifle_SlotSize.X
            set CanvasSlots += array
            {
                CanvasSlot4 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.0, Y := 0.0 }, Maximum := vector2{ X := 0.0, Y := 0.0 } }
                    Offsets := margin{ Top := 0.0, Left := CumulativeLeftOffset, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.0, Y := 0.0 }
                    SizeToContent := true
                    ZOrder := 1
                    Widget := CreateShopColumnCanvas(Snipers, Textures.T_SniperTitle,
                    TitleY, Textures.T_Snipers_BG, SniperHeavy_SlotSize, VerticalSpaceBetweenSlots)
            }
            set CanvasSlots += array
            {
                CanvasSlot5 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.0, Y := 0.0 }, Maximum := vector2{ X := 0.0, Y := 0.0 } }
                    Offsets := margin{ Top := SniperHeavyHalfHeight, Left := CumulativeLeftOffset, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.0, Y := 0.0 }
                    SizeToContent := true
                    ZOrder := 1
                    Widget := CreateShopColumnCanvas(Heavies, Textures.T_HeavyTitle,
                    TitleY, Textures.T_Heavy_BG, SniperHeavy_SlotSize, VerticalSpaceBetweenSlots)
            }

            # (frozenpawn): Create colum for shield, then health (need half size)
            ShieldHealthHalfHeight := TitleY + 1*VerticalSpaceBetweenSlots + VerticalSpaceWithTitle +
            1*ShieldHealth_SlotSize.Y

            set CumulativeLeftOffset += WidthBetweenColumns + SniperHeavy_SlotSize.X
            set CanvasSlots += array
            {
                CanvasSlot6 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.0, Y := 0.0 }, Maximum := vector2{ X := 0.0, Y := 0.0 } }
                    Offsets := margin{ Top := 0.0, Left := CumulativeLeftOffset, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.0, Y := 0.0 }
                    SizeToContent := true
                    ZOrder := 1
                    Widget := CreateShopColumnCanvas(ShieldArr, Textures.T_ShieldTitle,
                    TitleY, Textures.T_HealthShield_BG, ShieldHealth_SlotSize, VerticalSpaceBetweenSlots)
            }
            set CanvasSlots += array
            {
                CanvasSlot7 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.0, Y := 0.0 }, Maximum := vector2{ X := 0.0, Y := 0.0 } }
                    Offsets := margin{ Top := ShieldHealthHalfHeight, Left := CumulativeLeftOffset, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.0, Y := 0.0 }
                    SizeToContent := true
                    ZOrder := 1
                    Widget := CreateShopColumnCanvas(HealthArr, Textures.T_HealthTitle,
                    TitleY, Textures.T_HealthShield_BG, ShieldHealth_SlotSize, VerticalSpaceBetweenSlots)
            }

            Canvas := canvas:
                Slots := CanvasSlots

            return Canvas

        CreateShopColumnCanvas(ItemsData : []item_data, TitleTexture : texture,
        TitleY : float, SlotTexture : texture, SlotSize : vector2,
        VerticalOffset : float):canvas=
            Print("CreateShopColumnCanvas")

            var CanvasSlots : []canvas_slot = array{}

            # (frozenpawn): Column title.
            set CanvasSlots += array
            {
                CanvasSlot0 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.0, Y := 0.0 }, Maximum := vector2{ X := 0.0, Y := 0.0 }}
                    Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.0, Y := 0.0 }
                    SizeToContent := true
                    ZOrder := 1
                    Widget := texture_block{ DefaultImage := TitleTexture, DefaultDesiredSize := vector2{ X := SlotSize.X, Y := TitleY } }
            }

            # (frozenpawn): Item Slots.
            ItemCount := ItemsData.Length
            for (I := 0 .. ItemCount-1, ItemData := ItemsData[I]):

                ItemIcon := ItemData.UITexture
                ItemIconSize := vector2{ X := ItemData.UITextureSizeRatioX*SlotSize.X, Y := ItemData.UITextureSizeRatioY*SlotSize.Y }
                ItemPrice := ItemData.Price

                TopOffset := TitleY + (I+1)*VerticalOffset + I*SlotSize.Y                

                set CanvasSlots += array
                {
                    CanvasSlot1 := canvas_slot:
                        Anchors := anchors{ Minimum := vector2{ X := 0.0, Y := 0.0 }, Maximum := vector2{ X := 0.0, Y := 0.0 }}
                        Offsets := margin{ Top := TopOffset, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                        Alignment := vector2{ X := 0.0, Y := 0.0 }
                        SizeToContent := true
                        ZOrder := 1
                        Widget := CreateShopCellCanvas(ItemIcon, ItemIconSize, ItemPrice, SlotTexture, SlotSize)
                }

            Canvas := canvas:
                Slots := CanvasSlots

            return Canvas

        CreateShopCellCanvas(ItemIcon : texture, ItemIconSize : vector2, ItemPrice : int,
        SlotTexture : texture, SlotSize : vector2):canvas=
            Print("CreateShopCellCanvas")

            var CanvasSlots : []canvas_slot = array{}

            # (frozenpawn): BG Texture.
            set CanvasSlots += array
            {
                CanvasSlot0 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.0, Y := 0.0 }, Maximum := vector2{ X := 0.0, Y := 0.0 }}
                    Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.0, Y := 0.0 }
                    SizeToContent := true
                    ZOrder := 1
                    Widget := texture_block{ DefaultImage := SlotTexture, DefaultDesiredSize := SlotSize }
            }

            # (frozenpawn): Icon Texture.
            set CanvasSlots += array
            {
                CanvasSlot1 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.5, Y := 0.5 }, Maximum := vector2{ X := 0.5, Y := 0.5 }}
                    Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.5, Y := 0.5 }
                    SizeToContent := true
                    ZOrder := 1
                    Widget := texture_block{ DefaultImage := ItemIcon, DefaultDesiredSize := ItemIconSize }
            }

            # (frozenpawn): Price Text.
            set CanvasSlots += array
            {
                CanvasSlot2 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.0, Y := 1.0 }, Maximum := vector2{ X := 0.0, Y := 1.0 }}
                    Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.0, Y := 1.0 }
                    SizeToContent := true
                    ZOrder := 1
                    Widget := text_block{ DefaultText := TextForUI("💲{ItemPrice}"), DefaultTextColor := NamedColors.White }
            }

            # (frozenpawn): Overlay color block.
            set CanvasSlots += array
            {
                CanvasSlot3 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.0, Y := 0.0 }, Maximum := vector2{ X := 0.0, Y := 0.0 }}
                    Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.0, Y := 0.0 }
                    SizeToContent := true
                    ZOrder := 0
                    Widget := color_block{ DefaultColor := MakeColorFromSRGBValues(112, 196, 162), DefaultOpacity := 0.0,
                    DefaultDesiredSize := SlotSize }
            }

            Canvas := canvas:
                Slots := CanvasSlots

            return Canvas