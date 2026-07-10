# Moving Platform System
# Create platforms that move between waypoints. Supports linear, ping-pong, and loop movement patterns.
# Difficulty: intermediate  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/moving-platform-system?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }

# Movement pattern types
movement_pattern := enum:
    Linear      # Move through waypoints once
    PingPong    # Go back and forth
    Loop        # Loop continuously

# Moving platform controller
moving_platform := class(creative_device):

    @editable
    Platform : prop_mover_device = prop_mover_device{}

    @editable
    Waypoints : []beacon_device = array{}  # Use beacons as waypoints

    @editable
    MoveSpeed : float = 500.0  # Units per second

    @editable
    WaitAtWaypoint : float = 1.0  # Seconds to wait at each point

    @editable
    Pattern : movement_pattern = movement_pattern.Loop

    @editable
    StartOnBegin : logic = true

    var CurrentWaypointIndex : int = 0
    var MovingForward : logic = true
    var IsMoving : logic = false

    OnBegin<override>()<suspends> : void =
        if (Waypoints.Length < 2):
            Print("Error: Need at least 2 waypoints!")
            return

        if (StartOnBegin?):
            StartMovement()

    StartMovement()<suspends> : void =
        set IsMoving = true

        loop:
            if (not IsMoving?):
                break

            # Get current and next waypoint
            NextIndex := GetNextWaypointIndex()
            if (NextIndex < 0):
                break  # End of linear path

            # Move to next waypoint
            if (NextWaypoint := Waypoints[NextIndex]):
                MoveToWaypoint(NextWaypoint)
                Sleep(WaitAtWaypoint)

            set CurrentWaypointIndex = NextIndex

    GetNextWaypointIndex() : int =
        case (Pattern):
            movement_pattern.Linear =>
                if (CurrentWaypointIndex < Waypoints.Length - 1):
                    return CurrentWaypointIndex + 1
                return -1  # End of path

            movement_pattern.PingPong =>
                if (MovingForward?):
                    if (CurrentWaypointIndex < Waypoints.Length - 1):
                        return CurrentWaypointIndex + 1
                    else:
                        set MovingForward = false
                        return CurrentWaypointIndex - 1
                else:
                    if (CurrentWaypointIndex > 0):
                        return CurrentWaypointIndex - 1
                    else:
                        set MovingForward = true
                        return CurrentWaypointIndex + 1

            movement_pattern.Loop =>
                return Mod(CurrentWaypointIndex + 1, Waypoints.Length)

    MoveToWaypoint(Waypoint : beacon_device)<suspends> : void =
        TargetPos := Waypoint.GetTransform().Translation
        Platform.MoveTo(TargetPos, MoveSpeed)

    StopMovement() : void =
        set IsMoving = false

    ResumeMovement() : void =
        spawn { StartMovement() }

    # Teleport platform to specific waypoint
    GoToWaypoint(Index : int) : void =
        if (Index >= 0):
            if (Index < Waypoints.Length):
                set CurrentWaypointIndex = Index
                if (Waypoint := Waypoints[Index]):
                    Platform.MoveTo(Waypoint.GetTransform().Translation, 0.0)
