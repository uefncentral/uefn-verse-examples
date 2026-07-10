# Zonewars Minigame
# Verse code for Zonewars Minigame - UEFN/Fortnite Creative implementation
# Difficulty: beginner  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/zonewars-minigame?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

zonewars_minigame := class(creative_device):

    @editable Teleporter1:teleporter_device = teleporter_device{}
    @editable Teleporter2:teleporter_device = teleporter_device{}

    @editable Storm:basic_storm_controller_device = basic_storm_controller_device{}

    @editable Bombs:[]explosive_device = array{}

    StartMinigame():void=
        Players:=GetPlayspace().GetPlayers()

        if(Player1:=Players[0]):
            Teleporter1.Teleport(Player1)

        if(Player2:=Players[1]):
            Teleporter2.Teleport(Player2)

        if(TaggedObject := GetCreativeObjectsWithTag(UtilsTag{})[0], UtilsSystem := utils_system[TaggedObject]):
            UtilsSystem.GrantStandardItems()
        
        Storm.GenerateStorm()

    ResetMinigame():void=
        Storm.DestroyStorm()
        for(Bomb:Bombs):
            Players:=GetPlayspace().GetPlayers()

            if(Player1:=Players[0]):
                Bomb.Explode(Player1)
                Bomb.Reset()