# Playerclass 2
# Verse code for Playerclass 2 - UEFN/Fortnite Creative implementation
# Difficulty: beginner  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/playerclass-2-1?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }

PlayerVariable := class():
    AgentOB : agent

    RankBar: RankProgressBar = RankProgressBar{}

    var CurrentGoal<private> : int = 25

    var CurrentValue<private> : int = 0 

    GetCurrentGoal() : int =
        return CurrentGoal

    SetCurrentGoal(Change : int) : int =
        set CurrentGoal = Change

    GetCurrentValue() : int =
        return CurrentValue

    SetCurrentValue(Change : int) : int =
        set CurrentValue = Change