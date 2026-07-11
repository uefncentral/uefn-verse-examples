# Double Damage
# Verse code for Double Damage - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/double-damage?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters}
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }

DoubleDamage := class(creative_device):

    @editable var Class : int = 0
    @editable ClassTracker : tracker_device = tracker_device{}
    @editable HUDablity : hud_message_device = hud_message_device{}

    @editable Damage : damage_amplifier_powerup_device = damage_amplifier_powerup_device{}
    @editable ScaleDamage : float = 0.0

    OnBegin<override>()<suspends>:void=
        Damage.SetMagnitude(ScaleDamage)
        InitSpawners()

    InitSpawners() : void=
        Spawners := GetCreativeObjectsWithTag(spawner{})
        for (Obj : Spawners):
            if (Spawner := player_spawner_device[Obj]):
                Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

    OnPlayerSpawned(Agent : agent): void=
        if (Player := player[Agent]):
            spawn{GiveItem(Agent)}

    GiveItem(Agent : agent)<suspends>:void=
        Sleep(1.0)
        if(ClassTracker.GetValue(Agent) = Class):
            Damage.Spawn()
            Damage.Pickup(Agent)
            HUDablity.Show(Agent)   
                 

