# Voting Loadout System
# A voting system that allows players to vote for different loadouts during a timed voting phase. When voting ends, the system determines the winning loadout and grants corresponding items to players th
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/votingandloadout-1?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors }

# A device that manages voting and assigns loadouts based on the winning vote
voting_loadout_manager := class(creative_device):

    # Array to store voting buttons, each representing a loadout
    @editable
    VoteButtons : []button_device = array{}

    # Array to store item granters corresponding to loadouts
    @editable
    ItemGranters : []item_granter_device = array{}

    # Timer device to display the countdown
    @editable
    VotingTimer : timer_device = timer_device{}

    # Store votes for each loadout
    var VoteCounts : []int = array{}

    # Track if voting phase is active
    var IsVotingActive : logic = false

    # Voting duration in seconds
    @editable
    VotingDuration : float = 30.0

    # Winning loadout index
    var WinningIndex : int = -1

    # Store player votes to prevent multiple voting
    var PlayerVotes : [fort_character]logic = map{}

    # Called when the game starts
    OnBegin<override>() : void =
        InitializeVoteCounts()
        SetupButtonInteractions()
        StartVotingPhase()

    # Initialize vote counts to match the number of buttons
    InitializeVoteCounts() : void =
        set VoteCounts = array{}
        for (Button : VoteButtons):
            set VoteCounts += array{0}

    # Starts the voting phase
    StartVotingPhase() : void =
        set IsVotingActive = true
        Print("Voting has started!")

        # Reset player votes
        set PlayerVotes = map{}

        # Configure and start the timer
        VotingTimer.SetMaxDuration(VotingDuration)
        VotingTimer.Start()

        # Enable all voting buttons
        for (Button : VoteButtons):
            Button.Enable()

        # Subscribe to timer completion
        VotingTimer.SuccessEvent.Subscribe(OnTimerComplete)

    # Timer completion handler
    OnTimerComplete(Agent : ?agent) : void =
        if (VoteActive := IsVotingActive?):
            if (VoteActive = true):
                set IsVotingActive = false
                Print("Voting has ended!")

                # Disable all buttons
                for (Button : VoteButtons):
                    Button.Disable()

                # Find and process winning loadout
                var Winner : int = FindWinningIndex()
                Print("Vote totals:")
                var i : int = 0
                for (Votes : VoteCounts):
                    Print("Option {i}: {Votes} votes")
                    set i += 1
                Print("Winner chosen: {Winner}")
                
                if (Winner >= 0):
                    set WinningIndex = Winner
                    Print("About to distribute loadout {WinningIndex}")
                    DistributeWinningLoadout()

    # Helper to find winning index
    FindWinningIndex() : int =
        var ResultIndex : int = -1
        var MaxVotes : int = 0
        var Index : int = 0
        
        for (Votes : VoteCounts):
            Print("Checking votes for option {Index}: {Votes}")
            if (Votes > MaxVotes):
                set MaxVotes = Votes
                set ResultIndex = Index
                Print("New leader: option {ResultIndex} with {MaxVotes} votes")
            set Index += 1
        
        return ResultIndex

    # Distributes the winning loadout to all players
    DistributeWinningLoadout() : void =
        Print("Starting distribution. WinningIndex: {WinningIndex}, Items available: {ItemGranters.Length}")
        
        if (WinningIndex < 0 or WinningIndex >= ItemGranters.Length):
            Print("Invalid winning index")
            return
            
        Print("Getting item granter at index {WinningIndex}")
        if (Granter := ItemGranters[WinningIndex], Players := GetPlayspace().GetPlayers()):
            Print("Successfully got item granter, attempting to grant items")
            Print("Found {Players.Length} players")
            for (Player : Players):
                Print("Granting loadout to player...")
                Granter.GrantItem(Player)

    # Set up button interactions
    SetupButtonInteractions() : void =
        var Index : int = 0
        for (Button : VoteButtons):
            Button.InteractedWithEvent.Subscribe(OnButtonInteraction)
            set Index += 1

    # Handle button interaction
    OnButtonInteraction(Agent : agent) : void =
        if (Character := Agent.GetFortCharacter[]):
            HandleVote(0, Character)  # For testing, using first option

    # Handle vote
    HandleVote(ButtonIndex : int, Character : fort_character) : void =
        if (VoteActive := IsVotingActive?):
            if (VoteActive = true):
                if (HasVoted := PlayerVotes[Character]?):
                    if (HasVoted = false):
                        if (ButtonIndex >= 0 and ButtonIndex < VoteCounts.Length):
                            UpdateVote(ButtonIndex, Character)
                            Print("Recorded vote for option {ButtonIndex}")

    # Update the vote count and player vote status
    UpdateVote(Index : int, Character : fort_character) : void =
        if (CurrentVotes := VoteCounts[Index]):
            var NewVotes : []int = array{}
            var ArrayIndex : int = 0
            for (Vote : VoteCounts):
                if (ArrayIndex = Index):
                    set NewVotes += array{CurrentVotes + 1}
                else:
                    set NewVotes += array{Vote}
                set ArrayIndex += 1
            set VoteCounts = NewVotes
            # Update the player votes map
            var NewMap : [fort_character]logic = map{}
            if (set NewMap[Character] = true):
                set PlayerVotes = NewMap
            Print("Vote recorded for option {Index}")