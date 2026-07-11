# Gift Timer System
# A countdown timer system that manages gift opening mechanics in UEFN. Players can trigger gift opening events through a trigger device, with visual UI elements displaying gift images and timer functio
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/reward-manager-class-1?ref=github


using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Simulation }
using { /Fortnite.com/UI }
using { /Verse.org/Colors }
using { /Verse.org/Colors/NamedColors }
using { /Verse.org/Assets }
using { /Fortnite.com/Devices }

GiftClass := class():
    var Trigger : trigger_device = trigger_device{}
    StringToMessage<localizes>(String:string):message = "{String}"
    var MaybeGiftManager : ?GiftManager = false
    #Timer Section
    var Hours : int = 0
    var Minutes : int = 0
    var Seconds : int = 0
    var CurrentTime : string = "00:00:00"
    
    SetGiftManager(GiftsManager : GiftManager):void=
        set Self.MaybeGiftManager = option{GiftsManager}

    SetTime( AmountOfHours : int, AmountOfMinutes : int, AmountOfSeconds : int):void=
        set Self.Hours = AmountOfHours
        set Self.Minutes = AmountOfMinutes
        set Self.Seconds = AmountOfSeconds
        spawn{Self.StartCountdown()}

 

    SetTrigger(TriggerDevice : trigger_device):void=
        set Self.Trigger = TriggerDevice
        Self.Trigger.TriggeredEvent.Subscribe(Self.OpenGift)

    GiftOpened : event() = event(){}

    OpenGift(MaybeAgent : ?agent):void=
        Print("Gift Opened")

    #Button Section
    Button : button_quiet = button_quiet{}
    ButtonImage : texture_block = texture_block{DefaultImage := GiftAssets.BasicGift, DefaultDesiredSize := vector2{X := 10.0, Y := 10.0} }
    var GiftImage : texture_block = texture_block{DefaultImage := GiftAssets.BasicGift, DefaultDesiredSize := vector2{X := 200.0, Y := 200.0} }
    var GiftOpenedImage : texture_block = texture_block{DefaultImage := GiftAssets.BasicGift, DefaultDesiredSize := vector2{X := 200.0, Y := 100.0} }
    var Canvas : canvas = canvas{}

    SetGiftOpenedImage(Image : texture):void=
        Self.GiftOpenedImage.SetImage(Image)

    SetButtonText(Text : string):void=
        # Print("Setting Button Text")
        Message := StringToMessage(Text)
        Self.Button.SetText(Message)

    SetButtonSize(X : float, Y : float):void=
        Size := vector2{X := X, Y := Y}
        Self.ButtonImage.SetDesiredSize(Size)
        # Print(ToString(Self.ButtonImage.GetDesiredSize()))

    SetGiftImage(Image : texture):void=
        Self.GiftImage.SetImage(Image)
    
    GetGiftImage():texture=
        return Self.GiftImage.GetImage()

    EnableButton():void=
        Self.Button.SetEnabled(true)

    DisableButton():void=
        Self.Button.SetEnabled(false)

    HideButton():void=
        Self.Button.SetVisibility(widget_visibility.Hidden)

    SetButtonColor(Color: color):void=
        Self.ButtonImage.SetTint(Color)

    OnPressed(Message : widget_message):void=
        Player := Message.Player

        if(Self.IsGiftClaimable = true and Self.IsGiftClaimed = false):
            # Print("Gift Claimed")
            set Self.IsGiftClaimed = true
            Self.Trigger.Trigger(Player)
            Self.SetButtonText("Claimed")
            Self.SetGiftImage(GiftOpenedImage.GetImage())
            if(Manager := Self.MaybeGiftManager?):
                Manager.UpdateClaimableGifts()

        else if(Self.IsGiftClaimable = true and Self.IsGiftClaimed = true):
            # Print("Gift Already Claimed")
 
        else:
            # Print("Gift Not Claimable")
       
    CreateCanvas<public>() : canvas =
        block:
        # Self.SetButtonColor(Red)
        Self.Button.OnClick().Subscribe(Self.OnPressed)
        set Self.Canvas = canvas:
                Slots := array:
                    canvas_slot:
                        Anchors := anchors:
                            Minimum := vector2{X := 0.5, Y := 1.0}
                            Maximum := vector2{X := 0.5, Y := 1.0}
                        Alignment := vector2{X := 0.5, Y := 0.5 }
                        # Offsets := margin{Top := 520.540527, Left := 910.960938, Bottom := 520.540527, Right := 910.960938}
                        SizeToContent := true
                        Widget := Self.OverLayTest() 
                    canvas_slot:
                        Anchors := anchors:
                            Minimum := vector2{X := 0.5, Y := 0.1}
                            Maximum := vector2{X := 0.5, Y := 0.1}
                        Alignment := vector2{X := 0.5, Y := 0.5 }
                        Offsets := margin{Top := -100.0, Left := 0.0, Bottom := 0.0, Right := 0.0}
                        SizeToContent := true
                        Widget := Self.GiftImage
                        
        return Self.Canvas

    OverLayTest<public>():overlay=
        return overlay:
            Slots:= array:
                overlay_slot:
                    Widget := Self.Button
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
    
    #Logic Section
    var IsGiftClaimable : logic = false
    var IsGiftClaimed : logic = false

    #Timer Section

    CountdownEndedEvent : event() = event(){}

    TimeRemaining()<transacts>: int=
        return Self.Hours * 3600 + Self.Minutes * 60 + Self.Seconds

    StartCountdown()<suspends>: void =
        # Print("Starting countdown")
        spawn{Self.PrintItWorked()}
        set Self.IsGiftClaimable = false
        loop:
            Self.PrintCurrentTime()
            # Decrement the time
            Self.SetButtonText(Self.FormatTime())
            Self.DecrementTime()

            # Check if the countdown has finished
            if(Self.IsTimeUp() = true):
                Self.CountdownEndedEvent.Signal()
                if(Manager := Self.MaybeGiftManager?):
                    Manager.HighlightNextClaimableGift()
                break

            # Sleep for one second before next decrement
            Sleep(1.0)
        



    PrintItWorked()<suspends>:void=
        Self.CountdownEndedEvent.Await()
        # Print("It worked")
        Self.SetButtonText("Claim")
        # Self.SetButtonColor(Green)
        set Self.IsGiftClaimable = true
        if(Manager := Self.MaybeGiftManager?):
            Manager.HighlightNextClaimableGift()
            Manager.UpdateClaimableGifts()

    # Helper method to decrement the time
    DecrementTime(): void =
        # Print("Decrementing time")
        if(Self.Seconds > 0):
            set Self.Seconds = Self.Seconds - 1
        else:
            if(Self.Minutes > 0):
                set Self.Minutes = Self.Minutes - 1
                set Self.Seconds = 59
            else:
                if(Self.Hours > 0):
                    set Self.Hours = Self.Hours - 1
                    set Self.Minutes = 59
                    set Self.Seconds = 59

    # Helper method to check if the countdown is complete
    IsTimeUp()<transacts>: logic =
        var IsComplete : logic = false
        if (Self.Hours = 0 and Self.Minutes = 0 and Self.Seconds = 0):
            set IsComplete = true

        return IsComplete

    # Method to handle countdown completion
    OnCountdownComplete(): void =
        Print("Countdown Complete! You can now claim your gift.")

    # Helper method to print the current time in HH:MM:SS format
    PrintCurrentTime(): void =
        # Print(Self.FormatTime())
        set Self.CurrentTime = Self.FormatTime()

    # Helper method to ensure time components are always two digits
    PadZero(TimeComponent: int): string =
        if(TimeComponent < 10):
            return "0" + ToString(TimeComponent)
        return ToString(TimeComponent)
    
    # Helper method to format time as HH:MM:SS
    FormatTime(): string =
        return Self.PadZero(Hours) + ":" + Self.PadZero(Minutes) + ":" + Self.PadZero(Seconds)


