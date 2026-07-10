# Player Statistics Tracker
# A comprehensive player data management system that tracks kills, deaths, wins, losses, kill streaks, nukes, and calculates ratios and rankings. It stores persistent player statistics and provides meth
# Difficulty: beginner  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/customplayerdata-1?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

CustomPlayerData := class<public>():
    var Rank : int = 0
    var TotalScore : int = 0
    var TotalKills : int = 0
    var TotalDeaths : int = 0
    var KillDeathRatio : float = 0.0
    var TotalWins : int = 0
    var TotalRounds : int = 0
    var TotalLosses : int = 0
    var WinLossRatio : float = 0.0
    var TotalNukes : int = 0
    var KillStreak : int = 0
    var RankScore :int = 0
    var CurrentRank :int = 0
    var KillUI : hud_message_device = hud_message_device{}
    var KillPoints :score_manager_device = score_manager_device{}
    var DeathPoints :score_manager_device = score_manager_device{}
    var HasUI :logic = false
    var RankRange : []int = array{}
    var RankUp : logic = false
    var RankPercent : float = 0.0

    GetRank() : int=
        return Rank
    GetTotalScore(Player : agent) : int=
        return TotalScore
    GetTotalKills() : int=
        return TotalKills
    GetTotalDeaths() : int=
        return TotalDeaths
    GetKillDeathRatio() : float=
        TotalKillsFloat := TotalKills *1.0
        TotalDeathsFloat := TotalDeaths *1.0
        set KillDeathRatio = TotalKillsFloat / TotalDeathsFloat
        return KillDeathRatio
    GetTotalWins() : int=
        return TotalWins
    GetTotalRounds() : int=
        return TotalRounds
    GetTotalLosses() : int=
        set TotalLosses = TotalRounds - TotalWins
        return TotalLosses
    GetWinLossRatio() : float=
        GetTotalLosses()
        TotalWinsFloat := TotalWins *1.0
        TotalLossesFloat := TotalLosses *1.0
        set WinLossRatio = TotalWinsFloat / TotalLossesFloat
        return WinLossRatio
    GetTotalNukes() : int=
        return TotalNukes
    GetKillStreak() : int=
        return KillStreak
    