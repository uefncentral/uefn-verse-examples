# Teleport To Location
# Verse code for Teleport To Location - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/teleport-to-location?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/Verse }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters }
using { /Fortnite.com/FortPlayerUtilities }

TeleportToLocation := class(creative_device):

    @editable var Class : int = 0
    @editable ClassTracker : tracker_device = tracker_device{}
    @editable HUDablity : hud_message_device = hud_message_device{}

    @editable RemoteManager : signal_remote_manager_device = signal_remote_manager_device{}
    @editable ItemGranter: item_granter_device = item_granter_device{}
    @editable HUDSetLocation: hud_message_device = hud_message_device{}
    @editable HUDGetLocation: hud_message_device = hud_message_device{}
    @editable HUDNoLocationActive: hud_message_device = hud_message_device{}

    var AgentMap : [agent]transform = map{}

    var Location : logic = false

    OnBegin<override>()<suspends>:void=
        InitSpawners()
        RemoteManager.PrimarySignalEvent.Subscribe(UseFlashback)
        RemoteManager.SecondarySignalEvent.Subscribe(SetLocation)

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
            HUDablity.Show(Agent)
            ItemGranter.GrantItem(Agent)

    UseFlashback(Agent : agent):void=
        if(ClassTracker.GetValue(Agent) = Class):
            if(Location = true):
                if {Agent.Respawn(AgentMap[Agent].Translation, AgentMap[Agent].Rotation)}
                then:   
                    HUDGetLocation.Show(Agent)
            else:
                HUDNoLocationActive.Show(Agent)

    SetLocation(Agent : agent):void=
        if(ClassTracker.GetValue(Agent) = Class):
            if:
                FortCharacter := Agent.GetFortCharacter[]
                set AgentMap[Agent] = FortCharacter.GetTransform()
            then:
                HUDSetLocation.Show(Agent)
                set Location = true