# Enhanced Vehicle Spawner
# Creates a custom vehicle spawning system with visual effects, audio feedback, and cooldown management. When players enter or exit the spawned sportbike, it triggers special effects and sounds, with a 
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/customvehicle?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Vehicles }

CustomVehicle := class(creative_device):
    @editable CustomVehicleVehicle : vehicle_spawner_sportbike_device = vehicle_spawner_sportbike_device{} #Can be any vehicle (may have to change to better fit custom vehicle)
    @editable VehicleVFX : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable VehicleTrigger : trigger_device = trigger_device{}
    @editable VehicleSound : audio_player_device = audio_player_device{}


    var IsVehiclePiloted : logic = false
    var SleepTime : float = 5.0
    


    @editable Cooldown : float = 0.0
    var MaybeCooldown : logic = false
    @editable VehicleSpawnTimer : timer_device = timer_device{}
    @editable CooldownMSG : hud_message_device = hud_message_device{}





    OnBegin<override>()<suspends>:void=
        Sleep(3.0)
        VehicleTrigger.Trigger()
        VehicleSpawnTimer.SetMaxDuration(Cooldown)
        set MaybeCooldown = false
        VehicleSpawnTimer.SuccessEvent.Subscribe(ResetCooldown)

        CustomVehicleVehicle.AgentEntersVehicleEvent.Subscribe(HandleEntered)
        CustomVehicleVehicle.AgentExitsVehicleEvent.Subscribe(HandleExit)


    ResetCooldown(Agent:?agent) : void=
        set MaybeCooldown = false


    HandleEntered(Agent : agent) : void =
        VehicleVFX.Pickup(Agent)
        VehicleSound.Play(Agent)


    HandleExit( Agent : agent ) : void =
        VehicleTrigger.Trigger(Agent)
        VehicleSound.Stop(Agent)




    SpawnVehicle(Agent:agent) <suspends> : void=
        if(MaybeCooldown = false):
            VehicleSpawnTimer.Start(Agent)
            set MaybeCooldown=true
            CustomVehicleVehicle.RespawnVehicle()
            if(Player:=player[Agent],FC:=Player.GetFortCharacter[]):
                PlayerLocation := FC.GetTransform().Translation
                if(PlayerLocation.Y  >= 2000.0):
                    NewPlayerLocation := PlayerLocation - vector3{Y:= 400.0}
                    if(CustomVehicleVehicle.TeleportTo[NewPlayerLocation,IdentityRotation()]){}
                else:
                    if(CustomVehicleVehicle.TeleportTo[PlayerLocation- vector3{Y:= 200.0},IdentityRotation()]){}
                Sleep(1.0)
                CustomVehicleVehicle.AssignDriver(Agent)
        else:
            CooldownMSG.Show(Agent)