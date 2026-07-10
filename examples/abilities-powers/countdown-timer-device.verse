# Power Cooldown Timer
# Creates a visual countdown timer that displays on the HUD, showing cooldown time in seconds and tenths of seconds format. When the timer completes, it displays 'POWER READY' indicating an ability or p
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/countdown-timer-device?ref=github

using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Game }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

countdown_device := class<concrete>():

    @editable
    MainHUD : hud_message_device = hud_message_device{}


    CountdownTimerToUI<localizes>(CountdownTimerText : string)<computes> : message = "{CountdownTimerText}"

    InitTimer()<suspends>:void=
        Print("starting InitTimer")
        Sleep(0.25)
        MainHUD.Show()
        Sleep(0.25)
        HudMessage : string = "POWER READY"
        MainHUD.SetText(CountdownTimerToUI(HudMessage))

    StartTimer(TimerSeconds : int, TimerMiliSeconds : int)<suspends>:void=
        Print("starting timer")
        var Seconds : int = TimerSeconds
        var MiliSeconds : int = TimerMiliSeconds
        loop:
            Sleep(0.1)
            HudMessage : string = "COOLDOWN: {Seconds}.{MiliSeconds}"
            MainHUD.SetText(CountdownTimerToUI(HudMessage))
            if(MiliSeconds >= 1):
                set MiliSeconds -= 1
            else:
                if(Seconds > 0):
                    set Seconds -= 1
                    set MiliSeconds = 9
                else:
                    OnCompletedTimer()
                    break

    OnCompletedTimer():void=
        Print("timer completed")
        HudMessage : string = "POWER READY"
        MainHUD.SetText(CountdownTimerToUI(HudMessage))