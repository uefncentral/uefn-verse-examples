# Crate Service.verse
# Verse code for Crate Service.verse - UEFN/Fortnite Creative implementation
# Difficulty: beginner  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/crate-serviceverse?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }

CrateService<public> := class<unique><concrete>():

    HandleEvent(Agent: agent, Reward: item_granter_device): void =
        Reward.GrantItem(Agent)