# Moving Spawn Pads
# Verse code for Moving Spawn Pads - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/moving-spawn-pads?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Simulation/Tags }
using { /UnrealEngine.com/Temporary/SpatialMath }

MoveSpawnPads := class(creative_device):
    @editable
    SkyDiveVolume : skydive_volume_device = skydive_volume_device{}
    @editable
    PreIslandSpawnTimer: timer_device = timer_device{}
    @editable
    var StartPoint : vector3 = vector3{X := 0.0, Y := 0.0, Z := 0.0}
    @editable
    var EndPoint : vector3 = vector3{X := 0.0, Y := 0.0, Z := 0.0}
    @editable
    var TravelTimeInSeconds : float = 10.0
    
    var DeltaX : float = 0.0
    var DeltaY : float = 0.0
    var DeltaZ : float = 0.0


    OnBegin<override>()<suspends>:void=
        PreIslandSpawnTimer.SuccessEvent.Subscribe(SubscirbeStartMovingSpawnPads)

    SubscirbeStartMovingSpawnPads(Agent : ?agent):void=
        spawn:
            StartMovingSpawnPads()

    StartMovingSpawnPads()<suspends>:void=
        CalculateMovementPerSecond(StartPoint, EndPoint, TravelTimeInSeconds)
        var SkydiveUpdateLocation : vector3 = vector3{X := StartPoint.X, Y := StartPoint.Y, Z := StartPoint.Z}
        loop:
            Sleep(1.0)
            set SkydiveUpdateLocation  = vector3{X := SkydiveUpdateLocation.X + DeltaX, Y := SkydiveUpdateLocation.Y + DeltaY, Z := SkydiveUpdateLocation.Z + DeltaZ}
            # Print("Location:  X={SkydiveUpdateLocation.X}, Y={SkydiveUpdateLocation.Y}, Z={SkydiveUpdateLocation.Z}")
            SkyDiveVolume.MoveTo(SkydiveUpdateLocation, rotation{}, 0.001)

    CalculateMovementPerSecond(StartPoints : vector3, EndPoints : vector3, TravelTimeInSecond : float):void=
    # Unpack the start and end points into their respective coordinates
    
        StartX := StartPoint.X
        StartY := StartPoint.Y
        StartZ := StartPoint.Z

        EndX := EndPoint.X
        EndY := EndPoint.Y
        EndZ := EndPoint.Z

    # Calculate the change needed in each coordinate
        set DeltaX = (EndX - StartX) / TravelTimeInSeconds
        set DeltaY = (EndY - StartY) / TravelTimeInSeconds
        set DeltaZ = (EndZ - StartZ) / TravelTimeInSeconds

    # Return the change in each coordinate per second
    

# Example usage
        
        