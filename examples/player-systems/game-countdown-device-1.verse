# Visual Countdown Timer
# Creates a visual countdown timer that scales a prop's X-axis to represent remaining time. When the timer reaches zero, it triggers explosive devices and automatically restarts the countdown cycle.  **
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/game-countdown-device-1?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

game_countdown_device := class(creative_device):

    @editable TimerProp : creative_prop = creative_prop{}
    @editable Explosives : []explosive_device = array{}
    @editable InitialSeconds : int = 120
    
    OnBegin<override>()<suspends>:void=
        spawn {OnCountdownStart()}

    OnCountdownStart()<suspends>:void=
        var CurrentSeconds : int = 0
        set CurrentSeconds = InitialSeconds
        loop:
            set CurrentSeconds -= 1
            if (CurrentSeconds <= 0):
                UpdateTimerProp(0.001)
                Sleep(0.5)
                OnRoundEnd()
                break
            
            else:
                UpdateTimerProp(CurrentSeconds * 1.0)
            Sleep(0.5)

    UpdateTimerProp(Seconds : float)<suspends>:void=
        TimerTransform := TimerProp.GetTransform()
        TimerTranslation := TimerTransform.Translation
        TimerRotation := TimerTransform.Rotation
        TimerScaleY := TimerTransform.Scale.Y
        TimerScaleZ := TimerTransform.Scale.Z
        NewTransform := transform{Rotation := TimerRotation, Translation := TimerTranslation, Scale := vector3{X := Seconds, Y := TimerScaleY, Z := TimerScaleZ}}
        TimerProp.MoveTo(NewTransform, 0.5)
        if (Seconds < 1.0):
            ResetTimerProp(TimerTranslation, TimerRotation, TimerScaleY, TimerScaleZ)

    ResetTimerProp(TimerTranslation : vector3, TimerRotation : rotation, TimerScaleY : float, TimerScaleZ : float):void=
        NewTransform := transform{Rotation := TimerRotation, Translation := TimerTranslation, Scale := vector3{X := InitialSeconds * 1.0, Y := TimerScaleY, Z := TimerScaleZ}}
        if (TimerProp.TeleportTo[NewTransform]){}

    OnRoundEnd():void=
        TriggerExplosives()
        spawn {OnCountdownStart()}

    TriggerExplosives():void=
        Players := GetPlayspace().GetPlayers()
        if (Player := Players[0]):
            for (Explosive : Explosives):
                Explosive.Explode(Player)
                Explosive.Reset()