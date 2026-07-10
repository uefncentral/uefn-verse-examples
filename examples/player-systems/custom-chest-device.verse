# Custom Loot Chest
# Creates an interactive chest system that grants random items to players based on configurable drop chances. When activated, the chest visually changes state, plays audio, and randomly distributes item
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/custom-chest-device?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/Diagnostics }

CustomChestModule := module:

    item_dropper_data := class<concrete>:
        @editable
        ItemGranter : item_granter_device = item_granter_device{}

        @editable
        ItemDropChance : type {_X:float where 0.01 <= _X, _X <= 1.0 } = 0.01

    custom_chest_device := class(creative_device):

        @editable
        ItemDroppers : []item_dropper_data = array{}

        @editable
        ChestCloseProp : creative_prop = creative_prop{}
        @editable
        ChestOpenProp : creative_prop = creative_prop{}

        @editable
        ChestInteractionButton : button_device = button_device{}

        @editable
        ChestAudio : audio_player_device = audio_player_device{}
        @editable
        ChestOpenedAudio : audio_player_device = audio_player_device{}

        @editable
        OnChestOpened : trigger_device = trigger_device{}

        @editable
        bResetChest : logic = false
        @editable
        ChestResetSeconds : type{_X:float where _X >= 0.0} = 0.0

        var bChestOpen : logic = false

        OnBegin<override>()<suspends>:void=
            Print("OnBegin")

            ChestAudio.Play()
            ChestCloseProp.Show()
            ChestOpenProp.Hide()

            ChestInteractionButton.InteractedWithEvent.Subscribe(OnChestInteracted)

        OnChestInteracted(Agent : agent):void=
            if (bChestOpen = true):
                return

            for (ItemDropper : ItemDroppers):
                DropChance := GetRandomFloat(0.01, 1.0)
                if (ItemDropper.ItemDropChance >= DropChance):
                    ItemDropper.ItemGranter.GrantItem(Agent)

            set bChestOpen = true
            ChestAudio.Stop()
            ChestCloseProp.Hide()
            ChestOpenProp.Show()
            ChestInteractionButton.Disable()

            ChestOpenedAudio.Play(Agent)
            OnChestOpened.Trigger(Agent)

            if (bResetChest = true):
                spawn{ LateOpenChest() }

        LateOpenChest()<suspends>:void=
            Sleep(ChestResetSeconds)

            set bChestOpen = false
            ChestAudio.Play()
            ChestCloseProp.Show()
            ChestOpenProp.Hide()
            ChestInteractionButton.Enable()