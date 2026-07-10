# Costum Weapon
# Verse code for Costum Weapon - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/costum-weapon?ref=github

using { /Fortnite.com/Playspaces }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Teams }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Game }
using { /Verse.org/Simulation }
using { /Verse.org/Verse }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

CustomGun := class(creative_device):

    var Players : []player = array{}

    @editable var CustomGunEffect1 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var ClearCustomGunEffect1 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var TargetGun1 : conditional_button_device = conditional_button_device{}
    @editable var CustomGunEffect2 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var ClearCustomGunEffect2 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var TargetGun2 : conditional_button_device = conditional_button_device{}
    @editable var CustomGunEffect3 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var ClearCustomGunEffect3 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var TargetGun3 : conditional_button_device = conditional_button_device{}
    OnBegin<override>()<suspends>:void=
        set Players = GetPlayspace().GetPlayers() # assign all current player to array
        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerAdded)
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerRemoved)
        spawn:
            CheckCustomGun()

    OnPlayerAdded(Agent:agent):void=
        set Players = GetPlayspace().GetPlayers() # assign all current player to array
    OnPlayerRemoved(Agent:agent):void=
        set Players = GetPlayspace().GetPlayers() # assign all current player to array

    CheckCustomGun()<suspends>:void=
        loop:
            Sleep(0.0)
            for (Player:Players):
                if (TargetGun1.IsHoldingItem[Player]):
                    CustomGunEffect1.Pickup(Player)
                else if (TargetGun2.IsHoldingItem[Player]):
                    CustomGunEffect2.Pickup(Player)
                else if (TargetGun3.IsHoldingItem[Player]):
                    CustomGunEffect3.Pickup(Player)
                else:
                    ClearCustomGunEffect1.Pickup(Player)
                    ClearCustomGunEffect2.Pickup(Player)
                    ClearCustomGunEffect3.Pickup(Player)