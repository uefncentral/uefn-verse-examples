# Number Scientific Notation Parser
# Converts numbers into normalized scientific notation components, breaking them down into mantissa digits, exponent index, and decimal position. Provides utility functions to format and display the par
# Difficulty: beginner  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/num-parts-1?ref=github

decimal_position<public> := enum:
    None
    Tenths
    Hundredths

num_parts<public> := struct:
    Digits<public>:int
    ExpIndex<public>:int
    Decimal<public>:decimal_position

(Num:num).Parts<public>()<transacts>:num_parts =
    Number := Num.SetNormalize()
    Digits :=
        if (Number.Exponent = 0):
            if (Dig := Floor[Number.Value]):
                Dig
            else:
                0
        else:
            if (Number.Value < 10.0, Value := Floor[Number.Value * 100]):
                Value
            else if (Number.Value < 100.0, Value := Floor[Number.Value * 10]):
                Value
            else if (Value := Floor[Number.Value]):
                Value
            else:
                100
    ExpIndex := if (Index := Floor(Number.Exponent / 3)). Index else. 0
    Decimal :=
        if (Number.Exponent = 0):
            decimal_position.None
        else if (Number.Value < 10.0):
            decimal_position.Hundredths
        else if (Number.Value < 100.0):
            decimal_position.Tenths
        else:
            decimal_position.None

    return num_parts:
        Digits := Digits
        ExpIndex := ExpIndex
        Decimal := Decimal

ToString<public>(Parts:num_parts):string=
    "Digits: {Parts.Digits}, ExpIndex: {Parts.ExpIndex}, Decimal: {Parts.Decimal}"

ToString<public>(Pos:decimal_position):string=
    case(Pos):
        decimal_position.None => "None"
        decimal_position.Tenths => "Tenths"
        decimal_position.Hundredths => "Hundredths"
