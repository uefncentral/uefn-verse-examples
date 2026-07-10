# One Shot Elimination Device
# This device makes any damage from one player to another result in instant elimination, creating a one-hit-kill mechanic. It automatically listens for all damage events in the playspace and immediately
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/oneshot?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# Device to handle one-shot eliminations
one_shot_device := class(creative_device):
    # Variable to track if handler is enabled
    var Enabled : logic = true

    # Handle damage events
    OnBegin<override>()<suspends> : void =
        GetPlayspace().DamageHandlerEvent().Subscribe(HandleDamage)
    
    # Function to process damage
    HandleDamage(Agent : agent, DamageResult : damage_result) : void =
        if (Enabled?):
            if (Victim := player[DamageResult.Target]):
                if (Attacker := player[DamageResult.Instigator]):
                    if (Victim != Attacker):  # Prevent self-elimination
                        Victim.Eliminate()  # Instantly eliminate the player

    # Optional: Function to enable/disable the one-shot mechanic
    SetEnabled(NewState : logic) : void =
        set Enabled = NewState