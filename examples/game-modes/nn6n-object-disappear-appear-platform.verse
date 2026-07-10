# Platform Toggle System
# Automatically toggles a platform's visibility on and off in a continuous loop using color changing tiles. The platform hides and shows at regular intervals defined by a configurable delay parameter.  
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/nn6n-object-disappear-appear-platform?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Native }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
 
log_on_off_platform := class(log_channel){}
 
on_off_platform := class<concrete>(creative_device):
    Logger : log = log{Channel := log_on_off_platform}

    @editable
    ToggleDelay : float = 2.0 # How long to wait between showing and hiding the platform

    @editable
    Platform : color_changing_tiles_device = color_changing_tiles_device{} 
 
    OnBegin<override>()<suspends> : void =
        loop:
            Sleep(ToggleDelay) # Sleep(ToggleDelay) waits for ToggleDelay seconds before proceeding to the next instruction.
            Platform.Hide()
            Sleep(ToggleDelay)
            Platform.Show() # The loop restarts immediately, calling Sleep(ToggleDelay) again.