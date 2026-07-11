# Work State Manager
# A state management system that tracks work items through different phases (WarmUp and Available). It provides methods to start work (transitioning to WarmUp phase), complete work (returning to Availab
# Difficulty: beginner  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/work-1?ref=github

using { /Verse.org/Simulation }

phase<public> := enum:
    WarmUp
    Available

CopyWork<constructor>(Old:work)<transacts> := work:
    ID := Old.ID
    Phase := Old.Phase
    WarmUpDuration := Old.WarmUpDuration

work<public> := class<concrete>():
    @editable ID<public>:int = 0
    @editable Phase<public>:phase = phase.Available
    @editable WarmUpDuration<public>:float = 0.0

    StartWork<public>()<decides><transacts>:work =
        if (not IsAvailable[]). false?

        return work:
            CopyWork<constructor>(Self)
            Phase := phase.WarmUp

    CompleteWork<public>()<decides><transacts>:work =
        if (IsAvailable[]). false?

        return work:
            CopyWork<constructor>(Self)
            Phase := phase.Available

    IsAvailable<public>()<decides><transacts>:void = Phase = phase.Available
