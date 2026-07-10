# Boggiedown Minigame
# Verse code for Boggiedown Minigame - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/boggiedown-minigame?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

boggiedown_minigame := class(creative_device):

    @editable BoggieGranter:item_granter_device = item_granter_device{}

    var InProgress:logic = false

    StartMinigame():void=
        set InProgress = true

        Players:=GetPlayspace().GetPlayers()
        if(TaggedObject := GetCreativeObjectsWithTag(UtilsTag{})[0], UtilsSystem := utils_system[TaggedObject], Player1:=Players[0], Player2:=Players[1]):
            UtilsSystem.ClearPlayerItems(Player1)
            UtilsSystem.ClearPlayerItems(Player2)
            UtilsSystem.GrantStandardItems()
            for(Player:Players):
                BoggieGranter.CycleToRandomItem(Player)
                BoggieGranter.CycleToRandomItem(Player)
                BoggieGranter.CycleToRandomItem(Player)

        spawn{MinigameLoop()}

    
    MinigameLoop()<suspends>:void=
        Sleep(10.0)
        loop:
            if(InProgress = false):
                break

            Players:=GetPlayspace().GetPlayers()
            for(Player:Players):
                BoggieGranter.CycleToRandomItem(Player)

            Sleep(5.0)

    ResetMinigame():void=
        set InProgress = false