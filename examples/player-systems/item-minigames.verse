# Item Minigames
# Verse code for Item Minigames - UEFN/Fortnite Creative implementation
# Difficulty: intermediate  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/item-minigames?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

item_minigames := class(creative_device):
    @editable BladeItems:item_granter_device = item_granter_device{}
    @editable MythicItems:item_granter_device = item_granter_device{}
    @editable ExplosiveItems:item_granter_device = item_granter_device{}
    @editable ExoticItems:item_granter_device = item_granter_device{}
    @editable FishFightItems:item_granter_device = item_granter_device{}
    @editable OGItems:item_granter_device = item_granter_device{}
    @editable PrimalItems:item_granter_device = item_granter_device{}
    @editable CubedItems:item_granter_device = item_granter_device{}

    StartBlade():void=
        Players:=GetPlayspace().GetPlayers()
        for(Player:Players):
            BladeItems.GrantItem(Player)

    StartMythic():void=
        Players:=GetPlayspace().GetPlayers()
        for(Player:Players):
            MythicItems.CycleToRandomItem(Player)
            MythicItems.CycleToRandomItem(Player)
            MythicItems.CycleToRandomItem(Player)
            MythicItems.CycleToRandomItem(Player)
            MythicItems.CycleToRandomItem(Player)

    StartExplosive():void=
        Players:=GetPlayspace().GetPlayers()
        for(Player:Players):
            ExplosiveItems.GrantItem(Player)

    StartExotic():void=
        Players:=GetPlayspace().GetPlayers()
        for(Player:Players):
            ExoticItems.GrantItem(Player)

    StartFishFight():void=
        Players:=GetPlayspace().GetPlayers()
        for(Player:Players):
            FishFightItems.GrantItem(Player)

    StartOG():void=
        Players:=GetPlayspace().GetPlayers()
        for(Player:Players):
            OGItems.CycleToRandomItem(Player)
            OGItems.CycleToRandomItem(Player)
            OGItems.CycleToRandomItem(Player)
            OGItems.CycleToRandomItem(Player)
            OGItems.CycleToRandomItem(Player)

    StartPrimal():void=
        Players:=GetPlayspace().GetPlayers()
        for(Player:Players):
            PrimalItems.CycleToRandomItem(Player)
            PrimalItems.CycleToRandomItem(Player)
            PrimalItems.CycleToRandomItem(Player)
            PrimalItems.CycleToRandomItem(Player)
            PrimalItems.CycleToRandomItem(Player)

    StartCubed():void=
        Players:=GetPlayspace().GetPlayers()
        for(Player:Players):
            CubedItems.CycleToRandomItem(Player)
            CubedItems.CycleToRandomItem(Player)
            CubedItems.CycleToRandomItem(Player)
            CubedItems.CycleToRandomItem(Player)
            CubedItems.CycleToRandomItem(Player)

    ResetMinigame():void=
        block: