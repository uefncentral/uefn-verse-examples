# Countdown Timer UI
# Creates a customizable countdown timer with visual UI display that shows remaining time and added time feedback. The timer can be started, have time added dynamically, and fires events when the countd
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/countdown-timer-1?ref=github

using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Simulation }
using { /Fortnite.com/UI }

MakeCountdownTimer(MaxTime : float, InPlayer : agent) := countdown_timer:
    RemainingTime := MaxTime
    MaybePlayerUI := option{GetPlayerUI[player[InPlayer]]}

countdown_timer := class:
    <# This block runs for each instance of the countdown_timer class.
       We can setup the canvas once here. #>
    block:
        set Canvas = canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors:
                        Minimum := vector2{X := 0.4, Y := 0.3}
                        Maximum := vector2{X := 0.6, Y := 0.3}
                    Alignment := vector2{X := 0.5, Y := 0.5 }
                    Offsets := margin{Top := 0.0, Left := 0.0, Bottom := 0.0, Right := 0.0}
                    SizeToContent := true
                    Widget := RemainingTimeTextBlock
                canvas_slot:
                    Anchors := anchors:
                        Minimum := vector2{X := 0.4, Y := 0.3}
                        Maximum := vector2{X := 0.6, Y := 0.3}
                    Alignment := vector2{X := 0.0, Y := 1.0}
                    Offsets := margin{Top := 0.0, Right := 0.0}
                    SizeToContent := true
                    Widget := AddedTimeTextBlock

    CountdownEndedEvent : event(float) = event(float){}

    StartCountdown() : void =
        if (PlayerUI := MaybePlayerUI?):
            PlayerUI.AddWidget(Canvas)

        # Update the UI when we start the timer to see the initial RemainingTime on screen
        UpdateUI()
        spawn:
            RunCountdown()

    AddRemainingTime(Time : float) : void =
        set RemainingTime += Time
        # Immediately update UI for better player feedback when time is added.
        UpdateUI()

        # Fire a simple callout to show the time being added.
        spawn:
            AddedTimeCallout(Time)

    MaybePlayerUI : ?player_ui = false
    var RemainingTime : float = 0.0
    RemainingTimeTextBlock : text_block = text_block{}
    AddedTimeTextBlock : text_block = text_block{}
    RemainingTimeText(CurrentRemainingTime : int) : message = "{CurrentRemainingTime}"
    AddedTimeText(AddedTime : int) : message = " +{AddedTime}!"
    var Canvas : canvas = canvas{}
    var TotalTime : float = 0.0
    # The timer "precision": how often, in seconds, it ticks.
    TimerTickPeriod : float = 1.0

    RunCountdown() : void =
        # We loop with the TimerTickPeriod.
        # The UI is also updated each time.
        loop:
            Sleep(TimerTickPeriod)
            set TotalTime += TimerTickPeriod
            set RemainingTime -= TimerTickPeriod
            UpdateUI()

            # Timer End
            if (RemainingTime <= 0.0):

                Canvas.RemoveWidget(RemainingTimeTextBlock)

                if (UI := MaybePlayerUI?):
                    UI.RemoveWidget(Canvas)

                CountdownEndedEvent.Signal(TotalTime)
                break

    AddedTimeCallout(Time : float) : void =
        if:
            PlayerUI := MaybePlayerUI?
            IntTime := Int[Time]
        then:
            AddedTimeTextBlock.SetVisibility(widget_visibility.Visible)
            AddedTimeTextBlock.SetText(AddedTimeText(IntTime))
            Sleep(2.0)
            AddedTimeTextBlock.SetVisibility(widget_visibility.Hidden)

    UpdateUI() : void =
        if (IntTime := Int[RemainingTime]):
            RemainingTimeTextBlock.SetText(RemainingTimeText(IntTime))