# Build Reset On Elimination
# This device automatically triggers an explosion at a player's location when they are eliminated, then resets the explosive device for the next use. It's designed to clear player-built structures upon 
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/resetonelimination?ref=github

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