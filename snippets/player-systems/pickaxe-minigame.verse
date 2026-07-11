# Pickaxe Minigame
# Verse code for Pickaxe Minigame - UEFN/Fortnite Creative implementation
# Difficulty: beginner  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/pickaxe-minigame?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

pickaxe_minigame := class(creative_device):

    @editable PickaxeClass:class_and_team_selector_device = class_and_team_selector_device{}

    StartMinigame():void=
        Players:=GetPlayspace().GetPlayers()
        for(Player:Players):
            if(TaggedObject := GetCreativeObjectsWithTag(UtilsTag{})[0], UtilsSystem := utils_system[TaggedObject]):
                UtilsSystem.ClearPlayerItems(Player)
                PickaxeClass.ChangeClass(Player)

    ResetMinigame():void=
        block: