# Producer Repository Manager
# This code implements a repository system for managing producer objects with CRUD operations including loading, retrieving by ID, updating, and filtering by ownership. It maintains both array and map c
# Difficulty: beginner  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/producer-repository-1?ref=github

producer_repository<public> := class<concrete>():
    Initial<public>:[]producer = array{}
    var Keyed:[int]producer = map{}

    block. Load(Initial)
    Load<public>(New:[]producer)<transacts>:void=
        set Keyed = map{}
        for (G:New). if (set Keyed[G.ID] = G) {}

    GetAll<public>():[]producer = for(G:Keyed). G
    GetAllMapped<public>():[int]producer = Keyed
    GetByID<public>(ID:int)<decides><transacts>:producer = Keyed[ID]

    Update<public>(Prod:producer)<decides><transacts>:producer=
        GetByID[Prod.ID]
        set Keyed[Prod.ID] = Prod

    GetOwnedProducers<public>(OwnerID:int)<transacts>:[]producer=
        for (Producer:Keyed, Producer.GetCount(OwnerID) > 0). Producer

    OwnsProducer<public>(OwnerID:int, ProdID:int)<decides><transacts>:int=
        Prod := GetByID[ProdID]
        Count := Prod.GetCount(OwnerID)
        Count > 0