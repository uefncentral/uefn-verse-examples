# Speed Minigame
# Verse code for Speed Minigame - UEFN/Fortnite Creative implementation
# Difficulty: beginner  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/speed-minigame?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

speed_minigame := class(creative_device):

    @editable SpeedZone:mutator_zone_device = mutator_zone_device{}

    OnBegin<override>():void=
        SpeedZone.Disable()

    StartMinigame():void=
        SpeedZone.Enable()
        if(TaggedObject := GetCreativeObjectsWithTag(UtilsTag{})[0], UtilsSystem := utils_system[TaggedObject]):
            UtilsSystem.GrantStandardItems()

    ResetMinigame():void=
        SpeedZone.Disable()