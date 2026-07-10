# Auto Item Equipper
# This code automatically ensures a player always has a specific item equipped. It continuously monitors if the player is holding the required item and grants it again if they drop, use, or lose it.  **
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/item-extensions-1?ref=github

using { SimulationExtensions }
using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }

ItemExtensions<public> := module:
    equipper<public> := class(monitorable):
        Granter<public>:item_granter_device
        Checker<public>:conditional_button_device
        Player<public>:player

        Update<override>():void =
            if (not Checker.IsHoldingItem[Player]):
                Granter.GrantItem(Player)
