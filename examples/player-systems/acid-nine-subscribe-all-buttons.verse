# Tagged Button Item Granter
# This system automatically detects button devices tagged with 'search_buttons' and connects them to an item granter. When any tagged button is pressed by a player, it triggers the item granter to give 
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/acid-nine-subscribe-all-buttons?ref=github

using { /Verse.org/Simulation/Tags }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }

# This script will listen to any Tagged button devices and then trigger an item granter

# tags class for the buttons to get assigned to via details tab on the button device
search_buttons := class(tag){}

# main search button class
search_button_devices:= class(creative_device):
    
    @editable
    # This ItemGranter is granted.
    ItemGranter : item_granter_device = item_granter_device{}

    OnBegin<override>()<suspends>:void=
        TaggedActors := GetCreativeObjectsWithTag(search_buttons{})
        for (TaggedActor : TaggedActors):
            if (ButtonDevice := button_device[TaggedActor]):
                # Subscribe to the tagged Buttons
                ButtonDevice.InteractedWithEvent.Subscribe(SetupSearchButtons)

    # Take action when the button is interacted with
    SetupSearchButtons(InPlayer:agent) : void =
        Print("Grant Item")
        ItemGranter.GrantItem(InPlayer)
