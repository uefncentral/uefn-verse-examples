# Player Navigation Compass
# Creates a dynamic compass UI that guides players toward specific target locations with directional indicators and distance measurements. The compass displays appropriate directional textures (N, NE, E
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/compass-device?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Colors }
using { /Verse.org/Assets }

units := enum:
    KM
    M
    CM

compass_device := class(creative_device):

    # The unit of measurement for distance
    @editable
    Units : units = units.M
    # The size of the compass texture
    @editable
    CompassTextureSize : float = 45.0
    # The distance at which the compass will hide
    @editable
    DistanceToHideCompass : float = 300.0
    # The screen position of the compass
    @editable
    WidgetPos : vector2 = vector2{X := 0.5, Y := 0.9}
    # The alignment of the compass
    @editable
    WidgetAlignment : vector2 = vector2{X := 0.5, Y := 1.0}

    var TargetLocations : [player]vector3 = map{}
    var DistanceTextblocks: [player]text_block = map{}
    var DirectionWidgets: [player]texture_block = map{}
    var UIPerPlayer: [player]?canvas = map{}
    var BreakCompassAnimation: [player]?logic = map{}

    # Compass textures
    North : texture = UI.N
    NorthEast : texture = UI.NE
    East : texture = UI.E
    SouthEast : texture = UI.SE
    South : texture = UI.S
    SouthWest : texture = UI.SW
    West : texture = UI.W
    NorthWest : texture = UI.NW

    # Enable the compass for a player
    Navigate(Player : player, Target : vector3) : void =
        # Set the target location for the player
        if(set TargetLocations[Player] = Target) {}

        # Create the compass UI if it doesn't exist
        if (not UIPerPlayer[Player]?):
            CreateCompassUI(Player)

        # Animate the compass
        if(set BreakCompassAnimation[Player] = false) {}
        spawn { AnimateCompass(Player) }

    # Disable the compass for a player
    Disable(Player : player) : void =
        if (PlayerUI := GetPlayerUI[Player], MyUI := UIPerPlayer[Player]?):
            # Remove the compass UI
            PlayerUI.RemoveWidget(MyUI)
            # Stop the compass animation
            if(set UIPerPlayer[Player] = false, set BreakCompassAnimation[Player] = option{true}) {}

    # Creates the Compass UI
    CreateCompassUI(Player : player): void =
        if (PlayerUI := GetPlayerUI[Player]):
            PlayerDistance := GetDistance(Player)
            DistanceText : text_block = text_block{DefaultText := ToMessage(GetFormattedDistance(PlayerDistance)), DefaultTextColor := NamedColors.White}
            DirectionTexture : texture_block = texture_block{DefaultImage := North, DefaultDesiredSize := vector2{X := CompassTextureSize, Y := CompassTextureSize}}

            CompassStackBox := stack_box:
                Orientation := orientation.Vertical
                Slots := array:
                    stack_box_slot:
                        Widget := DirectionTexture
                        Padding := margin{Left := 50.0, Right := 50.0} # Increases container size to prevent constant side to side motion
                    stack_box_slot:
                        Widget := DistanceText

            MyCanvas : canvas = canvas:
                Slots := array:
                    canvas_slot:
                        Anchors := anchors{Minimum := WidgetPos, Maximum := WidgetPos}
                        Alignment := WidgetAlignment
                        Widget := CompassStackBox

            # Set the UI elements for the player and add the canvas to the player's UI
            if:
                set UIPerPlayer[Player] = option{MyCanvas}
                set DistanceTextblocks[Player] = DistanceText
                set DirectionWidgets[Player] = DirectionTexture
            then:
                PlayerUI.AddWidget(MyCanvas)

    # Animates the compass based on the player's location and target location
    AnimateCompass(Player : player)<suspends>: void =
        loop:
            Sleep(0.1)
            # Break if the compass is disabled or the player is not active
            if(Break := BreakCompassAnimation[Player]? or not Player.IsActive[]) {break}
                
            if (FortCharacter := Player.GetFortCharacter[], TargetLocation := TargetLocations[Player]):
                # Get the player's location and rotation
                PlayerLocation := FortCharacter.GetTransform().Translation
                Rotation := FortCharacter.GetTransform().Rotation
                if (Yaw := Rotation.GetYawPitchRollDegrees()[0]):
                    # Calculate the angle difference between the player's direction and the target location
                    DirectionVector := TargetLocation - PlayerLocation
                    TargetAngle := (ArcTan2(DirectionVector.Y, DirectionVector.X * 180.0 / Pi))
                    AngleDifference := NormalizeAngle(TargetAngle - Yaw)
                    PlayerDistance := Distance(PlayerLocation, TargetLocation)
            
                    if (DistanceText := DistanceTextblocks[Player], DirectionWidget := DirectionWidgets[Player]):
                        # Hide the compass if the player is close to the target location
                        if (PlayerDistance <= DistanceToHideCompass):
                            DistanceText.SetVisibility(widget_visibility.Hidden)
                            DirectionWidget.SetVisibility(widget_visibility.Hidden)
                        else:
                            # Show the compass and update the distance and direction
                            DistanceText.SetVisibility(widget_visibility.Visible)
                            DirectionWidget.SetVisibility(widget_visibility.Visible)
                            
                            # Convert and display distance based on selected unit
                            DistanceDisplay := GetFormattedDistance(PlayerDistance)
                            DistanceText.SetText(ToMessage(DistanceDisplay))
                                
                            # Update the compass texture based on the angle difference
                            DirectionTexture := 
                                if (AngleDifference > -22.5 and AngleDifference <= 22.5) then North
                                else if (AngleDifference > 22.5 and AngleDifference <= 67.5) then NorthEast
                                else if (AngleDifference > 67.5 and AngleDifference <= 112.5) then East
                                else if (AngleDifference > 112.5 and AngleDifference <= 157.5) then SouthEast
                                else if (AngleDifference > 157.5 or AngleDifference <= -157.5) then South
                                else if (AngleDifference > -157.5 and AngleDifference <= -112.5) then SouthWest
                                else if (AngleDifference > -112.5 and AngleDifference <= -67.5) then West
                                else NorthWest
                            
                            # Set the compass texture
                            DirectionWidget.SetImage(DirectionTexture)

    # Get the distance between the player and the target location
    GetDistance(Player: player): float =
        if (FortCharacter := Player.GetFortCharacter[], TargetLocation := TargetLocations[Player]):
            PlayerLocation := FortCharacter.GetTransform().Translation
            return Distance(PlayerLocation, TargetLocation)
        return 0.0

    # Get formatted distance string based on selected unit
    GetFormattedDistance(DistanceCM: float): string =
        case (Units):
            units.CM => "{ToTruncatedString(DistanceCM, 0)}cm"
            units.M => "{ToTruncatedString(DistanceCM / 100.0, 1)}m"
            units.KM => "{ToTruncatedString(DistanceCM / 100000.0, 2)}km"

