# Invisible 2
# Verse code for Invisible 2 - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/invisible-2-1?ref=github

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
