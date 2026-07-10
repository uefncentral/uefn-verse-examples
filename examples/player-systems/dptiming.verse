# Target Settings Configurator
# This code creates an interactive configuration system for shooting range targets. It allows players to cycle through different health and speed settings using buttons, with the current configuration d
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/dptiming?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

TargetConfiguration := class(creative_device):
    # Configuration devices
    @editable HealthButton : button_device = button_device{}  
    @editable SpeedButton : button_device = button_device{}   
    @editable ConfigBoard : billboard_device = billboard_device{} 
    @editable Target : shooting_range_target_track_device = shooting_range_target_track_device{}

    # Configuration values
    var CurrentHealthIndex : int = 0
    var CurrentSpeedIndex : int = 0
    var HealthOptions : []float = array{50.0, 100.0, 150.0, 200.0}
    var SpeedOptions : []float = array{0.5, 0.75, 1.0, 1.25}
    
    StringToMessage<localizes>(String : string) : message = "{String}"

    OnBegin<override>()<suspends>:void=
        # Setup initial display
        UpdateConfigDisplay()
        
        HealthButton.InteractedWithEvent.Subscribe(OnHealthChange)
        SpeedButton.InteractedWithEvent.Subscribe(OnSpeedChange)

    OnHealthChange(Agent : agent):void=
        if (CurrentHealthIndex < HealthOptions.Length - 1):
            set CurrentHealthIndex += 1
        else:
            set CurrentHealthIndex = 0
        UpdateConfigDisplay()

    OnSpeedChange(Agent : agent):void=
        if (CurrentSpeedIndex < SpeedOptions.Length - 1):
            set CurrentSpeedIndex += 1
        else:
            set CurrentSpeedIndex = 0
        UpdateConfigDisplay()

    UpdateConfigDisplay():void=
        if:
            # Safe array access
            CurrentHealth := HealthOptions[CurrentHealthIndex]
            CurrentSpeed := SpeedOptions[CurrentSpeedIndex]
        then:
            ConfigBoard.SetText(StringToMessage("Target Settings:\nHealth: {CurrentHealth}\nSpeed: {CurrentSpeed}x"))