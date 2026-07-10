# Multiplayer Collectible Adventure Game
# A two-player game system that manages coin/item collection mechanics with creature elimination objectives. Players spawn at designated points, collect various objects (gold coins, plasma balls, music 
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/gamemanager-2-1?ref=github

using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

GameManager := class(creative_device):

    var PlayersMap:[agent]CustomPlayer = map{}
    var UniqueUserID:int = 1

    @editable
    P1Spawner:player_spawner_device = player_spawner_device{}
    @editable
    P2Spawner:player_spawner_device = player_spawner_device{}

    @editable
    GoldCoinCollectible:collectible_object_device = collectible_object_device{}
    @editable
    SilverCoinCollectible:collectible_object_device = collectible_object_device{}
    @editable
    PlasmaBallCollectible:collectible_object_device = collectible_object_device{}
    @editable
    CylinderCollectible:collectible_object_device = collectible_object_device{}
    @editable
    MusicNoteCollectible:collectible_object_device = collectible_object_device{}

    @editable
    CollectibleObjects:[]collectible_object_device = array{}


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

    MaxCollectibles:int = 5


    MAX_CREATURE_ELIMS:int = 9

    var CurrentCreatureElims:int = 0
    var HasEliminatedAllCreatures:logic = false
    var AmbushedPlayer:logic = false

    OnBegin<override>()<suspends>:void=
        P1Spawner.SpawnedEvent.Subscribe(OnPlayerSpawn)
        P2Spawner.SpawnedEvent.Subscribe(OnPlayerSpawn)
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerRemoved)
        StepTrigger.TriggeredEvent.Subscribe(OnStepOnTrigger)
        StepTrigger2.TriggeredEvent.Subscribe(OnStepOnTrigger)
        StepTrigger3.TriggeredEvent.Subscribe(OnStepOnTrigger)
        CreaturePlacer.EliminatedEvent.Subscribe(OnCreatureEliminated)
        Creature2Placer.EliminatedEvent.Subscribe(OnCreatureEliminated)
        Creature3Placer.EliminatedEvent.Subscribe(OnCreatureEliminated)

        #GoldCoinCollectible.CollectedEvent.Subscribe(OnCollectibleCollected)
        #SilverCoinCollectible.CollectedEvent.Subscribe(OnCollectibleCollected)
        #PlasmaBallCollectible.CollectedEvent.Subscribe(OnCollectibleCollected)
        #CylinderCollectible.CollectedEvent.Subscribe(OnCollectibleCollected)
        #MusicNoteCollectible.CollectedEvent.Subscribe(OnCollectibleCollected)

        for(CO:CollectibleObjects):
            CO.CollectedEvent.Subscribe(OnCollectibleCollected2)

    OnCollectibleCollected(Agent:agent):void=
        Print("collected normal collectible")
        if(Player:=PlayersMap[Agent]):
            Player.AddCollectible()
            CheckToResetCollectibles(Player)
        
    OnCollectibleCollected2(Agent:agent):void=
        Print("collected item from array")
        if(Player:=PlayersMap[Agent]):
            Player.AddCollectible()
            CheckToResetCollectibles(Player)

    CheckToResetCollectibles(Player:CustomPlayer):void=
        Count:int = Player.GetCollectibleCount()
        if(Count = CollectibleObjects.Length):
            ResetAllCollectibles()

    ResetAllCollectibles():void=
        Print("reset all")
        GoldCoinCollectible.RespawnForAll()
        SilverCoinCollectible.RespawnForAll()
        PlasmaBallCollectible.RespawnForAll()
        CylinderCollectible.RespawnForAll()
        MusicNoteCollectible.RespawnForAll()

        #for(CO:CollectibleObjects):
            #CO.RespawnForAll()

        
    OnPlayerSpawn(Agent:agent):void=
        if(PlayerExists := PlayersMap[Agent]):
            #do nothing, player already exists
            Print("player respawned")
        else:
            #Print("add player")
            NewCustomPlayer:CustomPlayer = CustomPlayer{MyAgentObj:=Agent} 
            
            if:
                set PlayersMap[Agent] = NewCustomPlayer
            then:
                NewCustomPlayer.InitializePlayer(UniqueUserID)
                set UniqueUserID += 1
        


    #
    OnPlayerRemoved(OutPlayer:agent):void=
        if(ActualPlayer := PlayersMap[OutPlayer]):
            var TempAllPlayersMap:[agent]CustomPlayer = map{}
            for (Key -> Value : PlayersMap, Key <> OutPlayer):
                set TempAllPlayersMap = ConcatenateMaps(TempAllPlayersMap, map{Key => Value})

            set PlayersMap = TempAllPlayersMap
















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