# LifeSteal Class System
# Implements a class-based lifesteal mechanic where players with a specific class number heal themselves by a percentage of damage dealt to other players. The healing prioritizes shield restoration when
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/lifesteal?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }

LifeSteal := class(creative_device):
    @editable GameStartDevice : GameStart = GameStart{}
    @editable LifeStealClassNumber : int = 100

    @editable StealPercent : float = 0.0

    OnBegin<override>()<suspends>:void=
        for (Player : GetPlayspace().GetPlayers(), FortCharacter := Player.GetFortCharacter[]):
            FortCharacter.DamagedEvent().Subscribe(HealAttacker)
            FortCharacter.DamagedShieldEvent().Subscribe(HealAttacker)
  


    HealAttacker( Result : damage_result) : void =
        Amount := Result.Amount
        if (Instigator := Result.Instigator?, Agent := Instigator.GetInstigatorAgent[], FortCharacter := Agent.GetFortCharacter[]):
            if(Target:= fort_character[Result.Target]):
                if(GameStartDevice.EachPlayerMap[Agent].ClassNum = LifeStealClassNumber):
                    if(Target = FortCharacter):   
                        block:
                    else:
                        HealAmount := Amount * StealPercent
                        SheildAmount := FortCharacter.GetShield()
                        HealthAmount := FortCharacter.GetHealth()
                        if(SheildAmount > 0.0):
                            FortCharacter.SetShield(SheildAmount + HealAmount)
                        else if(SheildAmount = 0.0 and HealthAmount < 100.0):
                            FortCharacter.Heal(HealAmount)
                        else:
                            FortCharacter.SetShield(SheildAmount + HealAmount)


  



                
    