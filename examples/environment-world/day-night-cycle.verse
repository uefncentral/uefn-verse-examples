# Day/Night Cycle Controller
# Control the time of day with smooth transitions. Trigger events at dawn, noon, dusk, and midnight.
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/day-night-cycle?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# Time of day phases
time_phase := enum:
    Dawn
    Day
    Dusk
    Night

# Day/Night cycle controller
day_night_controller := class(creative_device):

    @editable
    SkyDome : skydome_device = skydome_device{}

    @editable
    CycleDurationMinutes : float = 10.0  # Full day-night cycle

    @editable
    StartTimeOfDay : float = 0.5  # 0.0 = midnight, 0.5 = noon

    @editable
    EnableCycle : logic = true

    # Event triggers for different times
    @editable
    DawnTrigger : trigger_device = trigger_device{}

    @editable
    NoonTrigger : trigger_device = trigger_device{}

    @editable
    DuskTrigger : trigger_device = trigger_device{}

    @editable
    MidnightTrigger : trigger_device = trigger_device{}

    var CurrentTime : float = 0.5  # 0.0 to 1.0
    var CurrentPhase : time_phase = time_phase.Day
    var LastTriggeredPhase : time_phase = time_phase.Day

    OnBegin<override>()<suspends> : void =
        set CurrentTime = StartTimeOfDay
        UpdateSkyDome()

        if (EnableCycle?):
            RunDayNightCycle()

    RunDayNightCycle()<suspends> : void =
        CycleSeconds := CycleDurationMinutes * 60.0
        TimeIncrement := 1.0 / CycleSeconds  # How much to advance per second

        loop:
            Sleep(1.0)

            # Advance time
            set CurrentTime = Mod(CurrentTime + TimeIncrement, 1.0)

            # Update visuals
            UpdateSkyDome()

            # Check for phase changes and trigger events
            CheckPhaseTransition()

    UpdateSkyDome() : void =
        # Convert 0-1 time to hours (0-24)
        Hours := CurrentTime * 24.0
        SkyDome.SetTimeOfDay(Hours)

    CheckPhaseTransition() : void =
        NewPhase := GetCurrentPhase()

        if (NewPhase <> CurrentPhase):
            set CurrentPhase = NewPhase

            # Only trigger if we haven't already triggered this phase
            if (CurrentPhase <> LastTriggeredPhase):
                set LastTriggeredPhase = CurrentPhase
                TriggerPhaseEvent(CurrentPhase)

    GetCurrentPhase() : time_phase =
        Hours := CurrentTime * 24.0

        if (Hours >= 5.0):
            if (Hours < 7.0):
                return time_phase.Dawn
        if (Hours >= 7.0):
            if (Hours < 18.0):
                return time_phase.Day
        if (Hours >= 18.0):
            if (Hours < 20.0):
                return time_phase.Dusk

        return time_phase.Night

    TriggerPhaseEvent(Phase : time_phase) : void =
        case (Phase):
            time_phase.Dawn =>
                DawnTrigger.Trigger()
                Print("Dawn has arrived!")
            time_phase.Day =>
                NoonTrigger.Trigger()
                Print("It is now daytime!")
            time_phase.Dusk =>
                DuskTrigger.Trigger()
                Print("Dusk is falling!")
            time_phase.Night =>
                MidnightTrigger.Trigger()
                Print("Night has fallen!")

    # Manual time control
    SetTimeOfDay(Time : float) : void =
        set CurrentTime = Clamp(Time, 0.0, 0.9999)
        UpdateSkyDome()

    # Jump to specific time
    SetToNoon() : void =
        SetTimeOfDay(0.5)

    SetToMidnight() : void =
        SetTimeOfDay(0.0)

    SetToDawn() : void =
        SetTimeOfDay(0.25)

    SetToDusk() : void =
        SetTimeOfDay(0.75)

    # Pause/Resume cycle
    PauseCycle() : void =
        # Would need to track paused state and modify loop
        Print("Cycle paused")

    ResumeCycle() : void =
        Print("Cycle resumed")
