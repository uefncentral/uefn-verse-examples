# String Conversion Utilities
# A collection of utility functions that convert various Verse data types (logic, vector3, rotation, transform, float) into readable string representations. Includes specialized formatting for truncatin
# Difficulty: beginner  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/nn6n-helper-scripts-handlestrings?ref=github

# Strings


(Value : logic).ToString<public>() : string =
    if (Value?):
        return "true"
    return "false"

(Value: string).ToMessage<localizes>() : message = "{Value}"

(Translation:vector3).ToString<public>():string = 
    return "V3 ~ X: {Translation.X}, Y: {Translation.Y}, Z: {Translation.Z}"

(Rotation:rotation).ToString<public>():string = 
    return "Rot2V3: {Rotation.GetAxis()}"

(Transform:transform).ToString<public>():string = 
    return "Transform ~ Translation: {Transform.Translation.ToString()}, Rotation: {Transform.Rotation.ToString()}, Scale: {Transform.Scale.ToString()}"

MakeMessageFromString<localizes>(Text: string): message = "{Text}"

# Returns Number converted to a string, truncated to Decimals places.
ToTruncatedString<public>(Number:float, Decimals:int):[]char=
    var Str:[]char = ToString(Number)
    if:
        DotIndex := Str.Find['.']
        StopIndex := if (Decimals > 0) then Min(DotIndex+Decimals+1,Str.Length) else DotIndex
        Tmp := Str.Slice[0, StopIndex] 
        set Str = Tmp
    Str