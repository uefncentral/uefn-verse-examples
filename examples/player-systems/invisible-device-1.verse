# Conditional Player Visibility
# This code creates a system that hides or shows players based on whether they are holding a specific item. It continuously checks all players every second and toggles their visibility depending on thei
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/invisible-device-1?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }

test := class(creative_device):

    @editable conbtn: conditional_button_device = conditional_button_device{}

    OnBegin<override>()<suspends>:void=
        spawn{checkForCard()}

    checkForCard()<suspends>:void=
        loop:
            Sleep(1.0)
            AllPlayers := GetPlayspace().GetPlayers()
            for(Player:AllPlayers):
                if (IsAgent:agent=agent[Player]):
                    if (conbtn.IsHoldingItem[IsAgent]):
                        HideAgent(IsAgent)
                    else:
                        ShowAgent(IsAgent)
                

    HideAgent(Agent:agent):void=
        if(FC := Agent.GetFortCharacter[]):
            FC.Hide()
    ShowAgent(Agent:agent):void=
        if(FC := Agent.GetFortCharacter[]):
            FC.Show()
            