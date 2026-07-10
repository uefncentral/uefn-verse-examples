# Moving Platform Pet System
# Creates a system with moving platforms that travel between two positions and robotic pets with animations and health systems. The platforms automatically move back and forth while pets can run, jump, 
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/gist-wahlbeckuefn-lesson-08?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

pawn := class():
    var TotalHP<private> : int = 100
    var CurrentHP<private> : int = 100

    TakeDamage<public>(DamagePoints : int):void=
        set CurrentHP -= DamagePoints

    Heal<public>(HealPoints : int):void=
        set CurrentHP += HealPoints

    IsAlive<public>()<decides>:void=
        if (CurrentHP > 0) { true }
        else { false }

platform := class(pawn):
    PlatformProp : creative_prop = creative_prop{}
    StartingPos : vector3 = vector3{}
    EndingPos : vector3 = vector3{}

    Move<public>()<suspends>:void=
        loop:
            if (not # PlatformProp.IsValid[]  # TODO: use type cast (e.g., player[Agent]?) instead) { break }
            PlatformProp.MoveTo(EndingPos, IdentityRotation(), 5.0)
            if (not # PlatformProp.IsValid[]  # TODO: use type cast (e.g., player[Agent]?) instead) { break }
            PlatformProp.MoveTo(StartingPos, IdentityRotation(), 5.0)

pet := class<concrete>(pawn):
    Name : string = "Default"
    @editable RoboProp : creative_prop = creative_prop{}
    @editable RunAnim : cinematic_sequence_device = cinematic_sequence_device{}
    @editable JumpAnim : cinematic_sequence_device = cinematic_sequence_device{}
    @editable DamageVol : damage_volume_device = damage_volume_device{}

    MoveToPlayer():void=
        block:

    Run():void=
        RunAnim.Play()

    Jump():void=
        JumpAnim.Play()

lesson_08 := class(creative_device):

    @editable PlatformAsset : creative_prop_asset = DefaultCreativePropAsset
    @editable Robots : []pet = array{}

    var Platforms : []platform = array{}
    
    OnBegin<override>()<suspends>:void=
        SomePawn := pawn{}
        SomePawn.TakeDamage(10)

        NewPlatform := platform{}
        NewPlatform.TakeDamage(10)

        InitPlatforms()
        MoveAllPlatforms()

    InitPlatforms():void=
        for (IDX := 1..20):
            Start := vector3{X:=IDX * 500.0, Y:= IDX * 500.0, Z:= 300.0}
            End := vector3{X:= IDX * 3000.0, Y:= IDX * 3000.0, Z:= 300.0}
            if (SpawnedProp := SpawnProp(PlatformAsset, Start, IdentityRotation())(0)?):
                Platform := platform{PlatformProp := SpawnedProp, StartingPos := Start, EndingPos := End}
                set Platforms += array{Platform}

    MoveAllPlatforms():void=
        for (Platform : Platforms):
            spawn:
                Platform.Move()

                <#
                    1. Bring a custom 3D prop into UEFN for an animal/creature
                    2. Bring a custom 3D prop into UEFN for a building
                    3. Bring a custom 3D prop into UEFN for a vehicle
                    4. Create a parent class that has 3 properties needed for these various 3D objects
                    5. Create 3 methods in this parent class that are needed for these various 3D objects
                    6. Create 3 subclasses, one for creature, one for building, one for vehicle
                    7. Create 2 methods for each subclass that is unique to that class
                    8. Create 2 properties for each subclass that is unique to that class

                #>
        