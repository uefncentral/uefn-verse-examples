# Sniperduel Minigame
# Verse code for Sniperduel Minigame - UEFN/Fortnite Creative implementation
# Difficulty: beginner  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/sniperduel-minigame?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

sniperduel_minigame := class(creative_device):

    @editable Teleporter1:teleporter_device = teleporter_device{}
    @editable Teleporter2:teleporter_device = teleporter_device{}
    
    @editable SniperGranter:item_granter_device = item_granter_device{}
    @editable SniperClass:class_and_team_selector_device = class_and_team_selector_device{}

    StartMinigame():void=
        Players:=GetPlayspace().GetPlayers()
        for(Player:Players):
            SniperGranter.GrantItem(Player)
            SniperClass.ChangeClass(Player)

        if(Player1:=Players[0]):
            Teleporter1.Teleport(Player1)

        if(Player2:=Players[1]):
            Teleporter2.Teleport(Player2)

    ResetMinigame():void=
        block: