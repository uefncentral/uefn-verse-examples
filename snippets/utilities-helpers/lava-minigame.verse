# Lava Minigame
# Verse code for Lava Minigame - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/lava-minigame?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

lava_minigame := class(creative_device):

    @editable Lava:creative_prop = creative_prop{}
    @editable StartPoint:creative_prop = creative_prop{}
    @editable EndPoint:creative_prop = creative_prop{}

    @editable LavaSpeed:float = 100.0

    StartMinigame():void=
        if(TaggedObject := GetCreativeObjectsWithTag(UtilsTag{})[0], UtilsSystem := utils_system[TaggedObject]):
            UtilsSystem.GrantStandardItems()

        StartLocation:=StartPoint.GetTransform()
        EndLocation:=EndPoint.GetTransform()
        if(Lava.TeleportTo[StartLocation]):
            spawn{Lava.MoveTo(EndLocation, LavaSpeed)}

    ResetMinigame():void=
        StartLocation:=StartPoint.GetTransform()
        if(Lava.TeleportTo[StartLocation]):
            Print("Minigame Reset")