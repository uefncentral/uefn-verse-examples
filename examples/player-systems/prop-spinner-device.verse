# Prop Spinner Device
# A spinning wheel device that rotates a prop to random angles when a button is pressed. The prop accelerates during rotation and can grant items to players based on the landing position.  **How to use:
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/prop-spinner-device?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/SpatialMath }


prop_spinner_device := class(creative_device):

    @editable Prop : creative_prop = creative_prop{}
    @editable Button : button_device = button_device{}
    @editable ItemGranters : []item_granter_device = array{}

    var IsRotating : logic = false
    var Degrees : []float = array{0.0, 30.0, 60.0, 90.0, 120.0, 150.0, -180.0, -150.0, -120.0, -90.0, -60.0, -30.0}
    var RandomInt : int = 0
    var RotateDegrees : float = 30.0
    var InitialSpeed : float = 0.2
    var InitialDelay : int = 0

    
    OnBegin<override>()<suspends>:void=
        Button.InteractedWithEvent.Subscribe(OnButtonClicked)

    OnButtonClicked(Agent : agent):void=
        if (not IsRotating?):
            set RandomInt = GetRandomInt(0, Degrees.Length -1)
            if (Angle := Degrees[RandomInt]):
                spawn {MakePropSpin(Agent, Angle)}

    MakePropSpin(Agent : agent, Angle : float)<suspends>:void=
        set IsRotating = true
        var CurrentSpeed : float = InitialSpeed
        var CurrentDelay : int = InitialDelay
        loop:
            Transform := Prop.GetTransform()
            Position := Transform.Translation
            Rotation := Transform.Rotation
            NewRotation := Rotation.ApplyRoll((RotateDegrees * Pi / 180.0)
            Prop.MoveTo(Position, NewRotation, CurrentSpeed)
            if (CurrentDelay <= 0):
                if (CurrentSpeed < 0.35):                
                    set CurrentSpeed += 0.05
                Print("Current speed: {CurrentSpeed}")
                PropCurrentRotation : []float = Prop.GetTransform().Rotation.GetYawPitchRollDegrees()
                if (CurrentAngle := PropCurrentRotation[2]): 
                    Print("Current angle is: {CurrentAngle}/{Angle}")               
                    if (RoundedCurrentAngle := Round[CurrentAngle] * 1.0):
                        if (RoundedCurrentAngle < Angle + 10.0 and RoundedCurrentAngle > Angle - 10.0):                        
                            set IsRotating = false
                            GrantItem(Agent)
                            break
            else:
                set CurrentDelay -= 1
            Sleep(0.0)

    GrantItem(Agent : agent):void=
        if (Item := ItemGranters[RandomInt]):
            Item.GrantItem(Agent)

            