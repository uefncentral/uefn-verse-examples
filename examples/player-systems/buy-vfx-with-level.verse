# Level-Gated VFX Purchase
# A system that allows players to purchase visual effects and unlock content only if they meet a minimum level requirement. When activated, it grants VFX powerups, removes barriers, plays cinematics and
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/buy-vfx-with-level?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { player_class }
using { helpers.MyUtils }

buy_vfx_with_level := class(creative_device):

    var StatsManager<public> : stats_manager = stats_manager{}

    @editable Button : button_device = button_device{}
    @editable BarrierToOpen : barrier_device = barrier_device{}
    @editable HUDFailXP : hud_message_device = hud_message_device{}
    @editable VFXPowerUp : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable CineamticDevice : cinematic_sequence_device = cinematic_sequence_device{}
    @editable SoundFX : audio_player_device = audio_player_device{}
    @editable LvlNeeded : int = 0
    
    OnBegin<override>()<suspends>:void=
        Button.InteractedWithEvent.Subscribe(OnConditionalButton)

    OnConditionalButton(Agent:agent):void=
        PlayersLevel := StatsManager.GetStat("Level",Agent)
        if (PlayersLevel >= LvlNeeded):
            Print("DO STUFF HERE")
            VFXPowerUp.Pickup(Agent)
            BarrierToOpen.AddToIgnoreList(Agent)
            CineamticDevice.Play(Agent)
            SoundFX.Play(Agent)
        else:
            Print("NOT HIGH ENOUGH LVL")
            HUDFailXP.Show(Agent)