# Participant Data Repository
# A data management class that stores and manages participant objects using ID-based indexing. It provides functionality to load, retrieve, and update participant data through a key-value mapping system
# Difficulty: beginner  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/participant-repository?ref=github

using { /UnrealEngine.com/Temporary/Diagnostics }

using { Tableau }

participant_repository<public> := class<concrete>():
    Initial<public>:[]participant = array{}
    var Keyed:[int]participant = map{}

    block. Load(Initial)
    Load<public>(New:[]participant)<transacts>:void=
        if (New.Length = 0). return ProjectLog("Attempted to load Zero participants", log_level.Warning)
        set Keyed = map{}
        for (P:New). if (set Keyed[P.ID] = P) {}

    GetAll<public>():[]participant = for (P:Keyed). P
    GetByID<public>(ID:int)<decides><transacts>:participant = Keyed[ID]

    Update<public>(Participant:participant)<decides><transacts>:participant=
        GetByID[Participant.ID]
        set Keyed[Participant.ID] = Participant
