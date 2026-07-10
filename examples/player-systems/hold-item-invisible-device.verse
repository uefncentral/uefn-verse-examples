# Item Hold Invisibility
# This code monitors all players and automatically makes them invisible when they hold a specific item, and visible again when they drop or stop holding it. The visibility state is continuously checked 
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/hold-item-invisible-device?ref=github


using { /Fortnite.com/Devices }
using { /Fortnite.com/Game }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

hold_item_invisible_device := class(creative_device):

    @editable
    CheckforItem:conditional_button_device = conditional_button_device{}

    @editable
    ConditionalButton:conditional_button_device = conditional_button_device{}

    @editable
    PlayerSpawner: []player_spawner_device = array{}



    OnBegin<override>()<suspends>:void=
 
        spawn:
            CheckForCard()

        
    CheckForCard()<suspends>:void=
        loop:
            Sleep(1.0)
            AllPlayers:=GetPlayspace().GetPlayers()
            for(Player:AllPlayers):
                if(IsAgent:agent = agent[Player]):
                    if(CheckforItem.IsHoldingItem[IsAgent]):
                        Print("Holding Item")
                        HidePlayer(IsAgent)
                    else:
                        Print("Not holding Item")
                        ShowPlayer(IsAgent)

    ShowPlayer(Agent:agent):void=
        if(FC:=Agent.GetFortCharacter[]):
            FC.Show()

    HidePlayer(Agent:agent):void=
        if(FC:=Agent.GetFortCharacter[]):
            FC.Hide()