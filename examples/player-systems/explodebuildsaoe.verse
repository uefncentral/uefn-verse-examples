# AOE Explosion System
# Creates an area-of-effect explosion system that teleports explosive devices to a player's location and triggers coordinated visual, audio, and destructive effects. The system includes cooldown managem
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/explodebuildsaoe?ref=github



using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters}
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }

ExplodeBuildsAOE := class(creative_device):
    @editable ExplodeAOEDevice : explosive_device = explosive_device{}
    @editable ExplodeAOESound : audio_player_device = audio_player_device{}
    @editable ExplodeAOEVFX : vfx_spawner_device = vfx_spawner_device{}



    @editable Cooldown : float = 0.0
    var MaybeCooldown : logic = false
    @editable ExplodeAOETimer : timer_device = timer_device{}
    @editable CooldownMSG : hud_message_device = hud_message_device{}


    OnBegin<override>()<suspends>:void=
        ExplodeAOETimer.SetMaxDuration(Cooldown)
        set MaybeCooldown = false
        ExplodeAOETimer.SuccessEvent.Subscribe(ResetCooldown)
    ResetCooldown(Agent:?agent) : void=
        set MaybeCooldown = false
    AOEExplosion(Agent:agent)<suspends> : void=
        if(MaybeCooldown = false):
            ExplodeAOETimer.Start(Agent)
            set MaybeCooldown=true
            if (Player:=player[Agent],Target := Player.GetFortCharacter[]):
                if(ExplodeAOEDevice.TeleportTo[Target.GetTransform().Translation, ExplodeAOEDevice.GetTransform().Rotation]){}
                if(ExplodeAOEVFX.TeleportTo[Target.GetTransform().Translation, ExplodeAOEDevice.GetTransform().Rotation]){}
                ExplodeAOEVFX.Enable()
                ExplodeAOEDevice.Explode(Agent)
                ExplodeAOESound.Play(Agent)
                Sleep(0.1)
                ExplodeAOEVFX.Disable()
                if(ExplodeAOEDevice.TeleportTo[vector3{X:=1000.0,Y:=1000.0,Z:=1000.0},ExplodeAOEDevice.GetTransform().Rotation]){}
                ExplodeAOEDevice.Reset()
        else:
            CooldownMSG.Show(Agent)




    