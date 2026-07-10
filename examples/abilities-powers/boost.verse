# Button Speed Modifier
# This code creates a system where players can activate a conditional button to modify their movement speed. When a player presses the button, it triggers a movement modulator device that changes the pl
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/boost?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics } 

CustomSpeed:= class(creative_device):
    
    @editable
    CB:conditional_button_device = conditional_button_device{}
    @editable
    MovementModifier:movement_modulator_device = movement_modulator_device{}
    
    OnBegin<override>()<suspends>:void=
        CB.ActivatedEvent.Subscribe(ChangeMovement) 

    ChangeMovement(Agent : agent):void=
        MovementModifier.Activate(Agent)