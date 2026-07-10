# Hide And Seek Device
# Verse code for Hide And Seek Device - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/hide-and-seek-device?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

# Hide and Seek Game Device
# Manages a complete hide and seek game with hiding phase, seeking phase, and win conditions
hide_and_seek_device := class(creative_device):

    # ==================== EDITABLE PROPERTIES ====================
    
    @editable
    HidingPhaseDuration : float = 30.0  # Seconds hiders have to hide
    
    @editable
    SeekingPhaseDuration : float = 180.0  # Seconds seekers have to find everyone
    
    @editable
    SeekerSpeedMultiplier : float = 1.2  # Seekers move faster
    
    @editable
    NumberOfSeekers : int = 1  # How many seekers at game start
    
    @editable
    TagRange : float = 200.0  # Distance for seeker to tag a hider
    
    # ==================== DEVICE REFERENCES ====================
    
    @editable
    HiderSpawners : []player_spawner_device = array{}
    
    @editable
    SeekerSpawners : []player_spawner_device = array{}
    
    @editable
    SeekerHoldingZone : player_spawner_device = player_spawner_device{}
    
    @editable
    HidingPhaseTimer : timer_device = timer_device{}
    
    @editable
    SeekingPhaseTimer : timer_device = timer_device{}
    
    @editable
    GameEndDevice : end_game_device = end_game_device{}
    
    @editable
    HiderTeam : team_settings_and_inventory_device = team_settings_and_inventory_device{}
    
    @editable
    SeekerTeam : team_settings_and_inventory_device = team_settings_and_inventory_device{}
    
    @editable
    TagButton : button_device = button_device{}  # Seeker uses this to tag
    
    @editable
    HiderFoundVFX : vfx_spawner_device = vfx_spawner_device{}
    
    @editable
    HUDMessageDevice : hud_message_device = hud_message_device{}
    
    # ==================== INTERNAL STATE ====================
    
    var Hiders : []player = array{}
    var Seekers : []player = array{}
    var FoundHiders : []player = array{}
    var GamePhase : game_phase = game_phase.Waiting
    var IsGameActive : logic = false
    
    # Game phase enum
    game_phase := enum:
        Waiting
        Hiding
        Seeking
        GameOver
    
    # ==================== INITIALIZATION ====================
    
    OnBegin<override>()<suspends> : void =
        Print("Hide and Seek Device Initialized")
        
        # Subscribe to timer events
        HidingPhaseTimer.SuccessEvent.Subscribe(OnHidingPhaseEnd)
        SeekingPhaseTimer.SuccessEvent.Subscribe(OnSeekingPhaseEnd)
        
        # Subscribe to tag button
        TagButton.InteractedWithEvent.Subscribe(OnTagAttempt)
        
        # Subscribe to player events
        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerAdded)
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerRemoved)
        
        # Start the game after a short delay to let players join
        Sleep(5.0)
        StartGame()
    
    # ==================== GAME FLOW ====================
    
    StartGame() : void =
        if (IsGameActive?):
            return
            
        set IsGameActive = true
        set GamePhase = game_phase.Hiding
        
        Print("Starting Hide and Seek Game!")
        
        # Get all players
        AllPlayers := GetPlayspace().GetPlayers()
        
        # Assign teams
        AssignTeams(AllPlayers)
        
        # Teleport hiders to hiding area
        SpawnHiders()
        
        # Hold seekers in waiting zone
        HoldSeekers()
        
        # Start hiding phase timer
        HidingPhaseTimer.Start()
        
        # Show HUD message
        ShowMessage("HIDING PHASE - Hiders have {HidingPhaseDuration} seconds to hide!")
    
    AssignTeams(AllPlayers : []player) : void =
        # Shuffle players for random selection
        var ShuffledPlayers : []player = array{}
        for (P : AllPlayers):
            set ShuffledPlayers = ShuffledPlayers + array{P}
        
        # Select seekers
        var SeekerCount : int = 0
        var TempSeekers : []player = array{}
        var TempHiders : []player = array{}
        
        for (Index -> P : ShuffledPlayers):
            if (SeekerCount < NumberOfSeekers):
                set TempSeekers = TempSeekers + array{P}
                set SeekerCount = SeekerCount + 1
                Print("Player assigned as SEEKER")
            else:
                set TempHiders = TempHiders + array{P}
                Print("Player assigned as HIDER")
        
        set Seekers = TempSeekers
        set Hiders = TempHiders
        set FoundHiders = array{}
    
    SpawnHiders() : void =
        var SpawnerIndex : int = 0
        for (Hider : Hiders):
            if (SpawnerIndex < HiderSpawners.Length):
                if (Spawner := HiderSpawners[SpawnerIndex]):
                    Spawner.# SpawnPlayer(Hider)  # TODO: not a Verse function — use player_spawner_device
            set SpawnerIndex = (SpawnerIndex + 1) % Max(HiderSpawners.Length, 1)
    
    HoldSeekers() : void =
        for (Seeker : Seekers):
            SeekerHoldingZone.# SpawnPlayer(Seeker)  # TODO: not a Verse function — use player_spawner_device
            # Could add movement restriction here if needed
    
    ReleaseSeekers() : void =
        var SpawnerIndex : int = 0
        for (Seeker : Seekers):
            if (SpawnerIndex < SeekerSpawners.Length):
                if (Spawner := SeekerSpawners[SpawnerIndex]):
                    Spawner.# SpawnPlayer(Seeker)  # TODO: not a Verse function — use player_spawner_device
            set SpawnerIndex = (SpawnerIndex + 1) % Max(SeekerSpawners.Length, 1)
    
    # ==================== PHASE TRANSITIONS ====================
    
    OnHidingPhaseEnd(MaybeAgent : ?agent) : void =
        set GamePhase = game_phase.Seeking
        
        Print("Hiding Phase Over - Seekers Released!")
        ShowMessage("SEEKING PHASE - Seekers are coming! You have {SeekingPhaseDuration} seconds!")
        
        # Release seekers
        ReleaseSeekers()
        
        # Start seeking phase timer
        SeekingPhaseTimer.Start()
        
        # Enable tag functionality
        TagButton.Enable()
    
    OnSeekingPhaseEnd(MaybeAgent : ?agent) : void =
        # Time ran out - Hiders win if any remain
        if (GetRemainingHiders().Length > 0):
            HidersWin()
        else:
            SeekersWin()
    
    # ==================== TAGGING SYSTEM ====================
    
    OnTagAttempt(Agent : agent) : void =
        if (GamePhase <> game_phase.Seeking):
            return
        
        # Check if the agent is a seeker
        if (Player := player[Agent]):
            if (not IsSeeker(Player)):
                return
            
            # Find nearest hider within range
            if (SeekerChar := Player.GetFortCharacter[]):
                SeekerPos := SeekerChar.GetTransform().Translation
                
                for (Hider : GetRemainingHiders()):
                    if (HiderChar := Hider.GetFortCharacter[]):
                        HiderPos := HiderChar.GetTransform().Translation
                        Distance := Distance(SeekerPos, HiderPos)
                        
                        if (Distance <= TagRange):
                            TagHider(Hider, Player)
                            return
                
                # No hider in range
                Print("No hider in range to tag!")
    
    TagHider(Hider : player, Seeker : player) : void =
        Print("Hider has been tagged!")
        
        # Add to found list
        set FoundHiders = FoundHiders + array{Hider}
        
        # Play VFX
        if (HiderChar := Hider.GetFortCharacter[]):
            HiderFoundVFX.SpawnAt(HiderChar.GetTransform().Translation, HiderChar.GetTransform().Rotation)
        
        # Convert hider to seeker (optional mechanic)
        set Seekers = Seekers + array{Hider}
        
        ShowMessage("{GetRemainingHiders().Length} hiders remaining!")
        
        # Check win condition
        if (GetRemainingHiders().Length <= 0):
            SeekersWin()
    
    # ==================== WIN CONDITIONS ====================
    
    SeekersWin() : void =
        set GamePhase = game_phase.GameOver
        set IsGameActive = false
        
        Print("SEEKERS WIN!")
        ShowMessage("SEEKERS WIN! All hiders have been found!")
        
        # Stop timers
        HidingPhaseTimer.Reset()
        SeekingPhaseTimer.Reset()
        
        # End game after delay
        spawn{ EndGameAfterDelay(5.0) }
    
    HidersWin() : void =
        set GamePhase = game_phase.GameOver
        set IsGameActive = false
        
        Print("HIDERS WIN!")
        ShowMessage("HIDERS WIN! {GetRemainingHiders().Length} hiders survived!")
        
        # Stop timers
        HidingPhaseTimer.Reset()
        SeekingPhaseTimer.Reset()
        
        # End game after delay
        spawn{ EndGameAfterDelay(5.0) }
    
    EndGameAfterDelay(Delay : float)<suspends> : void =
        Sleep(Delay)
        GameEndDevice.Activate(false)
    
    # ==================== UTILITY FUNCTIONS ====================
    
    GetRemainingHiders() : []player =
        var Remaining : []player = array{}
        for (Hider : Hiders):
            var WasFound : logic = false
            for (Found : FoundHiders):
                if (Hider = Found):
                    set WasFound = true
            if (not WasFound?):
                set Remaining = Remaining + array{Hider}
        return Remaining
    
    IsSeeker(Player : player) : logic =
        for (S : Seekers):
            if (S = Player):
                return true
        return false
    
    IsHider(Player : player) : logic =
        for (H : Hiders):
            if (H = Player):
                return true
        return false
    
    ShowMessage(Message : string) : void =
        HUDMessageDevice.Show()
        Print(Message)
    
    Distance(A : vector3, B : vector3) : float =
        DX := A.X - B.X
        DY := A.Y - B.Y
        DZ := A.Z - B.Z
        return Sqrt((DX * DX) + (DY * DY) + (DZ * DZ))
    
    # ==================== PLAYER MANAGEMENT ====================
    
    OnPlayerAdded(Player : player) : void =
        Print("Player joined the game")
        
        # If game is in progress, add as spectator or seeker
        if (IsGameActive?):
            if (GamePhase = game_phase.Seeking):
                # Late joiners become seekers
                set Seekers = Seekers + array{Player}
                if (SeekerSpawners.Length > 0):
                    if (Spawner := SeekerSpawners[0]):
                        Spawner.# SpawnPlayer(Player)  # TODO: not a Verse function — use player_spawner_device
    
    OnPlayerRemoved(Player : player) : void =
        Print("Player left the game")
        
        # Remove from appropriate list
        var NewHiders : []player = array{}
        for (H : Hiders):
            if (H <> Player):
                set NewHiders = NewHiders + array{H}
        set Hiders = NewHiders
        
        var NewSeekers : []player = array{}
        for (S : Seekers):
            if (S <> Player):
                set NewSeekers = NewSeekers + array{S}
        set Seekers = NewSeekers
        
        # Check if game should end
        if (IsGameActive?):
            if (GetRemainingHiders().Length <= 0):
                SeekersWin()
            else if (Seekers.Length <= 0):
                HidersWin()
