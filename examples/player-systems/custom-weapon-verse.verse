# Custom Weapon VFX System
# Monitors players' equipped weapons using conditional buttons and automatically applies corresponding visual effects when specific weapons are held. The system continuously checks what weapon each play
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/custom-weapon-verse?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

custom_weapon := class(creative_device):

    @editable 
    WeaponDetector : conditional_button_device = conditional_button_device{}   #conditional button for the weapon, insert your weapon inside the conditional button
    @editable 
    WeaponDetector2 : conditional_button_device = conditional_button_device{}  #conditional button for the weapon, insert your weapon inside the conditional button
    # @editable 
    # WeaponDetector3 : conditional_button_device = conditional_button_device{}  #conditional button for the weapon, insert your weapon inside the conditional button
    @editable 
    EmptyVFX : visual_effect_powerup_device = visual_effect_powerup_device{}		#empty power up
    @editable 
    CustomToy : visual_effect_powerup_device = visual_effect_powerup_device{}	#your gun power up
    @editable
    CustomToy2 : visual_effect_powerup_device = visual_effect_powerup_device{}	#your gun power up
    # @editable
    # CustomToy3 : visual_effect_powerup_device = visual_effect_powerup_device{}	#your gun power up


    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
            
        spawn:
            CheckForCustom()

    CheckForCustom()<suspends> : void=
        loop:
            Sleep(0.2)
            AllPlayers:=GetPlayspace().GetPlayers()
            for(Player:AllPlayers):
                if(A : agent = agent[Player]):
                    if(WeaponDetector.IsHoldingItem[A]):
                        CustomToy.Pickup(A)
                    else:
                        if(WeaponDetector2.IsHoldingItem[A]):
                            CustomToy2.Pickup(A)
                        else:
                            EmptyVFX.Pickup(A)
               