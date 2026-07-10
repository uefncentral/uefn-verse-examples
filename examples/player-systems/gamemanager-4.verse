# Creature Ambush System
# This system manages a creature elimination challenge where players spawn creatures by stepping on triggers and must eliminate a total of 9 creatures to complete the objective. It tracks elimination pr
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/gamemanager-4?ref=github

using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

GameManager := class(creative_device):

    @editable
    P1Spawner:player_spawner_device = player_spawner_device{}
    @editable
    P2Spawner:player_spawner_device = player_spawner_device{}

    @editable
    StepTrigger:trigger_device = trigger_device{}
    @editable
    StepTrigger2:trigger_device = trigger_device{}
    @editable
    StepTrigger3:trigger_device = trigger_device{}
    @editable
    VFX:vfx_spawner_device = vfx_spawner_device{}

    @editable
    CreaturePlacer:creature_placer_device = creature_placer_device{}
    @editable
    Creature2Placer:creature_placer_device = creature_placer_device{}
    @editable
    Creature3Placer:creature_placer_device = creature_placer_device{}

    MAX_CREATURE_ELIMS:int = 9

    var CurrentCreatureElims:int = 0
    var HasEliminatedAllCreatures:logic = false
    var AmbushedPlayer:logic = false

    OnBegin<override>()<suspends>:void=
        P1Spawner.SpawnedEvent.Subscribe(OnPlayerSpawn)
        P2Spawner.SpawnedEvent.Subscribe(OnPlayerSpawn)
        StepTrigger.TriggeredEvent.Subscribe(OnStepOnTrigger)
        StepTrigger2.TriggeredEvent.Subscribe(OnStepOnTrigger)
        StepTrigger3.TriggeredEvent.Subscribe(OnStepOnTrigger)
        CreaturePlacer.EliminatedEvent.Subscribe(OnCreatureEliminated)
        Creature2Placer.EliminatedEvent.Subscribe(OnCreatureEliminated)
        Creature3Placer.EliminatedEvent.Subscribe(OnCreatureEliminated)
        
    OnPlayerSpawn(Agent:agent):void=

        block:

    OnCreatureEliminated(Agent:?agent):void=
        set CurrentCreatureElims += 1

    OnStepOnTrigger(MaybeAgent:?agent):void=
        if(CurrentCreatureElims < MAX_CREATURE_ELIMS):
            if(Agent:agent = MaybeAgent?):
                spawn:
                    AmbushPlayer(Agent)


    ShowVFX()<suspends>:void=
        VFX.Enable()
        Sleep(5.0)
        VFX.Disable()

    AmbushPlayer(Agent:agent)<suspends>:void=
        if(AmbushedPlayer = false):
            if(FC:fort_character = Agent.GetFortCharacter[]):
                if(VFX.TeleportTo[FC.GetTransform().Translation, FC.GetTransform().Rotation]):
                    spawn:
                        ShowVFX()
                CurrentHealth:float = FC.GetHealth()
                FC.SetHealth(CurrentHealth - 10.0)
            set AmbushedPlayer = true
            CreaturePlacer.Spawn()
            Creature2Placer.Spawn()
            Creature3Placer.Spawn()
            Sleep(5.0)
            set AmbushedPlayer = false