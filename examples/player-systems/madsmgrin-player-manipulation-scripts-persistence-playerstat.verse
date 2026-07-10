# Player Stats System
# Creates a persistable data structure for tracking player statistics including example and money values. Includes a constructor function to duplicate existing player stat tables while maintaining all p
# Difficulty: beginner  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/madsmgrin-player-manipulation-scripts-persistence-playerstats?ref=github

# Define a class for storing player stats
player_stats_table := class<final><persistable>:
    Example: int = 0
    Money: int = 0

# Define a constructor function to create a new player_stats_table from an existing one
MakePlayerStatsTable<constructor>(OldTable:player_stats_table)<transacts> := player_stats_table:
    Example := OldTable.Example
    Money := OldTable.Money