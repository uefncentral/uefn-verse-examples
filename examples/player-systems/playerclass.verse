# Player Rank Progress System
# This code creates a player variable class that tracks individual player progress towards ranking goals with a visual progress bar. It manages current values and goals for each player, providing getter
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/playerclass?ref=github

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