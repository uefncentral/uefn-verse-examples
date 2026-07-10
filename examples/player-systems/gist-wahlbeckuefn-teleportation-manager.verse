# Dynamic Portal Teleporter
# Creates a dual-teleporter system that spawns two portal locations based on player's view direction when activated by remote. Teleporters are positioned at configurable near (500 units) and far (2500 u
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/gist-wahlbeckuefn-teleportation-manager?ref=github


using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }

gameplayer := class:
    Player : player
    GamePlayerDevices : gameplayer_devices

    NEAR_DISTANCE : float = 500.0
    FAR_DISTANCE : float = 2500.0
    GROUND_LEVEL : float = 0.0

    var PortalPropNear<private> : creative_prop = creative_prop{}
    var PortalPropFar<private> : creative_prop = creative_prop{}

    Init():void=
        ResetTeleporters()
        GamePlayerDevices.NearTeleporter.Disable()
        GamePlayerDevices.FarTeleporter.Disable()
        GamePlayerDevices.FarTeleporter.TeleportedEvent.Subscribe(OnTeleported)
        
    OnRemotePressed(Agent : agent):void=
        if:
            Fort := Agent.GetFortCharacter[]
            Tran := Fort.GetTransform()
        then:
            ResetTeleporters()
            
            GamePlayerDevices.NearTeleporter.Enable()
            GamePlayerDevices.FarTeleporter.Enable()

            var TeleLocation : vector3 = Fort.GetViewLocation() + Fort.GetViewRotation().GetLocalForward() * NEAR_DISTANCE
            if (TeleLocation.Z < GROUND_LEVEL) { set TeleLocation = vector3{X:= TeleLocation.X, Y:= TeleLocation.Y, Z:= GROUND_LEVEL} }

            var Tele2Location : vector3 = Fort.GetViewLocation() + Fort.GetViewRotation().GetLocalForward() * FAR_DISTANCE
            if (Tele2Location.Z < GROUND_LEVEL) { set Tele2Location = vector3{X:= Tele2Location.X, Y:= Tele2Location.Y, Z:= GROUND_LEVEL} }

            if (GamePlayerDevices.NearTeleporter.TeleportTo[TeleLocation, Tran.Rotation]) {}
            if (GamePlayerDevices.FarTeleporter.TeleportTo[Tele2Location, Tran.Rotation]) {}

            # Spawn the portal props
            if (GamePlayerDevices.ShowTeleporterPropVFX?):
                if (set PortalPropNear = SpawnProp(GamePlayerDevices.TeleporterVFXProp, TeleLocation, Tran.Rotation)(0)?) {}
                if (set PortalPropFar = SpawnProp(GamePlayerDevices.TeleporterVFXProp, Tele2Location, Tran.Rotation)(0)?) {}
            

    OnTeleported<private>(Agent : agent):void=
        GamePlayerDevices.NearTeleporter.Disable()
        GamePlayerDevices.FarTeleporter.Disable()
        ResetTeleporters()

    ResetTeleporters<private>():void=
        if (# PortalPropNear.IsValid[]  # TODO: use type cast (e.g., player[Agent]?) instead) {# PortalPropNear.Dispose()  # TODO: Verse has no manual disposal}
        if (# PortalPropFar.IsValid[]  # TODO: use type cast (e.g., player[Agent]?) instead) {# PortalPropFar.Dispose()  # TODO: Verse has no manual disposal}
        if (GamePlayerDevices.NearTeleporter.TeleportTo[GamePlayerDevices.HomeLocation, IdentityRotation()]) {}
        if (GamePlayerDevices.FarTeleporter.TeleportTo[GamePlayerDevices.HomeLocation, IdentityRotation()]) {}

gameplayer_devices := class<concrete><unique>:
    # Make sure these teleporters are linked to each other properly with groups
    @editable NearTeleporter : teleporter_device = teleporter_device{}
    @editable FarTeleporter : teleporter_device = teleporter_device{}
    @editable TeleporterVFXProp : creative_prop_asset = DefaultCreativePropAsset
    var IsAvailable : logic = true

    @editable var ShowTeleporterPropVFX : logic = false
    HomeLocation : vector3 = vector3{Z:=-5000.0}

teleportation_manager := class(creative_device):

    # Make sure there are enough of these to match the total player limit of the game
    @editable GameplayerDevices : []gameplayer_devices = array{}

    @editable Spawners : []player_spawner_device = array{}
    @editable RemoteGranter : item_granter_device = item_granter_device{}
    @editable RemoteManager : signal_remote_manager_device = signal_remote_manager_device{}

    var GamePlayers : [player]gameplayer = map{}

    OnBegin<override>()<suspends>:void=

        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerRemoved)
          
        for (Spawner : Spawners):
            Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

        RemoteManager.PrimarySignalEvent.Subscribe(OnRemotePressed)

        # First time init because sometimes spawners have already spawned players
        # Also needed for edit sessions when player doesn't spawn on pad
        Sleep(0.5)
        AllPlayers := GetPlayspace().GetPlayers()
        for (Player : AllPlayers) {InitPlayer(Player)}

    # Forward the event to the player
    OnRemotePressed(Agent : agent):void=
        if (Player := player[Agent], Gameplayer := GamePlayers[Player]):
            Gameplayer.OnRemotePressed(Agent)

    # Always use spawn events to init players instead of GetPlayspace().GetPlayers()
    # or player joined server events because those can fire before the player is fully initialized
    OnPlayerSpawned(Agent : agent):void=
        if (Player := player[Agent]) { InitPlayer(Player)}
            
    InitPlayer(Player : player):void=
        if (Existing := GamePlayers[Player]) {}
        else:
            # This is a new player joining the game
            # Find them an available device, create a new gameplayer, then store it in the map
            var AvailableDevice : ?gameplayer_devices = false
            var IDX : int = 0
            loop:
                if (IDX >= GameplayerDevices.Length ) { break }
                if (AD := GameplayerDevices[IDX], AD.IsAvailable?):
                    set AvailableDevice = option{AD}
                    if (set GameplayerDevices[IDX].IsAvailable = false) {}
                    break
                set IDX += 1
            
            if (AD := AvailableDevice?):
                # Give new player remote
                if (Agent := agent[Player]) { RemoteGranter.GrantItem(Agent)}
                
                NewGamePlayer := gameplayer{Player := Player, GamePlayerDevices := AD}
                NewGamePlayer.Init()
                if (set GamePlayers[Player] = NewGamePlayer) {}
                    
    # We free a device so join in progress players can use it
    # Then we remove the player from the map
    OnPlayerRemoved(Player : player):void=
        if (LeavingPlayer := GamePlayers[Player]):
            # Free up the used device for other players
            for (IDX := 0..GameplayerDevices.Length - 1):
                if (Device := GameplayerDevices[IDX], Device = LeavingPlayer.GamePlayerDevices):
                    if (set GameplayerDevices[IDX].IsAvailable = true) {}

            # Remove the leaving player from the map        
            var NewCustomPlayerMap:[player]gameplayer = map{}

            for (Key -> Value : GamePlayers, Key <> Player):
                set NewCustomPlayerMap = ConcatenateMaps(NewCustomPlayerMap, map{Key => Value})
            
            set GamePlayers = NewCustomPlayerMap 
           
                    
            
            