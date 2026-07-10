# Build Reset System
# Creates an explosive reset mechanism for player builds using a button trigger. When a player interacts with the button, it triggers an explosion at their location to clear builds, then automatically r
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/build-reset-button?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Playspaces }
using { /Verse.org/Simulation }
using { /Verse.org/Verse }

Build_Reset_Button := class(creative_device):

    @editable
    Boom:explosive_device = explosive_device{}

    @editable
    ResetButton:button_device = button_device{}
    

    OnBegin<override>()<suspends>:void=
        Print("Button Ready!")
        ResetButton.InteractedWithEvent.Subscribe(ResetBuilds)

    ResetBuilds(InPlayer:agent):void=
        Boom.Explode(InPlayer)
        Print("Boom!")
        Boom.Reset()
        Print("Resetting Explosives")