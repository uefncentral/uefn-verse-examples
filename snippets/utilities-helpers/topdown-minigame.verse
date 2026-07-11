# Topdown Minigame
# Verse code for Topdown Minigame - UEFN/Fortnite Creative implementation
# Difficulty: beginner  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/topdown-minigame?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

topdown_minigame := class(creative_device):

    @editable Camera:gameplay_camera_fixed_angle_device = gameplay_camera_fixed_angle_device{}
    @editable ThirdControl:gameplay_controls_third_person_device = gameplay_controls_third_person_device{}

    StartMinigame():void=
        Camera.AddToAll()
        ThirdControl.AddToAll()

        if(TaggedObject := GetCreativeObjectsWithTag(UtilsTag{})[0], UtilsSystem := utils_system[TaggedObject]):
            UtilsSystem.GrantStandardItems()

    ResetMinigame():void=
        Camera.RemoveFromAll()
        ThirdControl.RemoveFromAll()