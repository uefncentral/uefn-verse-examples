# Player Freeze Weapon
# This device creates a weapon that temporarily freezes players when they take damage. When a player holding a specific item (defined by the conditional button device) damages another player, the target
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/freeze-device-1?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation/Tags }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors/NamedColors }
using { /UnrealEngine.com/Temporary/SpatialMath }


freeze_device := class(creative_device):

    @editable ConditionalButton : conditional_button_device = conditional_button_device{}
    @editable FreezeTime : float = 2.0

    OnPlayerDamage(DamageResult : damage_result): void =
        if:
            Instigator := DamageResult.Instigator?
            Agent := Instigator.GetInstigatorAgent[]
            ConditionalButton.IsHoldingItem[Agent]
            Target := fort_character[DamageResult.Target]

        then:
            spawn:
                FreezePlayer(Target)

    FreezePlayer(Target : fort_character)<suspends> : void =
        Print("Frozen")
        Target.PutInStasis(stasis_args{})
        Sleep(FreezeTime)
        Target.ReleaseFromStasis()
        Print("UnFrozen")


    OnPLayerAdded(Player : player) : void =
        if (FortCharacter := Player.GetFortCharacter[]):
            FortCharacter.DamagedShieldEvent().Subscribe(OnPlayerDamage)

    OnBegin<override>()<suspends> : void =
            GetPlayspace().PlayerAddedEvent().Subscribe(OnPLayerAdded)

            for (Player : GetPlayspace().GetPlayers(), FortCharacter := Player.GetFortCharacter[]):
                FortCharacter.DamagedEvent().Subscribe(OnPlayerDamage)
                FortCharacter.DamagedShieldEvent().Subscribe(OnPlayerDamage)