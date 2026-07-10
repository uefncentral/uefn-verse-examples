# Turn Invincible
# Verse code for Turn Invincible - UEFN/Fortnite Creative implementation
# Difficulty: intermediate  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/turn-invincible?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }


TurnInvincible := class(creative_device):
    @editable InvincibityVFX : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable InvincibilitySound : audio_player_device = audio_player_device{}
    @editable InvincibilityTime : float = 0.0


    @editable Cooldown : float = 0.0
    var MaybeCooldown : logic = false
    @editable InvincibilityTimer : timer_device = timer_device{}
    @editable CooldownMSG : hud_message_device = hud_message_device{}
    # Make sure both VFX and Invincibility time are the same
    OnBegin<override>()<suspends>:void=
        for(Player : GetPlayspace().GetPlayers(),FC:=Player.GetFortCharacter[]):
            FC.SetVulnerability(true)


        InvincibilityTimer.SetMaxDuration(Cooldown)
        set MaybeCooldown = false
        InvincibilityTimer.SuccessEvent.Subscribe(ResetCooldown)
    ResetCooldown(Agent:?agent) : void=
        set MaybeCooldown = false
    
    Invincibity(Agent:agent)<suspends> : void=
        if(MaybeCooldown = false):
            InvincibilityTimer.Start(Agent)
            set MaybeCooldown=true

            if(Player:=player[Agent], FC:=Player.GetFortCharacter[]):
                InvincibilitySound.Play(Agent)
                InvincibityVFX.Pickup(Agent)
                FC.SetVulnerability(false)
                Sleep(InvincibilityTime)
                FC.SetVulnerability(true)
        else:
            CooldownMSG.Show(Agent)
        
    