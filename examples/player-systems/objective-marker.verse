# Objective Marker Mover
# This code creates a system to move objective markers (props with map indicators) to new positions. It supports both instant teleportation and smooth movement over time, making it useful for dynamic ob
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/objective-marker?ref=github

using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Devices/CreativeAnimation }

objective_marker<public> := struct<concrete>:

    # The prop that will be moved
    @editable
    RootProp<public> : creative_prop = creative_prop{}

    # The child of the prop that will move with it
    @editable
    MapIndicator<public> : map_indicator_device = map_indicator_device{}

# An extension method for objective_marker
# The ? in front of OverTime specifies it as a named argument
(Marker : objective_marker).MoveMarker<public>(Transform : transform, ?OverTime : float)<suspends> : void =

    if (OverTime > 0.0):
        Marker.RootProp.MoveTo(Transform.Translation, Transform.Rotation, OverTime)
    else:
        if:
            Marker.RootProp.TeleportTo[Transform.Translation, Transform.Rotation]