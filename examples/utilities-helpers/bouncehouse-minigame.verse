# Bouncehouse Minigame
# Verse code for Bouncehouse Minigame - UEFN/Fortnite Creative implementation
# Difficulty: beginner  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/bouncehouse-minigame?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

bouncehouse_minigame := class(creative_device):

    @editable Teleporter1:teleporter_device = teleporter_device{}
    @editable Teleporter2:teleporter_device = teleporter_device{}

    StartMinigame():void=
        Players:=GetPlayspace().GetPlayers()
        if(Player1:=Players[0]):
            Teleporter1.Teleport(Player1)

        if(Player2:=Players[1]):
            Teleporter2.Teleport(Player2)

        if(TaggedObject := GetCreativeObjectsWithTag(UtilsTag{})[0], UtilsSystem := utils_system[TaggedObject]):
            UtilsSystem.GrantStandardItems()

    ResetMinigame():void=
        block: