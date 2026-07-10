# Interactive Collectables System
# Creates a system for interactive collectables that players can gather by holding a button. When collected, items are granted to the player, the collectable disappears, and respawns after a cooldown pe
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/collectables-device-1?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

collectable_data := class<concrete>:
    @editable
    CollectableProp : creative_prop = creative_prop{}

    @editable
    CollectableButton : button_device = button_device{}

    @editable
    ItemIndexToGrant : int = -1

    @editable
    CollectTime : float = 1.0

    @editable
    CoolDownTime : float = 3.0

    @editable
    CollectAmount : int = 1

    @editable
    ItemName : string = ""

    var MaybeMainDevice : ?collectables_device = false

    ButtonInteractedWithEvent(Agent : agent):void=
        if (MainDevice := MaybeMainDevice?):
            MainDevice.OnCollected(Self, Agent)

collectables_device := class(creative_device):

    @editable
    CollectablesData : []collectable_data = array{}

    @editable
    ItemGranterForCollectables : item_granter_device = item_granter_device{}

    Message<localizes>(InText : string) : message = "{InText}"

    OnBegin<override>()<suspends>:void=
        Print("OnBegin")

        for (CollectableData : CollectablesData):
            CollectableData.CollectableButton.SetInteractionTime(CollectableData.CollectTime)
            CollectableData.CollectableButton.SetInteractionText(Message(CollectableData.ItemName))

            CollectableData.CollectableButton.InteractedWithEvent.Subscribe(CollectableData.ButtonInteractedWithEvent)
            set CollectableData.MaybeMainDevice = option{ Self }

    OnCollected(CollectableData : collectable_data, Agent : agent):void=
        for (I := 1..CollectableData.CollectAmount):
            ItemGranterForCollectables.SetNextItem(CollectableData.ItemIndexToGrant)
            ItemGranterForCollectables.GrantItem(Agent)

        CollectableData.CollectableButton.Disable()
        CollectableData.CollectableProp.Hide()

        spawn{ShowCollectable(CollectableData)}

    ShowCollectable(CollectableData: collectable_data)<suspends>:void=
        Sleep(CollectableData.CoolDownTime)

        CollectableData.CollectableButton.Enable()
        CollectableData.CollectableProp.Show()