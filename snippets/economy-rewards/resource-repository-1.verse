# Resource Repository Manager
# This code implements a generic resource management system that stores, retrieves, and updates resources by ID. It provides functionality to load arrays of resources into a keyed map structure and perf
# Difficulty: beginner  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/resource-repository-1?ref=github

using { /UnrealEngine.com/Temporary/Diagnostics }

using { Tableau }

resource_repository<public> := class<concrete>():
    Initial<public>:[]resource = array{}
    var Keyed:[int]resource = map{}

    block. Load(Initial)
    Load<public>(New:[]resource)<transacts>:void=
        if (New.Length = 0). return ProjectLog("Attempted to load Zero resources", log_level.Warning)
        set Keyed = map{}
        for (P:New). if (set Keyed[P.ID] = P) {}

    GetAll<public>():[]resource = for (P:Keyed). P
    GetByID<public>(ID:int)<decides><transacts>:resource = Keyed[ID]

    Update<public>(Resource:resource)<decides><transacts>:resource=
        GetByID[Resource.ID]
        set Keyed[Resource.ID] = Resource