#############################
# Helper Functions
#############################

# Converts a string to a localizable message type
ToMessage<public><localizes>(Value : string) : message = "{Value}"

# Converts a float to a string, truncated to specified decimal places
ToTruncatedString<public>(Number:float, Decimals:int):[]char=
    var Str:[]char = ToString(Number)
    if:
        DotIndex := Str.Find['.']
        StopIndex := if (Decimals > 0) then Min(DotIndex+Decimals+1,Str.Length) else DotIndex
        StrTemp := Str.Slice[0, StopIndex] 
        set Str = StrTemp
    Str

# Calculates the arctangent of Y/X, considering the quadrant
ArcTan2(Y : float, X : float) : float =
    if (X > 0.0):
        return ArcTan(Y / X)
    else if (X < 0.0 and Y >= 0.0):
        return ArcTan(Y / X) + PiFloat
    else if (X < 0.0 and Y < 0.0):
        return ArcTan(Y / X) - PiFloat
    else if (X = 0.0 and Y > 0.0):
        return PiFloat / 2.0
    else if (X = 0.0 and Y < 0.0):
        return -PiFloat / 2.0
    else:
        return 0.0  # X = 0 and Y = 0

# Normalizes an angle to the range [-180, 180] degrees
NormalizeAngle(CheckAngle : float) : float =
    if(Angle := (Mod[Int[CheckAngle], 360] * 1.0)):
        return if (Angle > 180.0) then Angle - 360.0 else if (Angle < -180.0) then Angle + 360.0 else Angle
    return 0.0