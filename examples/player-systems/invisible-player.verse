# Invisible Player
# Verse code for Invisible Player - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/invisible-player?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters }

# Define the device class
invisible_player := class(creative_device):
    @editable
    Spawners: []player_spawner_device = array{}  # Editable array of player spawner devices
    @editable
    Trigger: trigger_device = trigger_device{}  # Editable trigger device

    # Event triggered when the game begins
    OnBegin<override>()<suspends>: void =
        # Subscribe to the player spawn event for each spawner in the array
        for (Spawner : Spawners):
            Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

        # Subscribe to the Trigger event
        Trigger.TriggeredEvent.Subscribe(OnTriggerActivated)

    # Function to handle player spawn event
    OnPlayerSpawned(InAgent: agent): void =
        # Use a failure context to handle potential failure of GetFortCharacter[]
        if (Player := InAgent.GetFortCharacter[]):
            # Hide the player's fort_character
            Player.Hide()

    # Function to handle trigger activation event
    OnTriggerActivated(InPlayer: ?agent): void =
        # Check if InPlayer is not none
        if (InPlayer?):
            # Now that InPlayer is confirmed to be a valid agent, we can call GetFortCharacter[]
            if (Player := InPlayer?.GetFortCharacter[]):
                # Hide the player's fort_character
                Player.Hide()
