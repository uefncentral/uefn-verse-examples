# XP Achievement System
# Defines a flexible experience point system with achievement types (Pair, Round, Streak, Time) and a closure class for granting achievements to players. The system uses function pointers to allow custo
# Difficulty: beginner  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/xp-extensions-2?ref=github

using { /Verse.org/Simulation }

XPExtensions<public> := module:
    achievement<public> := enum{Pair, Round, Streak, Time}

    xp_closure<public> := class:
        Func<public>:type{_(:player, :achievement):void}
        Player<public>:player
        Achievement<public>:achievement

        Grant<public>():void =
            Func(Player, Achievement)
