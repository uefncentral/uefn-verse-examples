# Chili Power Item Grant
# This code creates a power-up system that automatically grants a chili item to players when they spawn or gain the power. It also plays death audio when the player with this power is eliminated.  **How
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/chili-movement-power-1?ref=github


using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Game }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }


chili_movement_power := class(power_class):

    @editable
    ChiliGranter : item_granter_device = item_granter_device{}

    InitializePower<override>(Player: player)<suspends>: void =
        Sleep(0.5)
        ChiliGranter.GrantItem(Player)

    
    PlayerEliminated<override>(EliminationResult : elimination_result):void=
        if:
            Player := GetAbilityPlayer[]
            FortChar := Player.GetFortCharacter[]
            FortChar = EliminationResult.EliminatedCharacter
        then:
            DeathAudio.Play(Player)