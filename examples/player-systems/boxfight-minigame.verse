# Boxfight Minigame
# Verse code for Boxfight Minigame - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/boxfight-minigame?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

boxfight_minigame := class(creative_device):

    @editable Teleporter1:teleporter_device = teleporter_device{}
    @editable Teleporter2:teleporter_device = teleporter_device{}
    
    @editable BoxFightClass:class_and_team_selector_device = class_and_team_selector_device{}
    @editable BoxFightItems:item_granter_device = item_granter_device{}

    @editable BrickBarrier:barrier_device = barrier_device{}
    @editable BoundBarrier:barrier_device = barrier_device{}

    @editable BuildsBomb:explosive_device = explosive_device{}

    @editable Timer:timer_device = timer_device{}

    StartMinigame():void=
        spawn{MinigameLoop()}

    MinigameLoop()<suspends>:void=
        Timer.Start()
        
        Players:=GetPlayspace().GetPlayers()
        for(Player:Players):
            BoxFightClass.ChangeClass(Player)
            BoxFightItems.GrantItem(Player)

        if(Player1:=Players[0], Player2:=Players[1]):
            Teleporter1.Teleport(Player1)
            Teleporter2.Teleport(Player2)

        Sleep(3.0)
        BrickBarrier.Disable()
        BoundBarrier.Disable()

    ResetMinigame():void=
        BuildsBomb.Reset()
        Players:=GetPlayspace().GetPlayers()
        if(Player1:=Players[0]):
            BuildsBomb.Explode(Player1)
            BrickBarrier.Enable()
            BoundBarrier.Enable()