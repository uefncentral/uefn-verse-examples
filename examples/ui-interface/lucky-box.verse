# Lucky Box
# Verse code for Lucky Box - UEFN/Fortnite Creative implementation
# Difficulty: intermediate  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/lucky-box?ref=github


using { /Fortnite.com/Devices }
using { /Fortnite.com/Devices/CreativeAnimation }
using { /Fortnite.com/Devices/CreativeAnimation/InterpolationTypes }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

luckybox_device := class(creative_device):

    @editable
    ConditionalButton : conditional_button_device = conditional_button_device{}

    @editable
    CreativeProp : creative_prop = creative_prop{}

    @editable
    ItemGranter : item_granter_device = item_granter_device{}

    var MaybeUserAgent : ?agent = false

    OnBegin<override>()<suspends>:void=
        Print("OnBegin")

        ConditionalButton.ActivatedEvent.Subscribe(OnConditionalButtonActivated)
        if (PropAnimController := CreativeProp.GetAnimationController[]):
            PropAnimController.MovementCompleteEvent.Subscribe(OnLuckyBoxAnimationCompleted)

    OnConditionalButtonActivated(Agent : agent):void=
        ConditionalButton.Disable()
        set MaybeUserAgent = option{ Agent }

        if (PropAnimController := CreativeProp.GetAnimationController[]):
            var AnimationKeyFrames : []keyframe_delta = array{}

            RandomFrameCount : int = 6
            InitialRotation := CreativeProp.GetTransform().Rotation
            var CurrentRotation : rotation = InitialRotation
            for (I := 0 .. RandomFrameCount-1):
                Interpolation : cubic_bezier_parameters = if (I = 0)
                then EaseIn
                else Linear

                RandomFloat1 := GetRandomFloat(-90.0, 90.0)
                RandomFloat2 := GetRandomFloat(-90.0, 90.0)
                RandomFloat3 := GetRandomFloat(-90.0, 90.0)
                RandomRotation := MakeRotationFromYawPitchRollDegrees(RandomFloat1, RandomFloat2, RandomFloat3)
                set CurrentRotation = RandomRotation.RotateBy(CurrentRotation)

                RandomRotationKeyFrame : keyframe_delta = keyframe_delta
                {
                    DeltaLocation := vector3{ X := 0.0, Y := 0.0, Z := 0.0 }
                    DeltaRotation := RandomRotation
                    DeltaScale := vector3{ X := 1.0, Y := 1.0, Z := 1.0 }
                    Time := 0.2
                    Interpolation := Interpolation
                }

                set AnimationKeyFrames += array{ RandomRotationKeyFrame }

            DefaultRotationKeyFrame : keyframe_delta = keyframe_delta
            {
                DeltaLocation := vector3{ X := 0.0, Y := 0.0, Z := 0.0 }
                DeltaRotation := MakeShortestRotationBetween(CurrentRotation, InitialRotation)
                DeltaScale := vector3{ X := 1.0, Y := 1.0, Z := 1.0 }
                Time := 0.5
                Interpolation := EaseOut
            }

            set AnimationKeyFrames += array{ DefaultRotationKeyFrame }

            PropAnimController.SetAnimation(AnimationKeyFrames, ?Mode := animation_mode.OneShot)
            PropAnimController.Play()

    OnLuckyBoxAnimationCompleted():void=
        if (UserAgent := MaybeUserAgent?):
            ItemGranter.CycleToRandomItem(UserAgent)
            set MaybeUserAgent = false

        ConditionalButton.Enable()