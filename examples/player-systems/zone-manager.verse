# Dynamic Storm Zone Manager
# Manages dynamic storm zone positioning and phases in Fortnite Creative. The code calculates new storm positions based on previous zones, randomizing location within specified constraints to create var
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/zone-manager?ref=github

using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Game }
using { /Fortnite.com/Teams }
using { /Verse.org/Simulation }
using { /Fortnite.com/FortPlayerUtilities }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/FortPlayerUtilities }
using { /Verse.org/Simulation }
using { /Verse.org/Verse }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Game }
using { /Verse.org/Random } 

zone_type := enum{Inside, Half, Outside}

zone_phase := class<unique>():
    CurrentStormBeacon : advanced_storm_beacon_device
    ZoneType : zone_type
    ZoneRadius : float
    PhaseIndex : int
    PreviousStormBeacon : tuple(float, vector3)

    Init():tuple(float, vector3)=
        CurrentRadius := ZoneRadius
        PrevRadius := PreviousStormBeacon(0)
        PrevPosition := PreviousStormBeacon(1)
        var NewPosition : vector3 = vector3{}
        Print("phase {PhaseIndex}")
        if (PhaseIndex = 1):
            Print("do nothing")
        else:
            if (ZoneType = zone_type.Inside):
                MinDistanceOffOfOrigin := 0.0
                MaxDistanceOffOfOrigin := PrevRadius - CurrentRadius
                # randomize distance
                RandomDistance := GetRandomFloat(MinDistanceOffOfOrigin * 100.0, MaxDistanceOffOfOrigin * 100.0)
                # randomize angle
                RandomTheta := GetRandomFloat(0.0, 2* 3.14159)
                # set the new position for current beacon
                XOffset := RandomDistance * Cos(RandomTheta)
                YOffset := RandomDistance * Sin(RandomTheta)
                set NewPosition = vector3{X:=PrevPosition.X + XOffset,Y:=PrevPosition.Y + YOffset,Z:=0.0}
                NewRotation := IdentityRotation()
                if(CurrentStormBeacon.TeleportTo[NewPosition, NewRotation]){
                    Print("Teleport Success")
                }
            else if (ZoneType = zone_type.Half):
                MinDistanceOffOfOrigin := PrevRadius
                MaxDistanceOffOfOrigin := PrevRadius
                # randomize distance
                RandomDistance := GetRandomFloat(MinDistanceOffOfOrigin * 100.0, MaxDistanceOffOfOrigin * 100.0)
                # randomize angle
                RandomTheta := GetRandomFloat(0.0, 2* 3.14159)
                # set the new position for current beacon
                XOffset := RandomDistance * Cos(RandomTheta)
                YOffset := RandomDistance * Sin(RandomTheta)
                set NewPosition = vector3{X:=PrevPosition.X + XOffset,Y:=PrevPosition.Y + YOffset,Z:=0.0}
                NewRotation := IdentityRotation()
                if(CurrentStormBeacon.TeleportTo[NewPosition, NewRotation]){
                    Print("Teleport Success")
                }
            else:
                MinDistanceOffOfOrigin := PrevRadius + CurrentRadius
                MaxDistanceOffOfOrigin := 2*(PrevRadius + CurrentRadius)
                # randomize distance
                RandomDistance := GetRandomFloat(MinDistanceOffOfOrigin * 100.0, MaxDistanceOffOfOrigin * 100.0)
                # randomize angle
                RandomTheta := GetRandomFloat(0.0, 3.14159)
                # set the new position for current beacon
                XOffset := RandomDistance * Cos(RandomTheta)
                YOffset := RandomDistance * Sin(RandomTheta)
                set NewPosition = vector3{X:=PrevPosition.X + XOffset,Y:=PrevPosition.Y + YOffset,Z:=0.0}
                NewRotation := IdentityRotation()
                if(CurrentStormBeacon.TeleportTo[NewPosition, NewRotation]){
                    Print("Teleport Success")
                }
        Print("Radius: {CurrentRadius} Position: {NewPosition.X}, {NewPosition.Y}")
        return (CurrentRadius, NewPosition)
 
zone_manager := class(creative_device):
    # Map of Team Maps, where the key is the team and the value is a map of

    # Set your zone settings here, make sure the zone_radius matches your Advanced Storm Controller Beacons
    ZoneSettings : []tuple(float,zone_type) = array{
        # zone_radius, # zone_type
        (100.0, zone_type.Inside),
        (75.0, zone_type.Inside),
        (50.0, zone_type.Inside),
        (25.0, zone_type.Half),
        (20.0, zone_type.Half),
        (15.0, zone_type.Half),
        (10.0, zone_type.Outside),
        (10.0, zone_type.Outside),
        (10.0, zone_type.Outside)
    }

    # player->int key-value pairs
    @editable StormBeacons : []advanced_storm_beacon_device = array{}
    @editable StormController : advanced_storm_controller_device = advanced_storm_controller_device{}

    var ZoneArray : []zone_phase = array{}
    OnPhaseEnd():void=
        Print("Phase end")

    OnBegin<override>()<suspends> : void =
        StormController.PhaseEndedEvent.Subscribe(OnPhaseEnd)
        Print("Beginning to assign players")
        var idx : int = 1
        var PreviousStormRadius : float = 200.0
        var PreviousStormPosition : vector3 = vector3{}
        for (StormBeacon : StormBeacons):
            if (ZoneSetting := ZoneSettings[idx-1]):
                ZoneRadius := ZoneSetting(0)
                ZoneType := ZoneSetting(1)
                ZonePhase := zone_phase{CurrentStormBeacon := StormBeacon, 
                                ZoneType := ZoneType, 
                                ZoneRadius := ZoneRadius, 
                                PhaseIndex := idx,
                                PreviousStormBeacon := (PreviousStormRadius, PreviousStormPosition)}
                PreviousStormSetting := ZonePhase.Init()
                set PreviousStormRadius = PreviousStormSetting(0)
                set PreviousStormPosition = PreviousStormSetting(1)
            set idx += 1

        StormController.GenerateStorm()
        for (StormBeacon : StormBeacons):
            Position := StormBeacon.GetTransform().Translation
            Print("Position: {Position.X}, {Position.Y}")

            