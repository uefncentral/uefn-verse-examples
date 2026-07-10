# Button Item Spawner
# Creates a simple interaction system where players can press a button to spawn items. When a player interacts with the designated button device, it triggers the connected item spawner to create an item
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/spawner-button-1?ref=github

using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }

spawner_button := class(creative_device):
    @editable
    Button:button_device = button_device{}
    @editable
    ItemSpawner:item_spawner_device = item_spawner_device{}

    OnBegin() : void =
        Button.InteractedWithEvent.Subscribe(OnButtonInteractedWith)

    OnButtonInteractedWith(InPlayer:agent) : void =
        ItemSpawner.SpawnItem()