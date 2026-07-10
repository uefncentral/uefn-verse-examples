# Player Stats Manager
# A centralized system for managing player statistics including coins, scores, levels, and playtime. Provides methods to get, set, and add values to various player stats through a unified interface.  **
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/stats-manager?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Game }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation/Tags }
using { player_class }
using { helpers.MyUtils }

stats_manager := class(creative_device):    

    var PlayerManager<public>:player_manager = player_manager{}

    GetStat(Stat:string, Agent:agent):int=
        if(PlayerStats:=PlayerManager.GetPlayerStats[Agent]):
            if(Stat = "Coins"):
                return PlayerStats.Coins
            else if(Stat = "HighScore"):
                return PlayerStats.HighScore
            else if(Stat = "AllTimeScore"):
                return PlayerStats.AllTimeScore
            else if(Stat = "Playtime"):
                return PlayerStats.Playtime
            else if(Stat = "Score"):
                return PlayerStats.Score
            else if(Stat = "Level"):
                return PlayerStats.Level
        return 0

    SetStat(Agent:agent, Stat:string, Value:int):void=
        if(PlayerStats:=PlayerManager.GetPlayerStats[Agent]):
            PlayerManager.SetPlayerStat(Agent, Stat, Value)

    AddStat(Agent:agent, Stat:string, Value:int):void=
        if(PlayerStats:=PlayerManager.GetPlayerStats[Agent]):
            PlayerManager.RecordPlayerStat(Agent, Stat, ?Value:=Value)

