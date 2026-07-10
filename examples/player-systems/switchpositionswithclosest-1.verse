# Player Position Teleport Swapper
# This code allows a player to instantly swap positions with their closest teammate when activated. It includes a cooldown system to prevent spam usage and uses audio cues and visual feedback when the p
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/switchpositionswithclosest-1?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters}
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }

SwitchPositionsWithClosest := class(creative_device):
    var Targets : []fort_character = array{}
    var NewTargets : []fort_character=array{}
    @editable SwitchPOSActivatorSound : audio_player_device = audio_player_device{}
    @editable SwitchPOSTargetSound : audio_player_device = audio_player_device{}
    @editable SwitchPOSTP1 : teleporter_device = teleporter_device{}
    @editable SwitchPOSTP2 : teleporter_device = teleporter_device{}

    @editable Cooldown : float = 0.0
    var MaybeCooldown : logic = false
    @editable SwitchPOSTimer : timer_device = timer_device{}
    @editable CooldownMSG : hud_message_device = hud_message_device{}

    OnBegin<override>()<suspends>:void=
        SwitchPOSTimer.SetMaxDuration(Cooldown)
        set MaybeCooldown = false
        SwitchPOSTimer.SuccessEvent.Subscribe(ResetCooldown)
    ResetCooldown(Agent:?agent) : void=
        set MaybeCooldown = false



    SwitchPositions(Agent:agent)<suspends> : void=
        if(MaybeCooldown = false):
            SwitchPOSTimer.Start(Agent)
            set MaybeCooldown=true
            set Targets = array{}
            for (Player : GetPlayspace().GetPlayers(),FortCharacter := Player.GetFortCharacter[]):
                set Targets += array{FortCharacter}
            if(ActivatorPlayer := player[Agent],ActivatorChar := ActivatorPlayer.GetFortCharacter[]):
                if(ActivatorIDX := Targets.Find[ActivatorChar]):
                    if(NEWTARRGET := Targets.RemoveElement[ActivatorIDX]):  
                        set NewTargets = NEWTARRGET
                    if(Target := ActivatorChar.FindNearestTarget[],NewTargets.Length > 0):
                        if(TargetAgent := Target.GetAgent[]):
                            TempLocation := ActivatorChar.GetTransform().Translation
                            TempRotation := ActivatorChar.GetTransform().Rotation

                            if(SwitchPOSTP1.TeleportTo[Target.GetTransform().Translation, Target.GetTransform().Rotation]){}
                            SwitchPOSTP1.Teleport(Agent)

                            if(SwitchPOSTP2.TeleportTo[TempLocation, TempRotation]){}
                            SwitchPOSTP2.Teleport(TargetAgent)

                            SwitchPOSActivatorSound.Play(Agent)
                            SwitchPOSTargetSound.Play(TargetAgent)

                            if(SwitchPOSTP1.TeleportTo[vector3{X:=1000.0,Y:=1000.0,Z:=1000.0},SwitchPOSTP1.GetTransform().Rotation]){}
                            if(SwitchPOSTP2.TeleportTo[vector3{X:=1000.0,Y:=1000.0,Z:=1000.0},SwitchPOSTP2.GetTransform().Rotation]){}
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