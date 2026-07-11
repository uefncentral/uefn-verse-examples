# Player Stats Tracker
# This code creates a persistent player statistics system that tracks wins and losses for each player across game sessions. It uses Verse's persistable classes to maintain player data between matches an
# Difficulty: beginner  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/nn6n-game-sets-epic-playerstattrackersystem-player-stats-table?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# Tracks different persistable stats for each player.
player_stats_table := class<final><persistable>:
    # The version of the current stats table.
    Version:int = 0


    # The number of wins for a player.
    Wins:player_stat = player_stat{}

    # The number of losses for a player.
    Losses:player_stat = player_stat{}

# Creates a new player_stats_table with the same values as the previous player_stats_table.
MakePlayerStatsTable<constructor>(OldTable:player_stats_table)<transacts> := player_stats_table:
    Version := OldTable.Version
    Wins := OldTable.Wins
    Losses := OldTable.Losses

# Maps players to a table of their player stats.
var PlayerStatsMap:weak_map(player, player_stats_table) = map{}