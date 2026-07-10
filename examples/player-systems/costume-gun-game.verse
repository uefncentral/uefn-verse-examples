# Costume Gun Game
# Verse code for Costume Gun Game - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/costume-gun-game?ref=github

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
    @editable var CustomGunEffect4 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var ClearCustomGunEffect4 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var TargetGun4 : conditional_button_device = conditional_button_device{}
    @editable var CustomGunEffect5 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var ClearCustomGunEffect5 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var TargetGun5 : conditional_button_device = conditional_button_device{}
    @editable var CustomGunEffect6 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var ClearCustomGunEffect6 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var TargetGun6 : conditional_button_device = conditional_button_device{}
    @editable var CustomGunEffect7 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var ClearCustomGunEffect7 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var TargetGun7 : conditional_button_device = conditional_button_device{}
    @editable var CustomGunEffect8 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var ClearCustomGunEffect8 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var TargetGun8  : conditional_button_device = conditional_button_device{}
    @editable var CustomGunEffect9 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var ClearCustomGunEffect9 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var TargetGun9  : conditional_button_device = conditional_button_device{}
    @editable var CustomGunEffect10 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var ClearCustomGunEffect10 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var TargetGun10 : conditional_button_device = conditional_button_device{}
    @editable var CustomGunEffect11 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var ClearCustomGunEffect11 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var TargetGun11 : conditional_button_device = conditional_button_device{}
    @editable var CustomGunEffect12 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var ClearCustomGunEffect12 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var TargetGun12 : conditional_button_device = conditional_button_device{}
    @editable var CustomGunEffect13 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var ClearCustomGunEffect13 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var TargetGun13 : conditional_button_device = conditional_button_device{}
    @editable var CustomGunEffect14 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var ClearCustomGunEffect14 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var TargetGun14 : conditional_button_device = conditional_button_device{}
    @editable var CustomGunEffect15 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var ClearCustomGunEffect15 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var TargetGun15 : conditional_button_device = conditional_button_device{}
    @editable var CustomGunEffect16 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var ClearCustomGunEffect16 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var TargetGun16 : conditional_button_device = conditional_button_device{}
    @editable var CustomGunEffect17 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var ClearCustomGunEffect17 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var TargetGun17 : conditional_button_device = conditional_button_device{}
    @editable var CustomGunEffect18 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var ClearCustomGunEffect18 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var TargetGun18 : conditional_button_device = conditional_button_device{}
    @editable var CustomGunEffect19 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var ClearCustomGunEffect19 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var TargetGun19 : conditional_button_device = conditional_button_device{}
    @editable var CustomGunEffect20 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var ClearCustomGunEffect20 : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable var TargetGun20 : conditional_button_device = conditional_button_device{}
    
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
                else if(TargetGun4.IsHoldingItem[Player]):
                    CustomGunEffect4.Pickup(Player)
                else if(TargetGun5.IsHoldingItem[Player]):
                    CustomGunEffect5.Pickup(Player)
                else if(TargetGun6.IsHoldingItem[Player]):
                    CustomGunEffect6.Pickup(Player)
                else if(TargetGun7.IsHoldingItem[Player]):
                    CustomGunEffect7.Pickup(Player)
                else if(TargetGun8.IsHoldingItem[Player]):
                    CustomGunEffect8.Pickup(Player)
                else if(TargetGun9.IsHoldingItem[Player]):
                    CustomGunEffect9.Pickup(Player)
                else if(TargetGun10.IsHoldingItem[Player]):
                    CustomGunEffect10.Pickup(Player)
                else if(TargetGun11.IsHoldingItem[Player]):
                    CustomGunEffect11.Pickup(Player)
                else if(TargetGun12.IsHoldingItem[Player]):
                    CustomGunEffect12.Pickup(Player)
                else if(TargetGun13.IsHoldingItem[Player]):
                    CustomGunEffect13.Pickup(Player)
                else if(TargetGun14.IsHoldingItem[Player]):
                    CustomGunEffect14.Pickup(Player)
                else if(TargetGun15.IsHoldingItem[Player]):
                    CustomGunEffect15.Pickup(Player)
                else if(TargetGun16.IsHoldingItem[Player]):
                    CustomGunEffect16.Pickup(Player)
                else if(TargetGun17.IsHoldingItem[Player]):
                    CustomGunEffect17.Pickup(Player)
                else if(TargetGun18.IsHoldingItem[Player]):
                    CustomGunEffect18.Pickup(Player)
                else if(TargetGun19.IsHoldingItem[Player]):
                    CustomGunEffect19.Pickup(Player)
                else if(TargetGun20.IsHoldingItem[Player]):
                    CustomGunEffect20.Pickup(Player)                                                                                                                      
                else:
                    ClearCustomGunEffect1.Pickup(Player)
                    ClearCustomGunEffect2.Pickup(Player)
                    ClearCustomGunEffect3.Pickup(Player)
                    ClearCustomGunEffect4.Pickup(Player)
                    ClearCustomGunEffect5.Pickup(Player)
                    ClearCustomGunEffect6.Pickup(Player)
                    ClearCustomGunEffect7.Pickup(Player)
                    ClearCustomGunEffect8.Pickup(Player)
                    ClearCustomGunEffect9.Pickup(Player)
                    ClearCustomGunEffect10.Pickup(Player)
                    ClearCustomGunEffect11.Pickup(Player)
                    ClearCustomGunEffect12.Pickup(Player)
                    ClearCustomGunEffect13.Pickup(Player)
                    ClearCustomGunEffect14.Pickup(Player)
                    ClearCustomGunEffect15.Pickup(Player)
                    ClearCustomGunEffect16.Pickup(Player)
                    ClearCustomGunEffect17.Pickup(Player)
                    ClearCustomGunEffect18.Pickup(Player)
                    ClearCustomGunEffect19.Pickup(Player)
                    ClearCustomGunEffect20.Pickup(Player)
                    