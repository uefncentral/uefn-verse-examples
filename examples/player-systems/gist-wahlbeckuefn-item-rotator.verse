# Automatic Object Rotator
# This device automatically rotates tagged props in the scene with customizable rotation axes (yaw, pitch, roll) and speed. It uses a tag system to identify which objects to rotate and continuously appl
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/gist-wahlbeckuefn-item-rotator?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Simulation/Tags }

# Tag system so we can find all objects we want to rotate
rotate_on := class(tag) {}


item_rotator := class(creative_device):

    @editable var RotateYaw : logic = false
    @editable var RotatePitch : logic = false
    @editable var RotateRoll : logic = false
    @editable var Speed : float = 0.10

    # Any props we want to rotate
    var RotatingObjects : []creative_object_interface = array{}
    
    OnBegin<override>()<suspends>:void=
        # Find all Props that are tagged with rotate_on
        set RotatingObjects = GetCreativeObjectsWithTag(rotate_on{}) 
        block:
            for (Obj : RotatingObjects):
                if (Prop := creative_prop[Obj]):
                    spawn:
                        SmoothRotate(Prop)
    
    <# Uses Teleport instead of MoveTo. Animations 
    aren't as smooth but it's less glitchy #>
    RotateProp<private>(Prop : creative_prop)<suspends> : void=
        loop:
            Transform := Prop.GetTransform()
            Position := Transform.Translation
            Rotation := Transform.Rotation
            var NewRotation : rotation = Rotation
            if (RotateYaw = true, set NewRotation = NewRotation.ApplyYaw(Speed)
            if (RotateRoll = true, set NewRotation = NewRotation.ApplyRoll(Speed)
            if (RotatePitch = true, set NewRotation = NewRotation.ApplyPitch(Speed)
            if (Prop.TeleportTo[Position, NewRotation]) { }
            
            
            Sleep(0.01) 
            # 0.01 = 100 Frames Per second / 0.10 60 FPS
            
            <# If you set Sleep(0.0) it will update every game frame
            If you do that it might look better, but the rotation speed
            will be different on each platform depending on FPS of the device #>
            
    <# We let MoveTo do its smooth rotation then
    wait for the result, then make a recursive function call
    to start it all again #>

    # BUG: Occassionally objects glitch when the rotation restarts. Not sure why yet.
    SmoothRotate<private>(Prop : creative_prop)<suspends> : void=
        Transform := Prop.GetTransform()
        Position := Transform.Translation
        Rotation := Transform.Rotation
        var NewRotation : rotation = Rotation

        <# Example of how to "add" rotation in degrees
        These are just examples and you can remove any one of 
        three rotations as desired #>
        set NewRotation = NewRotation.ApplyYaw(180.0)
        set NewRotation = NewRotation.ApplyPitch(70.0)
        set NewRotation = NewRotation.ApplyRoll(50.0)

        MoveResult := Prop.MoveTo(Position, NewRotation, 3.0)  

        # Program suspends here until movement complete
        if (MoveResult = move_to_result.DestinationReached):
            SmoothRotate(Prop)