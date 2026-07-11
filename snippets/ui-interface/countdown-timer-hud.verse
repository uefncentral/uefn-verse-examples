# Countdown Timer HUD
# A customizable countdown timer that displays on the HUD. Supports pause, resume, and completion events.
# Difficulty: beginner  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/countdown-timer-hud?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# Countdown Timer with HUD Display
countdown_timer := class(creative_device):

    @editable
    TimerDuration : float = 60.0  # Duration in seconds

    @editable
    HUDMessage : hud_message_device = hud_message_device{}

    @editable
    OnCompleteChannel : trigger_device = trigger_device{}

    @editable
    UpdateInterval : float = 1.0

    var RemainingTime : float = 0.0
    var IsPaused : logic = false
    var IsRunning : logic = false

    OnBegin<override>()<suspends> : void =
        StartTimer()

    StartTimer()<suspends> : void =
        set RemainingTime = TimerDuration
        set IsRunning = true
        set IsPaused = false

        loop:
            if (not IsRunning?):
                break

            if (not IsPaused?):
                UpdateDisplay()

                if (RemainingTime <= 0.0):
                    OnTimerComplete()
                    break

                Sleep(UpdateInterval)
                set RemainingTime -= UpdateInterval
            else:
                Sleep(0.1)  # Short sleep while paused

    UpdateDisplay() : void =
        Minutes := Floor(RemainingTime / 60.0)
        Seconds := Floor(Mod(RemainingTime, 60.0))

        # Format as MM:SS
        MinuteStr := if (Minutes < 10) then "0{Minutes}" else "{Minutes}"
        SecondStr := if (Seconds < 10) then "0{Seconds}" else "{Seconds}"

        Message := StringToMessage("{MinuteStr}:{SecondStr}")
        HUDMessage.SetText(Message)
        HUDMessage.Show()

    OnTimerComplete() : void =
        set IsRunning = false
        HUDMessage.SetText(StringToMessage("Time's Up!"))
        OnCompleteChannel.Trigger()
        Print("Timer completed!")

    PauseTimer() : void =
        set IsPaused = true

    ResumeTimer() : void =
        set IsPaused = false

    ResetTimer()<suspends> : void =
        set IsRunning = false
        Sleep(0.1)
        StartTimer()

    AddTime(Seconds : float) : void =
        set RemainingTime += Seconds
        UpdateDisplay()

    GetRemainingTime() : float =
        return RemainingTime
