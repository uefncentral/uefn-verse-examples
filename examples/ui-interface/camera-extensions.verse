# Board Camera Positioning
# Automatically calculates and positions a fixed-point camera to properly frame a 2D grid/board structure. The function determines optimal camera distance and location based on board dimensions and fiel
# Difficulty: beginner  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/camera-extensions?ref=github

using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Devices }
using { MovementExtensions }

CameraExtensions<public> := module:
    RepositionCamera<public>(Board:[][]space, Camera:gameplay_camera_fixed_point_device)<decides><transacts>:vector3 =
        BottomLeftSpace := Board[0][0]
        BottomRightSpace := Board[0][Board[0].Length - 1]
        TopRightSpace := Board[Board.Length - 1][Board[0].Length - 1]
        RowLength := EndToEndDistance(BottomLeftSpace, BottomRightSpace)
        FieldOfView := 120.0
        ViewDistance := BottomLeftSpace.GetCentroid().Z + RowLength / (2.0 * Tan((FieldOfView / 2.0 * Pi / 180.0)))
        Center := Lerp(TopRightSpace.GetSurface(), BottomLeftSpace.GetSurface(), 0.5)
        vector3{X := Center.X + 192.0, Y := Center.Y, Z := ViewDistance}
