# Freeze Closest Player
# Verse code for Freeze Closest Player - UEFN/Fortnite Creative implementation
# Difficulty: intermediate  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/freeze-closest-player?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters}
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }


FreezeClosestPlayer := class(creative_device):
    var Targets : []fort_character = array{}
    var NewTargets : []fort_character = array{}
    @editable FreezeClosestProp : creative_prop = creative_prop{}
    @editable FreezeTime : float = 0.0
    @editable FreezeClosestSound : audio_player_device = audio_player_device{}
    @editable FreezeClosestMSG : hud_message_device = hud_message_device{}
    
    


    @editable Cooldown : float = 0.0
    var MaybeCooldown : logic = false
    @editable FreezeClosestTimer : timer_device = timer_device{}
    @editable CooldownMSG : hud_message_device = hud_message_device{}


    OnBegin<override>()<suspends>:void=
        FreezeClosestTimer.SetMaxDuration(Cooldown)
        set MaybeCooldown = false
        FreezeClosestTimer.SuccessEvent.Subscribe(ResetCooldown)
        FreezeClosestMSG.SetDisplayTime(FreezeTime)
    ResetCooldown(Agent:?agent) : void=
        set MaybeCooldown = false


    FreezePlayer(Agent:agent)<suspends> : void=
        if(MaybeCooldown = false):
            FreezeClosestTimer.Start(Agent)
            set MaybeCooldown=true

            set Targets = array{}
            for(Player : GetPlayspace().GetPlayers(),FC := Player.GetFortCharacter[]):
                set Targets += array{FC}
            if(ActivatorPlayer := player[Agent],ActivatorChar := ActivatorPlayer.GetFortCharacter[]):
                if(ActivatorIDX := Targets.Find[ActivatorChar]):
                    if(NEWTARGET := Targets.RemoveElement[ActivatorIDX]):
                        set NewTargets = NEWTARGET
                        if(Target := ActivatorChar.FindNearestTarget[], NewTargets.Length > 0):
                            if(TargetAgent := Target.GetAgent[]):
                                FreezeClosestSound.Play(TargetAgent)
                                FreezeClosestMSG.Show(TargetAgent)
                                if(FreezeClosestProp.TeleportTo[Target.GetTransform().Translation - vector3{Z:=80.0}, Target.GetTransform().Rotation]){} #Required because uefn is weird and broken
                                Target.PutInStasis(stasis_args{})
                                Sleep(FreezeTime)
                                Target.ReleaseFromStasis()
                                if(FreezeClosestProp.TeleportTo[vector3{X:=1000.0,Y:=1000.0,Z:=1000.0},FreezeClosestProp.GetTransform().Rotation]){}
        else:
            CooldownMSG.Show(Agent)


    (FortCharacter : fort_character).FindNearestTarget()<transacts><decides> : fort_character =
        var MaybeTarget : ?fort_character = false
        var NearestLocation : float = 1000000.0
        for (Target : NewTargets):
            if (DistancePlayerToTarget := Distance(Target.GetTransform().Translation, FortCharacter.GetTransform().Translation) < NearestLocation):
                set MaybeTarget = option{Target}
                set NearestLocation = DistancePlayerToTarget
        return MaybeTarget?