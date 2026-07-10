# Impulse Minigame
# Verse code for Impulse Minigame - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/impulse-minigame?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

impulse_minigame := class(creative_device):

    @editable Teleporter1:teleporter_device = teleporter_device{}
    @editable Teleporter2:teleporter_device = teleporter_device{}
    
    @editable ImpulseGranter:item_granter_device = item_granter_device{}
    @editable ImpulseClass:class_and_team_selector_device = class_and_team_selector_device{}

    @editable Timer1:timer_device = timer_device{}
    @editable Timer2:timer_device = timer_device{}

    var InProgress:logic = false

    StartMinigame():void=
        set InProgress = true

        Players:=GetPlayspace().GetPlayers()
        for(Player:Players):
            if(TaggedObject := GetCreativeObjectsWithTag(UtilsTag{})[0], UtilsSystem := utils_system[TaggedObject]):
                UtilsSystem.ClearPlayerItems(Player)

            ImpulseClass.ChangeClass(Player)

        if(Player1:=Players[0]):
            Teleporter1.Teleport(Player1)

        if(Player2:=Players[1]):
            Teleporter2.Teleport(Player2)

        spawn{MinigameLoop()}

    
    MinigameLoop()<suspends>:void=
        race:
            block:
                if(TaggedObject := GetCreativeObjectsWithTag(GameManagerTag{})[0], GameManager := game_manager[TaggedObject]):
                    GameManager.NewMinigameEvent.Await()
            block:
                Timer1.Start()
                Sleep(5.0)
                loop:
                    if(InProgress = false):
                        break

                    Players:=GetPlayspace().GetPlayers()
                    for(Player:Players):
                        ImpulseGranter.GrantItem(Player)

                    Timer2.Start()
                    Sleep(5.0)

    ResetMinigame():void=
        set InProgress = false
        Timer1.Reset()
        Timer2.Reset()