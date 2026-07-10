# Build Reset System
# A system that allows players to reset/destroy all builds in an area by pressing a button. When activated, it triggers explosive devices throughout the map to clear player-built structures.  **How to u
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/resetbuilds-1?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }


ResetBuildsCode := class(creative_device):
    @editable ResetButton : button_device = button_device{}    #button to reset builds
    @editable ExplosiveDevices : []explosive_device = array{}   #explosive devices to destroy builds

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        ResetButton.InteractedWithEvent.Subscribe(ResetBuilds)

        
    ResetBuilds(Agent:agent):void =     
        spawn:
            ResetBuildsReal(Agent)


    ResetBuildsReal(Agent:agent)<suspends>:void =    #activates when button is pressed
        for (explosive : ExplosiveDevices):    #explodes all explosive devices
            explosive.Explode(Agent)
            explosive.Reset()
 