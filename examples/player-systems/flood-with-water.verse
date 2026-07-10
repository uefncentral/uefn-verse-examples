# Flood With Water
# Verse code for Flood With Water - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/flood-with-water?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters }

FloodWithWater := class(creative_device):
    @editable WaterSound : audio_player_device = audio_player_device{}
    @editable WaterDevice : water_device = water_device{}
    @editable WaterStandStillTime : float = 0.0
    @editable WaterRiseAndFallTime : float = 0.0
    @editable WaterDMGBoost : damage_amplifier_powerup_device = damage_amplifier_powerup_device{}
    @editable WaterSpeedBoost : movement_modulator_device = movement_modulator_device{}
    @editable WaterDMGScaleAmount : float = 0.0
    @editable WaterDamageAmount : float = 0.0
    @editable WaterSetting : int = 0
    #if 1 water will damage other players


    @editable WaterMaxHeight : float = 0.0
    # 0.0 fills the arena half-way

    var HasPowers : logic = false
    var PlayerAgent : []agent = array{} 

    @editable Cooldown : float = 0.0
    var MaybeCooldown : logic = false
    @editable WaterTimer : timer_device = timer_device{}
    @editable CooldownMSG : hud_message_device = hud_message_device{}

    OnBegin<override>()<suspends>:void=
        WaterDMGBoost.SetMagnitude(WaterDMGScaleAmount)
        WaterTimer.SetMaxDuration(Cooldown)
        set MaybeCooldown = false
        WaterTimer.SuccessEvent.Subscribe(ResetCooldown)



        set PlayerAgent = array{}
        WaterDevice.AgentEntersWaterEvent.Subscribe(WaterEnterT)
    ResetCooldown(Agent:?agent) : void=
        set MaybeCooldown = false

    FloodWater(Agent:agent)<suspends> : void=
        if(MaybeCooldown = false):
            WaterTimer.Start(Agent)
            set MaybeCooldown=true
            set PlayerAgent = array{}
            set PlayerAgent += array{Agent}
            WaterSound.Play(Agent)

            WaterMaxPosition := vector3{X:=1536.0,Y:=512.0,Z:=WaterMaxHeight}
            if(WaterDevice.TeleportTo[vector3{X:=1536.0,Y:=512.0,Z:=-384.0} , WaterDevice.GetTransform().Rotation]){}

            WaterDevice.MoveTo(WaterMaxPosition , WaterDevice.GetTransform().Rotation , WaterRiseAndFallTime)
            Sleep(WaterStandStillTime)
            WaterDevice.MoveTo(vector3{X:=1536.0,Y:=512.0,Z:=-384.0} , WaterDevice.GetTransform().Rotation , WaterRiseAndFallTime)

            if(WaterDevice.TeleportTo[vector3{X:=10000.0,Y:=10000.0,Z:=-10000.0} , WaterDevice.GetTransform().Rotation]){}

        else:
            CooldownMSG.Show(Agent)
    

    WaterEnterT(Agent:agent) : void=
        spawn:
            WaterEnter(Agent)
    WaterEnter(Agent:agent)<suspends> : void=
        if(Player := player[Agent],FC := Player.GetFortCharacter[]):
            loop:
                Sleep(1.0)
                if(FC.IsInWater[]):
                    if(Agent = PlayerAgent[0]):
                        if(HasPowers = false):
                            set HasPowers = true
                            spawn:
                                ResetHasPowers()
                            WaterDMGBoost.Pickup(Agent)
                            WaterSpeedBoost.Activate(Agent)
                    else:
                        if(WaterSetting = 1):
                            FC.Damage(WaterDamageAmount)
    ResetHasPowers()<suspends> : void=
        Sleep(5.0)
        set HasPowers = false
                
