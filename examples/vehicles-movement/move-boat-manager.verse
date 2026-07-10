# Move Boat Manager
# Verse code for Move Boat Manager - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/move-boat-manager?ref=github


using { /Fortnite.com/Devices }
using { /Fortnite.com/Devices/CreativeAnimation }
using { /Fortnite.com/Devices/CreativeAnimation/InterpolationTypes }
using { /Verse.org/Simulation }

using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

MoveBoatManager := class(creative_device):

    @editable
    Boat:creative_prop = creative_prop{}

    @editable
    BoatSequence:cinematic_sequence_device = cinematic_sequence_device{}

    @editable
    ResetButton:button_device = button_device{}

    @editable
    MoveToButton:button_device = button_device{}

    @editable
    AnimateButton:button_device = button_device{}

    @editable
    TeleportToButton:button_device = button_device{}

    @editable
    PlaySequenceButton:button_device = button_device{}

    OnBegin<override>()<suspends>:void=

        ResetButton.InteractedWithEvent.Subscribe(OnReset)
        MoveToButton.InteractedWithEvent.Subscribe(OnMove)
        AnimateButton.InteractedWithEvent.Subscribe(OnAnimate)
        TeleportToButton.InteractedWithEvent.Subscribe(OnTeleport)
        PlaySequenceButton.InteractedWithEvent.Subscribe(OnPlaySequence)


    OnReset(Agent:agent):void=
        
        if(Boat.TeleportTo[vector3{X:=-4960.0,Y:=3191.0,Z:=336.0}, Boat.GetTransform().Rotation]):

    OnMove(Agent:agent):void=
        spawn:
            MoveBoat()

    MoveBoat()<suspends>:void=
        Boat.MoveTo(vector3{X:=2150.0,Y:=3191.0,Z:=336.0}, Boat.GetTransform().Rotation, 5.0)

    OnAnimate(Agent:agent):void=

        MovementKeyFrame1: keyframe_delta = keyframe_delta
            {
                
                DeltaLocation := vector3 { X:=7100.0, Y:=0.0, Z:=0.0 }
                # Rotate the object 90 degrees about the Z (Yaw)
                DeltaRotation := MakeRotationFromYawPitchRollDegrees(0.0, 0.0, 0.0)
                # Do not change scale
                DeltaScale := vector3 { X:=1.0, Y:=1.0, Z:=1.0 }
                
                Time := 5.0
                # Use EaseOut interpolation
                Interpolation := EaseInOut
            }

            if (BoatController := Boat.GetAnimationController[]):
                # Make an array of the keyframes
                FortVaderKeyFrames:[]keyframe_delta = array { MovementKeyFrame1 }
                # Set the animation to play
                BoatController.SetAnimation(FortVaderKeyFrames, ?Mode:=animation_mode.OneShot)
                # Play the animation
                BoatController.Play()


    OnTeleport(Agent:agent):void=
        if(Boat.TeleportTo[vector3{X:=2150.0,Y:=3191.0,Z:=336.0}, Boat.GetTransform().Rotation]):

    OnPlaySequence(Agent:agent):void=
        BoatSequence.Play()



