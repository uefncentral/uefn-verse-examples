# Item Shopp
# Verse code for Item Shopp - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/item-shopp?ref=github


using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /Verse.org/Colors }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }

shop_item := class<concrete>:
    # Name must be unique otherwise will not save
    @editable
    Name:string = ""

    @editable
    Price:int = 1

    @editable
    EquippedTrigger:?trigger_device = false

    @editable
    UnequipTrigger:?trigger_device = false

shop_tab := class<concrete>:
    # Name must be unique otherwise will not save
    @editable
    TabName:string = "Tab"

    @editable
    TabItems:[]shop_item = array{}

    @editable
    UnequippedAnyTrigger:?trigger_device = false

shop_hud_component := class:
    Canvas:canvas

    TotalMoneyText:text_block

    ShopPanelStackBox:stack_box

    var ShopButtons:[string]shop_overlay_button = map{}
    #var ShopItemWidgets:[]widget = array{}
    var ShopRows:[]widget = array{}

    var CurrentPage:int = 1

    var CurrentTab:int = 0

    ResetButtons:event() = event(){}
    HudDestroyedEvent:event()

shop_device := class(creative_device):

    # PUT YOUR TEXTURES HERE || The string should match the corresponding tab name
    ShopItemTextures:[string][]texture = map:
        "Mobility" => array:
            ItemShop.Wings_of_Icarus
            ItemShop.Mythic_Witch_Broom
            ItemShop.Jules_Glider_Gun
            ItemShop.Tow_Hook_Cannon
            ItemShop.Jetpack
            ItemShop.InflateABull
            ItemShop.Grappler
            ItemShop.Grapple_Glove
            ItemShop.Grapple_Blade
            ItemShop.Exotic_Icy_Grappler
            ItemShop.Crash_Pad_Jr
            ItemShop.Balloon
        "Misc" => array:
                ItemShop.Blue_Cuddle_Fish
                ItemShop.Cluster_Clinger
                ItemShop.Dynamite
                ItemShop.Grenade
                ItemShop.Mythic_Goldfish
                ItemShop.Remote_Explosive
                ItemShop.Shield_Breaker_EMP_Grenade
                ItemShop.Blow_Torch
                ItemShop.Thunderbolt_of_Zeus

    # Texture used to show currency
    MoneyTexture:texture = ItemShop.Gold_Coin

    @editable
    Tabs:[]shop_tab = array{}
        
    @editable
    ShowShopTrigger:trigger_device = trigger_device{}

    @editable
    GoldConditionalButton:conditional_button_device = conditional_button_device{}

    @editable
    BackgroundColor:color = MakeColorFromHex("2779CAFF")

    @editable
    BackgroundGradientColor:color = MakeColorFromHex("CC5E9BFF")

    @editable
    HeaderColor:color = MakeColorFromHex("FFFFFFFF")

    @editable
    UnlockButtonColor:color = MakeColorFromHex("767676FF")

    @editable
    EquipButtonColor:color = MakeColorFromHex("0099FFFF")

    @editable
    EquippedButtonColor:color = MakeColorFromHex("00E163FF")

    @editable
    TabDefaultColor:color = NamedColors.Gray

    @editable
    TabHighlightColor:color = NamedColors.Green

    var ShopHudPerAgent:[agent]shop_hud_component = map{}

    Rows:int = 2
    Columns:int = 5

    OnItemChanged:event(tuple(player, ?shop_item, ?shop_item)) = event(tuple(player, ?shop_item, ?shop_item)){} # player / Old Item / New Item

    # String to Message
    ShopStringToMessage<localizes>(value:string) : message = "{value}"

    OnBegin<override>()<suspends>:void=
        for(Player : GetPlayspace().GetPlayers()):
            OnPlayerJoined(Player)

        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerJoined)
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerRemoved)

        ShowShopTrigger.TriggeredEvent.Subscribe(ShowShopUI)

    OnPlayerJoined(Player:player):void=
        # Get player shop data and equip their saved items
        if(PlayerShopData :=  GlobalSavedShopData[Player]):
            for(Tab : Tabs):
                if(ShopItem := GetShopItem(Tab.TabName, PlayerShopData.TabsData[Tab.TabName].CurrentItem)?):
                    OnItemChanged.Signal(Player, false, option{ShopItem})
                    if(EquipTrigger := ShopItem.EquippedTrigger?):
                        EquipTrigger.Trigger(Player)

        else:
            if(set GlobalSavedShopData[Player] = shop_data{}) {}

    OnPlayerRemoved(Player:player):void=
        RemoveUI(Player)

    # Get Players Current Item
    GetSelectedItem(TabName:string, Player:player):?shop_item=
        if(PlayerShopData := Player.GetPlayerShopData[], TabData := PlayerShopData.TabsData[TabName]):
            return GetShopItem(TabName, TabData.CurrentItem)

        return false

    # Get Shop Item From String
    GetShopItem(TabName:string, ItemName:string)<transacts>:?shop_item=
        for(Tab : Tabs, Tab.TabName = TabName):
            for(Item : Tab.TabItems, Item.Name = ItemName):
                return option{Item}
        return false

    # Show the Shop UI for Player
    ShowShopUI(Agent:?agent):void=
        if:
            Player := player[Agent?]
            PlayerUI := GetPlayerUI[Player]
        then:
            RemoveUI(Player)
            ShopComponent := CreateUI(Player)
            PlayerUI.AddWidget(ShopComponent.Canvas, player_ui_slot{InputMode := ui_input_mode.All})
            if(set ShopHudPerAgent[Player] = ShopComponent){}
            UpdatePage(Player)
            
    RemoveUI(Agent:agent):void=
        if:
            PlayerUI := GetPlayerUI[player[Agent]]
            ShopComponent := ShopHudPerAgent[Agent]
        then:
            ShopComponent.Canvas.SetVisibility(widget_visibility.Collapsed)
            PlayerUI.RemoveWidget(ShopComponent.Canvas)

            ShopComponent.HudDestroyedEvent.Signal()

            # Removes the shop component from the map
            var NewMap:[agent]shop_hud_component = map{}
            for (Key -> Value : ShopHudPerAgent, Key <> Agent):
                set NewMap = ConcatenateMaps(NewMap, map{Key => Value})
            set ShopHudPerAgent = NewMap

    OnExitButton(WidgetMessage:widget_message):void=
        RemoveUI(WidgetMessage.Player)

    PreviousPage(WidgetMessage:widget_message):void=
        if(ShopHudComponent := ShopHudPerAgent[WidgetMessage.Player], TabItems := Tabs[ShopHudComponent.CurrentTab].TabItems):
            TotalPages := Ceil(TabItems.Length / (Rows*Columns)) or 1
            set ShopHudComponent.CurrentPage = Clamp(ShopHudComponent.CurrentPage-1, 1, TotalPages)

            UpdatePage(WidgetMessage.Player)

    NextPage(WidgetMessage:widget_message):void=
        if(ShopHudComponent := ShopHudPerAgent[WidgetMessage.Player], TabItems := Tabs[ShopHudComponent.CurrentTab].TabItems):
            TotalPages := Ceil(TabItems.Length / (Rows*Columns)) or 1
            set ShopHudComponent.CurrentPage = Clamp(ShopHudComponent.CurrentPage+1, 1, TotalPages)

            UpdatePage(WidgetMessage.Player)

    UpdatePage(Player:player):void=
        if:
            ShopHudComponent := ShopHudPerAgent[Player]
            PlayerShopData := Player.GetPlayerShopData[]
            TabData := Tabs[ShopHudComponent.CurrentTab]
            SavedTabData := PlayerShopData.TabsData[Tabs[ShopHudComponent.CurrentTab].TabName] or tab_data{}
        then:
            var CurrentTotalIndex:int = (ShopHudComponent.CurrentPage-1) * (Rows * Columns)
            ShopHudComponent.ResetButtons.Signal()

            for(ShopRow : ShopHudComponent.ShopRows):
                ShopHudComponent.ShopPanelStackBox.RemoveWidget(ShopRow)
                ShopRow.SetVisibility(widget_visibility.Collapsed)

            var NewShopButtons:[string]shop_overlay_button = map{}
            var NewShopRowWidgets:[]widget = array{}

            for(RowIndex := 0..Rows-1):
                ShopItemsRowStackBox := stack_box:
                    Orientation := orientation.Horizontal

                ShopItemsRowStackBoxSlot := stack_box_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Distribution := option{1.0}
                    Widget := ShopItemsRowStackBox

                set NewShopRowWidgets += array{ShopItemsRowStackBox}
                ShopHudComponent.ShopPanelStackBox.AddWidget(ShopItemsRowStackBoxSlot)

                for(ColumnIndex := 0..Columns-1, ShopItem := TabData.TabItems[CurrentTotalIndex], ShopItemTexture := ShopItemTextures[TabData.TabName][CurrentTotalIndex]):
                    set CurrentTotalIndex += 1

                    var UnlockText:message = if(SavedTabData.UnlockedItems.Find[ShopItem.Name]) then ShopStringToMessage("Equip") else ShopStringToMessage(formatter.Abbreviate(ShopItem.Price * 1.0))
                    var UnlockColor:color = if(SavedTabData.UnlockedItems.Find[ShopItem.Name]) then EquipButtonColor else UnlockButtonColor
                    if(SavedTabData.CurrentItem = ShopItem.Name):
                        set UnlockText = ShopStringToMessage("Equipped")
                        set UnlockColor = EquippedButtonColor

                    # Unlock Button
                    UnlockButton := shop_overlay_button:
                        BackgroundTexture := ItemShop.T_ItemShop_Button_Equip
                        BackgroundTextureSize := vector2{X := 197.0, Y := 82.0}
                        IconTexture := if(SavedTabData.UnlockedItems.Find[ShopItem.Name]) then false else option{MoneyTexture}
                        IconTextureSize := option{vector2{X := 40.0, Y := 40.0}}
                        ButtonPadding := margin{Top := 3.0, Bottom := 3.0, Left := 3.0, Right := 3.0}
                        DefaultText := UnlockText
                    UnlockButton.Create()
                    UnlockButton.BackgroundImage.SetTint(UnlockColor)
                    spawn {AwaitShopButtonSelect(Player, ShopHudComponent, UnlockButton, ShopItem)}

                    ShopItemNameText := text_block:
                        DefaultTextColor := NamedColors.White
                        DefaultShadowOffset := option{vector2{X := 2.0, Y := 2.0}}
                        DefaultText := ShopStringToMessage(ShopItem.Name)
                    ShopItemNameText.SetShadowOpacity(1.0)

                    ItemStackBoxSlot := stack_box_slot:
                        HorizontalAlignment := horizontal_alignment.Center
                        VerticalAlignment := vertical_alignment.Top
                        Padding := margin{Left := 20.0, Top := 20.0, Right := 20.0, Bottom := 20.0}
                        Widget := stack_box:
                            Orientation := orientation.Vertical
                            Slots := array:
                                # Item Name
                                stack_box_slot:
                                    HorizontalAlignment := horizontal_alignment.Center
                                    VerticalAlignment := vertical_alignment.Top
                                    Widget := ShopItemNameText
                                # Item Icon
                                stack_box_slot:
                                    HorizontalAlignment := horizontal_alignment.Center
                                    VerticalAlignment := vertical_alignment.Center
                                    Widget := texture_block:
                                        DefaultDesiredSize := vector2{X := 200.0, Y := 200.0}
                                        DefaultImage := ShopItemTexture
                                # Unlock Button
                                stack_box_slot:
                                    HorizontalAlignment := horizontal_alignment.Center
                                    VerticalAlignment := vertical_alignment.Center
                                    Widget := UnlockButton.Widget

                    if(set NewShopButtons[ShopItem.Name] = UnlockButton) {}
                    ShopItemsRowStackBox.AddWidget(ItemStackBoxSlot)

            set ShopHudComponent.ShopRows = NewShopRowWidgets
            set ShopHudComponent.ShopButtons = NewShopButtons

    AwaitTabSelected(Player:player, ButtonContainer:shop_selectable_button_container, CancelEvent:event())<suspends>:void=
        race:
            CancelEvent.Await()
            loop:
                NewTabIndex := ButtonContainer.NewSelectionEvent.Await()
                if(ShopHudComponent := ShopHudPerAgent[Player]):
                    set ShopHudComponent.CurrentTab = NewTabIndex
                    set ShopHudComponent.CurrentPage = 1
                    UpdatePage(Player)            

    AwaitShopButtonSelect(Player:player, ShopHudComponent:shop_hud_component, ShopButton:shop_overlay_button, ShopItem:shop_item)<suspends>:void=
        race:
            ShopHudComponent.ResetButtons.Await()
            ShopHudComponent.HudDestroyedEvent.Await()
            loop:
                ShopButton.Button.OnClick().Await()
                if:
                    PlayerShopData := Player.GetPlayerShopData[]
                    TabData := Tabs[ShopHudComponent.CurrentTab]
                    SavedTabData := PlayerShopData.TabsData[TabData.TabName] or tab_data{}
                then:
                    GoldConditionalButton.SetItemCountRequired(0, ShopItem.Price)

                    if(SavedTabData.CurrentItem = ShopItem.Name):
                        # Unequip
                        ShopButton.Text.SetText(ShopStringToMessage("Equip"))
                        ShopButton.BackgroundImage.SetTint(EquipButtonColor)

                        OnItemChanged.Signal(Player, option{ShopItem}, false)
                        if(UnequipTrigger := ShopItem.UnequipTrigger?):
                            UnequipTrigger.Trigger(Player)
                        if(UnequipTrigger := TabData.UnequippedAnyTrigger?):
                            UnequipTrigger.Trigger(Player)

                        ShopDataUpdateCurrentItem(Player, TabData.TabName, "")

                    else if(SavedTabData.UnlockedItems.Find[ShopItem.Name]):
                        # Equip new Item
                        ShopButton.Text.SetText(ShopStringToMessage("Equipped"))
                        ShopButton.BackgroundImage.SetTint(EquippedButtonColor)
                        if(EquippedButton := ShopHudComponent.ShopButtons[SavedTabData.CurrentItem]):
                            EquippedButton.Text.SetText(ShopStringToMessage("Equip"))
                            EquippedButton.BackgroundImage.SetTint(EquipButtonColor)

                        OnItemChanged.Signal(Player, GetShopItem(TabData.TabName, SavedTabData.CurrentItem), option{ShopItem})
                        if(UnequipTrigger := GetShopItem(TabData.TabName, SavedTabData.CurrentItem)?.UnequipTrigger?):
                            UnequipTrigger.Trigger(Player)
                        if(UnequipTrigger := TabData.UnequippedAnyTrigger?):
                            UnequipTrigger.Trigger(Player)
                        if(EquipTrigger := ShopItem.EquippedTrigger?):
                            EquipTrigger.Trigger(Player)

                        ShopDataUpdateCurrentItem(Player, TabData.TabName, ShopItem.Name)

                    else if(GoldConditionalButton.HasAllItems[Player]):
                        # Try buy item
                        GoldConditionalButton.Activate(Player)
                        ShopHudComponent.TotalMoneyText.SetText(ShopStringToMessage(formatter.Abbreviate(GoldConditionalButton.GetItemCount(Player, 0) * 1.0)))
                        # Equip new Item
                        ShopButton.Text.SetText(ShopStringToMessage("Equipped"))
                        ShopButton.BackgroundImage.SetTint(EquippedButtonColor)
                        ShopButton.Icon.SetVisibility(widget_visibility.Collapsed)

                        if(EquippedButton := ShopHudComponent.ShopButtons[SavedTabData.CurrentItem]):
                            EquippedButton.Text.SetText(ShopStringToMessage("Equip"))
                            EquippedButton.BackgroundImage.SetTint(EquipButtonColor)

                        OnItemChanged.Signal(Player, GetShopItem(TabData.TabName, SavedTabData.CurrentItem), option{ShopItem})
                        if(UnequipTrigger := GetShopItem(TabData.TabName, SavedTabData.CurrentItem)?.UnequipTrigger?):
                            UnequipTrigger.Trigger(Player)
                        if(UnequipTrigger := TabData.UnequippedAnyTrigger?):
                            UnequipTrigger.Trigger(Player)
                        if(EquipTrigger := ShopItem.EquippedTrigger?):
                            EquipTrigger.Trigger(Player)
                            
                        ShopDataUnlockEquip(Player, TabData.TabName, ShopItem.Name)

    CreateUI(Player:player):shop_hud_component=
        HudDestroyedEvent:event() = event(){}

        # Exit Button
        ExitButton := shop_overlay_button:
            BackgroundTexture := ItemShop.T_ItemShop_Button_Back
            BackgroundTextureSize := vector2{X := 233.0, Y := 70.0}
            ButtonPadding := margin{Top := 3.0, Bottom := 3.0, Left := 3.0, Right := 3.0}
            DefaultText := ShopStringToMessage("Back")

        ExitButton.Create()
        ExitButton.BackgroundImage.SetTint(MakeColorFromHex("C50000FF"))
        ExitButton.Button.OnClick().Subscribe(OnExitButton)

        # Total Money Text
        TotalMoneyText := text_block:
            DefaultTextColor := NamedColors.White
            DefaultText := ShopStringToMessage(formatter.Abbreviate(GoldConditionalButton.GetItemCount(Player, 0) * 1.0))

        TotalMoneyOverlay := overlay:
            Slots := array:
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Widget := texture_block:
                        DefaultImage := ItemShop.T_ItemShop_MoneyBackground
                        DefaultDesiredSize := vector2{X := 220.0, Y := 50.0}
                        DefaultTint := NamedColors.Black
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Center
                    Widget := stack_box:
                        Orientation := orientation.Horizontal
                        Slots := array:
                            stack_box_slot:
                                Padding := margin{Left := 10.0}
                                Widget := texture_block:
                                    DefaultImage := MoneyTexture
                                    DefaultDesiredSize := vector2{X := 40.0, Y := 40.0}
                            stack_box_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment := vertical_alignment.Center
                                Distribution := option{1.0}
                                Widget := TotalMoneyText

        TabsStackBox := stack_box:
            Orientation := orientation.Horizontal
            Slots := array:
                stack_box_slot:
                    Widget := TotalMoneyOverlay

        TabSelectableButtonContainer:shop_selectable_button_container = shop_selectable_button_container{CleanupCallback := HudDestroyedEvent}
        for(Index->Tab : Tabs):
            TabButton := shop_selectable_button:
                SelectedColor := TabHighlightColor
                DefaultColor := TabDefaultColor
                BackgroundTexture := ItemShop.T_ItemShop_Button_Equip
                BackgroundTextureSize := vector2{X := 180.0, Y := 65.0}
                DefaultText := ShopStringToMessage(Tab.TabName)
            HighlightIndex := if(Index = 0) then true else false
            TabSelectableButtonContainer.AddButton(TabButton, HighlightIndex)

            TabButtonStackBoxSlot := stack_box_slot:
                HorizontalAlignment := horizontal_alignment.Center
                VerticalAlignment := vertical_alignment.Center
                Padding := margin{Left := 15.0}#HighlightIndex? and margin{Left := 50.0} or margin{Left := 15.0}
                Widget := TabButton.Widget

            TabsStackBox.AddWidget(TabButtonStackBoxSlot)

        spawn. AwaitTabSelected(Player, TabSelectableButtonContainer, HudDestroyedEvent)

        # Previous Page Button
        PreviousPageButton := shop_overlay_button:
            BackgroundTexture := ItemShop.T_ItemShop_Button_Page
            BackgroundTextureSize := vector2{X := 109.0, Y := 70.0}
            ButtonPadding := margin{Top := 3.0, Bottom := 3.0, Left := 3.0, Right := 3.0}
            DefaultText := ShopStringToMessage("◀")

        PreviousPageButton.Create()
        PreviousPageButton.BackgroundImage.SetTint(MakeColorFromHex("AEAEAEFF"))
        PreviousPageButton.Button.OnClick().Subscribe(PreviousPage)

        # Next Page Button
        NextPageButton := shop_overlay_button:
            BackgroundTexture := ItemShop.T_ItemShop_Button_Page
            BackgroundTextureSize := vector2{X := 109.0, Y := 70.0}
            ButtonPadding := margin{Top := 3.0, Bottom := 3.0, Left := 3.0, Right := 3.0}
            DefaultText := ShopStringToMessage("▶")

        NextPageButton.Create()
        NextPageButton.BackgroundImage.SetTint(MakeColorFromHex("AEAEAEFF"))
        NextPageButton.Button.OnClick().Subscribe(NextPage)

        # Options Stack Box
        OptionsStackBox := stack_box:
            Orientation := orientation.Horizontal
            Slots := array:
                # Previous Button
                stack_box_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Widget := PreviousPageButton.Widget
                # Back Button
                stack_box_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left := 10.0, Right := 10.0}
                    Widget := ExitButton.Widget
                # next Button
                stack_box_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Widget := NextPageButton.Widget

        # Shop Stack Box
        ShopStackBox := stack_box:
            Orientation := orientation.Vertical

        # Foreground Stack Box
        ForegroundStackBox := stack_box:
            Orientation := orientation.Vertical
            Slots := array:
                # Tabs
                stack_box_slot:
                    HorizontalAlignment := horizontal_alignment.Left
                    VerticalAlignment := vertical_alignment.Center
                    Widget := TabsStackBox
                # Shop Panel
                stack_box_slot:
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Distribution := option{1.0}
                    Widget := ShopStackBox

        MyCanvas := canvas:
            Slots := array:
                # Shop Panel
                canvas_slot:
                    Anchors := anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}}
                    Offsets := margin{Left := 0.0, Top := 0.0}
                    Alignment := vector2{X:=0.5,Y:=0.5}
                    SizeToContent := true
                    Widget := overlay:
                        Slots := array:
                            # Background
                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment := vertical_alignment.Center
                                Widget := texture_block:
                                    DefaultDesiredSize := vector2{X := 1528.0, Y := 928.0}
                                    DefaultTint := BackgroundColor
                                    DefaultImage := ItemShop.T_ItemShop_Background
                            # Background Gradient
                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment := vertical_alignment.Center
                                Widget := texture_block:
                                    DefaultDesiredSize := vector2{X := 1500.0, Y := 900.0}
                                    DefaultTint := BackgroundGradientColor
                                    DefaultImage := ItemShop.T_ItemShop_BackgroundGradient
                            # Foreground
                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Fill
                                VerticalAlignment := vertical_alignment.Fill
                                Padding := margin{Left := 50.0, Top := 50.0, Right := 50.0, Bottom := 50.0}
                                Widget := ForegroundStackBox
                            # Option Buttons
                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment := vertical_alignment.Bottom
                                Padding := margin{Bottom := -30.0}
                                Widget := OptionsStackBox
                            # Header
                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment := vertical_alignment.Top
                                Padding := margin{Top := -60.0}
                                Widget := texture_block:
                                    DefaultImage := ItemShop.T_ItemShop_Header
                                    DefaultDesiredSize := vector2{X := 424.0, Y := 111.0}
                                    DefaultTint := HeaderColor

        ShopHudComponent := shop_hud_component:
            Canvas := MyCanvas
            TotalMoneyText := TotalMoneyText
            ShopPanelStackBox := ShopStackBox
            HudDestroyedEvent := HudDestroyedEvent

        return ShopHudComponent

