# Hulk Class System
# Creates a class-based character enhancement system that gives players increased health and speed when they match a specific class value. When a player spawns with the correct class tracker value, they
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/hulk-1?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters}
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }

Hulk := class(creative_device):

    @editable var Class : int = 0
    @editable ClassTracker : tracker_device = tracker_device{}
    @editable HUDablity : hud_message_device = hud_message_device{}

    @editable Speed : movement_modulator_device = movement_modulator_device{}
    @editable AddedHealth : float = 0.0

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        InitSpawners()

    InitSpawners() : void=
        Spawners := GetCreativeObjectsWithTag(spawner{})
        for (Obj : Spawners):
            if (Spawner := player_spawner_device[Obj]):
                Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

    OnPlayerSpawned(Agent : agent): void=
        if (Player := player[Agent]):
            spawn{HealthtoStrength(Agent)}
    
    HealthtoStrength(Agent:agent)<suspends> : void=
        Sleep(1.0)
        if(ClassTracker.GetValue(Agent) = Class):
            HUDablity.Show(Agent)
            if (Player := player[Agent], FC := Player.GetFortCharacter[]):
                    FC.SetMaxHealth(100.0 + AddedHealth)
                    FC.SetHealth(100.0 + AddedHealth)
                    Speed.Activate(Agent)
        else:
   


