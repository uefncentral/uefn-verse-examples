# Separate Arena Button
# Verse code for Separate Arena Button - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/separate-arena-button?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Game }
SeparateArenaButton := class(creative_device):
    @editable Cooldown : float = 0.0
    var MaybeCooldown : logic = false
    @editable SeparateArenaTimer : timer_device = timer_device{}
    @editable CooldownMSG : hud_message_device = hud_message_device{}
    
    @editable SeparateArenaButtonStormCircle : basic_storm_controller_device = basic_storm_controller_device{}
    @editable SeparateArenaButtonTargetTP : teleporter_device = teleporter_device{}
    @editable SeparateArenaButtonActivatorTP : teleporter_device = teleporter_device{}
    @editable SeparateArenaButtonTargetBackTP : teleporter_device = teleporter_device{}
    @editable SeparateArenaButtonActivatorBackTP : teleporter_device = teleporter_device{}
    @editable SeparateArenaButtonCin : cinematic_sequence_device = cinematic_sequence_device{}
    @editable SeparateArenaButtonCin2 : cinematic_sequence_device = cinematic_sequence_device{}
    @editable TimeInArena : float = 0.0
    @editable FreezePlayersLength : float = 0.0 #Make sure this is equal to the length of the cinematic
    @editable SeparateArenaButtonSound : audio_player_device = audio_player_device{}
    @editable ArenaSetting : int = 0
    #1 = Closest Player
    #2 = Only Works In 1v1
    var Targets : []fort_character = array{}
    var NewTargets : []fort_character = array{}
    var CheckPlayerCountArray : []fort_character = array{}
    var EndTime : logic = false
    var Playerhasdied: logic = false 

    OnBegin<override>()<suspends>:void=
        SeparateArenaTimer.SetMaxDuration(Cooldown)
        set MaybeCooldown = false
        SeparateArenaTimer.SuccessEvent.Subscribe(ResetCooldown)
        spawn:
            StartZone()
    ResetCooldown(Agent:?agent) : void=
        set MaybeCooldown = false

    SeparateArenaAbility(Agent:agent)<suspends> : void=
        if(MaybeCooldown = false):
            SeparateArenaTimer.Start(Agent)
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
                        if(ArenaSetting = 1):
                            
                            var ActivatorLocation : vector3 = ActivatorChar.GetTransform().Translation
                            var TargetLocation : vector3 = Target.GetTransform().Translation
                            SeparateArenaButtonActivatorTP.Teleport(Agent)
                            SeparateArenaButtonTargetTP.Teleport(TargetAgent)
                            ActivatorChar.PutInStasis(stasis_args{})
                            Target.PutInStasis(stasis_args{})
                            SeparateArenaButtonSound.Play()
                            SeparateArenaButtonCin.Play(Agent)
                            SeparateArenaButtonCin2.Play(TargetAgent)
                            Sleep(FreezePlayersLength)
                            SeparateArenaButtonCin.Stop(Agent)
                            SeparateArenaButtonCin2.Stop(TargetAgent)
                            ActivatorChar.ReleaseFromStasis()
                            Target.ReleaseFromStasis()
                            set EndTime = false
                            set Playerhasdied = false
                            spawn:
                                Time()
                            Target.EliminatedEvent().Subscribe(EndTimeFunc)
                            ActivatorChar.EliminatedEvent().Subscribe(EndTimeFunc)
                            loop:
                                Sleep(0.1)
                                if(EndTime = true):
                                    if(SeparateArenaButtonActivatorBackTP.TeleportTo[ActivatorLocation,IdentityRotation()]){}
                                    SeparateArenaButtonActivatorBackTP.Teleport(Agent)
                                    if(SeparateArenaButtonActivatorBackTP.TeleportTo[vector3{X:=10000.0, Y:=10000.0, Z:=10000.0},IdentityRotation()]){}

                                    if(SeparateArenaButtonTargetBackTP.TeleportTo[TargetLocation,IdentityRotation()]){}
                                    SeparateArenaButtonTargetBackTP.Teleport(TargetAgent)
                                    if(SeparateArenaButtonTargetBackTP.TeleportTo[vector3{X:=10000.0, Y:=10000.0, Z:=10000.0},IdentityRotation()]){}
                                    break

                        else if(ArenaSetting = 2):
                            set CheckPlayerCountArray = array{}
                            for (Player : GetPlayspace().GetPlayers(),FC := Player.GetFortCharacter[]):
                                if(FC.IsActive[]):
                                    set CheckPlayerCountArray += array{FC}
                            if(CheckPlayerCountArray.Length = 2):
                                SeparateArenaButtonActivatorTP.Teleport(Agent)
                                SeparateArenaButtonTargetTP.Teleport(TargetAgent)
                                ActivatorChar.PutInStasis(stasis_args{})
                                Target.PutInStasis(stasis_args{})
                                SeparateArenaButtonSound.Play()
                                SeparateArenaButtonCin.Play(Agent)
                                SeparateArenaButtonCin2.Play(TargetAgent)
                                Sleep(FreezePlayersLength)
                                SeparateArenaButtonCin.Stop(Agent)
                                SeparateArenaButtonCin2.Stop(TargetAgent)
                                ActivatorChar.ReleaseFromStasis()
                                Target.ReleaseFromStasis()
                        else:

        else:
            CooldownMSG.Show(Agent)

    EndTimeFunc(Result : elimination_result) : void=
        set EndTime = true
        set Playerhasdied = true
    Time()<suspends> : void=
        Sleep(TimeInArena)
        if (Playerhasdied = false):
            set EndTime = true






    (FortCharacter : fort_character).FindNearestTarget()<transacts><decides> : fort_character =
        var MaybeTarget : ?fort_character = false
        var NearestLocation : float = 1000000.0
        for (Target : NewTargets):
            if (DistancePlayerToTarget := Distance(Target.GetTransform().Translation, FortCharacter.GetTransform().Translation) < NearestLocation):
                set MaybeTarget = option{Target}
                set NearestLocation = DistancePlayerToTarget
        return MaybeTarget?


    StartZone()<suspends> : void=
        Sleep(3.0)
        SeparateArenaButtonStormCircle.GenerateStorm()

