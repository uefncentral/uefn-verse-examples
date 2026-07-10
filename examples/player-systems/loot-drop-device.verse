# Creature Loot Drop System
# Creates a loot drop system where eliminated creatures have a chance to spawn items at their death location. Uses configurable drop chances and connects creature spawners to item spawners through elimi
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/loot-drop-device?ref=github


using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

loot_drop_data := class<concrete>:
    @editable
    CreatureSpawnerDevice : creature_spawner_device = creature_spawner_device{}

    @editable
    ItemSpawnerDevice : item_spawner_device = item_spawner_device{}

    @editable
    DropChance : type {_X:float where 0.0 <= _X, _X <= 1.0} = 0.0

    var MaybeMainDevice : ?loot_drop_device = false

    OnCreatureEliminated(DeviceAIInteractionResult : device_ai_interaction_result):void=
        if (MainDevice := MaybeMainDevice?):
            MainDevice.OnCreatureEliminated(DeviceAIInteractionResult, Self)

loot_drop_device := class(creative_device):

    @editable
    LootDropsData : []loot_drop_data = array{}

    OnBegin<override>()<suspends>:void=
        Print("OnBegin")
        for (LootDropData : LootDropsData):
            set LootDropData.MaybeMainDevice = option{ Self }
            LootDropData.CreatureSpawnerDevice.EliminatedEvent.Subscribe(LootDropData.OnCreatureEliminated)

    OnCreatureEliminated(DeviceAIInteractionResult : device_ai_interaction_result, LootDropData : loot_drop_data):void=
        RandomChance : float = GetRandomFloat(0.01, 1.0)
        if (LootDropData.DropChance < RandomChance):
            return

        if (TargetAgent := DeviceAIInteractionResult.Target?, TargetFortCharacter := TargetAgent.GetFortCharacter[]):
            Location := TargetFortCharacter.GetTransform().Translation
            if (LootDropData.ItemSpawnerDevice.TeleportTo[Location, IdentityRotation()]):
                LootDropData.ItemSpawnerDevice.SpawnItem()