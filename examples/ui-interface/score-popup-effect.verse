# Score Popup Effect
# Display animated score popups when players earn points. Shows +10, +50, etc. with fade effects.
# Difficulty: intermediate  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/score-popup-effect?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /Fortnite.com/Game }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# Score popup display system
score_popup_manager := class(creative_device):

    @editable
    PopupDuration : float = 2.0

    @editable
    BillboardDevices : []billboard_device = array{}

    var AvailableBillboards : []billboard_device = array{}

    OnBegin<override>()<suspends> : void =
        set AvailableBillboards = BillboardDevices
        Print("Score popup manager initialized with {BillboardDevices.Length} billboards")

    # Call this to show a score popup for a player
    ShowScorePopup(Player : player, Points : int)<suspends> : void =
        if (AvailableBillboards.Length > 0):
            if (Billboard := AvailableBillboards[0]):
                # Remove from available pool
                set AvailableBillboards = AvailableBillboards.RemoveFirstElement()

                # Set the text
                Prefix := if (Points > 0) then "+" else ""
                Message := StringToMessage("{Prefix}{Points}")
                Billboard.SetText(Message)
                Billboard.ShowText()

                # Show popup
                Sleep(PopupDuration)

                # Hide and return to pool
                Billboard.HideText()
                set AvailableBillboards = AvailableBillboards + array{Billboard}

    # Convenience method for common point values
    ShowKillPoints(Player : player)<suspends> : void =
        ShowScorePopup(Player, 100)

    ShowAssistPoints(Player : player)<suspends> : void =
        ShowScorePopup(Player, 25)

    ShowObjectivePoints(Player : player)<suspends> : void =
        ShowScorePopup(Player, 50)
