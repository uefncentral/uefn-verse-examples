# Elimination Loot Spawner
# Automatically spawns collectible items at locations where players or AI guards are eliminated. When any player or guard dies, a collectible object appears at their elimination position and activates a
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/custom-1?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

elimination_item_spawner := class(creative_device):

    @editable
    CollectibleDevice : collectible_object_device = collectible_object_device{}
    
    @editable
    TriggerDevice : trigger_device = trigger_device{}
    
    @editable
    GuardSpawner : guard_spawner_device = guard_spawner_device{}

    @editable
    EliminationManager : elimination_manager_device = elimination_manager_device{}
    
    OnBegin<override>()<suspends>:void=
        InitializeSpawner()
    
    InitializeSpawner():void=
        GuardSpawner.EliminatedEvent.Subscribe(HandleGuardEliminated)
        EliminationManager.EliminationEvent.Subscribe(HandlePlayerEliminated)
    
    SpawnItemAtLocation(Location : vector3)<suspends>:void=
        CollectibleDevice.MoveTo(Location, rotation{}, 0.1)  # Changed from 0.0 to 0.1 seconds
        TriggerDevice.Enable()
    
    HandlePlayerEliminated(Agent : ?agent):void=
        if (Player := Agent?):
            spawn{ OnPlayerEliminated(Player) }
    
    OnPlayerEliminated(Agent : agent)<suspends>:void=
        if (Character := Agent.GetFortCharacter[]):
            EliminationLocation := Character.GetTransform().Translation
            SpawnItemAtLocation(EliminationLocation)
    
    HandleGuardEliminated(Result : device_ai_interaction_result):void=
        spawn{DoGuardEliminated(Result)}
    
    DoGuardEliminated(Result : device_ai_interaction_result)<suspends>:void=
        SpawnItemAtLocation(GuardSpawner.GetTransform().Translation)