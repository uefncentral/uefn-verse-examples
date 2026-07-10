# Simple Item Granter
# A basic service class that grants items to players through an item granter device. When the HandleEvent method is called with an agent and item granter device, it immediately grants the specified item
# Difficulty: beginner  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/crateservice-1?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }

CrateService<public> := class<unique><concrete>():

    HandleEvent(Agent: agent, Reward: item_granter_device): void =
        Reward.GrantItem(Agent)