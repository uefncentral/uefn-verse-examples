# EZUI Framework Module
# A utility framework module for UEFN that provides helper functions for UI development in Verse. It includes type definitions for UI constraints, player validation functions, and conversion utilities f
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/code02m01-device-1?ref=github

<#
   This module needs to be used for any EZUI scripts and 
   contains premade features for the framework. Call these
   functions with "EZUI.<function>" from your scripts after
   importing them with "using {EZUI}"
#>

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

#imports
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /Verse.org/Colors }
using { /Fortnite.com/Playspaces }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Assets }


EZUI<public> := module:

    # Toolkit ---------------------------------------------------------------------------------------

    # converts string to message
    TextToMsg<public><localizes> (t : string) : message = "{t}" 

    # comverts int to message
    IntToMsg<public><localizes>(i : int) : message = "{i}"

    # defines a custom typing for opacity which requires constraints
    opacity_range<public> := type{_X:float where 0.000000 <= _X, _X <= 1.000000}

    # defines a custom typing for anchors which requires constraints
    anchor_range<public> := type{_X:float where 0.000000 <= _X, _X <= 1.000000}

    <#
        EZUI.IsAPlayer
        used to determine if a TriggerEvent is from a player, or to check if the 
        input is a player, to allow for a UI to bereferenced
    #>
    IsAPlayer<public>(MaybeAgent : ?agent, VerseDevice : creative_device) : logic =

        if(not MaybeAgent?):
            Print("EZUI: Not an Agent")
            return false

        if(MaybePlayer := MaybeAgent?):
            for (k -> v : VerseDevice.GetPlayspace().GetPlayers()):
                if (v = player[MaybePlayer]):
                    Print("EZUI: Is a Player")
                    return true
        
        Print("EZUI: Not a Player")
        return false
        





    # VFX library ---------------------------------------------------------------------------------

    <#
        EZUI.FlickerVF
        Used to create a flickering effect on UI elements for a defined
        duration and then ending with one of four ways:
            1 - visible
            2 = invisible
            3 = invisible and collapsed
            4 = removed
    
    #>
    FlickerVFX <public> (ThisWidget : widget, Duration : float, VFXEnd : int, LinkedPlayer : player)<suspends> : void =
        var Countdown : float = (Duration * 10)
        
        loop:
                ThisWidget.SetVisibility(widget_visibility.Hidden)
                Sleep(0.05)
                ThisWidget.SetVisibility(widget_visibility.Visible)
                Sleep(0.05)
                set Countdown = Countdown - 1.0
        
                if(Countdown = 0.0):

                    if (VFXEnd = 1):
                        ThisWidget.SetVisibility(widget_visibility.Visible)
                        
                    if (VFXEnd = 2):
                        ThisWidget.SetVisibility(widget_visibility.Hidden)
                    
                    if (VFXEnd = 3):
                        ThisWidget.SetVisibility(widget_visibility.Collapsed) 

                    if (VFXEnd = 4):
                        if (PlayerUI := GetPlayerUI[LinkedPlayer]):
                            PlayerUI.RemoveWidget(ThisWidget)           
                       
                    break

            