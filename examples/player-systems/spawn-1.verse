# Game Start Trigger
# Automatically triggers a specified trigger device when the game begins. This creates a simple automation that executes an action immediately upon game start without requiring player interaction.  **Ho
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/spawn-1?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

game_start_device := class(creative_device):
    @editable
    TriggerDevice : trigger_device = trigger_device{}

    # Called when the game starts
    OnBegin<override>()<suspends> : void =
        # Trigger the device when game starts
        TriggerDevice.Trigger()