# AI Farmer Management System
# Manages AI-controlled farmer characters that move between designated farming locations. The system handles adding/removing farmers from the active list and teleports them to different farming spots in
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/npcfarmer?ref=github

using { /Fortnite.com/Game }
using { /Fortnite.com/AI }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }

# A device that manages AI-controlled farmers
farm_worker_behavior := class(creative_device):
    @editable
    var FarmingSpots: []vector3 = array{
        vector3{X := 0.0, Y := 0.0, Z := 0.0},
        vector3{X := 100.0, Y := 0.0, Z := 0.0},
        vector3{X := 0.0, Y := 100.0, Z := 0.0}
    }

    var ActiveFarmers: []agent = array{}
    var CurrentSpotIndex: int = 0

    GetNextSpot()<decides>:vector3 =
        if (FarmingSpots.Length > 0):
            if (CurrentSpotIndex >= FarmingSpots.Length - 1):
                set CurrentSpotIndex = 0
            else:
                set CurrentSpotIndex += 1
            FarmingSpots[CurrentSpotIndex]
        else:
            vector3{}

    MoveFarmerToLocation(Farmer : agent, Location : vector3)<suspends>:void =
        if (Character := fort_character[Farmer]):
            if (TeleportResult := Character.TeleportTo[Location, rotation{}]):
                Print("Moved farmer")

    AddFarmer(NewFarmer : agent):void =
        var IsFound : logic = false
        for (Farmer : ActiveFarmers):
            if (Farmer = NewFarmer):
                set IsFound = true
        if (IsFound = false):
            set ActiveFarmers += array{NewFarmer}

    RemoveFarmer(FarmerToRemove : agent):void =
        var NewFarmers : []agent = array{}
        for (Farmer : ActiveFarmers):
            if (Farmer <> FarmerToRemove):
                set NewFarmers += array{Farmer}
        set ActiveFarmers = NewFarmers