# Interactive Car Spawner
# Creates a button-activated car spawning system with visual effects. When a player interacts with the button, it spawns a sports car and automatically assigns the player as the driver, with VFX feedbac
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/custom-cars-1?ref=github

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

    @editable PlotManager : Plot_Manager = Plot_Manager{}


    OnBegin<override>()<suspends>:void=

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
            EmptyVFX.Pickup(Agent)

    OnCarButtonInteracted(Agent : agent):void=
        CarButton.Disable()
        CarVFX.Pickup(Agent)

        CarSpawner.Enable()
        if (FortCharacter := Agent.GetFortCharacter[]):

        spawn{ AsyncCarHandle(Agent, true, 0.1) }

    OnCarExited(Agent : agent):void=
        if(PPlayer := PlotManager.PlotsPlayer[0], PPlayer = Agent):
            if (CurrentVehicle := MaybeCurrentVehicle?):

            set MaybeCurrentVehicle = false
            CarSpawner.Disable()
            spawn{ AsyncCarHandle(Agent, false, 0.25) }

    OnCarSpawned(FortVehicle : fort_vehicle):void=
        set MaybeCurrentVehicle = option{ FortVehicle }