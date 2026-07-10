# Item-Based Player Invisibility
# This device makes players invisible when they hold a specific item and visible when they don't. It continuously monitors players entering a mutator zone and checks their inventory status through a con
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/invis-device-1?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

invisible := class(creative_device):

    @editable
    cond_btn: conditional_button_device = conditional_button_device{}

    @editable
    mutator: mutator_zone_device = mutator_zone_device{}

    HoldingEvent( Agent : agent) : void =
        if(FortCharacter := Agent.GetFortCharacter[]):
            if(cond_btn.IsHoldingItem[Agent]):
                FortCharacter.Hide()
            else:
                FortCharacter.Show()       


    OnBegin<override>()<suspends>: void =
            loop:
                mutator.Enable()
                mutator.AgentEntersEvent.Subscribe(HoldingEvent)
                Sleep(0.1)
                mutator.Disable()
                Sleep(0.1)