# Custom button that allows for a texture to overlay a quiet button
PlaceholderText<localizes>:message = ""
shop_overlay_button := class:

    var Widget:overlay = overlay:
    
    BackgroundImage:texture_block = texture_block:
        DefaultImage := ItemShop.T_ItemShop_IconBlank
    
    BackgroundTexture:texture
    BackgroundTextureSize:vector2
    IconTexture:?texture = false
    IconTextureSize:?vector2 = false
    TextColor:color = NamedColors.White
    ButtonPadding:margin = margin{}
    DefaultText:message = PlaceholderText
    
    Icon:texture_block = texture_block:
        DefaultImage := ItemShop.T_ItemShop_IconBlank
    
    Text:text_block = text_block:
        DefaultText := PlaceholderText
        DefaultTextColor := NamedColors.White
    
    Button:button_quiet = button_quiet:
        DefaultText := PlaceholderText

    Create():void=
        set Widget = overlay:
            Slots := array:
                overlay_slot: # background of button
                    Widget := BackgroundImage
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Widget := stack_box:
                        Orientation := orientation.Horizontal
                        Slots := array:
                            stack_box_slot:
                                Widget := Icon
                            stack_box_slot:
                                Widget := Text
                overlay_slot: # button
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Padding := ButtonPadding
                    Widget := Button
    
        BackgroundImage.SetImage(BackgroundTexture)
        BackgroundImage.SetDesiredSize(BackgroundTextureSize)

        if(FoundIconTexture := IconTexture?):
            Icon.SetImage(FoundIconTexture)

            if(FoundIconTextureSize := IconTextureSize?):
                Icon.SetDesiredSize(FoundIconTextureSize)
        else:
            Icon.SetVisibility(widget_visibility.Collapsed)

        Text.SetTextColor(TextColor)
        Text.SetText(DefaultText)

