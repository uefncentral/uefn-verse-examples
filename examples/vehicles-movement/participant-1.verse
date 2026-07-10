# Resource Management System
# Implements a participant-based resource management system where participants can add, remove, and query resources by ID. The system uses immutable participant objects that return new instances when re
# Difficulty: beginner  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/participant-1?ref=github

using { /Verse.org/Simulation }

using { Tableau }

CopyParticipant<constructor><public>(Old:participant)<transacts> := participant:
    ID := Old.ID
    Resources := Old.Resources

participant<public> := class<unique><concrete>():
    @editable ID<public>:int = 0
    # @editable Resources<public>:num = num{}
    Resources<public>:[int]num = map{}

    AddResources<public>(ResourceID:int, Amount:num):participant=
        if (Amount.IsZero[]). return Self

        var NewResources:[int]num = Resources
        if (set NewResources[ResourceID] = GetResource(ResourceID) + Amount):
            return participant:
                CopyParticipant<constructor>(Self)
                Resources := NewResources
        else:
            return Self

    RemoveResources<public>(ResourceID:int, Amount:num)<decides><transacts>:participant=
        if (not GetResource(ResourceID).GreaterThanOrEqual[Amount]). false?

        var NewResources:[int]num = Resources
        if (set NewResources[ResourceID] = GetResource(ResourceID) - Amount):
            return participant:
                CopyParticipant<constructor>(Self)
                Resources := NewResources
        else:
            return Self

    GetResource<public>(ResourceID:int)<computes>:num=
        if (Amount := Resources[ResourceID]). Amount else. num{}