# Find Closest Player
# This function calculates which player character is nearest to a specified creative prop by measuring 3D distances between all players and the prop. It returns the closest player character or none if n
# Difficulty: beginner  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/gist-wahlbeckuefn-get-closest-player?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }            
    
    GetClosestPlayerToProp(AllPlayers: []fort_character, Prop : creative_prop): ?fort_character =
        var ClosestPlayer : ?fort_character = false
        var ClosestDistance: float = 1000000000.0 # initialize with a large number
        for (Player : AllPlayers):
            EDistance := Distance(Prop.GetTransform().Translation, Player.GetTransform().Translation)
            if (EDistance < ClosestDistance):
                set ClosestPlayer = option{Player}
                set ClosestDistance = EDistance
        return ClosestPlayer