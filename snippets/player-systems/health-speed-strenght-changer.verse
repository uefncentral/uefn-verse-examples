# Health Speed Strenght Changer
# Verse code for Health Speed Strenght Changer - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/health-speed-strenght-changer?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters}
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }

HealthSpeedStrenghtChanger := class(creative_device):

    @editable var Class : int = 0
    @editable ClassTracker : tracker_device = tracker_device{}
    @editable HUDablity : hud_message_device = hud_message_device{}

    @editable Damage : damage_amplifier_powerup_device = damage_amplifier_powerup_device{}
    @editable Speed : movement_modulator_device = movement_modulator_device{}
    @editable ReduceHealth : float = 0.0
    @editable ScaleDamage : float = 0.0

    var THealth : float = 0.0
    var NHealth : float = 0.0
    var TShield : float = 0.0
    var NShield : float = 0.0

    # Runs when the device is started in a running game
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
            spawn{CheckClass(Agent)}

    CheckClass(Agent : agent)<suspends>:void=
        Sleep(1.0)
        if(ClassTracker.GetValue(Agent) = Class):
            spawn:
                HealthtoStrength(Agent)

    HealthtoStrength(Agent:agent)<suspends> : void=
        HUDablity.Show(Agent)
        if (Player := player[Agent], FC := Player.GetFortCharacter[]):
            set TShield = FC.GetShield()
            if (TShield <= ReduceHealth):
                set NShield = 0.0
                set THealth = FC.GetHealth()
                set NHealth = THealth - (ReduceHealth - TShield)
                FC.SetShield(NShield)
                FC.SetHealth(NHealth)

            else:
                set  TShield = FC.GetShield()
                set NShield = TShield - ReduceHealth
                FC.SetShield(NShield)

        Damage.Spawn()
        Damage.Pickup(Agent)  
        Speed.Activate(Agent)

