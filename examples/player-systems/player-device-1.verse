# Player Progress Tracker
# This code defines a custom player class that tracks progress toward goals with a rank progression system. It manages current values and goals for each player, along with a progress bar UI element for 
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/player-device-1?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation/Tags }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }

TextForUI<localizes>(Agent : agent) : message = "{Agent}"

CustomPlayer := class():
    AgentOB : agent
    
    var CurrentGoal<private> : int = 25

    var CurrentValue<private> : int = 0

    RankBar : RankProgressBar = RankProgressBar{}

    GetCurrentGoal():int =
        return CurrentGoal
    
    SetCurrentGoal(Change : int):int =
        set CurrentGoal = Change

    GetCurrentValue():int =
        return CurrentValue

    SetCurrentValue(Change : int) : int =
        set CurrentValue = Change    
        