shop_selectable_button := class(shop_overlay_button):
    SelectedColor:color = NamedColors.Gold
    DefaultColor:color = NamedColors.White

    SelectButton():void=
        BackgroundImage.SetTint(SelectedColor)

    DeselectButton():void=
        BackgroundImage.SetTint(DefaultColor)

    Create<override>():void=
        (super:)Create()

        BackgroundImage.SetTint(DefaultColor)

shop_selectable_button_container := class:
    CleanupCallback:event()

    var SelectableButtons:[]shop_selectable_button = array{}

    var CurrentSelectedIndex:int = 0

    NewSelectionEvent:event(int) = event(int){}

    AddButton(NewButton:shop_selectable_button, Highlight:logic):void=
        NewButton.Create()

        set SelectableButtons += array{ NewButton }
        ButtonIndex := SelectableButtons.Length-1

        if(Highlight = true):
            SelectButtonIndex(CurrentSelectedIndex)

        spawn { AwaitButtonClick(NewButton, ButtonIndex) }

    SelectButtonIndex(IndexToSelect:int):void=
        NewSelectionEvent.Signal(IndexToSelect)
        set CurrentSelectedIndex = IndexToSelect
        for(Index->SelectableButton : SelectableButtons):
            if(Index <> IndexToSelect):
                SelectableButton.DeselectButton()
            else:
                SelectableButton.SelectButton()

    AwaitButtonClick(Button:shop_selectable_button, Index:int)<suspends>:void=
        race:
            CleanupCallback.Await()
            loop:
                Button.Button.OnClick().Await()
                NewSelectionEvent.Signal(Index)
                set CurrentSelectedIndex = Index

                for(SelectableButton : SelectableButtons):
                    if(SelectableButton.Widget <> Button.Widget):
                        SelectableButton.DeselectButton()
                    else:
                        SelectableButton.SelectButton()

