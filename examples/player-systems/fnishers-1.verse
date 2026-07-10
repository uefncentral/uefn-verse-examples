# Finisher Animation System
# Triggers a cinematic finisher animation when a player deals exactly 20 damage to an opponent who has 20 or less health remaining. The system monitors all player damage events and activates special fin
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/fnishers-1?ref=github

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
    @editable Triggerclear : trigger_device = trigger_device{}
    OnBegin<override>()<suspends> : void=
        for(Player : GetPlayspace().GetPlayers() , FC := Player.GetFortCharacter []):
            FC.DamagedEvent().Subscribe ( Damage_Check)
        

    Damage_Check(Result : damage_result):void=
            if:
                Instigator := Result.Instigator?
                _Instigator := Result.Instigator
                Agent := Instigator.GetInstigatorAgent[]
                Target := Result.Target
                Target_FortCharacter := fort_character[Target]
                Target_Agent := Target_FortCharacter.GetAgent[]
                Instigator_Player := player[Agent]
                Target_Player := player[Target_Agent]
                var Amount : float = Result.Amount
                Instigator_FortCharacter := Agent.GetFortCharacter[]
                var Target_Health :float= Target_FortCharacter.GetHealth()
                Instigator_Health :float= Instigator_FortCharacter.GetHealth()
                Target_Shield :float= Target_FortCharacter.GetShield()
                Instigator_Shield :float= Instigator_FortCharacter.GetShield()
            then:
                        if(Target_FortCharacter.GetHealth() <= 20.0):
                            if(Amount =20.0):
                                    spawn{StartAnimation(Target_FortCharacter,Instigator_FortCharacter)}
                                    spawn{StopAnimation(Target_FortCharacter,Instigator_FortCharacter)}

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
                    
                    Finisher.Play()

                    if(AnchorProp.TeleportTo[InstigatorFC.GetTransform().Translation , InstigatorFC.GetTransform().Rotation]){}
                    

                    

                    StopAnimation(TargetFC, InstigatorFC)

    StopAnimation(TargetFC : fort_character , InstigatorFC : fort_character)<suspends> : void=
        Sleep(4.0)
        TargetFC.ReleaseFromStasis()
        InstigatorFC.ReleaseFromStasis()

        

        TargetFC.SetVulnerability(true)
        InstigatorFC.SetVulnerability(true)
        
       
        
        TargetFC.Show()
        InstigatorFC.Show()
       
        
        Finisher.Stop()
        if(AgentTarget := TargetFC.GetAgent[], AgentInstigator := InstigatorFC.GetAgent[]):
            Triggerclear.Trigger(AgentTarget)
            Triggerclear.Trigger(AgentInstigator)
        

        TargetFC.Damage(20.0)