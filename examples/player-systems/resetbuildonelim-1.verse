# Build Reset on Elimination
# Automatically triggers an explosion and resets it whenever a player is eliminated. This creates a visual effect that occurs each time a player dies in the game.  **How to use:** Place the Build_Reset 
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/resetbuildonelim-1?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Playspaces }
using { /Verse.org/Simulation }
using { /Verse.org/Verse }


Build_Reset := class(creative_device):

    @editable
    IgniteExplosion:explosive_device = explosive_device{}

    @editable
    Elim : elimination_manager_device = elimination_manager_device{}



    OnBegin<override>()<suspends>:void=
 
        Elim.EliminatedEvent.Subscribe(ResetBuilds)

    ResetBuilds(InPlayer:agent):void=
        IgniteExplosion.Explode(InPlayer)
        IgniteExplosion.Reset()