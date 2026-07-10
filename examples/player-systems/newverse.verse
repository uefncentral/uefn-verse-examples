# Player Score Elimination Tracker
# A game manager that tracks player eliminations and deaths, automatically updating scores based on kills (+1) and deaths (-1). It manages player spawning, subscription cleanup, and provides localized s
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/newverse?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Simulation/Tags }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }

# Spawner tag to identify player spawn points
spawner := class(tag){}

# Custom player data structure
custom_player := class():
    Player : player
    var Subscriptions : []cancelable = array{}

    # Clean up subscriptions
    CleanUp():void=
        for (Sub : Subscriptions):
            Sub.Cancel()

# Constants for game configuration
constants := class():
    # Score limits
    MAX_SCORE : int = 1000
    MIN_SCORE : int = 0
    
    # Score adjustments
    ELIMINATION_SCORE : int = 1
    DEATH_SCORE : int = -1

# Main game manager class
game_manager := class(creative_device):
    # Player tracking
    var CustomPlayers : [player]custom_player = map{}
    
    # Required devices
    @editable StatCreator : stat_creator_device = stat_creator_device{}
    @editable PlayerStatsManager : player_stats_manager = player_stats_manager{}
    @editable EliminationDevice : elimination_manager_device = elimination_manager_device{}
    
    # Logging level
    var LoggingEnabled : logic = true
    
    # Localized message formatting
    GetAgentScore<localizes>(Agent : agent, Score : int):message = "{Agent} score: {Score}"
    GetErrorMessage<localizes>(Message : string):message = "Error: {Message}"

    # Initialize the game manager
    OnBegin<override>()<suspends>:void=
        if (ValidateDevices()):
            GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerLeft)
            EliminationDevice.EliminationEvent.Subscribe(OnElimination)
            EliminationDevice.EliminatedEvent.Subscribe(OnEliminated)
            InitSpawners()
            LogMessage("Game Manager initialized successfully")
        else:
            LogError("Failed to initialize - invalid device configuration")

    # Validate all required devices are properly set
    ValidateDevices():logic=
        if (StatCreator = null):
            LogError("StatCreator device not set")
            false
        else if (PlayerStatsManager = null):
            LogError("PlayerStatsManager device not set")
            false
        else if (EliminationDevice = null):
            LogError("EliminationDevice device not set")
            false
        else:
            true

    # Initialize spawn points
    InitSpawners():void=
        SpawnerCount := 0
        for (Tagged : FindCreativeObjectsWithTag(spawner{}), Obj := Tagged):
            if (Spawner := player_spawner_device[Obj]):
                Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)
                set SpawnerCount += 1
        
        if (SpawnerCount = 0):
            LogError("No spawner devices found with spawner tag")
        else:
            LogMessage("Initialized {SpawnerCount} spawners")

    # Handle player spawn
    OnPlayerSpawned(Agent : agent):void=
        if:
            Player := player[Agent]
            not CustomPlayers[Player]  # Only initialize new players
        then:
            InitPlayer(Player)

    # Initialize a new player
    InitPlayer(Player : player):void=
        if (FortChar := Player.GetFortCharacter[]):
            var Subscriptions : []cancelable = array{}
            
            # Subscribe to elimination events
            EliminationSub := FortChar.EliminatedEvent().Subscribe(UpdateEliminations)
            if (set Subscriptions += array{EliminationSub}):
                {}
            
            # Initialize stats
            PlayerStatsManager.InitPlayerStats(Player)
            InitPlayerStats(Player)
            
            # Create and store custom player
            CustomPlayer := custom_player{Player := Player, Subscriptions := Subscriptions}
            if (set CustomPlayers[Player] = CustomPlayer):
                LogMessage("Player {Player} initialized")
        else:
            LogError("Failed to get character for player {Player}")

    # Initialize player statistics
    InitPlayerStats(Player : player):void=
        if (PlayerStats := PlayerStatsManager.GetPlayerStats(Player)):
            if (not StatCreator.SetLevel[Player, PlayerStats.Rank]):
                LogError("Failed to set initial level for player {Player}")
            if (not StatCreator.SetValue[Player, PlayerStats.CurrentScore]):
                LogError("Failed to set initial score for player {Player}")

    # Update eliminations with safety checks
    UpdateEliminations(Result : elimination_result):void=
        if:
            EliminatingChar := Result.EliminatingCharacter?
            EliminatedChar := Result.EliminatedCharacter
            EliminatingChar <> EliminatedChar  # Prevent self-elimination counting
        then:
            spawn{UpdatePlayerStats(EliminatingChar, constants.ELIMINATION_SCORE)}
            spawn{UpdatePlayerStats(EliminatedChar, constants.DEATH_SCORE)}

    # Handle elimination events
    OnElimination(Agent : agent):void=
        if:
            EliminatorPlayer := player[Agent]
            EliminatorChar := EliminatorPlayer.GetFortCharacter[]
        then:
            spawn{UpdatePlayerStats(EliminatorChar, constants.ELIMINATION_SCORE)}

    # Handle eliminated events
    OnEliminated(Eliminated : agent):void=
        if:
            EliminatedPlayer := player[Eliminated]
            EliminatedChar := EliminatedPlayer.GetFortCharacter[]
        then:
            spawn{UpdatePlayerStats(EliminatedChar, constants.DEATH_SCORE)}

    # Update player statistics with validation
    UpdatePlayerStats(PlayerChar : fort_character, Value : int)<suspends>:void=
        if:
            Agent := PlayerChar.GetAgent[]
            Player := player[Agent]
            PlayerStats := PlayerStatsManager.GetPlayerStats(Player)
            CurrentScore := StatCreator.GetValue[Player]
            NewScore := CurrentScore + Value
            # Validate score bounds
            NewScore >= constants.MIN_SCORE and NewScore <= constants.MAX_SCORE
        then:
            if (StatCreator.SetValue[Player, NewScore]):
                if:
                    PlayerNewLevel := StatCreator.GetLevel[Player]
                    PlayerStatsManager.UpdateScore(Player, PlayerNewLevel, NewScore)
                then:
                    Message := GetAgentScore(Player, NewScore)
                    Print(Message)
                    LogMessage("Updated stats for player {Player}: Level {PlayerNewLevel}, Score {NewScore}")
                else:
                    LogError("Failed to update player stats in PlayerStatsManager")
            else:
                LogError("Failed to set new score value")
        else:
            LogError("Invalid score update attempted")

    # Handle player leaving
    OnPlayerLeft(LeavingPlayer : player):void=
        if (CustomPlayer := CustomPlayers[LeavingPlayer]):
            # Clean up subscriptions
            CustomPlayer.CleanUp()
            
            # Remove player from tracking
            var NewCustomPlayers : [player]custom_player = map{}
            for (Key -> Value : CustomPlayers, Key <> LeavingPlayer):
                set NewCustomPlayers = ConcatenateMaps(NewCustomPlayers, map{Key => Value})
            set CustomPlayers = NewCustomPlayers
            
            LogMessage("Player {LeavingPlayer} removed")

    # Logging utilities
    LogMessage(Message : string):void=
        if (LoggingEnabled):
            Print("GameManager: {Message}")

    LogError(Message : string):void=
        Print(GetErrorMessage(Message))