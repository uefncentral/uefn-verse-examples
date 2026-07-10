# Player Stats Persistence System
# Creates a persistent data storage system for player statistics and purchases in a game. The code defines classes to store and manage player currency (money, resources), purchased items (pets, doors, a
# Difficulty: beginner  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/playerstatmap?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/UI }

#THIS CODE IS A TABLE FOR ALL PLAYER STAT PERSISTENCE

player_stat := class<final><persistable>:
    CurrentValue:int = 0

    SetHighestValue(NewValue:int)<transacts>:int=
        CurrentValue

MakeUpdatedPlayerStat<constructor>(OldStats:player_stat, NewValue:int)<transacts> := player_stat:
    CurrentValue := NewValue



player_stats_table := class<final><persistable>:

    BoughtPets : []int = array {}
    BoughtDoors : []int = array {}
    BoughtApparels : []int = array {}
    MoneyAmount: float = 0.0
    IdleMoneyAmount : float = 0.0
    Resource2Amount : float = 0.0
    IdleResource2Amount : float = 0.0
    RebirthAmount : float = 0.0
    



var PlayerStatsMap:weak_map(player, player_stats_table) = map{}

MakePlayerStatsTable<constructor>(OldTable:player_stats_table)<transacts> := player_stats_table:
    MoneyAmount := OldTable.MoneyAmount
    IdleMoneyAmount := OldTable.IdleMoneyAmount
    Resource2Amount := OldTable.Resource2Amount
    IdleResource2Amount := OldTable.IdleResource2Amount
    BoughtPets := OldTable.BoughtPets
    BoughtDoors := OldTable.BoughtDoors
    BoughtApparels := OldTable.BoughtApparels
    RebirthAmount := OldTable.RebirthAmount


