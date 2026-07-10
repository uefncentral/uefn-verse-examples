# Car Spawn System
# Creates an interactive car spawning system where players can press a button to spawn a sports car and automatically become the driver. The system manages visual effects for spawning/despawning and han
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/custom-car-device?ref=github


using { /Fortnite.com/Devices }
using { /Fortnite.com/Vehicles }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

custom_car_device := class(creative_device):

    @editable
    CarButton : button_device = button_device{}

    @editable
    CarSpawner : vehicle_spawner_sports_car_device = vehicle_spawner_sports_car_device{}

    @editable
    CarVFX : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable
    EmptyVFX : visual_effect_powerup_device = visual_effect_powerup_device{}

    var MaybeCurrentVehicle : ?fort_vehicle = false
    var VehicleLastLocation : vector3 = vector3{}

    OnBegin<override>()<suspends>:void=
        Print("OnBegin")

        CarButton.InteractedWithEvent.Subscribe(OnCarButtonInteracted)
        CarSpawner.AgentExitsVehicleEvent.Subscribe(OnCarExited)
        CarSpawner.SpawnedEvent.Subscribe(OnCarSpawned)

        CarSpawner.Disable()

    AsyncCarHandle(Agent : agent, bCarSpawned : logic, InitialDelay : float)<suspends>:void=
        Sleep(InitialDelay)

        if (bCarSpawned = true):
            CarSpawner.AssignDriver(Agent)
        else:
            CarButton.Enable()
            if (CarButton.TeleportTo[VehicleLastLocation, IdentityRotation()]){}
            EmptyVFX.Pickup(Agent)

    OnCarButtonInteracted(Agent : agent):void=
        CarButton.Disable()
        CarVFX.Pickup(Agent)
        var ButtonLocation : vector3 = CarButton.GetTransform().Translation
        set ButtonLocation.Z -= 1000.0
        if (CarButton.TeleportTo[ButtonLocation, IdentityRotation()]){}  

        CarSpawner.Enable()
        if (FortCharacter := Agent.GetFortCharacter[]):
            var TeleportLocation : vector3 = FortCharacter.GetTransform().Translation
            set TeleportLocation.Z += 50.0
            if (CarSpawner.TeleportTo[TeleportLocation,IdentityRotation()]){}

        spawn{ AsyncCarHandle(Agent, true, 0.1) }

    OnCarExited(Agent : agent):void=
        if (CurrentVehicle := MaybeCurrentVehicle?):
            set VehicleLastLocation = CurrentVehicle.GetTransform().Translation

        set MaybeCurrentVehicle = false
        CarSpawner.Disable()
        spawn{ AsyncCarHandle(Agent, false, 0.25) }

    OnCarSpawned(FortVehicle : fort_vehicle):void=
        set MaybeCurrentVehicle = option{ FortVehicle }