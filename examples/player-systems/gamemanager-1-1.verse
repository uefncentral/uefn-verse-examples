# Multiplayer Collectible Racing Game
# A competitive multiplayer game where two players race to collect various items (coins, plasma balls, cylinders, music notes) while navigating through trigger zones. The system manages player spawning,
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/gamemanager-1-1?ref=github

using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Devices/CreativeAnimation }
using { /Fortnite.com/Devices/CreativeAnimation/InterpolationTypes }

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

    @editable
    BlueTrigger:trigger_device = trigger_device{}
    @editable
    RedTrigger:trigger_device = trigger_device{}

    @editable
    Rocket_Blue:creative_prop = creative_prop{}
    @editable
    Rocket_Red:creative_prop = creative_prop{}

    @editable
    RocketVFX_Blue:vfx_spawner_device = vfx_spawner_device{}
    @editable
    RocketVFX_Red:vfx_spawner_device = vfx_spawner_device{}

    @editable
    RocketSFX_Blue:audio_player_device = audio_player_device{}
    @editable
    RocketSFX_Red:audio_player_device = audio_player_device{}

    @editable
    Explosion_Blue:vfx_spawner_device = vfx_spawner_device{}
    @editable
    Explosion_Red:vfx_spawner_device = vfx_spawner_device{}

    L:customizable_light_device = customizable_light_device{}

    MAX_CREATURE_ELIMS:int = 9

    BLUE_ROCKET:int = 0
    RED_ROCKET:int = 1

    var CanLaunchBlueRocket:logic = true
    var CanLaunchRedRocket:logic = true

    var CurrentCreatureElims:int = 0
    var HasEliminatedAllCreatures:logic = false
    var AmbushedPlayer:logic = false

    var BlueScore:int = 0
    var RedScore:int = 0

    var BlueRocketOriginalTransform:transform = transform{}
    var RedRocketOriginalTransform:transform = transform{}

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

        BlueTrigger.TriggeredEvent.Subscribe(OnBlueTrigger)
        RedTrigger.TriggeredEvent.Subscribe(OnRedTrigger)

        #GoldCoinCollectible.CollectedEvent.Subscribe(OnCollectibleCollected)
        #SilverCoinCollectible.CollectedEvent.Subscribe(OnCollectibleCollected)
        #PlasmaBallCollectible.CollectedEvent.Subscribe(OnCollectibleCollected)
        #CylinderCollectible.CollectedEvent.Subscribe(OnCollectibleCollected)
        #MusicNoteCollectible.CollectedEvent.Subscribe(OnCollectibleCollected)

        for(CO:CollectibleObjects):
            CO.CollectedEvent.Subscribe(OnCollectibleCollected2)

        set BlueRocketOriginalTransform = Rocket_Blue.GetTransform()
        set RedRocketOriginalTransform = Rocket_Red.GetTransform()


    #
    OnBlueTrigger(Agent:?agent):void=
        Print("launch blue rocket")
        LaunchRocket(BLUE_ROCKET)


    OnRedTrigger(Agent:?agent):void=
        Print("launch red rocket")
        LaunchRocket(RED_ROCKET)

    
    LaunchRocket(Rocket:int):void=
        if(Rocket = BLUE_ROCKET and CanLaunchBlueRocket = true):
            set BlueScore += 1

            for(CP:PlayersMap):
                CP.SetTeamScores(BlueScore, RedScore)
            set CanLaunchBlueRocket = false
            RocketVFX_Blue.Enable()
            RocketSFX_Blue.Play()
            MovementKeyFrame1: keyframe_delta = keyframe_delta
            {
                
                DeltaLocation := vector3 { X:=0.0, Y:=0.0, Z:=3000.0 }
                # Rotate the object 90 degrees about the Z (Yaw)
                DeltaRotation := MakeRotationFromYawPitchRollDegrees(0.0, 0.0, 0.0)
                # Do not change scale
                DeltaScale := vector3 { X:=1.0, Y:=1.0, Z:=1.0 }
                
                Time := 1.5
                # Use EaseOut interpolation
                Interpolation := EaseOut
            }
            
            MovementKeyFrame2: keyframe_delta = keyframe_delta
            {
                
                DeltaLocation := vector3 { X:=0.0, Y:=0.0, Z:=15000.0 }
                # Rotate the object 90 degrees about the Z (Yaw)
                DeltaRotation := MakeRotationFromYawPitchRollDegrees(0.0, 0.0, 0.0)
                # Do not change scale
                DeltaScale := vector3 { X:=1.0, Y:=1.0, Z:=1.0 }
                
                Time := 5.0
                # Use EaseOut interpolation
                Interpolation := Linear
            }

            if (BlueController := Rocket_Blue.GetAnimationController[]):
                # Make an array of the keyframes
                FortVaderKeyFrames:[]keyframe_delta = array { MovementKeyFrame1, MovementKeyFrame2 }
                # Set the animation to play
                BlueController.SetAnimation(FortVaderKeyFrames, ?Mode:=animation_mode.OneShot)
                # Play the animation
                BlueController.Play()
                spawn:
                    ResetRocket(BLUE_ROCKET)
            
        else if(Rocket = RED_ROCKET and CanLaunchRedRocket = true):
            set RedScore += 1
            for(CP:PlayersMap):
                CP.SetTeamScores(BlueScore, RedScore)
            set CanLaunchRedRocket = false
            RocketVFX_Red.Enable()
            RocketSFX_Red.Play()
            MovementKeyFrame1: keyframe_delta = keyframe_delta
            {
                
                DeltaLocation := vector3 { X:=0.0, Y:=0.0, Z:=3000.0 }
                # Rotate the object 90 degrees about the Z (Yaw)
                DeltaRotation := MakeRotationFromYawPitchRollDegrees(0.0, 0.0, 0.0)
                # Do not change scale
                DeltaScale := vector3 { X:=1.0, Y:=1.0, Z:=1.0 }
                
                Time := 1.5
                # Use EaseOut interpolation
                Interpolation := EaseOut
            }
            
            MovementKeyFrame2: keyframe_delta = keyframe_delta
            {
                
                DeltaLocation := vector3 { X:=0.0, Y:=0.0, Z:=15000.0 }
                # Rotate the object 90 degrees about the Z (Yaw)
                DeltaRotation := MakeRotationFromYawPitchRollDegrees(0.0, 0.0, 0.0)
                # Do not change scale
                DeltaScale := vector3 { X:=1.0, Y:=1.0, Z:=1.0 }
                
                Time := 5.0
                # Use EaseOut interpolation
                Interpolation := Linear
            }

            if (RedController := Rocket_Red.GetAnimationController[]):
                # Make an array of the keyframes
                FortVaderKeyFrames:[]keyframe_delta = array { MovementKeyFrame1, MovementKeyFrame2 }
                # Set the animation to play
                RedController.SetAnimation(FortVaderKeyFrames, ?Mode:=animation_mode.OneShot)
                # Play the animation
                RedController.Play()

            spawn:
                ResetRocket(RED_ROCKET)
 
    ResetRocket(Rocket:int)<suspends>:void=
        Sleep(5.0)
        if(Rocket = BLUE_ROCKET):
            if(Explosion_Blue.TeleportTo[Rocket_Blue.GetTransform()]):

            Explosion_Blue.Enable()
            Explosion_Blue.Restart()
            
            RocketVFX_Blue.Disable()
            RocketSFX_Blue.Stop()
            if(Rocket_Blue.TeleportTo[BlueRocketOriginalTransform]):
            
            set CanLaunchBlueRocket = true

        else if(Rocket = RED_ROCKET):
            if(Explosion_Red.TeleportTo[Rocket_Red.GetTransform()]):
            Explosion_Red.Enable()
            Explosion_Red.Restart()
            RocketVFX_Red.Disable()
            RocketSFX_Red.Stop()
            if(Rocket_Red.TeleportTo[RedRocketOriginalTransform]):
            
            set CanLaunchRedRocket = true



        
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