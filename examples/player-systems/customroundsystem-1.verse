# Custom Round System
# A comprehensive round-based game system that manages player spawning, elimination handling, mutator zones, damage volumes, and HUD messaging. The system tracks round progression and handles player tel
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/customroundsystem-1?ref=github

using { /Fortnite.com/FortPlayerUtilities }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/Devices }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Simulation/Tags }

spawner2 := class(tag){}

CustomRoundSystem := class(creative_device):

    StringToMessage<localizes>(String : string)<computes> : message = "{String}"

    var FloatZero : float = 0.0
 
    @editable var SpawnsPad : []player_spawner_device = array{}
    @editable ElimManager : elimination_manager_device = elimination_manager_device{}
    @editable MutatorZone : mutator_zone_device = mutator_zone_device{}
    @editable MutatorZoneClear : mutator_zone_device = mutator_zone_device{}
    
    @editable DamageVolume1 : damage_volume_device = damage_volume_device{}
    @editable DamageVolume2 : damage_volume_device = damage_volume_device{}
    @editable TrackerDevice : tracker_device = tracker_device{}
    @editable TrackerRounds : tracker_device = tracker_device{}

    @editable StormDevice : basic_storm_controller_device = basic_storm_controller_device{}

    @editable HUDRoundStart : hud_message_device = hud_message_device{}
    @editable HUDRoundStats : hud_message_device = hud_message_device{}

    @editable HUDclearTrigger : trigger_device = trigger_device{}

    @editable ItemGranterGame : item_granter_device = item_granter_device{}
    @editable ItemGranterClear : item_granter_device = item_granter_device{}

    @editable Timer : timer_device = timer_device{}
    @editable ExplosionDevice : explosive_device = explosive_device{}

    @editable Barriers : []barrier_device = array{}

    var RoundStarted : int = 0
    var TotalRounds : int = 0

    OnBegin<override>()<suspends>:void=
        MutatorZoneClear.Disable()  
        ElimManager.EliminatedEvent.Subscribe(TeleportAfterDeath)
        MutatorZone.AgentEntersEvent.Subscribe(AddingPlayer)
        MutatorZone.AgentExitsEvent.Subscribe(RemovingPlayer)
        Timer.SuccessEvent.Subscribe(TimerComplete)
        InitSpawners()
        InitSpawners2()
        set RoundStarted = 0

    TimerComplete(Agent : ?agent):void=
        spawn:
            DisableBarriers()

    DisableBarriers()<suspends>:void=
        for (Barrier : Barriers):
            Barrier.Disable()

    EnableBarriers()<suspends>:void=
        for (Barrier : Barriers):
            Barrier.Enable()

    InitSpawners() : void=
        Spawners := GetCreativeObjectsWithTag(spawner{})
        for (Obj : Spawners):
            if (Spawner := player_spawner_device[Obj]):
                Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)
        
    InitSpawners2() : void=
        Spawners2 := GetCreativeObjectsWithTag(spawner2{})
        for (Obj : Spawners2):
            if (Spawner2 := player_spawner_device[Obj]):
                Spawner2.SpawnedEvent.Subscribe(OnPlayerSpawned2)

    OnPlayerSpawned2(Agent : agent): void=
        ItemGranterClear.GrantItem(Agent)

    OnPlayerSpawned(Agent : agent): void=
        if (Player := player[Agent]):
            spawn{DisablePlayerSpawners(Agent)}
            spawn{RoundStartHud(Agent)}
            set RoundStarted += 1
            ItemGranterGame.GrantItem(Agent)
            Timer.Start(Agent)
            spawn:
                EnableBarriers()
            spawn{CheckPlayersInsideZone(Agent)}
        
    RoundStartHud(Agent : agent)<suspends>:void=
        HUDRoundStart.Show(Agent)
        HUDRoundStats.SetText(StringToMessage("Rounds : {TrackerRounds.GetValue()}"))
        HUDRoundStats.Show(Agent)

    AddingPlayer(Agent : agent): void=
        TrackerDevice.Increment(Agent)

    RemovingPlayer(Agent : agent): void=
        TrackerDevice.Decrement(Agent)
        spawn{CheckPlayersInsideZone(Agent)}

    CheckPlayersInsideZone(Agent : agent)<suspends>:void=
        Sleep(0.5) #0.5
        StormDevice.GenerateStorm()
        Sleep(0.5) #0.5
        if(RoundStarted <= 1):
            Sleep(1.0) #1.0
            if(TrackerDevice.GetValue() = 0):
                Sleep(2.0) #2.0
                set RoundStarted = 0
                Spawners := GetCreativeObjectsWithTag(spawner{})
                for (Obj : Spawners):
                    if (Spawner := player_spawner_device[Obj]):
                        Spawner.Enable()

                Spawners2 := GetCreativeObjectsWithTag(spawner2{})
                for (Obj : Spawners2):
                    if (Spawner2 := player_spawner_device[Obj]):
                        Spawner2.Disable()
                Sleep(0.3) #2.0
                DamageVolume1.Enable() #Enable
                DamageVolume2.Enable() #Enable
                DamageVolume1.Disable()
                DamageVolume2.Disable()

                TrackerRounds.Increment(Agent)

                HUDclearTrigger.Trigger()
                ExplosionDevice.Explode(Agent)

                spawn{MutatorZoneClearSpawn(Agent)}

                StormDevice.DestroyStorm()


                Print("Round Over Player1")
            else{}    
        if (RoundStarted >= 2):
            if(TrackerDevice.GetValue() <= 1):
                Sleep(2.0) # 2.0
                set RoundStarted = 0
                Spawners := GetCreativeObjectsWithTag(spawner{})
                for (Obj : Spawners):
                    if (Spawner := player_spawner_device[Obj]):
                        Spawner.Enable()

                Spawners2 := GetCreativeObjectsWithTag(spawner2{})
                for (Obj : Spawners2):
                    if (Spawner2 := player_spawner_device[Obj]):
                        Spawner2.Disable()
                Sleep(0.3) #0.5
                DamageVolume1.Enable() #Enable
                DamageVolume2.Enable() #Enable
                DamageVolume1.Disable()
                DamageVolume2.Disable()

                TrackerRounds.Increment(Agent)

                HUDclearTrigger.Trigger()
                ExplosionDevice.Explode(Agent)

                spawn{MutatorZoneClearSpawn(Agent)}

                StormDevice.DestroyStorm()


                Print("Round Over")
            if(TrackerDevice.GetValue() > 1):
                Print("Round in progress")  
            else{}  

    MutatorZoneClearSpawn(Agent : agent)<suspends>:void=
        MutatorZoneClear.Enable()  
        Sleep(0.8) #0.8
        MutatorZoneClear.Disable()

    DisablePlayerSpawners(Agent : agent)<suspends>:void=
        ExplosionDevice.Reset()
        Sleep(2.0) #2.0
        Spawners := GetCreativeObjectsWithTag(spawner{})
        for (Obj : Spawners):
            if (Spawner := player_spawner_device[Obj]):
                Spawner.Disable()

        Spawners2 := GetCreativeObjectsWithTag(spawner2{})
        for (Obj : Spawners2):
            if (Spawner2 := player_spawner_device[Obj]):
                Spawner2.Enable()

    TeleportAfterDeath(Agent:agent):void=
        PadRandom := GetRandomInt(1,SpawnsPad.Length)
        if ( RandomInt := SpawnsPad[PadRandom-1] ): 
            Transform := RandomInt.GetTransform()
            Agent.Respawn(Transform.Translation, Transform.Rotation)        
      
