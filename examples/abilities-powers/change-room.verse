# Change Room
# Verse code for Change Room - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/change-room?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }

ChangeRoom := class(creative_device):
    @editable BasicFuncs : BasicFunctions = BasicFunctions{}

    @editable Cooldown : float = 0.0
    var MaybeCooldown : logic = false
    @editable ChangeRoomTimer : timer_device = timer_device{}
    @editable CooldownMSG : hud_message_device = hud_message_device{}

    @editable ChangeRoomBarrier : barrier_device = barrier_device{}
    @editable ChangeRoomVFXs : []vfx_spawner_device = array{}
    @editable ChangeRoomCin : cinematic_sequence_device = cinematic_sequence_device{}
    @editable ChangeRoomAllSound : audio_player_device = audio_player_device{}
    @editable ChangeRoomCinSound : audio_player_device = audio_player_device{}
    @editable ChangeRoomMutator : mutator_zone_device = mutator_zone_device{}
    @editable ChangeRoomExplosive : explosive_device = explosive_device{}
    @editable ChangeRoomTime : float = 0.0


    @editable ChangeRoom1v1Setting : int  = 0
    #if 1: only works in 1v1



    @editable ChangeRoomCinematicSetting : int = 0
    #if 1: No Cinematic
    #if 2: Cinematic

    @editable ChangeRoomBuffSetting : int = 0
    #if 1: DMG Boost
    #if 2: Speed Boost
    #if 3: DMG and Speed
    #if 4: Invincible




    @editable DMGBoostAmount : float = 0.0
    @editable BuffTime : float = 0.0
    @editable ChangeRoomInvincibilityVFX : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable ChangeRoomSpeedDevice : movement_modulator_device = movement_modulator_device{}



    OnBegin<override>()<suspends>:void=
        ChangeRoomTimer.SetMaxDuration(Cooldown)
        set MaybeCooldown = false
        ChangeRoomTimer.SuccessEvent.Subscribe(ResetCooldown)
    ResetCooldown(Agent:?agent) : void=
        set MaybeCooldown = false
    
    ChangeRoomAbility(Agent:agent) <suspends> : void=
        if(MaybeCooldown = false):
            ChangeRoomTimer.Start(Agent)
            set MaybeCooldown=true

            if(ChangeRoom1v1Setting = 1):
                Players := GetPlayspace().GetPlayers()
                if(Players.Length < 2):
                
                else:
                    if(ChangeRoomCinematicSetting = 1):
                        spawn:
                            NoCinChangeRoom(Agent)
                    else if(ChangeRoomCinematicSetting = 2):
                        spawn:
                            CinChangeRoom(Agent)

            else:
                if(ChangeRoomCinematicSetting = 1):
                    spawn:
                        NoCinChangeRoom(Agent)
                else if(ChangeRoomCinematicSetting = 2):
                    spawn:
                        CinChangeRoom(Agent)
        else:
            CooldownMSG.Show(Agent)


    NoCinChangeRoom(Agent:agent) <suspends> : void=
        for(Player:GetPlayspace().GetPlayers()):
            if(FC := Player.GetFortCharacter[], NewAgent:=FC.GetAgent[]):
                ChangeRoomAllSound.Play(NewAgent)
        for(VFX : ChangeRoomVFXs ):
            VFX.Enable()
        ChangeRoomBarrier.Enable()
        ChangeRoomMutator.Enable()
        ChangeRoomExplosive.Explode(Agent)
        BuffCheck(Agent)
        Sleep(ChangeRoomTime)
        for(VFX : ChangeRoomVFXs ):
            VFX.Disable()
        ChangeRoomBarrier.Disable()
        ChangeRoomMutator.Disable()
        ChangeRoomExplosive.Reset()
        for(Player:GetPlayspace().GetPlayers()):
            if(FC := Player.GetFortCharacter[], NewAgent:=FC.GetAgent[]):
                ChangeRoomAllSound.Stop(NewAgent)







    CinChangeRoom(Agent:agent) <suspends> : void=
        for(Player:GetPlayspace().GetPlayers()):
            if(FC := Player.GetFortCharacter[], NewAgent:=FC.GetAgent[]):
                ChangeRoomCin.Play(NewAgent)
        ChangeRoomCinSound.Play()
        for(VFX : ChangeRoomVFXs ):
            VFX.Enable()
        ChangeRoomBarrier.Enable()
        ChangeRoomMutator.Enable()
        ChangeRoomExplosive.Explode(Agent)
        BuffCheck(Agent)
        Sleep(ChangeRoomTime)
        for(VFX : ChangeRoomVFXs ):
            VFX.Disable()
        ChangeRoomBarrier.Disable()
        ChangeRoomMutator.Disable()
        ChangeRoomExplosive.Reset()
        for(Player:GetPlayspace().GetPlayers()):
            if(FC := Player.GetFortCharacter[], NewAgent:=FC.GetAgent[]):
                ChangeRoomCin.Stop(NewAgent)


    BuffCheck(Agent:agent) : void=
        if(ChangeRoomBuffSetting = 1):
            BasicFuncs.DoDamageBuff(Agent,BuffTime,DMGBoostAmount)
        else if(ChangeRoomBuffSetting = 2):
            ChangeRoomSpeedDevice.Activate(Agent)
        else if(ChangeRoomBuffSetting = 3):
            BasicFuncs.DoDamageBuff(Agent,BuffTime,DMGBoostAmount)
            ChangeRoomSpeedDevice.Activate(Agent)
        else if(ChangeRoomBuffSetting = 4):
            ChangeRoomInvincibilityVFX.SetDuration(BuffTime)
            ChangeRoomInvincibilityVFX.Pickup(Agent)
            spawn:
                BasicFuncs.DoInvcibilityBuff(Agent, BuffTime)
        else:
            