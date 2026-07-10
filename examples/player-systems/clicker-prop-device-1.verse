# Clicker Prop System
# Creates an interactive prop that players can damage/click to receive items, with a scaling animation effect. When players damage the prop, they are granted items through the item granter device and th
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/clicker-prop-device-1?ref=github


using { /Fortnite.com/Devices }
using { /Fortnite.com/Devices/CreativeAnimation }
using { /Fortnite.com/Devices/CreativeAnimation/InterpolationTypes }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }

clicker_prop_device := class(creative_device):

    @editable
    PropManipulator : prop_manipulator_device = prop_manipulator_device{}

    @editable
    ClickerProp : creative_prop = creative_prop{}

    @editable
    ItemGranter : item_granter_device = item_granter_device{}

    var AnimationKeyFrames : []keyframe_delta = array{}

    OnBegin<override>()<suspends>:void=
        Print("OnBegin")

        PropManipulator.DamagedEvent.Subscribe(OnPropDamaged)

        TargetScale : float = 0.8
        InverseTargetScale : float = 1.0/0.8
        DownScaleKeyFrame : keyframe_delta = keyframe_delta
        {
            DeltaLocation := vector3{ X := 0.0, Y := 0.0, Z := 0.0 }
            DeltaRotation := IdentityRotation()
            DeltaScale := vector3{ X := TargetScale, Y := TargetScale, Z := TargetScale }
            Time := 0.2
            Interpolation := EaseIn
        }

        UpScaleKeyFrame : keyframe_delta = keyframe_delta
        {
            DeltaLocation := vector3{ X := 0.0, Y := 0.0, Z := 0.0 }
            DeltaRotation := IdentityRotation()
            DeltaScale := vector3{ X := InverseTargetScale, Y := InverseTargetScale, Z := InverseTargetScale }
            Time := 0.2
            Interpolation := EaseIn
        }

        set AnimationKeyFrames = array{ DownScaleKeyFrame, UpScaleKeyFrame }

    OnPropDamaged(Agent : agent):void=
        ItemGranter.GrantItem(Agent)

        if (PropAnimController := ClickerProp.GetAnimationController[]):
            AnimState := PropAnimController.GetState()
            if (AnimState = animation_controller_state.AnimationNotSet or AnimState = animation_controller_state.Stopped):
                PropAnimController.SetAnimation(AnimationKeyFrames, ?Mode := animation_mode.OneShot)
                PropAnimController.Play()