# Shop Persistence
var GlobalSavedShopData:weak_map(player, shop_data) = map{}

(Player:player).GetPlayerShopData()<decides><transacts>:shop_data=
    GlobalSavedShopData[Player]

tab_data := class<final><persistable>:
    CurrentItem:string = ""
    UnlockedItems:[]string = array{}

shop_data := class<final><persistable>:
    TabsData:[string]tab_data = map{}

ShopDataUpdateCurrentItem(Agent:agent, Tab:string, NewCurrentItem:string):void=
    if:
        Player := player[Agent]
        SourceData := GlobalSavedShopData[Player]

        OldTabData := SourceData.TabsData[Tab] or tab_data{}
        NewTabData := tab_data:
            CurrentItem := NewCurrentItem
            UnlockedItems := OldTabData.UnlockedItems
        set GlobalSavedShopData[Player] = shop_data:
            TabsData := ConcatenateMaps(SourceData.TabsData, map{Tab => NewTabData})

ShopDataAddUnlockedItem(Agent:agent, Tab:string, NewUnlockedItem:string):void=
    if:
        Player := player[Agent]
        SourceData := GlobalSavedShopData[Player]

        OldTabData := SourceData.TabsData[Tab] or tab_data{}
        NewTabData := tab_data:
            CurrentItem := OldTabData.CurrentItem
            UnlockedItems := OldTabData.UnlockedItems + array{NewUnlockedItem}
        set GlobalSavedShopData[Player] = shop_data:
            TabsData := ConcatenateMaps(SourceData.TabsData, map{Tab => NewTabData})

ShopDataUnlockEquip(Agent:agent, Tab:string, NewItem:string):void=
    if:
        Player := player[Agent]
        SourceData := GlobalSavedShopData[Player]

        OldTabData := SourceData.TabsData[Tab] or tab_data{}
        NewTabData := tab_data:
            CurrentItem := NewItem
            UnlockedItems := OldTabData.UnlockedItems + array{NewItem}
        set GlobalSavedShopData[Player] = shop_data:
            TabsData := ConcatenateMaps(SourceData.TabsData, map{Tab => NewTabData})