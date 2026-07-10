# Finisher Animation System
# Triggers cinematic finisher animations when players damage enemies while not holding weapons from a specified list. Monitors all player damage events and initiates custom animation sequences for unarm
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/finisher-manger-mrv-1?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game}
Finisher_Manager := class(creative_device):

    @editable AnchorProp : creative_prop = creative_prop{}
    @editable AllWeapons: [] conditional_button_device = array{}
    @editable Finisher: cinematic_sequence_device = cinematic_sequence_device{}
    @editable Trigger1 : trigger_device = trigger_device{}
    @editable Trigger2 : trigger_device = trigger_device{}
    OnBegin<override>()<suspends> : void=
        for (Player : GetPlayspace().GetPlayers() , FC := Player.GetFortCharacter []):
            FC.DamagedEvent().Subscribe (OnDamaged)
        loop:
            JoiningPlayer := GetPlayspace ().PlayerAddedEvent().Await()
            if (FC := JoiningPlayer.GetFortCharacter []):
                FC.DamagedEvent().Subscribe (OnDamaged)

    OnDamaged (Result : damage_result) : void=
        if:
            Instigator := Result.Instigator?
            Agent := Instigator.GetInstigatorAgent[]
            TargetFC := fort_character [Result.Target]
            InstigatorFC := Agent.GetFortCharacter []
        then:
            if (InstigatorFC <> TargetFC):
            var IsHolding : logic = false
            for (Conditional: AllWeapons):
                if(Conditional.IsHoldingItem [Agent]):
                    set IsHolding = true
            if (IsHolding = false):
                spawn:
                    StartAnimation(TargetFC, InstigatorFC)

    StartAnimation (TargetFC: fort_character, InstigatorFC: fort_character)<suspends>:void=
        if:
            TargetAgent := TargetFC.GetAgent[]
            InstiagtorAgent := InstigatorFC.GetAgent[]
        then:
            sync:
                block:
                    Sleep(0.1)
                    InstigatorFC.PutInStasis(stasis_args{})
                block:
                    TargetFC.PutInStasis(stasis_args{})
                    InstigatorFC.PutInStasis(stasis_args{})

                    TargetFC.SetVulnerability(false)
                    InstigatorFC.SetVulnerability(false)

                    TargetFC.Hide()
                    InstigatorFC.Hide()

                    Trigger1.Trigger(TargetAgent)
                    Trigger2.Trigger(InstiagtorAgent)

                    if(AnchorProp.TeleportTo[InstigatorFC.GetTransform().Translation , InstigatorFC.GetTransform().Rotation]){}

                    StopAnimation(TargetFC, InstigatorFC)

    StopAnimation(TargetFC : fort_character , InstigatorFC : fort_character)<suspends> : void=
        TargetFC.ReleaseFromStasis()
        InstigatorFC.ReleaseFromStasis()

        TargetFC.SetVulnerability(true)
        InstigatorFC.SetVulnerability(true)

        TargetFC.Show()
        InstigatorFC.Show()

        Finisher

        TargetFC.Damage(500.0)