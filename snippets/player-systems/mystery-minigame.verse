# Mystery Minigame
# Verse code for Mystery Minigame - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/mystery-minigame?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

mystery_minigame := class(creative_device):

    var InProgress:logic = false

    @editable RandomItem:item_granter_device = item_granter_device{}
    @editable RemoveItem:item_remover_device = item_remover_device{}
    @editable Timer:timer_device = timer_device{}

    StartMinigame():void=
        set InProgress = true
        spawn{MinigameLoop()}

    MinigameLoop()<suspends>:void=
        race:
            block:
                if(TaggedObject := GetCreativeObjectsWithTag(GameManagerTag{})[0], GameManager := game_manager[TaggedObject]):
                    GameManager.NewMinigameEvent.Await()
            block:
                Timer.Start()

                loop:
                    if(InProgress = false):
                        break

                    Players:=GetPlayspace().GetPlayers()
                    for(Player:Players):
                        RandomItem.CycleToRandomItem(Player)
                        RandomItem.CycleToRandomItem(Player)
                        RandomItem.CycleToRandomItem(Player)
                        RandomItem.CycleToRandomItem(Player)
                        RandomItem.CycleToRandomItem(Player)

                    Sleep(15.0)

                    for(Player:Players):
                        if(InProgress = true):
                            RemoveItem.Remove(Player)

    ResetMinigame():void=
        set InProgress = false
        Timer.Reset()