# Hello World Device
# A basic creative device that prints greeting messages to the console when the game starts. It demonstrates fundamental Verse syntax by outputting 'Hello, world!' and a simple mathematical calculation.
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/hello-world-device-4?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }

\# A Verse-authored creative device that can be placed in a level
hello_world_device := class(creative_device):

 # Runs when the device is started in a running game
 OnBegin():void=
 # TODO: Replace this with your code
 Print("Hello, world!")
 Print("2 + 2 = {2 + 2}")