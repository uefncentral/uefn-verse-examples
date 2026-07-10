# Card-Based Player Invisibility
# This code creates a stealth mechanic that continuously monitors all players and makes them invisible when they hold a specific item (card) detected by a conditional button device. Players become visib
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/invisible-1?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }

game_manager := class(creative_device):

    @editable
    CardDetector:conditional_button_device = conditional_button_device{}
    @editable
    PlayerSpawner : player_spawner_device = player_spawner_device{}
    @editable
    CondButton:conditional_button_device = conditional_button_device{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=

        spawn:

            CheckForCard()

    CheckForCard()<suspends>:void=
        loop:
            Sleep(1.0)
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
