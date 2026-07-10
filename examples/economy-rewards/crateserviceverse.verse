# Crate Reward System
# A simple service class that handles reward distribution by granting items to players through an item granter device. When an event occurs involving a player and a reward crate, it automatically gives 
# Difficulty: beginner  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/crateserviceverse?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }

CrateService<public> := class<unique><concrete>():

    HandleEvent(Agent: agent, Reward: item_granter_device): void =
        Reward.GrantItem(Agent)