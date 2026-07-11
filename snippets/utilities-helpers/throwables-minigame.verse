# Throwables Minigame
# Verse code for Throwables Minigame - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/throwables-minigame?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

throwables_minigame := class(creative_device):

    @editable ThrowableGranter:item_granter_device = item_granter_device{}

    var InProgress:logic = false

    StartMinigame():void=
        set InProgress = true

        Players:=GetPlayspace().GetPlayers()
        for(Player:Players):
            if(TaggedObject := GetCreativeObjectsWithTag(UtilsTag{})[0], UtilsSystem := utils_system[TaggedObject]):
                UtilsSystem.ClearPlayerItems(Player)
                ThrowableGranter.CycleToRandomItem(Player)
                ThrowableGranter.CycleToRandomItem(Player)
                ThrowableGranter.CycleToRandomItem(Player)
                ThrowableGranter.CycleToRandomItem(Player)
                ThrowableGranter.CycleToRandomItem(Player)

        spawn{MinigameLoop()}

    MinigameLoop()<suspends>:void=
        race:
            block:
                if(TaggedObject := GetCreativeObjectsWithTag(GameManagerTag{})[0], GameManager := game_manager[TaggedObject]):
                    GameManager.NewMinigameEvent.Await()
            block:
                Sleep(10.0)
                loop:
                    if(InProgress = false):
                        break

                    Players:=GetPlayspace().GetPlayers()
                    for(Player:Players):
                        ThrowableGranter.GrantItem(Player)

                    Sleep(5.0)

    ResetMinigame():void=
        set InProgress = false