# Proximity Blinding Effect
# A class-based ability system that grants specific players a blinding item and allows them to trigger a blinding effect on nearby targets. The system uses tracker devices to identify eligible players b
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/blinding?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }

Blinding := class(creative_device):
    @editable var Class : int = 0
    @editable ClassTracker : tracker_device = tracker_device{}
    @editable HUDablity : hud_message_device = hud_message_device{}

    @editable BlindingHUD : hud_message_device = hud_message_device{}

    @editable RemoteManager : signal_remote_manager_device = signal_remote_manager_device{}
    @editable ItemGranter:item_granter_device = item_granter_device{}

    var Targets : []fort_character = array{}
    var NewTargets : []fort_character = array{}

    OnBegin<override>()<suspends>:void=
        RemoteManager.PrimarySignalEvent.Subscribe(BlindingSleep)
        RemoteManager.SecondarySignalEvent.Subscribe(BlindingSleep)
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
            ItemGranter.GrantItem(Agent)
            HUDablity.Show(Agent)

    BlindingSleep(Agent : agent):void=
        if(ClassTracker.GetValue(Agent) = Class):
            spawn{BlindingEffect(Agent)}

    BlindingEffect(Agent:agent)<suspends> : void=
        if(ClassTracker.GetValue(Agent) = Class):
            if(ActivatorPlayer := player[Agent], ActivatorChar := ActivatorPlayer.GetFortCharacter[]):
                set Targets = array{}
                for(Player : GetPlayspace().GetPlayers(),FC:=Player.GetFortCharacter[],EveryAgent:=FC.GetAgent[]):
                    set Targets += array{FC}
                    if(ActivatorIDX := Targets.Find[ActivatorChar]):
                        if(NEWTARGET := Targets.RemoveElement[ActivatorIDX]):
                            set NewTargets = NEWTARGET

                    if(Target := ActivatorChar.FindNearestTarget[],TargetAgent := Target.GetAgent[]):
                        Print("Blinding")
                        BlindingHUD.Show(TargetAgent)

    (FortCharacter : fort_character).FindNearestTarget()<transacts><decides> : fort_character =
        var MaybeTarget : ?fort_character = false
        var NearestLocation : float = 1000000.0
        for (Target : NewTargets):
            if (DistancePlayerToTarget := Distance(Target.GetTransform().Translation, FortCharacter.GetTransform().Translation) < NearestLocation):
                set MaybeTarget = option{Target}
                set NearestLocation = DistancePlayerToTarget
        return MaybeTarget?