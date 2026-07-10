# Countdown Timer Device
# A customizable countdown timer that displays time in MM:SS format on a HUD message device. When the timer reaches zero, it triggers a celebration effect and can be started or stopped using trigger dev
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/countdown?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# Un dispositivo creativo programado en Verse que puede colocarse en un nivel
TimerDevice := class(creative_device):
    @editable MainHUD : hud_message_device = hud_message_device{}
    @editable StartCountdown : trigger_device = trigger_device{}
    @editable StopCountdown : trigger_device = trigger_device{}
    @editable PartyVFX : vfx_spawner_device = vfx_spawner_device{}
    @editable TimerMins : int = 0
    @editable TimerSec : int = 20
    var BreakLoop: logic = false 
    CountdownTimerToUI<localizes>(CountdownTimerText : string)<computes> : message = "{CountdownTimerText}" 
   
    # Se ejecuta cuando el dispositivo se inicia en un juego en curso
    OnBegin<override>()<suspends>:void=
        StartCountdown.TriggeredEvent.Subscribe(StartCountdownEvent)
        StopCountdown.TriggeredEvent.Subscribe(StopCountdownEvent)
    StartCountdownEvent(Agent : ?agent):void=
        spawn {OnCountdownTimer()}
    StopCountdownEvent(Agent : ?agent):void=
        set BreakLoop = true
    
    OnCountdownTimer()<suspends>:void=
        var Minutes : int = TimerMins
        var Seconds : int = TimerSec 
        set BreakLoop = false 
        loop: 
            Sleep(1.0)
            if (Seconds >= 10):
                HudMessage : string = "{Minutes}:{Seconds}"
                MainHUD.SetText(CountdownTimerToUI(HudMessage))
            else:
                HudMessage : string = "{Minutes}:0{Seconds}"
                MainHUD.SetText(CountdownTimerToUI(HudMessage))
            if (Seconds >= 1):
                set Seconds -= 1
            else:
                if (Minutes > 0):
                    set Minutes -=1 
                    set Seconds = 59
                else:
                    set BreakLoop = true
                    OnCelebration()
            
            if (BreakLoop?):
                break
    OnCelebration():void=
        PartyVFX.Enable()
        HudMessage : string = "¡Hora de la Fiesta!"
        MainHUD.SetText(CountdownTimerToUI(HudMessage))