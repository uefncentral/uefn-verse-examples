# Pizza Party
# Verse code for Pizza Party - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/pizza-party?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Game }

PizzaParty := class(creative_device):

    @editable var Class : int = 0
    @editable ClassTracker : tracker_device = tracker_device{}
    @editable HUDablity : hud_message_device = hud_message_device{}

    @editable Timer : timer_device = timer_device{}
    @editable SeparateArenaButtonActivatorTP : teleporter_device = teleporter_device{}
    @editable SeparateArenaButtonActivatorBackTP : teleporter_device = teleporter_device{}
    
    @editable RemoteManager : signal_remote_manager_device = signal_remote_manager_device{}
    @editable ItemGranter : item_granter_device = item_granter_device{} 
    @editable RemoveRemoteInventory : item_remover_device = item_remover_device{} 

    @editable TimeInArena : float = 0.0

    var Targets : []fort_character = array{}
    var NewTargets : []fort_character = array{}
    var CheckPlayerCountArray : []fort_character = array{}
    var EndTime : logic = false
    var Playerhasdied: logic = false 

    OnBegin<override>()<suspends>:void=
        Timer.SetMaxDuration(TimeInArena)
        Timer.SuccessEvent.Subscribe(TimerComplete)
        RemoteManager.PrimarySignalEvent.Subscribe(SeparateArenaAbility)
        RemoteManager.SecondarySignalEvent.Subscribe(SeparateArenaAbility)
        InitSpawners()

    InitSpawners() : void=
        Spawners := GetCreativeObjectsWithTag(spawner{})
        for (Obj : Spawners):
            if (Spawner := player_spawner_device[Obj]):
                Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

    OnPlayerSpawned(Agent : agent): void=
        if (Player := player[Agent]):
            spawn{GiveItem(Agent)}

    GiveItem(Agent : agent)<suspends>:void=
        Sleep(1.0)
        if(ClassTracker.GetValue(Agent) = Class):
            HUDablity.Show(Agent) 
            ItemGranter.GrantItem(Agent)
            spawn:
                RemoveRemoteAfterTime(Agent)

    RemoveRemoteAfterTime(Agent : agent)<suspends>:void=
        Sleep(30.0)
        if(ClassTracker.GetValue(Agent) = Class):
            RemoveRemoteInventory.Remove(Agent)

    TimerComplete(Agent:?agent): void=
        spawn:
            TimerCompleteReal(Agent)

    TimerCompleteReal(Agent:?agent)<suspends>: void=
        Sleep(0.1)
        set EndTime = true

    SeparateArenaAbility(Agent:agent): void=
        if(ClassTracker.GetValue(Agent) = Class):
            RemoveRemoteInventory.Remove(Agent)
            spawn:
                SeparateArenaAbilityReal(Agent)

    SeparateArenaAbilityReal(Agent:agent)<suspends> : void=
        Timer.Start(Agent)
        if(ActivatorPlayer := player[Agent],ActivatorChar := ActivatorPlayer.GetFortCharacter[]):               
            var ActivatorLocation : vector3 = ActivatorChar.GetTransform().Translation
            Sleep(0.1)
            SeparateArenaButtonActivatorTP.Teleport(Agent)
            ActivatorChar.PutInStasis(stasis_args{})
            ActivatorChar.ReleaseFromStasis()
            set EndTime = false
            set Playerhasdied = false
            loop:
                Sleep(0.3)
                if(EndTime = true):
                    if(SeparateArenaButtonActivatorBackTP.TeleportTo[ActivatorLocation,IdentityRotation()]){}
                    SeparateArenaButtonActivatorBackTP.Teleport(Agent)
                    break