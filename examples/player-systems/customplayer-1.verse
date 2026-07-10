# Player Collection Tracker
# This code defines a custom player class that tracks collectible items gathered by individual players. It provides methods to initialize players with unique IDs, increment collection counts, reset coun
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/customplayer-1?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

CustomPlayer := class():

    var UniqueID:int = 0
    MyAgentObj:agent

    var CollectedObjectsCount:int = 0

    InitializePlayer(UID:int):void=
        set UniqueID = UID
        Print("new player in game")

    GetCollectibleCount():int=
        Print("current count: {CollectedObjectsCount}")
        return CollectedObjectsCount

    ResetCollectibleCount():void=
        set CollectedObjectsCount = 0

    AddCollectible():void=
        set CollectedObjectsCount +=1
