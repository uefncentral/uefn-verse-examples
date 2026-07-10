# Blade Minigame
# Verse code for Blade Minigame - UEFN/Fortnite Creative implementation
# Difficulty: beginner  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/blade-minigame?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

blade_minigame := class(creative_device):

    @editable BladeClass:class_and_team_selector_device = class_and_team_selector_device{}
    @editable BladeRemover:item_remover_device = item_remover_device{}

    StartMinigame():void=
        Players:=GetPlayspace().GetPlayers()
        for(Player:Players):
            BladeClass.ChangeClass(Player)

    ResetMinigame():void=
        Players:=GetPlayspace().GetPlayers()
        if(Player1:=Players[0]):
            BladeRemover.Remove(Player1)  
        block: