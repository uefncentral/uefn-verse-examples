# Ik
# Verse code for Ik - UEFN/Fortnite Creative implementation
# Difficulty: intermediate  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/ik?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }

self_elimination_button := class(creative_device):
    @editable Trigger : trigger_device = trigger_device{}
    OnBegin<override>()<suspends>:void=
        Trigger.TriggeredEvent.Subscribe(DeathButton)

    DeathButton(Agent : ?agent):void=  
        if (Player := player[Agent?]):  
            if (FortChar := Player.GetFortCharacter[]):
                FortChar.Damage(10000.0)
