# Balloon Minigame
# Verse code for Balloon Minigame - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/balloon-minigame?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

balloon_minigame := class(creative_device):

    @editable Holder:creative_prop = creative_prop{}
    @editable StartPoint:creative_prop = creative_prop{}
    @editable EndPoint:creative_prop = creative_prop{}

    @editable PM:prop_manipulator_device = prop_manipulator_device{}

    @editable MinigameItems:item_granter_device = item_granter_device{}
    @editable Timer:timer_device = timer_device{}

    @editable Teleport1:teleporter_device = teleporter_device{}
    @editable Teleport2:teleporter_device = teleporter_device{}

    StartMinigame():void=
        spawn{MinigameLoop()}

    MinigameLoop()<suspends>:void=
        race:
            block:
                if(TaggedObject := GetCreativeObjectsWithTag(GameManagerTag{})[0], GameManager := game_manager[TaggedObject]):
                    GameManager.NewMinigameEvent.Await()
            block:
                Players:=GetPlayspace().GetPlayers()
                for(Player:Players):
                    MinigameItems.GrantItem(Player)

                if(Player1:=Players[0]):
                    Teleport1.Teleport(Player1)

                if(Player2:=Players[1]):
                    Teleport2.Teleport(Player2)

                Timer.Start()
                Sleep(5.0)
                PM.HideProps()

    ResetMinigame():void=
        PM.ShowProps()