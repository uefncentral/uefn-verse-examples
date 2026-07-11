# Work Data Repository
# This code implements a generic repository class for managing work items with unique IDs. It provides functionality to load, retrieve, and update work objects using both array and map storage structure
# Difficulty: beginner  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/work-repository?ref=github

work_repository<public> := class<concrete>():
    Initial<public>:[]work = array{}
    var Keyed:[int]work = map{}

    block. Load(Initial)
    Load<public>(New:[]work)<transacts>:void=
        set Keyed = map{}
        for (G:New). if (set Keyed[G.ID] = G) {}

    GetAll<public>():[]work = for(G:Keyed). G
    GetByID<public>(ID:int)<decides><transacts>:work = Keyed[ID]

    Update<public>(Work:work)<decides><transacts>:work=
        GetByID[Work.ID]
        set Keyed[Work.ID] = Work
