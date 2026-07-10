# Invisible Minigame
# Verse code for Invisible Minigame - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/invisible-minigame?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Fortnite.com/Characters }

invisible_minigame := class(creative_device):

    @editable CardDetector:conditional_button_device = conditional_button_device{}
    @editable CardGranter:item_granter_device = item_granter_device{}

    var InProgress:logic = false

    OnBegin<override>()<suspends>:void=
        spawn{CheckForCard()}

    StartMinigame():void=
        if(TaggedObject := GetCreativeObjectsWithTag(UtilsTag{})[0], UtilsSystem := utils_system[TaggedObject]):
            UtilsSystem.GrantStandardItems()

        Players:=GetPlayspace().GetPlayers()
        for(Player:Players):
            CardGranter.GrantItem(Player)

    CheckForCard()<suspends>:void=
        loop:
            Sleep(0.5)
            AllPlayers:=GetPlayspace().GetPlayers()
            for(Player:AllPlayers):
                if(IsAgent:agent = agent[Player]):
                    if(CardDetector.IsHoldingItem[IsAgent]):
                        HidePlayer(IsAgent)
                    else:
                        ShowPlayer(IsAgent)

    ShowPlayer(Agent:agent):void=
        if(FC:=Agent.GetFortCharacter[]):
            FC.Show()

    HidePlayer(Agent:agent):void=
        if(FC:=Agent.GetFortCharacter[]):
            FC.Hide()

    ResetMinigame():void=
        block: