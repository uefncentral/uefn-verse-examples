# Double Pump Training
# Verse code for Double Pump Training - UEFN/Fortnite Creative implementation
# Difficulty: intermediate  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/double-pump-training?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

DoublePumpTraining := class(creative_device):
    # For target knockdown counting
    @editable KnockdownTrigger : trigger_device = trigger_device{}
    @editable KnockdownBoard : billboard_device = billboard_device{}
    
    # For double pump timing
    @editable TimingTrigger : trigger_device = trigger_device{}
    @editable TimingBoard : billboard_device = billboard_device{}
    
    # Knockdown tracking
    var KnockDowns : int = 0
    var LastKnockdownTime : float = 0.0
    var BestKnockdownTime : float = 999.0
    var WorstKnockdownTime : float = 0.0
    var TotalKnockdownTime : float = 0.0
    
    # Double pump timing
    var LastShotTime : float = 0.0
    var CurrentShotTime : float = 0.0
    var BestTime : float = 999.0
    var WorstTime : float = 0.0
    var TotalShotTime : float = 0.0
    var ShotCount : int = 0
    
    StringToMessage<localizes>(String : string) : message = "{String}"

    OnBegin<override>()<suspends>:void=
        # Setup both displays
        KnockdownBoard.SetText(StringToMessage("Ready for Target Practice!"))
        TimingBoard.SetText(StringToMessage("Ready for Timing Practice!"))
        
        # Subscribe to both triggers
        KnockdownTrigger.TriggeredEvent.Subscribe(OnKnockDown)
        TimingTrigger.TriggeredEvent.Subscribe(OnTimingShot)

    OnKnockDown(Agent : ?agent):void=
        var CurrentTime : float = GetSimulationElapsedTime()
        if (LastKnockdownTime > 0.0):
            var TimeDiff : float = CurrentTime - LastKnockdownTime
            if (TimeDiff < BestKnockdownTime):
                set BestKnockdownTime = TimeDiff
            if (TimeDiff > WorstKnockdownTime):
                set WorstKnockdownTime = TimeDiff
            set TotalKnockdownTime += TimeDiff
        set LastKnockdownTime = CurrentTime
        set KnockDowns += 1
        
        # Calculate average
        var AverageKnockdown : float = 0.0
        if (KnockDowns > 1):
            var KnockdownFloat : float = KnockDowns * 1.0
            set AverageKnockdown = TotalKnockdownTime / (KnockdownFloat - 1.0)
            
        KnockdownBoard.SetText(StringToMessage("Target Knockdowns: {KnockDowns}\nBest Time: {BestKnockdownTime}\nWorst Time: {WorstKnockdownTime}\nAverage Time: {AverageKnockdown}"))

    OnTimingShot(Agent : ?agent):void=
        set CurrentShotTime = GetSimulationElapsedTime()
        if (LastShotTime > 0.0):
            var TimeBetweenShots : float = CurrentShotTime - LastShotTime
            if (TimeBetweenShots < BestTime):
                set BestTime = TimeBetweenShots
            if (TimeBetweenShots > WorstTime):
                set WorstTime = TimeBetweenShots
            set TotalShotTime += TimeBetweenShots
            set ShotCount += 1
            UpdateTimingDisplay()
        set LastShotTime = CurrentShotTime

    UpdateTimingDisplay():void=
        var AverageTime : float = 0.0
        if (ShotCount > 0):
            var ShotCountFloat : float = ShotCount * 1.0
            set AverageTime = TotalShotTime / ShotCountFloat
            
        TimingBoard.SetText(StringToMessage("Best Time: {BestTime}\nWorst Time: {WorstTime}\nAverage Time: {AverageTime}"))