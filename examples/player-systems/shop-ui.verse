# Shop Ui
# Verse code for Shop Ui - UEFN/Fortnite Creative implementation
# Difficulty: intermediate  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/shop-ui?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# A device that lets players choose between Chapter 1 and Chapter 6 loadouts
loadout_selector_device := class(creative_device):

    # Reference to the trigger devices
    @editable
    MainTrigger : trigger_device = trigger_device{}
    
    @editable
    Chapter1Trigger : trigger_device = trigger_device{}
    
    @editable
    Chapter6Trigger : trigger_device = trigger_device{}

    # Reference to the item granters for different loadouts
    @editable
    Chapter1ItemGranter : item_granter_device = item_granter_device{}
    
    @editable
    Chapter6ItemGranter : item_granter_device = item_granter_device{}

    # Reference to HUD Message Device
    @editable
    MessageDevice : hud_message_device = hud_message_device{}

    # Called when the device is started
    OnBegin<override>()<suspends>:void=
        Print("Device Started")
        # Subscribe to events
        MainTrigger.TriggeredEvent.Subscribe(OnMainTriggerActivated)
        Chapter1Trigger.TriggeredEvent.Subscribe(OnChapter1Selected)
        Chapter6Trigger.TriggeredEvent.Subscribe(OnChapter6Selected)

    # Handles the main trigger activation
    OnMainTriggerActivated(MaybeAgent : ?agent) : void =
        Print("Main Trigger Activated")
        if (Agent := MaybeAgent?):
            Print("Agent Found")
            if (Player := player[Agent]):
                Print("Player Found")
                # Show message to player
                MessageDevice.Show()
                # Enable selection triggers
                Chapter1Trigger.Enable()
                Chapter6Trigger.Enable()

    # Handle Chapter 1 selection
    OnChapter1Selected(Agent : ?agent) : void =
        Print("Chapter 1 Selected")
        if (Player := player[Agent?]):
            Chapter1ItemGranter.Enable()
            Chapter1Trigger.Disable()
            Chapter6Trigger.Disable()

    # Handle Chapter 6 selection
    OnChapter6Selected(Agent : ?agent) : void =
        Print("Chapter 6 Selected")
        if (Player := player[Agent?]):
            Chapter6ItemGranter.Enable()
            Chapter1Trigger.Disable()
            Chapter6Trigger.Disable()