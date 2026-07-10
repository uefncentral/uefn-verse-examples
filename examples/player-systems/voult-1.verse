# Timed Vault Door System
# Creates a vault with two moving walls/doors that open automatically after a configurable timer expires. The system disables a mutator zone and animates both doors sliding apart horizontally when the t
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/voult-1?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/Devices/CreativeAnimation }
using { /Fortnite.com/FortPlayerUtilities }
using { /Fortnite.com/Devices/CreativeAnimation/InterpolationTypes }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }


VaultMovingCode := class(creative_device):

    @editable VaultTimer : timer_device = timer_device{}
    @editable TimerTimeInMinutes : int = 30
    @editable VaultOpenInMinutes : int = 5

    @editable RightWall : creative_prop = creative_prop{}
    @editable LeftWall : creative_prop = creative_prop{}

    @editable MutatorZone : mutator_zone_device = mutator_zone_device{}
    @editable TeleportDev : teleporter_device = teleporter_device{}


    var KeyFramesForRightDoor : []keyframe_delta = array{}
    var KeyFramesForLeftDoor : []keyframe_delta = array{}



    OnBegin<override>()<suspends>:void=
        VaultTimer.SuccessEvent.Subscribe(OnVaultTimerSuccess)


    OnVaultTimerSuccess(Agent:?agent):void=
        SetTimer()
        spawn:
            MoveDoors()

    SetTimer():void=
        VaultTimer.SetMaxDuration(TimerTimeInMinutes *60.0)

    MoveDoors()<suspends>:void=

        MoveDoorToTheRight : keyframe_delta = keyframe_delta{
            DeltaLocation := vector3{X:=-2013.0, Y:=0.0, Z:=0.0}
            DeltaRotation := IdentityRotation()
            Time := 1.0
            Interpolation:=EaseIn
        }

        MoveDoorToTheLeft : keyframe_delta = keyframe_delta{
            DeltaLocation := vector3{X:=2013.0, Y:=0.0, Z:=0.0}
            DeltaRotation := IdentityRotation()
            Time := 1.0
            Interpolation:=EaseIn
        }

        set KeyFramesForRightDoor = array{MoveDoorToTheRight}
        set KeyFramesForLeftDoor = array{MoveDoorToTheLeft}

        Print("TriggerWasTrigger")
        MutatorZone.Disable()
        if(RightWallAnimController := RightWall.GetAnimationController[]):
            if(LeftWallAnimController := LeftWall.GetAnimationController[]):
                RightAnimState := RightWallAnimController.GetState()
                LeftAnimState := LeftWallAnimController.GetState()
                if(RightAnimState = animation_controller_state.AnimationNotSet or RightAnimState = animation_controller_state.Stopped):
                    if(LeftAnimState = animation_controller_state.AnimationNotSet or LeftAnimState = animation_controller_state.Stopped):
                        RightWallAnimController.SetAnimation(KeyFramesForRightDoor, ?Mode := animation_mode.OneShot)
                        LeftWallAnimController.SetAnimation(KeyFramesForLeftDoor, ?Mode := animation_mode.OneShot)
                        RightWallAnimController.Play()
                        LeftWallAnimController.Play()
                        Sleep(VaultOpenInMinutes * 60.0)
                        set KeyFramesForRightDoor = array{MoveDoorToTheLeft}
                        set KeyFramesForLeftDoor = array{MoveDoorToTheRight}
                        RightWallAnimController.SetAnimation(KeyFramesForRightDoor, ?Mode := animation_mode.OneShot)
                        LeftWallAnimController.SetAnimation(KeyFramesForLeftDoor, ?Mode := animation_mode.OneShot)
                        RightWallAnimController.Play()
                        LeftWallAnimController.Play()
                        Print("Move Doors")
                        MutatorZone.Enable()
                        MutatorZone.AgentEntersEvent.Subscribe(TeleportAgent)
                        VaultTimer.Reset()
                        VaultTimer.Start()

    TeleportAgent(Agent:agent):void=
        TeleportDev.Teleport(Agent)