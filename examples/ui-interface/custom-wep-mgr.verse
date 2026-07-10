# Custom Wep Mgr
# Verse code for Custom Wep Mgr - UEFN/Fortnite Creative implementation
# Difficulty: intermediate  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/custom-wep-mgr?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }

Custom_Weapon := class<concrete>():
    @editable Conditional : conditional_button_device = conditional_button_device{}
    @editable VFX : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable CrosshairHUD : hud_message_device = hud_message_device{}
    @editable Projectile : creative_prop_asset = DefaultCreativePropAsset
    @editable WeaponSpeed : float = 0.0
    @editable WeaponRange : float = 0.0
    @editable WeaponDamage : float = 0.0
    var Identifier : int = 0

    Equip(Agent:agent) : void=
        VFX.Pickup(Agent)
        CrosshairHUD.Show(Agent)

    Fire(Agent:agent)<suspends> : void=
        if(FC := Agent.GetFortCharacter[]):
            PlayerPos := FC.GetTransform().Translation
            PlayerViewRot := FC.GetViewRotation()
            PlayerForwardVector := PlayerViewRot.GetLocalForward() * 400.0
            PlayerForwardVectorEnd := PlayerViewRot.GetLocalForward() * WeaponRange
            SpawnPos := PlayerPos + PlayerForwardVector
            FinishPos := PlayerPos + PlayerForwardVectorEnd
            if(NewProp := SpawnProp(Projectile , SpawnPos, IdentityRotation())(0)?):
                race:
                    block:
                        NewProp.MoveTo(FinishPos,IdentityRotation(),WeaponSpeed)
                        # NewProp.Dispose()  # TODO: Verse has no manual disposal
                        return
                    DamageCheck(NewProp , Agent)

    DamageCheck(Prop : creative_prop , Agent : agent)<suspends> : void=
        loop:
            Sleep(0.0)
            for(Player : Prop.GetPlayspace().GetPlayers() ,Player <> Agent , FC := Player.GetFortCharacter[]):
                if(Distance(FC.GetTransform().Translation , Prop.GetTransform().Translation) < 400.0):
                    FC.Damage(WeaponDamage)