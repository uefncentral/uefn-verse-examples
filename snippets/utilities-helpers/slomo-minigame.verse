# Slomo Minigame
# Verse code for Slomo Minigame - UEFN/Fortnite Creative implementation
# Difficulty: beginner  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/slomo-minigame?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

slomo_minigame := class(creative_device):

    @editable SlomoSequence:cinematic_sequence_device = cinematic_sequence_device{}

    StartMinigame():void=
        if(TaggedObject := GetCreativeObjectsWithTag(UtilsTag{})[0], UtilsSystem := utils_system[TaggedObject]):
            UtilsSystem.GrantStandardItems()

        SlomoSequence.Play()

    ResetMinigame():void=
        SlomoSequence.Stop()