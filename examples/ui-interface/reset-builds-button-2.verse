# Reset Builds Button 2
# Verse code for Reset Builds Button 2 - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/reset-builds-button-2?ref=github


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
 
