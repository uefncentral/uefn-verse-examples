# Reaction Training
# Verse code for Reaction Training - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/reaction-training?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /Verse.org }
using { /Verse.org/Concurrency }

ReactionTraining := class(creative_device):
    @editable TargetSpawners : []creature_placer_device = array{}
    @editable DisplayBoard : billboard_device = billboard_device{}
    @editable StartControl : button_device = button_device{}
    @editable StopControl : button_device = button_device{}
    @editable MinSpawnDelay : float = 1.0
    @editable MaxSpawnDelay : float = 3.0
    
    # State tracking
    var ActiveTargetIndex : int = -1  # No target active
    var BestReactionTime : float = 999.0
    var TotalReactionTime : float = 0.0
    var TargetCount : float = 0.0
    var TargetSpawnTime : float = 0.0
    var IsTrainingActive : logic = false
    
    # Helper function to convert strings to messages
    StringToMessage<localizes>(String : string) : message = "{String}"
    
    # Initialize the training device
    OnBegin<override>()<suspends>:void=
        DisplayBoard.SetText(StringToMessage("Press the Start button to begin training!"))
        
        # Subscribe to events for each spawner
        for (Spawner : TargetSpawners):
            Spawner.EliminatedEvent.Subscribe(OnTargetEliminated)
            
        # Subscribe to button events
        StartControl.InteractedWithEvent.Subscribe(OnStartButtonPressed)
        StopControl.InteractedWithEvent.Subscribe(OnStopButtonPressed)
        
        StartControl.Enable()
        StopControl.Disable()

    # Handle start button press
    OnStartButtonPressed(Agent : agent):void=
        if (IsTrainingActive = false):
            StartTraining()
            StartControl.Disable()
            StopControl.Enable()

    # Handle stop button press
    OnStopButtonPressed(Agent : agent):void=
        if (IsTrainingActive = true):
            StopTraining()
            StartControl.Enable()
            StopControl.Disable()

    # Main training loop
    StartTraining():void=
        set IsTrainingActive = true
        set TargetCount = 0.0
        set TotalReactionTime = 0.0
        set BestReactionTime = 999.0
        DisplayBoard.SetText(StringToMessage("Training Started!\nGet ready..."))
        
        # Start training loop in a new task
        spawn{ TrainingLoop() }
    
    # Stop the training
    StopTraining():void=
        set IsTrainingActive = false
        # Clean up any active targets
        for (Spawner : TargetSpawners):
            Spawner.Despawn()
        DisplayBoard.SetText(StringToMessage("Training Stopped\nFinal Stats:\nTargets Hit: {TargetCount}\nBest Time: {BestReactionTime} s"))
    
    # Training loop
    TrainingLoop()<suspends>:void=
        loop:
            if (IsTrainingActive = false):
                break
                
            # Pick and spawn new target
            var NewIndex : int = GetRandomInt(0, TargetSpawners.Length - 1)
            # Avoid same target twice in a row
            if (NewIndex = ActiveTargetIndex):
                set NewIndex = if (NewIndex + 1 >= TargetSpawners.Length) then 0 else NewIndex + 1
                
            set ActiveTargetIndex = NewIndex
            
            # Spawn new target
            if (NewSpawner := TargetSpawners[ActiveTargetIndex]):
                NewSpawner.Spawn()
                set TargetSpawnTime = GetSimulationElapsedTime()
                
            UpdateStats()
            
            # Wait for target hit or timeout
            Sleep(5.0)  # Timeout after 5 seconds if target not hit
            
            # Despawn current target if it wasn't hit
            if (CurrentSpawner := TargetSpawners[ActiveTargetIndex]):
                CurrentSpawner.Despawn()
            
            # Random delay before next target
            var RandomDelay : float = MinSpawnDelay + (GetRandomFloat(0.0, 1.0) * (MaxSpawnDelay - MinSpawnDelay))
            Sleep(RandomDelay)
    
    # Handle target hits
    OnTargetEliminated(Agent : ?agent):void=
        if (IsTrainingActive = false):
            return
        
        # Calculate reaction time
        var CurrentTime : float = GetSimulationElapsedTime()
        var ReactionTime : float = CurrentTime - TargetSpawnTime
        
        # Update stats
        set TargetCount = TargetCount + 1.0
        set TotalReactionTime += ReactionTime
        if (ReactionTime < BestReactionTime):
            set BestReactionTime = ReactionTime
            
        UpdateStats()
    
    # Update the stats display
    UpdateStats():void=
        if (TargetCount > 0.0):
            var AverageTime : float = TotalReactionTime / TargetCount
            DisplayBoard.SetText(StringToMessage("Targets Hit: {TargetCount}\nBest Time: {BestReactionTime} s\nAverage Time: {AverageTime} s"))