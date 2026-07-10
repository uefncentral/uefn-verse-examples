# Hello World Device
# A basic custom creative device that demonstrates Verse programming fundamentals by printing greeting messages and simple calculations to the console. This serves as a starter template for learning Ver
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/nn6n-helper-scripts-hello-world-device?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }

# A Verse-authored creative device that can be placed in a level
hello_world_device := class(creative_device):

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        # TODO: Replace this with your code
        Print("Hello, world!")
        Print("2 + 2 = {2 + 2}")