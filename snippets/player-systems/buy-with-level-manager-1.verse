# Level-Gated Purchase System
# Creates a button interaction system that checks if a player meets a minimum level requirement before allowing a purchase or action. If the player's level is insufficient, it displays a failure message
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/buy-with-level-manager-1?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { player_class }
using { helpers.MyUtils }

buy_with_level_manager := class(creative_device):

    var StatsManager<public> : stats_manager = stats_manager{}

    @editable Button : button_device = button_device{}
    @editable HUDFailXP : hud_message_device = hud_message_device{}
    @editable LvlNeeded : int = 0
    

    OnBegin<override>()<suspends>:void=
        Button.InteractedWithEvent.Subscribe(OnConditionalButton)

    OnConditionalButton(Agent:agent):void=
        PlayersLevel := StatsManager.GetStat("Level",Agent)
        if (PlayersLevel >= LvlNeeded):
            Print("DO STUFF HERE")
        else:
            Print("NOT HIGH ENOUGH LVL")
            HUDFailXP.Show(Agent)