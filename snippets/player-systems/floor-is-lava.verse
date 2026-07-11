# Floor Is Lava
# Verse code for Floor Is Lava - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/floor-is-lava?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters }

FloorIsLava := class(creative_device):
    @editable var Class : int = 0
    @editable ClassTracker : tracker_device = tracker_device{}

    @editable WaterDevice : water_device = water_device{}
    @editable RemoteControl : signal_remote_manager_device = signal_remote_manager_device{}
    @editable ItemGranter : item_granter_device = item_granter_device{}

    @editable WaterMaxHeight : float = 0.0
    @editable WaterCoordinateX : float = 0.0
    @editable WaterCoordinateY : float = 0.0
    @editable WaterCoordinateZ : float = 0.0

    @editable WaterIncreasesYourDamage : float = 0.0

    @editable TimeStill : float = 0.0
    @editable TimeRise : float = 0.0
    @editable Cooldown : float = 0.0

    @editable WaterDoesDamage : logic = false
    @editable WaterDamageAmount : float = 0.0

    var HasPowers : logic = false
    var PlayerAgent : []agent = array{} 

    OnBegin<override>()<suspends>:void=
        WaterDevice.AgentEntersWaterEvent.Subscribe(WaterEnterSleep)
        RemoteControl.PrimarySignalEvent.Subscribe(FloodWatercall)
        set PlayerAgent = array{}
        InitSpawners()

    InitSpawners() : void=
        # Print("InitSpawners")
            Spawners := GetCreativeObjectsWithTag(spawner{})
            for (Obj : Spawners):
                if (Spawner := player_spawner_device[Obj]):
                    Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)
            
    OnPlayerSpawned(Agent : agent): void=
        #Print("OnPlayerSpawnedfunction")
        if (Player := player[Agent]):
            spawn{OnPlayerSpawnedSleep(Player)}

    OnPlayerSpawnedSleep(Player : player)<suspends>:void=
        Sleep(1.0)
        if(ClassTracker.GetValue(Player) = Class):
            ItemGranter.GrantItem(Player)


    FloodWatercall(Agent : agent): void=
        spawn{FloodWater(Agent)}

    FloodWater(Agent:agent)<suspends> : void=
        Sleep(1.0)
        if(ClassTracker.GetValue(Agent) = Class):
            set PlayerAgent = array{}
            set PlayerAgent += array{Agent}

            WaterMaxPosition := vector3{X:=WaterCoordinateX,Y:=WaterCoordinateY,Z:=WaterMaxHeight}
            if(WaterDevice.TeleportTo[vector3{X:=WaterCoordinateX,Y:=WaterCoordinateY,Z:=WaterCoordinateZ} , WaterDevice.GetTransform().Rotation]){}

            WaterDevice.MoveTo(WaterMaxPosition , WaterDevice.GetTransform().Rotation , TimeRise)
            Sleep(TimeStill)
            WaterDevice.MoveTo(vector3{X:=WaterCoordinateX,Y:=WaterCoordinateY,Z:=WaterCoordinateZ} , WaterDevice.GetTransform().Rotation , TimeRise)

            if(WaterDevice.TeleportTo[vector3{X:=10000.0,Y:=10000.0,Z:=-10000.0} , WaterDevice.GetTransform().Rotation]){}

    WaterEnterSleep(Agent:agent) : void=
        spawn:
            WaterEnter(Agent)
            
    WaterEnter(Agent:agent)<suspends> : void=
        if(Player := player[Agent],FC := Player.GetFortCharacter[]):
            loop:
                Sleep(1.0)
                if(FC.IsInWater[]):
                    if(Agent = PlayerAgent[0]):
                        if(HasPowers = false):
                            set HasPowers = true
                            spawn:
                                ResetHasPowers()
                    else:
                        if(WaterDoesDamage = true):
                            FC.Damage(WaterDamageAmount)
    ResetHasPowers()<suspends> : void=
        Sleep(5.0)
        set HasPowers = false