# Crate System Manager
# A game manager that initializes and controls multiple crate controllers in the game. It prints a creator credit on startup and loops through all assigned crate controllers to initialize them.  **How t
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/madsmgrin-object-manipulation-scripts-cratesystem-gamemanager?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }

GameManager := class(creative_device):

    @editable _CrateController : []CrateController = array {}

    OnBegin<override>()<suspends>:void=
        Print("@GrinernCreates")

        for(crate : _CrateController):
            crate.Initialize()