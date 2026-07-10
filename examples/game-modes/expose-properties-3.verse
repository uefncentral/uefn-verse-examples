# Custom Message Display
# This code creates a custom device that displays editable greeting and introduction messages when the game begins. It demonstrates basic property exposure and message printing functionality in UEFN.  *
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/expose-properties-3?ref=github

using { /Verse.org/Simulation }
using { /Fortnite.com/Devices}

expose_properties := class(creative_device):

 @editable
 GreetingMessage : string = "Hello, stranger"
 @editable
 IntroMessages : []string = array{"Welcome to the Game", "Have Fun!"}

 OnBegin() : void =
 Print("{GreetingMessage}")
 for (Message : IntroMessages):
     Print("{Message}")