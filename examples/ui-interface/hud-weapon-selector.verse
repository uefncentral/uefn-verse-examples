# Hud Weapon Selector
# Verse code for Hud Weapon Selector - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/hud-weapon-selector?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Colors/NamedColors }
using { /Fortnite.com/Characters }
WeaponHudSelector := class(creative_device):
    var PlayerMap : [player]WeaponHudSelector = map{}
    @editable Weapon1 : conditional_button_device = conditional_button_device{}
    @editable Weapon2 : conditional_button_device = conditional_button_device{}
    @editable Weapon3 : conditional_button_device = conditional_button_device{}
    @editable WeaponHUD1 : trigger_device = trigger_device{}
    @editable WeaponHUD2 : trigger_device = trigger_device{}
    @editable WeaponHUD3 : trigger_device = trigger_device{}
    @editable GunReset : trigger_device = trigger_device{}
    OnBegin<override>()<suspends>:void =
        spawn:
            CheckForGuns()
    CheckForGuns()<suspends>:void =
        loop:
            Sleep(0.0)
            AllPlayers := GetPlayspace().GetPlayers()
            for (Player : AllPlayers):
                if (IsAgent : agent = agent[Player]):
                    if (Weapon1.IsHoldingItem[IsAgent]):
                        WeaponHUD1.Trigger(IsAgent)
                    else if (Weapon2.IsHoldingItem[IsAgent]):
                        WeaponHUD2.Trigger(IsAgent)
                    else if (Weapon3.IsHoldingItem[IsAgent]):
                        WeaponHUD3.Trigger(IsAgent)
                    else:
                        GunReset.Trigger(IsAgent)

        
         
             