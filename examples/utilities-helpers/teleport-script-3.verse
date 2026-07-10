# Teleport-script
# Verse code for Teleport-script - UEFN/Fortnite Creative implementation
# Difficulty: intermediate  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/teleport-script-3?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# Handles teleportation logic when players enter a mutator zone
teleport_controller := class(creative_device):

    # Reference to the mutator zone device
    @editable
    TriggerZone : mutator_zone_device = mutator_zone_device{}

    # Reference to the first teleporter device
    @editable
    Teleporter1 : teleporter_device = teleporter_device{}

    # Reference to the second teleporter device
    @editable
    Teleporter2 : teleporter_device = teleporter_device{}

    # Variable to track number of players in zone
    var PlayersInZone : int = 0

    # Last two agents that entered
    var LastAgent1 : ?agent = false
    var LastAgent2 : ?agent = false

    # Initialize the device
    OnBegin<override>()<suspends>:void=
        # Subscribe to the player entering event
        TriggerZone.AgentEntersEvent.Subscribe(OnPlayerEnterZone)
        # Subscribe to the player exiting event
        TriggerZone.AgentExitsEvent.Subscribe(OnPlayerExitZone)

    # Handler for when a player enters the zone
    OnPlayerEnterZone(MyAgent : agent):void=
        if (ThePlayer := player[MyAgent]):
            # Increment player count
            set PlayersInZone += 1
            
            # Store the agent
            if (PlayersInZone = 1):
                set LastAgent1 = option{MyAgent}
            else if (PlayersInZone = 2):
                set LastAgent2 = option{MyAgent}
                # Teleport players when we have 2
                TeleportPlayers()

    # Handler for when a player exits the zone
    OnPlayerExitZone(MyAgent : agent):void=
        if (PlayersInZone > 0):
            set PlayersInZone -= 1
            if (LastAgent1? = MyAgent):
                set LastAgent1 = false
            if (LastAgent2? = MyAgent):
                set LastAgent2 = false

    # Function to handle teleporting the players
    TeleportPlayers():void=
        if (Agent1 := LastAgent1?):
            Teleporter1.Teleport(Agent1)
        if (Agent2 := LastAgent2?):
            Teleporter2.Teleport(Agent2)
        
        # Reset counters after teleporting
        set PlayersInZone = 0
        set LastAgent1 = false
        set LastAgent2 = false
