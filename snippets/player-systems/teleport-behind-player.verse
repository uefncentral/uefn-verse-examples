# Teleport Behind Player
# Verse code for Teleport Behind Player - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/teleport-behind-player?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters}
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }

TeleportBehindRandom := class(creative_device):
    
    @editable var Class : int = 0
    @editable ClassTracker : tracker_device = tracker_device{}
    @editable HUDablity : hud_message_device = hud_message_device{}

    @editable TeleportBehindRandomTP : teleporter_device = teleporter_device{}
    @editable RemoteControl : signal_remote_manager_device = signal_remote_manager_device{}
    @editable ItemGranter : item_granter_device = item_granter_device{}

    var ArrayOfPlayers : []player = array{}
    var ButtonPresserIDX: int = 0
    OnBegin<override>()<suspends>:void=
        RemoteControl.PrimarySignalEvent.Subscribe(TeleportPlayerCall)
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
            spawn{GrantItem(Agent)}
            HUDablity.Show(Agent)

    GrantItem(Agent : agent)<suspends>:void=
        Sleep(5.0)
        ItemGranter.GrantItem(Agent)

    TeleportPlayerCall(Agent : agent) :void=
        if(ClassTracker.GetValue(Agent) = Class):
            spawn{TeleportPlayer(Agent)}      

    TeleportPlayer(Agent:agent)<suspends> : void=
        set ArrayOfPlayers = array{}
        for (Player : GetPlayspace().GetPlayers(),FortCharacter := Player.GetFortCharacter[]):
            set ArrayOfPlayers += array{Player}
        if (ButtonPresser := player[Agent], ButtonPresserChar := ButtonPresser.GetFortCharacter[]):
            if(NEWIDX  := ArrayOfPlayers.Find[ButtonPresser]):
                if(NEWARRAY := ArrayOfPlayers.RemoveElement[NEWIDX]):
                    set ArrayOfPlayers = NEWARRAY
                RandomInt :=  GetRandomInt(0, ArrayOfPlayers.Length-1)
                if(RandomPlayer := ArrayOfPlayers[RandomInt],RandomChar := RandomPlayer.GetFortCharacter[]):
                    if(TeleportBehindRandomTP.TeleportTo[RandomChar.GetViewLocation(), RandomChar.GetTransform().Rotation]){}
                    TeleportBehindRandomTP.Teleport(Agent)
                    if(TeleportBehindRandomTP.TeleportTo[vector3{X:=1000.0,Y:=1000.0,Z:=1000.0},TeleportBehindRandomTP.GetTransform().Rotation]){}
                    if(ActivatorPlayer := player[Agent],ActivatorChar := ActivatorPlayer.GetFortCharacter[]):
                        S:stasis_args = stasis_args{}
                        if(S.AllowEmotes = false, S.AllowFalling = true, S.AllowTurning=false):
                        ActivatorChar.PutInStasis(S)
                        ActivatorChar.ReleaseFromStasis()