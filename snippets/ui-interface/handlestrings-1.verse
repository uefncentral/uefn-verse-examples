# String Utility Extensions
# This code provides custom string conversion and formatting functions for common UEFN data types including logic, vector3, rotation, and transform. It also includes a utility to truncate floating-point
# Difficulty: beginner  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/handlestrings-1?ref=github

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