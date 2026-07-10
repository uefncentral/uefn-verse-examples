# Resource Data Structure
# Defines a basic resource class with ID and name properties, plus a copy constructor function. This creates a simple data container that can be used to represent game resources like items, materials, o
# Difficulty: beginner  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/resource-1?ref=github

using { /Verse.org/Simulation }

using { Tableau }

CopyResource<constructor>(Old:resource)<transacts> := resource:
    ID := Old.ID
    Name := Old.Name

resource<public> := class<unique><concrete>():
    @editable ID<public>:int = 0
    @editable Name<public>:string = ""
