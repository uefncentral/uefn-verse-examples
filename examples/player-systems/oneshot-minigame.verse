# Oneshot Minigame
# Verse code for Oneshot Minigame - UEFN/Fortnite Creative implementation
# Difficulty: beginner  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/oneshot-minigame?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

oneshot_minigame := class(creative_device):

    @editable OneShotWeapons:item_granter_device = item_granter_device{}
    @editable OneShotConsumables:item_granter_device = item_granter_device{}
    @editable OneShotClass:class_and_team_selector_device = class_and_team_selector_device{}

    StartMinigame():void=
        Players:=GetPlayspace().GetPlayers()
        for(Player:Players):
            OneShotClass.ChangeClass(Player)
            OneShotWeapons.CycleToRandomItem(Player)
            OneShotWeapons.CycleToRandomItem(Player)
            OneShotWeapons.CycleToRandomItem(Player)
            OneShotWeapons.CycleToRandomItem(Player)
            OneShotConsumables.GrantItem(Player)

    ResetMinigame():void=
        block: