# Countdown Timer UI
# Creates a customizable countdown timer with visual display that can be extended with additional time during gameplay. The timer includes two text displays - one for the main countdown and another for 
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/timer-extensions-2?ref=github

using { GUIExtensions }
using { /Verse.org/Simulation }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath}

TimerExtensions<public> := module:
    countdown_timer<public> := class:
        TimeDisplay:text_block = text_block{}
        ExtensionDisplay:text_block = text_block{}

        TimerTickPeriod<public>:float = 1.0
        var RemainingTime<public>:float

        RunCountdown<public>()<suspends>:void =
            ConfigureUI()
            if (Time := Int[RemainingTime]):
                UpdateUI(Time)
            loop:
                Sleep(TimerTickPeriod)
                set RemainingTime -= TimerTickPeriod

                if (Time := Int[RemainingTime]):
                    UpdateUI(Time)

                if (RemainingTime <= 0.0):
                    break

        AddRemainingTime<public>(ExtraTime:float):void =
            if (RemainingTime > 0.0):
                set RemainingTime += ExtraTime
                if (Time := Int[RemainingTime], AddedTime := Int[ExtraTime]):
                    UpdateUI(Time)
                    spawn{FlashExtension(AddedTime)}

        GetSlots<public>()<transacts>:[]canvas_slot =
            array:
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.0}, Maximum := vector2{X := 0.5, Y := 0.0}}
                    Alignment := vector2{X := 0.5, Y := 0.0}
                    Widget := TimeDisplay  
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.1}, Maximum := vector2{X := 0.5, Y := 0.1}}
                    Alignment := vector2{X := 0.5, Y := 0.0}
                    Offsets := margin{Top := 0.0, Left := 50.0, Bottom := 15.0, Right := 0.0}
                    Widget := ExtensionDisplay

        ConfigureUI():void =
            ExtensionDisplay.SetVisibility(widget_visibility.Hidden)
        
        UpdateUI(Time:int):void =
            TimeDisplay.SetText(ToUIMessage(Time))

        FlashExtension(Time:int)<suspends>:void =
            ExtensionDisplay.SetVisibility(widget_visibility.Visible)
            ExtensionDisplay.SetText(ToUIMessage("+{Time}"))
            Sleep(2.0)
            ExtensionDisplay.SetVisibility(widget_visibility.Hidden)


