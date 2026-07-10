# Slow Motion Effect
# Creates a cinematic slow motion effect with visual feedback and cooldown system. Players can trigger the effect which plays a sequence and shows HUD messages, with a timer preventing spam activation. 
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/slowmotion?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }


SlowMotion := class(creative_device):
    @editable SlowMotionSequence : cinematic_sequence_device = cinematic_sequence_device{}
    @editable SlowMotionMSG : hud_message_device = hud_message_device{}
    @editable SlowMoLength : float = 0.0

    
    @editable Cooldown : float = 0.0
    var MaybeCooldown : logic = false
    @editable SloMoTimer : timer_device = timer_device{}
    @editable CooldownMSG : hud_message_device = hud_message_device{}

    OnBegin<override>()<suspends>:void=
        SlowMotionMSG.SetDisplayTime(SlowMoLength)
        SloMoTimer.SetMaxDuration(Cooldown)
        set MaybeCooldown = false
        SloMoTimer.SuccessEvent.Subscribe(ResetCooldown)
    ResetCooldown(Agent:?agent) : void=
        set MaybeCooldown = false

    StartSlowMo(Agent:agent) <suspends>: void=  
        if(MaybeCooldown = false):
            SloMoTimer.Start(Agent)
            set MaybeCooldown=true
            SlowMotionMSG.Show()
            SlowMotionSequence.Play()
            Sleep(SlowMoLength)
            SlowMotionSequence.Stop()
        else:
            CooldownMSG.Show(Agent)