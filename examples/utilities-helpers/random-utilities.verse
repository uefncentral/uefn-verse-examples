# Random Number Utilities
# Utility functions for random number generation, weighted random selection, and shuffling arrays.
# Difficulty: beginner  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/random-utilities?ref=github

using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/Diagnostics }

# Random number utility functions

# Get a random integer between min and max (inclusive)
GetRandomIntInRange(Min : int, Max : int) : int =
    if (Max <= Min):
        return Min
    return GetRandomInt(Min, Max)

# Get a random float between min and max
GetRandomFloatInRange(Min : float, Max : float) : float =
    Range := Max - Min
    return Min + (GetRandomFloat() * Range)

# Random boolean with custom probability (0.0 to 1.0)
GetRandomBool(TrueProbability : float) : logic =
    return GetRandomFloat() < TrueProbability

# Weighted random selection - returns index of selected item
# Weights should be positive numbers (higher = more likely)
WeightedRandomSelect(Weights : []float) : int =
    if (Weights.Length = 0):
        return 0

    var TotalWeight : float = 0.0
    for (W : Weights):
        set TotalWeight += W

    var RandomValue : float = GetRandomFloat() * TotalWeight
    var CumulativeWeight : float = 0.0

    for (I := 0..Weights.Length - 1):
        if (W := Weights[I]):
            set CumulativeWeight += W
            if (RandomValue <= CumulativeWeight):
                return I

    return Weights.Length - 1

# Shuffle an array of integers using Fisher-Yates algorithm
ShuffleIntArray(InArray : []int) : []int =
    var Result : []int = InArray
    for (I := Result.Length - 1..1):
        J := GetRandomInt(0, I)
        if (TempI := Result[I]):
            if (TempJ := Result[J]):
                if (set Result[I] = TempJ) {}
                if (set Result[J] = TempI) {}
    return Result

# Get N random unique integers from a range
GetRandomUniqueInts(Count : int, Min : int, Max : int) : []int =
    Range := Max - Min + 1
    if (Count > Range):
        return array{}

    # Create array of all possible values
    var AllValues : []int = array{}
    for (I := Min..Max):
        set AllValues = AllValues + array{I}

    # Shuffle and take first N
    Shuffled := ShuffleIntArray(AllValues)
    var Result : []int = array{}
    for (I := 0..Count - 1):
        if (Val := Shuffled[I]):
            set Result = Result + array{Val}

    return Result

# Roll dice - returns sum of N dice with S sides
RollDice(NumDice : int, NumSides : int) : int =
    var Total : int = 0
    for (I := 0..NumDice - 1):
        set Total += GetRandomInt(1, NumSides)
    return Total

# Percentage chance check (0-100)
PercentChance(Percent : float) : logic =
    return GetRandomFloat() * 100.0 < Percent
