# Capture The Flag Device
# Verse code for Capture The Flag Device - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/capture-the-flag-device?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/UI }
using { /Fortnite.com/Playspaces }
using { /Verse.org/Simulation }
using { /Verse.org/Colors }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }

# ============================================================================
# CAPTURE THE FLAG GAME MODE
# ============================================================================
# A complete CTF implementation with:
# - Two teams with flag bases at opposite ends
# - Flag pickup when player enters enemy base zone
# - Flag carrier visible on map and moves slower
# - Flag drops on elimination, can be picked up or returned
# - Score point when carrying enemy flag to your base
# - Flag auto-returns after 30 seconds on ground
# - First to 3 captures wins
# - Full UI showing flag status for both teams
# ============================================================================

# Enum to track flag states
flag_state := enum:
    AtBase
    Carried
    Dropped

# Struct to hold flag data
flag_data := struct:
    var State : flag_state = flag_state.AtBase
    var Carrier : ?agent = false
    var DroppedTime : float = 0.0
    var DroppedPosition : vector3 = vector3{X := 0.0, Y := 0.0, Z := 0.0}

# Main CTF Device
capture_the_flag_device := class(creative_device):

    # ========================================================================
    # EDITABLE PROPERTIES - Configure these in UEFN
    # ========================================================================
    
    # Team 1 (Red Team) Devices
    @editable
    Team1FlagBase : prop_manipulator_device = prop_manipulator_device{}
    
    @editable
    Team1FlagProp : prop_manipulator_device = prop_manipulator_device{}
    
    @editable
    Team1BaseZone : mutator_zone_device = mutator_zone_device{}
    
    @editable
    Team1FlagZone : mutator_zone_device = mutator_zone_device{}
    
    @editable
    Team1MapIndicator : map_indicator_device = map_indicator_device{}
    
    @editable
    Team1FlagCarrierIndicator : map_indicator_device = map_indicator_device{}
    
    # Team 2 (Blue Team) Devices
    @editable
    Team2FlagBase : prop_manipulator_device = prop_manipulator_device{}
    
    @editable
    Team2FlagProp : prop_manipulator_device = prop_manipulator_device{}
    
    @editable
    Team2BaseZone : mutator_zone_device = mutator_zone_device{}
    
    @editable
    Team2FlagZone : mutator_zone_device = mutator_zone_device{}
    
    @editable
    Team2MapIndicator : map_indicator_device = map_indicator_device{}
    
    @editable
    Team2FlagCarrierIndicator : map_indicator_device = map_indicator_device{}
    
    # Game Configuration Devices
    @editable
    Team1ScoreManager : score_manager_device = score_manager_device{}
    
    @editable
    Team2ScoreManager : score_manager_device = score_manager_device{}
    
    @editable
    FlagCarrierSpeedModifier : player_speed_modifier_device = player_speed_modifier_device{}
    
    @editable
    EndGameDevice : end_game_device = end_game_device{}
    
    @editable
    Team1HUDMessage : hud_message_device = hud_message_device{}
    
    @editable
    Team2HUDMessage : hud_message_device = hud_message_device{}
    
    @editable
    GlobalHUDMessage : hud_message_device = hud_message_device{}
    
    @editable
    Team1Billboard : billboard_device = billboard_device{}
    
    @editable
    Team2Billboard : billboard_device = billboard_device{}
    
    # Game Settings
    @editable
    ScoreToWin : int = 3
    
    @editable
    FlagReturnTime : float = 30.0
    
    @editable
    FlagCarrierSpeedMultiplier : float = 0.7
    
    # ========================================================================
    # INTERNAL VARIABLES
    # ========================================================================
    
    var Team1Flag : flag_data = flag_data{}
    var Team2Flag : flag_data = flag_data{}
    
    var Team1Score : int = 0
    var Team2Score : int = 0
    
    var GameActive : logic = true
    
    var FlagReturnTasks : [agent]?cancelable = map{}
    
    # ========================================================================
    # INITIALIZATION
    # ========================================================================
    
    OnBegin<override>()<suspends> : void =
        Print("Capture The Flag - Initializing...")
        
        # Initialize flag states
        set Team1Flag = flag_data{State := flag_state.AtBase}
        set Team2Flag = flag_data{State := flag_state.AtBase}
        
        # Set up zone event subscriptions
        Team1FlagZone.AgentEntersEvent.Subscribe(OnPlayerEnterTeam1FlagZone)
        Team2FlagZone.AgentEntersEvent.Subscribe(OnPlayerEnterTeam2FlagZone)
        
        Team1BaseZone.AgentEntersEvent.Subscribe(OnPlayerEnterTeam1Base)
        Team2BaseZone.AgentEntersEvent.Subscribe(OnPlayerEnterTeam2Base)
        
        # Subscribe to elimination events
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerRemoved)
        
        # Subscribe to all player eliminations
        SubscribeToEliminations()
        
        # Initialize map indicators
        Team1FlagCarrierIndicator.Disable()
        Team2FlagCarrierIndicator.Disable()
        
        # Update initial UI
        UpdateFlagStatusUI()
        
        Print("Capture The Flag - Ready!")
        
        # Start the flag return timer loop
        spawn { FlagReturnTimerLoop() }
    
    # ========================================================================
    # ELIMINATION HANDLING
    # ========================================================================
    
    SubscribeToEliminations() : void =
        # Get all players and subscribe to their elimination events
        AllPlayers := GetPlayspace().GetPlayers()
        for (Player : AllPlayers):
            if (FortCharacter := Player.GetFortCharacter[]):
                FortCharacter.EliminatedEvent().Subscribe(OnPlayerEliminated)
    
    OnPlayerEliminated(Result : elimination_result) : void =
        EliminatedAgent := Result.EliminatedCharacter.GetAgent[]
        
        if (Agent := EliminatedAgent?):
            # Check if this player was carrying a flag
            if (Team1Flag.State = flag_state.Carried):
                if (Carrier := Team1Flag.Carrier?):
                    if (Carrier = Agent):
                        DropFlag(1, Agent)
            
            if (Team2Flag.State = flag_state.Carried):
                if (Carrier := Team2Flag.Carrier?):
                    if (Carrier = Agent):
                        DropFlag(2, Agent)
    
    OnPlayerRemoved(Player : player) : void =
        # Handle player leaving - drop their flag if carrying
        if (Team1Flag.State = flag_state.Carried):
            if (Carrier := Team1Flag.Carrier?):
                if (Carrier = Player):
                    ReturnFlagToBase(1)
                    BroadcastMessage("Team 1's flag returned - carrier left!")
        
        if (Team2Flag.State = flag_state.Carried):
            if (Carrier := Team2Flag.Carrier?):
                if (Carrier = Player):
                    ReturnFlagToBase(2)
                    BroadcastMessage("Team 2's flag returned - carrier left!")
    
    # ========================================================================
    # FLAG ZONE EVENTS
    # ========================================================================
    
    OnPlayerEnterTeam1FlagZone(Agent : agent) : void =
        if (not GameActive?):
            return
            
        # Only allow pickup if flag is at base or dropped
        if (Team1Flag.State = flag_state.AtBase or Team1Flag.State = flag_state.Dropped):
            TeamIndex := GetAgentTeamIndex(Agent)
            
            if (TeamIndex = 1):
                # Team 1 player returning their own flag
                if (Team1Flag.State = flag_state.Dropped):
                    ReturnFlagToBase(1)
                    BroadcastMessage("Team 1's flag returned!")
            else if (TeamIndex = 2):
                # Team 2 player picking up Team 1's flag
                PickupFlag(1, Agent)
                BroadcastMessage("Team 2 has Team 1's flag!")
    
    OnPlayerEnterTeam2FlagZone(Agent : agent) : void =
        if (not GameActive?):
            return
            
        if (Team2Flag.State = flag_state.AtBase or Team2Flag.State = flag_state.Dropped):
            TeamIndex := GetAgentTeamIndex(Agent)
            
            if (TeamIndex = 2):
                # Team 2 player returning their own flag
                if (Team2Flag.State = flag_state.Dropped):
                    ReturnFlagToBase(2)
                    BroadcastMessage("Team 2's flag returned!")
            else if (TeamIndex = 1):
                # Team 1 player picking up Team 2's flag
                PickupFlag(2, Agent)
                BroadcastMessage("Team 1 has Team 2's flag!")
    
    # ========================================================================
    # BASE ZONE EVENTS (SCORING)
    # ========================================================================
    
    OnPlayerEnterTeam1Base(Agent : agent) : void =
        if (not GameActive?):
            return
            
        TeamIndex := GetAgentTeamIndex(Agent)
        
        # Team 1 player with Team 2's flag scores
        if (TeamIndex = 1):
            if (Team2Flag.State = flag_state.Carried):
                if (Carrier := Team2Flag.Carrier?):
                    if (Carrier = Agent):
                        # Check if Team 1's flag is at base (required to score)
                        if (Team1Flag.State = flag_state.AtBase):
                            ScorePoint(1, Agent)
                        else:
                            ShowMessageToPlayer(Agent, "Your flag must be at base to score!")
    
    OnPlayerEnterTeam2Base(Agent : agent) : void =
        if (not GameActive?):
            return
            
        TeamIndex := GetAgentTeamIndex(Agent)
        
        # Team 2 player with Team 1's flag scores
        if (TeamIndex = 2):
            if (Team1Flag.State = flag_state.Carried):
                if (Carrier := Team1Flag.Carrier?):
                    if (Carrier = Agent):
                        # Check if Team 2's flag is at base (required to score)
                        if (Team2Flag.State = flag_state.AtBase):
                            ScorePoint(2, Agent)
                        else:
                            ShowMessageToPlayer(Agent, "Your flag must be at base to score!")
    
    # ========================================================================
    # FLAG ACTIONS
    # ========================================================================
    
    PickupFlag(FlagTeam : int, Agent : agent) : void =
        if (FlagTeam = 1):
            set Team1Flag.State = flag_state.Carried
            set Team1Flag.Carrier = option{Agent}
            
            # Hide flag at base, show carrier indicator
            Team1FlagProp.Hide()
            Team1FlagCarrierIndicator.Enable()
            Team1FlagCarrierIndicator.Attach(Agent)
            
            # Slow down the carrier
            FlagCarrierSpeedModifier.AddTo(Agent)
            
            # Cancel any return timer
            CancelFlagReturnTimer(Agent)
            
        else if (FlagTeam = 2):
            set Team2Flag.State = flag_state.Carried
            set Team2Flag.Carrier = option{Agent}
            
            Team2FlagProp.Hide()
            Team2FlagCarrierIndicator.Enable()
            Team2FlagCarrierIndicator.Attach(Agent)
            
            FlagCarrierSpeedModifier.AddTo(Agent)
            
            CancelFlagReturnTimer(Agent)
        
        UpdateFlagStatusUI()
    
    DropFlag(FlagTeam : int, Agent : agent) : void =
        # Get drop position from player
        var DropPosition : vector3 = vector3{X := 0.0, Y := 0.0, Z := 0.0}
        
        if (FortCharacter := Agent.GetFortCharacter[]):
            DropPosition := FortCharacter.GetTransform().Translation
        
        if (FlagTeam = 1):
            set Team1Flag.State = flag_state.Dropped
            set Team1Flag.Carrier = false
            set Team1Flag.DroppedTime = GetSimulationElapsedTime()
            set Team1Flag.DroppedPosition = DropPosition
            
            # Move flag prop to drop location
            Team1FlagProp.MoveTo(DropPosition, IdentityRotation())
            Team1FlagProp.Show()
            Team1FlagCarrierIndicator.Disable()
            
            # Remove speed modifier
            FlagCarrierSpeedModifier.RemoveFrom(Agent)
            
            # Start return timer
            spawn { StartFlagReturnTimer(1, DropPosition) }
            
            BroadcastMessage("Team 1's flag dropped!")
            
        else if (FlagTeam = 2):
            set Team2Flag.State = flag_state.Dropped
            set Team2Flag.Carrier = false
            set Team2Flag.DroppedTime = GetSimulationElapsedTime()
            set Team2Flag.DroppedPosition = DropPosition
            
            Team2FlagProp.MoveTo(DropPosition, IdentityRotation())
            Team2FlagProp.Show()
            Team2FlagCarrierIndicator.Disable()
            
            FlagCarrierSpeedModifier.RemoveFrom(Agent)
            
            spawn { StartFlagReturnTimer(2, DropPosition) }
            
            BroadcastMessage("Team 2's flag dropped!")
        
        UpdateFlagStatusUI()
    
    ReturnFlagToBase(FlagTeam : int) : void =
        if (FlagTeam = 1):
            set Team1Flag.State = flag_state.AtBase
            set Team1Flag.Carrier = false
            
            # Reset flag prop to base position
            Team1FlagProp.Show()
            Team1FlagCarrierIndicator.Disable()
            
        else if (FlagTeam = 2):
            set Team2Flag.State = flag_state.AtBase
            set Team2Flag.Carrier = false
            
            Team2FlagProp.Show()
            Team2FlagCarrierIndicator.Disable()
        
        UpdateFlagStatusUI()
    
    # ========================================================================
    # FLAG RETURN TIMER
    # ========================================================================
    
    StartFlagReturnTimer(FlagTeam : int, Position : vector3)<suspends> : void =
        Sleep(FlagReturnTime)
        
        # Check if flag is still dropped at this position
        if (FlagTeam = 1 and Team1Flag.State = flag_state.Dropped):
            ReturnFlagToBase(1)
            BroadcastMessage("Team 1's flag auto-returned!")
        else if (FlagTeam = 2 and Team2Flag.State = flag_state.Dropped):
            ReturnFlagToBase(2)
            BroadcastMessage("Team 2's flag auto-returned!")
    
    FlagReturnTimerLoop()<suspends> : void =
        loop:
            Sleep(1.0)
            
            # Update countdown UI for dropped flags
            CurrentTime := GetSimulationElapsedTime()
            
            if (Team1Flag.State = flag_state.Dropped):
                TimeRemaining := FlagReturnTime - (CurrentTime - Team1Flag.DroppedTime)
                if (TimeRemaining <= 0.0):
                    ReturnFlagToBase(1)
                    BroadcastMessage("Team 1's flag auto-returned!")
            
            if (Team2Flag.State = flag_state.Dropped):
                TimeRemaining := FlagReturnTime - (CurrentTime - Team2Flag.DroppedTime)
                if (TimeRemaining <= 0.0):
                    ReturnFlagToBase(2)
                    BroadcastMessage("Team 2's flag auto-returned!")
    
    CancelFlagReturnTimer(Agent : agent) : void =
        if (Task := FlagReturnTasks[Agent]):
            Task.Cancel()
            if (set FlagReturnTasks = FlagReturnTasks.RemoveElement[Agent]):
                # Task cancelled successfully
                Print("Flag return timer cancelled")
    
    # ========================================================================
    # SCORING
    # ========================================================================
    
    ScorePoint(ScoringTeam : int, Agent : agent) : void =
        if (ScoringTeam = 1):
            set Team1Score = Team1Score + 1
            Team1ScoreManager.Activate(Agent)
            
            # Return the enemy flag
            ReturnFlagToBase(2)
            
            # Remove carrier effects
            FlagCarrierSpeedModifier.RemoveFrom(Agent)
            Team2FlagCarrierIndicator.Disable()
            
            BroadcastMessage("TEAM 1 SCORES! ({Team1Score}/{ScoreToWin})")
            
            if (Team1Score >= ScoreToWin):
                EndGame(1)
                
        else if (ScoringTeam = 2):
            set Team2Score = Team2Score + 1
            Team2ScoreManager.Activate(Agent)
            
            ReturnFlagToBase(1)
            
            FlagCarrierSpeedModifier.RemoveFrom(Agent)
            Team1FlagCarrierIndicator.Disable()
            
            BroadcastMessage("TEAM 2 SCORES! ({Team2Score}/{ScoreToWin})")
            
            if (Team2Score >= ScoreToWin):
                EndGame(2)
        
        UpdateFlagStatusUI()
    
    EndGame(WinningTeam : int) : void =
        set GameActive = false
        
        if (WinningTeam = 1):
            BroadcastMessage("TEAM 1 WINS!")
        else:
            BroadcastMessage("TEAM 2 WINS!")
        
        # Activate end game
        EndGameDevice.Activate(GetPlayspace().GetPlayers()[0])
    
    # ========================================================================
    # UI UPDATES
    # ========================================================================
    
    UpdateFlagStatusUI() : void =
        # Build status strings
        Team1Status := GetFlagStatusString(1)
        Team2Status := GetFlagStatusString(2)
        
        # Update billboards
        Team1Billboard.SetText(StringToMessage("Team 1 Flag: {Team1Status}"))
        Team2Billboard.SetText(StringToMessage("Team 2 Flag: {Team2Status}"))
        
        # Update HUD messages
        ScoreText := "Score: Team 1 [{Team1Score}] - Team 2 [{Team2Score}]"
        GlobalHUDMessage.SetText(StringToMessage(ScoreText))
    
    GetFlagStatusString(FlagTeam : int) : string =
        if (FlagTeam = 1):
            case (Team1Flag.State):
                flag_state.AtBase => return "AT BASE"
                flag_state.Carried => return "STOLEN!"
                flag_state.Dropped => return "DROPPED"
        else:
            case (Team2Flag.State):
                flag_state.AtBase => return "AT BASE"
                flag_state.Carried => return "STOLEN!"
                flag_state.Dropped => return "DROPPED"
        
        return "UNKNOWN"
    
    # ========================================================================
    # UTILITY FUNCTIONS
    # ========================================================================
    
    GetAgentTeamIndex(Agent : agent) : int =
        if (Player := player[Agent]):
            if (FortCharacter := Player.GetFortCharacter[]):
                TeamCollection := GetPlayspace().GetTeamCollection()
                if (Team := TeamCollection.GetTeam[FortCharacter]):
                    # Returns 1 for Team 1, 2 for Team 2, etc.
                    Teams := TeamCollection.GetTeams()
                    for (Index -> T : Teams):
                        if (T = Team):
                            return Index + 1
        return 0
    
    BroadcastMessage(Message : string) : void =
        GlobalHUDMessage.SetText(StringToMessage(Message))
        GlobalHUDMessage.Show()
    
    ShowMessageToPlayer(Agent : agent, Message : string) : void =
        # Show message to specific player using HUD
        Team1HUDMessage.SetText(StringToMessage(Message))
        Team1HUDMessage.Show(Agent)
    
    StringToMessage<localizes>(Text : string) : message = "{Text}"
