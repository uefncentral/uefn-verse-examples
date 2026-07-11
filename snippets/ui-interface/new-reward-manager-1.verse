# Daily Gift System
# Creates a timed gift reward system that displays gift UI with countdown timers and gift indicators. Players can claim gifts at specified intervals using triggers and interactive buttons.  **How to use
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/new-reward-manager-1?ref=github


using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Simulation }
using { /Fortnite.com/UI }
using { /Verse.org/Colors }
using { /Verse.org/Colors/NamedColors }
using { /Verse.org/Assets }
using { /Fortnite.com/Devices }


Gifts:= class<concrete>():

    @editable Hours : int = 0
    @editable Minutes : int = 0
    @editable Seconds : int = 0

    @editable GiftTrigger : trigger_device = trigger_device{}


GiftManager := class:
    StringToMessage<localizes>(String:string):message = "{String}"
    IntToMessage<localizes>(Indt:int):message = "{Indt}"

    BackGround : texture_block = texture_block{DefaultImage := GiftAssets.reward_bg1, DefaultDesiredSize := vector2{X := 1920.0, Y := 1080.0}}
    ExitButtonImage : texture_block = texture_block{DefaultImage := GiftAssets.close_reward,DefaultDesiredSize := vector2{X := 450.0, Y := 90.0}}
    var GiftIconImage : texture_block = texture_block{DefaultImage := GiftAssets.present_9,DefaultDesiredSize := vector2{X := 150.0, Y := 150.0}}
    var GiftIconText : text_block = text_block{DefaultShadowColor := Black,DefaultShadowOffset := option{vector2{X:= 5.0, Y:= 2.0}}, DefaultTextColor := White }
    var GiftIconBackground : texture_block = texture_block{DefaultImage := GiftAssets.BasicGift,DefaultDesiredSize := vector2{X := 0.0, Y := 0.0}}
    var GiftForGiftIconTimer : GiftClass := GiftClass{}
    GiftIndicatorImage : texture_block = texture_block{DefaultImage := GiftAssets.Gift_Indicator,DefaultDesiredSize := vector2{X := 45.0, Y := 45.0}}
    var GiftIndicatorText : text_block = text_block{DefaultShadowColor := Black,DefaultShadowOffset := option{vector2{X:= 5.0, Y:= 2.0}}, DefaultTextColor := White }
    CloseButton : button_quiet = button_quiet{}

    GiftsDevice : GiftDevice 
    
    var Gift1 : GiftClass = GiftClass{}
    var Gift2 : GiftClass = GiftClass{}
    var Gift3 : GiftClass = GiftClass{}
    var Gift4 : GiftClass = GiftClass{}
    var Gift5 : GiftClass = GiftClass{}
    var Gift6 : GiftClass = GiftClass{}
    var Gift7 : GiftClass = GiftClass{}
    var Gift8 : GiftClass = GiftClass{}
    var Gift9 : GiftClass = GiftClass{}
    
    var GiftsArray : []GiftClass = array{}

    var Canvas : canvas = canvas{}
    var GiftIcon : canvas = canvas{}

    var GiftsToBeClaimed : []GiftClass = array{}

    UpdateClaimableGifts():void=
        var NewArray :[]GiftClass= array{}
        for(Gift : GiftsArray):
            if(Gift.IsGiftClaimable = true and Gift.IsGiftClaimed = false):
               set NewArray += array{Gift}
        set GiftsToBeClaimed = NewArray
        UpdateIndicatorText()

    UpdateIndicatorText():void=
        Amount := GiftsToBeClaimed.Length
        GiftIndicatorText.SetText(IntToMessage(Amount))
        if(Amount > 0):
            # GiftIconText.SetTextColor(Green)
            GiftIconText.SetText(StringToMessage("Ready!"))
      
    UpdateGiftIconTimer()<suspends>: void =
        loop:
            Amount := GiftsToBeClaimed.Length
            if(Amount = 0):
                Self.GiftIconText.SetText(StringToMessage(GiftForGiftIconTimer.FormatTime()))
            Sleep(0.9)

    CreateGiftIcon<public>(): void =
        block:
        set Self.GiftIcon = canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors:
                        Minimum := vector2{X := -0.03, Y := 0.72}
                        Maximum := vector2{X := -0.03, Y := 0.72}
                    Alignment := vector2{X := -0.5, Y := 2.0}                 
                    SizeToContent := true
                    Widget := Self.CreateGiftIconOverlay()

    CreateGiftIconOverlay<public>(): overlay = 
        Self.GiftIconText.SetShadowOpacity(0.0)
        Self.GiftIndicatorText.SetShadowOpacity(0.0)
        return overlay:
            Slots:= array:
                overlay_slot:
                    Widget := Self.GiftIconBackground
                    Padding := margin{Top := 0.0, Left := 0.0, Bottom := 0.0, Right := 0.0}
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Fill
                overlay_slot:
                    Widget := Self.GiftIconText
                    Padding := margin{Top := 205.0, Left := 63.0, Bottom := 0.0, Right := 0.0}
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Bottom
                overlay_slot:
                    Widget := Self.GiftIconImage
                    Padding := margin{Top := 205.0, Left := 0.0, Bottom := 0.0, Right := 60.0}
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Top
                overlay_slot:
                    Widget := Self.CreateGiftIndicatorOverlay()
                    Padding := margin{Top := 0.0, Left := 0.0, Bottom := -75.0, Right := 0.0}
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center

    CreateGiftIndicatorOverlay<public>(): overlay = 
        return overlay:
            Slots:= array:
                overlay_slot:
                    Widget := Self.GiftIndicatorImage
                    Padding := margin{Top := 0.0, Left := -3.0, Bottom := 0.0, Right := 0.0}
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                overlay_slot:
                    Widget := Self.GiftIndicatorText
                    Padding := margin{Top := 0.0, Left := 0.0, Bottom := 0.0, Right := 0.0}
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center

    SetGiftsArray() : void =
        set GiftsArray = array{Gift1, Gift2, Gift3, Gift4, Gift5, Gift6, Gift7, Gift8, Gift9}
        for(Gift : GiftsArray):
            Gift.SetGiftManager(Self)
    

    OpenUI(Player : player) : void =
        WidgetMessage : widget_message = widget_message{Player := Player, Source := Self.Canvas}
        # Print("Opening UI")
        if(PlayerUI := GetPlayerUI[Player]):
            PlayerUI.AddWidget(Self.Canvas,player_ui_slot{InputMode := ui_input_mode.All})
        # for(Gift : GiftsArray):
        #     Gift.OnPressed(WidgetMessage)

    AddGiftIcon(Player : player) : void =
        if(PlayerUI := GetPlayerUI[Player]):
            PlayerUI.AddWidget(Self.GiftIcon,player_ui_slot{})
 
    CloseUI(Message : widget_message) : void =
        # Print("Closing UI")
        Player := Message.Player
        Widget := Self.Canvas
            # Print("Removing Widget")
        # Widget := Message.Source
        if(PlayerUI := GetPlayerUI[Player]):
            PlayerUI.RemoveWidget(Widget)
            # Print("Removed Widget")


    CreateCanvas<public>() : void =
        # Print("CreatingCanvas")
        SetGiftsArray()
        UpdateClaimableGifts()
        # Change The Timer for each gift (Hours, Minutes, Seconds)
        if(G := GiftsDevice.Gift[0]):
            Gift1.SetTime(G.Hours, G.Minutes, G.Seconds)
        if(G := GiftsDevice.Gift[1]):
            Gift2.SetTime(G.Hours, G.Minutes, G.Seconds)
        if(G := GiftsDevice.Gift[2]):
            Gift3.SetTime(G.Hours, G.Minutes, G.Seconds)
        if(G := GiftsDevice.Gift[3]):
            Gift4.SetTime(G.Hours, G.Minutes, G.Seconds)
        if(G := GiftsDevice.Gift[4]):
            Gift5.SetTime(G.Hours, G.Minutes, G.Seconds) 
        if(G := GiftsDevice.Gift[5]):
            Gift6.SetTime(G.Hours, G.Minutes, G.Seconds)
        if(G := GiftsDevice.Gift[6]):
            Gift7.SetTime(G.Hours, G.Minutes, G.Seconds)
        if(G := GiftsDevice.Gift[7]):
            Gift8.SetTime(G.Hours, G.Minutes, G.Seconds)
        if(G := GiftsDevice.Gift[8]):
            Gift9.SetTime(G.Hours, G.Minutes, G.Seconds)
        # set the trigger you can ignore this
        if(G := GiftsDevice.Gift[0]):
            Gift1.SetTrigger(G.GiftTrigger)
        if(G := GiftsDevice.Gift[1]):
            Gift2.SetTrigger(G.GiftTrigger)
        if(G := GiftsDevice.Gift[2]):
            Gift3.SetTrigger(G.GiftTrigger)
        if(G := GiftsDevice.Gift[3]):
            Gift4.SetTrigger(G.GiftTrigger)
        if(G := GiftsDevice.Gift[4]):
            Gift5.SetTrigger(G.GiftTrigger)
        if(G := GiftsDevice.Gift[5]):
            Gift6.SetTrigger(G.GiftTrigger)
        if(G := GiftsDevice.Gift[6]):
            Gift7.SetTrigger(G.GiftTrigger)
        if(G := GiftsDevice.Gift[7]):
            Gift8.SetTrigger(G.GiftTrigger)
        if(G := GiftsDevice.Gift[8]):
            Gift9.SetTrigger(G.GiftTrigger)
        # Set the image for each gift First part is folder name then second is the image name example (FolderName.ImageName)
        Gift1.SetGiftImage(GiftAssets.white_present)
        Gift2.SetGiftImage(GiftAssets.present_1)
        Gift3.SetGiftImage(GiftAssets.present_3)
        Gift4.SetGiftImage(GiftAssets.present_6)
        Gift5.SetGiftImage(GiftAssets.present_2)
        Gift6.SetGiftImage(GiftAssets.present_7)
        Gift7.SetGiftImage(GiftAssets.present_5)
        Gift8.SetGiftImage(GiftAssets.present_4)
        Gift9.SetGiftImage(GiftAssets.present_9)
        # Set the gift open image for each gift
        Gift1.SetGiftOpenedImage(GiftAssets.claimed_1)
        Gift2.SetGiftOpenedImage(GiftAssets.claimed_2)
        Gift3.SetGiftOpenedImage(GiftAssets.claimed_3)
        Gift4.SetGiftOpenedImage(GiftAssets.claimed_4)
        Gift5.SetGiftOpenedImage(GiftAssets.claimed_5)
        Gift6.SetGiftOpenedImage(GiftAssets.claimed_6)
        Gift7.SetGiftOpenedImage(GiftAssets.claimed_7)
        Gift8.SetGiftOpenedImage(GiftAssets.claimed_8)
        Gift9.SetGiftOpenedImage(GiftAssets.claimed_9)
        Self.CloseButton.OnClick().Subscribe(CloseUI)
        block:
        set Self.Canvas = canvas:
                Slots := array:
                    canvas_slot:
                        Anchors := anchors:
                            Minimum := vector2{X := 0.52, Y := 0.5}
                            Maximum := vector2{X := 0.52, Y := 0.5}
                        Alignment := vector2{X := 0.5, Y := 0.5 }
                        SizeToContent := true
                        Widget := BackGround
                    canvas_slot:
                        Anchors := anchors:
                            Minimum := vector2{X := 0.52, Y := 0.95}
                            Maximum := vector2{X := 0.52, Y := 0.95}
                        Alignment := vector2{X := 0.5, Y := 0.5 }
                        SizeToContent := true
                        Widget := CreateExitButton()
                    canvas_slot:
                        Anchors := anchors:
                            Minimum := vector2{X := 0.42, Y := 0.4}
                            Maximum := vector2{X := 0.42, Y := 0.4}
                        Alignment := vector2{X := 0.5, Y := 0.5 }
                        SizeToContent := false
                        Widget := Gift1.CreateCanvas()
                    canvas_slot:
                        Anchors := anchors:
                            Minimum := vector2{X := 0.52, Y := 0.4}
                            Maximum := vector2{X := 0.52, Y := 0.4}
                        Alignment := vector2{X := 0.5, Y := 0.5 }
                        SizeToContent := false
                        Widget := Gift2.CreateCanvas()
                    canvas_slot:
                        Anchors := anchors:
                            Minimum := vector2{X := 0.62, Y := 0.4}
                            Maximum := vector2{X := 0.62, Y := 0.4}
                        Alignment := vector2{X := 0.5, Y := 0.5 }
                        SizeToContent := false
                        Widget := Gift3.CreateCanvas()
                    canvas_slot:
                        Anchors := anchors:
                            Minimum := vector2{X := 0.42, Y := 0.6}
                            Maximum := vector2{X := 0.42, Y := 0.6}
                        Alignment := vector2{X := 0.5, Y := 0.5 }
                        SizeToContent := false
                        Widget := Gift4.CreateCanvas()
                    canvas_slot:
                        Anchors := anchors:
                            Minimum := vector2{X := 0.52, Y := 0.6}
                            Maximum := vector2{X := 0.52, Y := 0.6}
                        Alignment := vector2{X := 0.5, Y := 0.5 }
                        SizeToContent := false
                        Widget := Gift5.CreateCanvas()
                    canvas_slot:
                        Anchors := anchors:
                            Minimum := vector2{X := 0.62, Y := 0.6}
                            Maximum := vector2{X := 0.62, Y := 0.6}
                        Alignment := vector2{X := 0.5, Y := 0.5 }
                        SizeToContent := false
                        Widget := Gift6.CreateCanvas()
                    canvas_slot:
                        Anchors := anchors:
                            Minimum := vector2{X := 0.42, Y := 0.8}
                            Maximum := vector2{X := 0.42, Y := 0.8}
                        Alignment := vector2{X := 0.5, Y := 0.5 }
                        SizeToContent := false
                        Widget := Gift7.CreateCanvas()
                    canvas_slot:
                        Anchors := anchors:
                            Minimum := vector2{X := 0.52, Y := 0.8}
                            Maximum := vector2{X := 0.52, Y := 0.8}
                        Alignment := vector2{X := 0.5, Y := 0.5 }
                        SizeToContent := false
                        Widget := Gift8.CreateCanvas()
                    canvas_slot:
                        Anchors := anchors:
                            Minimum := vector2{X := 0.62, Y := 0.8}
                            Maximum := vector2{X := 0.62, Y := 0.8}
                        Alignment := vector2{X := 0.5, Y := 0.5 }
                        SizeToContent := false
                        Widget := Gift9.CreateCanvas()
        HighlightNextClaimableGift()
        CreateGiftIcon()
        spawn{UpdateGiftIconTimer()}
                    
    CreateExitButton(): overlay= 
        return overlay:
            Slots:= array:
                overlay_slot:
                    Widget := ExitButtonImage 
                    # Padding := margin{Top := 0.0, Left := 100.0, Bottom := 0.0, Right := 100.0}
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                overlay_slot:
                    Widget := CloseButton
                    # Padding := margin{Top := 0.0, Left := 100.0, Bottom := 0.0, Right := 100.0}
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill

    FindNextClaimableGift(): ?GiftClass =
        # Print("Finding Next Claimable Gift")
        var minimumTime: int = 999999 # Arbitrarily large number
        var nextGift: ?GiftClass = false

        var gifts: []GiftClass = array{Gift1, Gift2, Gift3, Gift4, Gift5, Gift6, Gift7, Gift8, Gift9}
        for (Gift : gifts):
            if(Gift.IsGiftClaimable = false):
                # Print("Gift is not claimable")
                var time: int = Gift.TimeRemaining()
                if (time < minimumTime and time > 0): # Ensure we don't select already claimable gifts
                    # Print("Gift is next Claimable Gift")
                    set minimumTime = time
                    set nextGift = option{Gift}

        return nextGift

    HighlightNextClaimableGift(): void =
        # Print("Highlighting Next Claimable Gift")
        var nextGift: ?GiftClass = Self.FindNextClaimableGift()
        if (Gift := nextGift?):
            # Print("Highlighting Next Claimable Gift")
            Gift.SetButtonColor(Yellow)
            # GiftIconImage.SetImage(Gift.GetGiftImage())
            set GiftForGiftIconTimer = Gift


