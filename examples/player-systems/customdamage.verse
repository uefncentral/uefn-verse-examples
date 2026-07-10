# Customdamage
# Verse code for Customdamage - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/customdamage?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }

# ──────────────────────────────────────────────────────────────────────────────
weapon_damage_manager := class(creative_device):

    # One Conditional Button per weapon (same settings you already use)
    @editable
    WeaponChecks     : []conditional_button_device       = array{}

    # Matching Damage Amplifiers (index 0 ↔ button 0, etc.)
    @editable
    DamageAmplifiers : []damage_amplifier_powerup_device = array{}

    # Single “normal damage” amplifier (multiplier 1 ×)
    @editable
    BaseAmplifier    : damage_amplifier_powerup_device   = damage_amplifier_powerup_device{}

    # Poll rate
    @editable
    CheckInterval    : float                             = 0.1     # keep your original value

    # ─────────────────────────  start-up  ─────────────────────────
    OnBegin<override>()<suspends>:void =
        spawn { RunTimer() }

    # ─────────────────────────  main loop  ────────────────────────
    RunTimer()<suspends>:void =
        loop:
            Sleep(CheckInterval)

            for (Plr : GetPlayspace().GetPlayers()):
                if (Ag := agent[Plr]):                 # square-bracket call → ‘decides’; OK in ‘if’
                    UpdatePlayer(Ag)

    # ─────────────────────────  per-player check  ────────────────
    UpdatePlayer(Ag:agent):void =
        var Found : logic = false
        var i     : int   = 0
        var max   : int   = WeaponChecks.Length

        loop:                                         # manual loop so we can break
            if (i >= max):
                break

            # array access with [] is a ‘decides’ call → fine inside ‘if’
            if (Btn := WeaponChecks[i]):
                if (Btn.IsHoldingItem[Ag]):           # square brackets: ‘decides’
                    if (Amp := DamageAmplifiers[i]):
                        Amp.Pickup(Ag)
                    set Found = true
                    break

            set i = i + 1

        # no tracked weapon matched → normal damage
        if (Found = false):
            BaseAmplifier.Pickup(Ag)

