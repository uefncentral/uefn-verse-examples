# Build Reset On Elimination
# Automatically triggers explosive devices to destroy player builds when a player is eliminated. The explosives then reset themselves, ready for the next elimination event.  **How to use:** Place the Bu
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/resetbuildsonelim?ref=github

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

    @editable
    Timer: timer_device = timer_device{}
    
    OnBegin<override>()<suspends>:void =
        Elim.EliminatedEvent.Subscribe(ResetBuildsOnElim)
   
    ResetBuildsOnElim(InPlayer: agent): void =
        for (AllExplosions: Explosions):
            AllExplosions.Explode(InPlayer)
            AllExplosions.Reset()