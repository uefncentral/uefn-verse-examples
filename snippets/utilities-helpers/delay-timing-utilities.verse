# Delay and Timing Utilities
# Helper functions for delays, intervals, and timed operations. Includes debounce and throttle patterns.
# Difficulty: intermediate  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/delay-timing-utilities?ref=github

using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# Timing and delay utility class
timing_controller := class:
    var LastExecutionTime : float = 0.0
    var CooldownDuration : float = 0.0

# Execute a function after a delay
DelayedExecute(DelaySeconds : float, Callback : tuple() -> void)<suspends> : void =
    Sleep(DelaySeconds)
    Callback()

# Execute a function repeatedly at an interval
RepeatAtInterval(IntervalSeconds : float, RepeatCount : int, Callback : tuple(int) -> void)<suspends> : void =
    for (I := 0..RepeatCount - 1):
        Callback(I)
        if (I < RepeatCount - 1):
            Sleep(IntervalSeconds)

# Execute forever at an interval (use in spawn block)
RepeatForever(IntervalSeconds : float, Callback : tuple() -> void)<suspends> : void =
    loop:
        Callback()
        Sleep(IntervalSeconds)

# Countdown from a number, calling callback each tick
Countdown(FromNumber : int, IntervalSeconds : float, OnTick : tuple(int) -> void, OnComplete : tuple() -> void)<suspends> : void =
    for (I := FromNumber..1):
        OnTick(I)
        Sleep(IntervalSeconds)
    OnComplete()

# Throttle - only execute if enough time has passed
# Returns true if executed, false if throttled
throttle_handler := class:
    var LastCallTime : float = -999999.0
    MinInterval : float = 1.0

    TryExecute(CurrentTime : float) : logic =
        if (CurrentTime - LastCallTime >= MinInterval):
            set LastCallTime = CurrentTime
            return true
        return false

# Debounce - delay execution until calls stop
# Use with spawn and race pattern
debounce_handler := class:
    var PendingExecution : logic = false
    DebounceTime : float = 0.5

    Trigger()<suspends> : void =
        set PendingExecution = true
        Sleep(DebounceTime)
        if (PendingExecution?):
            set PendingExecution = false
            # Execute the debounced action here

    Cancel() : void =
        set PendingExecution = false

# Wait until a condition is true
WaitUntil(Condition : tuple() -> logic, CheckInterval : float)<suspends> : void =
    loop:
        if (Condition()):
            break
        Sleep(CheckInterval)

# Wait for any of multiple events (returns index of first completed)
# Usage: Index := WaitForFirst(array{Event1, Event2})
# Note: This is a pattern example - actual implementation depends on event types
