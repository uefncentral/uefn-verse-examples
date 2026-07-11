# XP Bonus Purchaser
# This system allows players to purchase XP bonuses using in-game currency if they meet level and money requirements. When successful, it plays audio/cinematic feedback and applies the XP bonus to the p
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/xp-bonus-buyer?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { player_class }
using { helpers.MyUtils }

xp_bonus_buyer := class(creative_device):

    var PlayerManager<public>:player_manager = player_manager{}
    var StatsManager<public> : stats_manager = stats_manager{}
    var LevelManager<public> : level_manager = level_manager{} 

    @editable Button : button_device = button_device{}
    @editable HUDFailXP : hud_message_device = hud_message_device{}
    @editable HUDFailMoney : hud_message_device = hud_message_device{}
    @editable SoundFX : audio_player_device = audio_player_device{}
    @editable CineamticDevice : cinematic_sequence_device = cinematic_sequence_device{}
    @editable LvlNeeded : int = 0
    @editable XPBonus : int = 0
    @editable MoneyNeeded : int = 0

    OnBegin<override>()<suspends>:void=
        Button.InteractedWithEvent.Subscribe(OnButton)

    OnButton(Agent:agent):void=
        AllPlayerInfos := PlayerManager.GetPlayers()
        PlayersLevel := StatsManager.GetStat("Level",Agent)
        PlayersCoins := StatsManager.GetStat("Coins",Agent)
        if (PlayersLevel >= LvlNeeded, PlayersCoins >= MoneyNeeded):
            SoundFX.Play(Agent)
            CineamticDevice.Play(Agent)
            for (API : AllPlayerInfos):
                if (API.AgentRef = Agent):
                    set API.XPBonus = XPBonus
                    LevelManager.UpdateRankHUD(Agent)
        else if(PlayersCoins < MoneyNeeded):
            Print("NOT ENOUGH MONEY")
            HUDFailMoney.Show(Agent)
        else if(PlayersLevel < LvlNeeded):
            Print("NOT HIGH ENOUGH LVL")
            HUDFailXP.Show(Agent)