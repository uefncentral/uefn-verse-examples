# Frogger Game Initialization
# This code sets up the core components for a Frogger-style game in UEFN. It creates a grid-based game board with configurable lanes, spawns frog player characters with movement capabilities, and initia
# Difficulty: beginner  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/frogger-initialization-1?ref=github

using { BoardExtensions }
using { MovementExtensions }
using { PlayerExtensions }
using { ProgressExtensions }
using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/SpatialMath }

FroggerInitialization<public> := module:
    AspectRatio:tuple(int, int) = (16, 9)

    CreateBoard(Pivot:vector3, Lanes:int, Asset:asset)<transacts>:[][]space =
        for (X := 0..Lanes - 1, Width := Floor(Lanes * AspectRatio(0) / AspectRatio(1)) - 1):
            for:
                Y := 0..Width
                Translation := Pivot + Asset.Size * vector3{X := (Lanes - 1 - X) * 1.0, Y := (Width - Y) * 1.0, Z := 1.0}
                Rotation := IdentityRotation().ApplyLocalRotationZ((90.0 * Pi / 180.0))
                Result := SpawnProp(Asset.PropAsset, Translation, Rotation)
                Prop := Result(0)?
            do:
                space:
                    Position := (X, Y)
                    Offset := Asset.Offset
                    Size := Asset.Size
                    Facing := Asset.Facing
                    Object := Prop

    CreateFrog<public>(Asset:asset, Label:label, Player:player, State:state):respawnable_prop_figure =
        Frog := respawnable_prop_figure:
            Asset := Asset
            PlayerName := Label
            Player := Player
            PlacementRequest := State.PlacementRequest
            MoveRequest := State.MoveRequest
            RemovalRequest := State.RemovalRequest
            MoveComplete := State.MoveComplete
        Frog.SetUp()
        Frog

    CreateFroggerState<public>(Pivot:vector3, Lanes:int, Asset:asset, ProgressReporter:progress_reporter)<transacts>:state =
        state:
            Board := CreateBoard(Pivot, Lanes, Asset)
            ProgressReporter := ProgressReporter
