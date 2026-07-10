# Player Buff System
# This code provides a utility class for applying temporary buffs to players in UEFN. It includes functions to give damage amplification buffs using a powerup device and temporary invincibility by manip
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/basicfunctions?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }

BasicFunctions := class(creative_device):
    @editable BasicDMGInc : damage_amplifier_powerup_device = damage_amplifier_powerup_device{}


    OnBegin<override>()<suspends>:void=
        block:


    DoDamageBuff(NewAgent : agent, TimeLast : float, IncreaseBy : float) : void=
        BasicDMGInc.SetMagnitude(IncreaseBy)
        BasicDMGInc.SetDuration(TimeLast)
        BasicDMGInc.Pickup(NewAgent)

    DoInvcibilityBuff(NewAgent : agent, TimeLast : float) <suspends>: void=
        if(Player := player[NewAgent], FC:=Player.GetFortCharacter[]):
            FC.SetVulnerability(false)
            Sleep(TimeLast)
            FC.SetVulnerability(true)



 
