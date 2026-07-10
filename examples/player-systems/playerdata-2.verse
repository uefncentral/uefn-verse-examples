# Player Coin Teleporter Tracker
# This code defines a player data structure that tracks coins collected by each player and associates them with a teleporter device. It appears to be the foundation for a system where teleporter access 
# Difficulty: beginner  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/playerdata-2?ref=github

using { /Fortnite.com/Devices }

PlayerData := class:
    var Teleporter : teleporter_device = teleporter_device {}
    var CoinsCollected : int = 0