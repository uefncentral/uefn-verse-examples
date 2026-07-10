# Button Trigger Manager
# This device manages multiple interactive buttons and activates a single trigger when any button is pressed. It provides a centralized way to handle button interactions and execute a common trigger res
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/interaction-manager-device-1?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# Device that handles button interactions with popups
interaction_manager_device := class(creative_device):

    # Array of interactive buttons
    @editable var InteractButtons : []button_device = array{}
    @editable Trigger : trigger_device = trigger_device{}

    # OnBegin is called when the game starts
    OnBegin<override>()<suspends>:void=
        # Set up button interactions
        for (Button : InteractButtons):
            Button.InteractedWithEvent.Subscribe(OnButtonInteracted)

    # Handles button interaction
    OnButtonInteracted(Agent : agent):void=
        # Activate trigger when button is interacted with
        ActivateTrigger()

    # Common function to activate the trigger
    ActivateTrigger():void=
        Trigger.Trigger()