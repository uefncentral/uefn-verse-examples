# Item Reward Service
# A simple service class that handles rewarding players with items through an item granter device. When an event occurs involving a player, it automatically grants the specified item to that player.  **
# Difficulty: beginner  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/madsmgrin-object-manipulation-scripts-cratesystem-crateservice?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }

CrateService<public> := class<unique><concrete>():

    HandleEvent(Agent: agent, Reward: item_granter_device): void =
        Reward.GrantItem(Agent)