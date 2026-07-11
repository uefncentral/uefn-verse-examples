# Poseidon Water Powers System
# Creates a class-based water control system where players with a specific class can manipulate water levels and gain damage boosts while in water. The system tracks player classes and provides special 
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/poseidon-1?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters }

Poseidon := class(creative_device):
    @editable var Class : int = 0
    @editable ClassTracker : tracker_device = tracker_device{}
    @editable HUDablity : hud_message_device = hud_message_device{}

    @editable WaterDMGBoost : damage_amplifier_powerup_device = damage_amplifier_powerup_device{}
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

    @editable WaterDoesDamage : logic = false
    @editable WaterDamageAmount : float = 0.0



    var HasPowers : logic = false
    var PlayerAgent : []agent = array{} 

    OnBegin<override>()<suspends>:void=
        InitSpawners()
        WaterDMGBoost.SetMagnitude(WaterIncreasesYourDamage)
        WaterDevice.AgentEntersWaterEvent.Subscribe(WaterEnterSleep)
        RemoteControl.PrimarySignalEvent.Subscribe(FloodWatercall)

    InitSpawners() : void=
        Spawners := GetCreativeObjectsWithTag(spawner{})
        for (Obj : Spawners):
            if (Spawner := player_spawner_device[Obj]):
                Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)
            
    OnPlayerSpawned(Agent : agent): void=
        if (Player := player[Agent]):
            spawn{CheckClass(Agent)}

    CheckClass(Agent : agent)<suspends>:void=
        Sleep(1.0)
        if(ClassTracker.GetValue(Agent) = Class):
            ItemGranter.GrantItem(Agent)
            HUDablity.Show(Agent)

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
                            WaterDMGBoost.Pickup(Agent)
                    else:
                        if(WaterDoesDamage = true):
                            FC.Damage(WaterDamageAmount)
    ResetHasPowers()<suspends> : void=
        Sleep(5.0)
        set HasPowers = false