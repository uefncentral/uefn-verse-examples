# Explosivedevice
# Verse code for Explosivedevice - UEFN/Fortnite Creative implementation
# Difficulty: intermediate  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/explosivedevice?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Playspaces }
using { /Verse.org/Simulation }
using { /Verse.org/Verse }

Build_Reset := class(creative_device):

    @editable
    Explosions: []explosive_device = array{}

    @editable
    Elim: elimination_manager_device = elimination_manager_device{}

    OnBegin<override>()<suspends>:void =
        Elim.EliminatedEvent.Subscribe(ResetBuildsOnElim)

    ResetBuildsOnElim(InPlayer: agent): void =
        for (AllExplosions: Explosions):
            AllExplosions.Explode(InPlayer)
            AllExplosions.Reset()