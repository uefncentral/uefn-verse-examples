# Jump Toggle Visibility
# This device allows players to toggle their character's visibility by jumping. When a player jumps, their character alternates between being visible and hidden, creating a simple hide-and-seek or steal
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/jump-to-hide-1?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
 
jump_to_hide_device := class(creative_device):
 
    var IsHiding : logic = false
 
    OnBegin<override>()<suspends>:void=
        for(Player : GetPlayspace().GetPlayers(), FortChar := Player.GetFortCharacter[]):
            FortChar.JumpedEvent().Subscribe(OnJumped)
 
    OnJumped(FortChar:fort_character):void=
        if(IsHiding?):
            FortChar.Show()
            set IsHiding = true
        else:
            FortChar.Hide()
            set IsHiding = false