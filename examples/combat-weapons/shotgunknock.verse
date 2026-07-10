# Shotgunknock
# Verse code for Shotgunknock - UEFN/Fortnite Creative implementation
# Difficulty: intermediate  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/shotgunknock?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

#
# Push the player forward when they press Fire,
# but only if they’re holding a specific weapon.
# Includes a per-player cooldown.
#
dash_on_fire := class(creative_device):

    @editable FireTrigger   : input_trigger_device      = input_trigger_device{}
    @editable WeaponCheck   : conditional_button_device = conditional_button_device{}
    @editable DashModulator : movement_modulator_device = movement_modulator_device{}

    @editable CooldownSeconds : float = 1.0            # tweak in Details

    var LastDash : [agent]float = map{}                # key = player, value = time

    OnBegin<override>()<suspends>: void =
        FireTrigger.PressedEvent.Subscribe(OnFire)

    OnFire(Player : agent) : void =
        # 1) Wrong weapon? Quit early.
        if (WeaponCheck.IsHoldingItem[Player]):
             Print("Holding weapon") 

            Now := GetSimulationElapsedTime()

            # 2) Cool-down check.
            if (Last := LastDash[Player]):
                if (Now - Last < CooldownSeconds):
                    return

            # 3) Apply the dash (Activate has no_rollback, so standalone stmt is OK).
            DashModulator.Activate(Player)
             Print("Activated dash")  

            # 4) Store the new timestamp (set has 'decides', wrap it in an if).
            if (set LastDash[Player] = Now) {}


            