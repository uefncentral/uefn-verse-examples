# Closest Player Teleporter
# This device teleports the activating player to the location of the nearest other player in the game. When triggered via a signal remote manager, it calculates distances between players and instantly m
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/teleport?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }
 
 teleport_device := class(creative_device):
 
    @editable
    TeleportSignalRemoteManager: signal_remote_manager_device = signal_remote_manager_device{}

    @editable
    HudMessageDevice: hud_message_device = hud_message_device{}
 
    # Runs when the device is started in a running game
    OnBegin<override>()<suspends >:void=
        TeleportSignalRemoteManager.PrimarySignalEvent.Subscribe(TeleportEvent)
        Print("[OnBegin]Begin Event Initialized.")
 
    TeleportEvent(Agent:agent):void=
        spawn:
            TeleportActivated(Agent)
 
    TeleportActivated(Agent:agent)<suspends>:void=
        AllPlayers := GetPlayspace().GetPlayers()
 
        if (InitialCharacter : fort_character = Agent.GetFortCharacter[]):
            Viewpoint := InitialCharacter.GetViewLocation()
 
            ClosestCharacter := GetClosestPlayerToViewpoint(AllPlayers, Viewpoint, InitialCharacter)

            EnemyPos := ClosestCharacter.GetTransform()
            if:
                InitialCharacter.TeleportTo[EnemyPos.Translation, EnemyPos.Rotation]
            HudMessageDevice.Show(Agent)
 
    GetClosestPlayerToViewpoint(AllPlayers: []player, Viewpoint:vector3, InitialCharacter: fort_character): fort_character =
        var ClosestCharacter : fort_character = InitialCharacter
        var ClosestDistance: float = 1000000000.0
        for (Player : AllPlayers):
            if (FNCharacter : fort_character = Player.GetFortCharacter[]):
                if (FNCharacter <> InitialCharacter):
                    PlayerLocation := FNCharacter.GetTransform().Translation
                    EDistance := Distance(Viewpoint, PlayerLocation)
                    if (EDistance < ClosestDistance):
                        set ClosestCharacter = FNCharacter
                        set ClosestDistance = EDistance
        Print("[GetClosestPlayerToViewpoint]Closest Agent Found.")
        return ClosestCharacter