GiftDevice := class(creative_device):
    @editable OpenUIButtons : []button_device = array{}

    @editable RegisterPlayerTriggers : []trigger_device = array{}

    @editable Gift : []Gifts = array{}



    var PlayersGifts : [player]GiftManager = map{}


    OnBegin<override>()<suspends> : void =
        for(T : RegisterPlayerTriggers):
            T.TriggeredEvent.Subscribe(InitGift)
        for(buttons : OpenUIButtons):
            buttons.InteractedWithEvent.Subscribe(OpenUI)
      

    OpenGift1(MaybeAgent : ?agent) : void =
        if(Agent := MaybeAgent?):
            # Print("Opened Gift 1")

    OpenGift2(MaybeAgent : ?agent) : void =
        if(Agent := MaybeAgent?):
            # Print("Opened Gift 2")
        
    OpenGift3(MaybeAgent : ?agent) : void =
        if(Agent := MaybeAgent?):
            # Print("Opened Gift 3")
    
    InitGift(FakeAgent : ?agent) : void =
        Print("Trying to init")
        if(Agent := FakeAgent?):
            if(Player := player[Agent]):
                if(not PlayersGifts[Player]):
                    # Print("Player Added")
                    if(PlayersUI := GetPlayerUI[Player]):
                        UIToAdd := GiftManager{GiftsDevice := Self}
                        UIToAdd.CreateCanvas()
                        UIToAdd.AddGiftIcon(Player)
                        if(set PlayersGifts[Player] = UIToAdd):
                            # Print("Added UI")
                            if(PlayerGifts := PlayersGifts[Player]):

    OpenUI(MaybeAgent : agent) : void =
        if(Player := player[MaybeAgent]):
            if(PlayerGifts := PlayersGifts[Player]):
                PlayerGifts.OpenUI(Player)