# Random Compass Navigator
# This device allows players to activate a compass that points to random target locations from a predefined set of coordinates. Players can enable the compass navigation with one button and disable it w
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/compass?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }

example_device := class(creative_device):

    @editable
    Compass : compass_device = compass_device{}  # The compass device

    @editable
    EnableButton : button_device = button_device{}  # Button to enable the compass and navigate to a target location

    @editable
    DisableButton : button_device = button_device{}  # Button to disable the compass

    TargetLocations : []vector3 = array:
        vector3{X:=1792.0, Y:=1792.0, Z:=0.0},
        vector3{X:=-1792.0, Y:=1792.0, Z:=0.0},
        vector3{X:=1792.0, Y:=-1792.0, Z:=0.0},
        vector3{X:=-1792.0, Y:=-1792.0, Z:=0.0}

    OnBegin<override>()<suspends>: void =
        EnableButton.InteractedWithEvent.Subscribe(ExampleCompassEnableEvent)
        DisableButton.InteractedWithEvent.Subscribe(ExampleCompassDisableEvent)

    # Function to handle enabling the compass
    ExampleCompassEnableEvent(Agent : agent): void =
        # Get a random target location
        TargetLocation : vector3 = GetRandomLocation()
        
        if (Player := player[Agent]):
            # Activate the compass for the player, pointing to the target location
            Compass.Navigate(Player, TargetLocation)
            
    # Function to handle disabling the compass
    ExampleCompassDisableEvent(Agent : agent): void =
        if (Player := player[Agent]):
            # Method to disable the compass for the player
            Compass.Disable(Player)

    # Get a random location from the TargetLocations array
    GetRandomLocation() : vector3 =
        return TargetLocations[GetRandomInt(0, TargetLocations.Length-1)] or vector3{X:=0.0, Y:=0.0, Z:=0.0}