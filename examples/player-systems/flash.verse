# Flash Class System
# Creates a class-based system that grants special abilities to players with a specific class value. When players spawn with the correct class, they receive items, HUD messages, and can activate speed b
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/flash?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Game }

Flash := class(creative_device):

    @editable var Class : int = 0
    @editable ClassTracker : tracker_device = tracker_device{}
    @editable HUDablity : hud_message_device = hud_message_device{}

    @editable Speed : movement_modulator_device = movement_modulator_device{}
    @editable RemoteManager : signal_remote_manager_device = signal_remote_manager_device{}
    @editable ItemGranter : item_granter_device = item_granter_device{} 

    OnBegin<override>()<suspends>:void=
        RemoteManager.PrimarySignalEvent.Subscribe(SpeedActivation)
        RemoteManager.SecondarySignalEvent.Subscribe(SpeedActivation)
        InitSpawners()

    InitSpawners() : void=
        Spawners := GetCreativeObjectsWithTag(spawner{})
        for (Obj : Spawners):
            if (Spawner := player_spawner_device[Obj]):
                Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

    OnPlayerSpawned(Agent : agent): void=
        if (Player := player[Agent]):
            spawn{CheckClass(Agent)}

    CheckClass(Agent : agent)<suspends>:void=
        Sleep(1.0)
        if(ClassTracker.GetValue(Agent) = Class):
            ItemGranter.GrantItem(Agent)
            HUDablity.Show(Agent)

    SpeedActivation(Agent : agent): void=
        if(ClassTracker.GetValue(Agent) = Class):
            Speed.Activate(Agent)