# Temporary Invisibility Button
# Creates a button that makes players invisible for 30 seconds when pressed. The player automatically becomes visible again after the duration expires.  **How to use:** Place the InvisDevice in your isl
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/invisdevice?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }


InvisDevice := class(creative_device):

    @editable
    Button : button_device = button_device{}
    

    InvisOnButton( Agent :agent): void=
        if (InvisPlayer := Agent, FortCharacter := InvisPlayer.GetFortCharacter[]):
            FortCharacter.Hide()
            spawn:
                UnhideButton(FortCharacter)

    UnhideButton(FortCharacter : fort_character)<suspends> : void =
        Sleep(30.0)
        FortCharacter.Show()            


    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        Button.InteractedWithEvent.Subscribe(InvisOnButton)
        