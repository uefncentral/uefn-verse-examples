# Rank System 3
# Verse code for Rank System 3 - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/rank-system-3?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Assets }
using { /Verse.org/Colors }
using { /Fortnite.com/Game }
using { /Fortnite.com/Characters }



# A Verse-authored creative device that can be placed in a level
RankSystem := class(creative_device):

    RankSettings1 : Rank_Settings = Rank_Settings{}
    var Anchors :anchors=anchors{Minimum := vector2{X := 0.0, Y := 1.0}, Maximum := vector2{X:= 0.0, Y := 1.0}}
    var Margins : margin = margin{Left := 10.0, Top := -581.0, Right := 0.0, Bottom := 0.0}
    var EloDenominators :[]int = array{ 25, 75, 175, 250, 450, 650, 750, 900, 1200, 1400, 1750 , 2000, 2200,2500, 3000, 3400, 4000,5000,6000}

    S2M<localizes>(value:string)<computes> : message = "{value}" 
    ATM<localizes>(value:agent)<computes> : message = "{value}"


    GeneralSettings : RankDifficulty  = RankDifficulty{}
   
    var Leaderboard : Min_Heap = Min_Heap{} 

    # you store a Custom_Player_Rank class for each player in the game here
    var Custom_Player_Rank_Map: [player]Custom_Player_Rank = map{}
   
    # Verse Persistence Stats Manager
    var PlayerStatsManager : player_stats_manager = player_stats_manager{}
  
    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        # When a Player Leaves we need to remove there Custom_Player_Rank_UI from the map to free up memory  
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerLeft)

        # Initialize the spawners (For Join in progress)
        InitSpawners() 
        # Add a Custom Player UI to all players in the game
        InitPlayers()
       

    #Function to update the UI of a player
    OnEliminated(ER:elimination_result):void=
       
        if(EliminatedPlayer := player[ER.EliminatedCharacter.GetAgent[]] , EliminatingPlayer := player[ER.EliminatingCharacter?.GetAgent[]]):
            if(EliminatedPlayer <> EliminatingPlayer):
                if(EliminatingCustomPlayer := Custom_Player_Rank_Map[EliminatingPlayer]):
                    UpdateKillProgress(EliminatingCustomPlayer,EliminatingPlayer)
                if(EliminatedCustomPlayer := Custom_Player_Rank_Map[EliminatedPlayer]):
                    UpdateDeathProgress(EliminatedCustomPlayer,EliminatedPlayer)
            else: 
                Print("Eliminated Player is the same as Eliminating Player")       
    


    #Function for Debuging         
    OnEliminationButton(Agent:agent):void=
       if(Player := player[Agent]):  
        if(EliminatingCustomPlayer := Custom_Player_Rank_Map[Player]):
            UpdateKillProgress(EliminatingCustomPlayer,Player)
    
    OnEliminatedButton(Agent:agent):void=
       if(Player := player[Agent]):  
        if(EliminatedCustomPlayer := Custom_Player_Rank_Map[Player]):
            UpdateDeathProgress(EliminatedCustomPlayer,Player)
    
    # initialize the spawners and subscribe to the PlayerJoined event
    InitSpawners():void=
        for(Spawner:RankSettings1.BackBling_Settings.PlayerSpawners):
            Spawner.SpawnedEvent.Subscribe(OnPlayerJoined)
    
    UpdateKillProgress(CustomPlayer:Custom_Player_Rank,Player:player):void=
       if: 
        CurrentPlayerStats := PlayerStatsManager.GetPlayerStats[Player]
        CurrentElo := CurrentPlayerStats.Elo.CurrentValue
        CurrentKills := CurrentPlayerStats.Kills.CurrentValue
        CurrentGoal := EloDenominators[CustomPlayer.CurrentRank]
        EloGain := GeneralSettings.EloGainPerKill
        var NewElo : int = CurrentElo + EloGain
       then:
            if (NewElo >= CurrentGoal):
                Print("Player Promoted")
                PlayerStatsManager.RecordPlayerStat(Player, StatType1.Elo, ?Value := NewElo)
                PlayerStatsManager.RecordPlayerStat(Player, StatType1.Kills, ?Value := CurrentKills + 1)
                set CustomPlayer.CurrentRank = DetermineRank(NewElo)
                set CustomPlayer.Elo = NewElo
                GeneralSettings.RankUpXp.Award(Player)
                GeneralSettings.PromotedSound.Play()
                InitUi(Player)
            else:
                PlayerStatsManager.RecordPlayerStat(Player, StatType1.Elo, ?Value := NewElo)
                PlayerStatsManager.RecordPlayerStat(Player, StatType1.Kills, ?Value := CurrentKills + 1)
                set CustomPlayer.Elo = NewElo

     
         Leaderboard.UpdateScore(CustomPlayer, CustomPlayer.Elo)
         UpdateLeaderboard()
    UpdateDeathProgress(CustomPlayer:Custom_Player_Rank,Player:player):void=
        if: 
         CurrentPlayerStats := PlayerStatsManager.GetPlayerStats[Player]
         CurrentElo := CurrentPlayerStats.Elo.CurrentValue
         CurrentDeaths := CurrentPlayerStats.Deaths.CurrentValue
         EloLoss := GeneralSettings.EloLossPerDeath
         var NewElo : int = CurrentElo - EloLoss
         var CurrentRank : int = CustomPlayer.CurrentRank - 1
        then:
         # Prevent ELO from going negative
         if. NewElo < 0 then. set NewElo = 0
         if. CurrentRank < 0 then. set CurrentRank = 0
        #Print("Current Rank: {CurrentRank}")   
            if(PreviousGoal := EloDenominators[CurrentRank], CurrentGoal := EloDenominators[CurrentRank + 1]):
                if (NewElo < PreviousGoal):
                    Print("Player Demoted")
                    PlayerStatsManager.RecordPlayerStat(Player, StatType1.Elo, ?Value := NewElo)
                    PlayerStatsManager.RecordPlayerStat(Player, StatType1.Deaths, ?Value := CurrentDeaths + 1)
                    set CustomPlayer.CurrentRank = DetermineRank(NewElo)
                    set CustomPlayer.Elo = NewElo
                    GeneralSettings.DemotedSound.Play(Player)
                    InitUi(Player)
                else:
                    PlayerStatsManager.RecordPlayerStat(Player, StatType1.Elo, ?Value := NewElo)
                    PlayerStatsManager.RecordPlayerStat(Player, StatType1.Deaths, ?Value := CurrentDeaths + 1)
                    set CustomPlayer.Elo = NewElo
              
            Leaderboard.UpdateScore(CustomPlayer, CustomPlayer.Elo)
            UpdateLeaderboard()


    UpdateLeaderboard():void=
       for(Key -> Value : Custom_Player_Rank_Map):    
         Value.UpdateLeaderboard(Leaderboard.GetSortedTopK())
    # Function to Initialize the UI of a Player
    InitUi(Player:player):void=
         Print("Init UI")
       if(CustomPlayer := Custom_Player_Rank_Map[Player]):
            if: 
                Texture := RankIconsArray[CustomPlayer.CurrentRank] 
                EloDenominator := EloDenominators[CustomPlayer.CurrentRank]
                RankNameText :string= RankNamesArray[CustomPlayer.CurrentRank]
            then:  

                Print(RankNameText)
            else:
                Print("Current Rank { CustomPlayer.CurrentRank} is out of bounds")
                Print("Failed to Initialize UI")
    # Function to Create a Custom_Player_Rank_UI and assign to a player
    OnPlayerJoined(PlayerJoining:agent):void=   
        # Cast Agent to Player 
        if(Player := player[PlayerJoining]):
            # Check if Player already has a Custom_Player_Rank_UI
            if(PlayerExists := Custom_Player_Rank_Map[Player]):
                #Player already has a Custom_Player_Rank_UI so do nothing
            else:
              # Initialize the Player Stats
              PlayerStatsManager.InitializePlayer(Player)  
              #Get the Current Player Stats
              if(CurrentPlayerStats := PlayerStatsManager.GetPlayerStats[Player]):       
                # Subscribe to the Eliminated Event
                if. FC := Player.GetFortCharacter[] then. FC.EliminatedEvent().Subscribe(OnEliminated) 
                #Create a new Custom_Player_Rank_UI for the Player
                CustomPlayer := Custom_Player_Rank{Player := Player}
                # Assign the CustomPlayer to the Player
                option. set  Custom_Player_Rank_Map[Player] = CustomPlayer
                # Set the Elo Value of the CustomPlayer to the Elo Value stored in previous games
                set CustomPlayer.Elo = CurrentPlayerStats.Elo.CurrentValue
                # Get the Current Rank of the Player
                set CustomPlayer.CurrentRank = DetermineRank(CurrentPlayerStats.Elo.CurrentValue)
                set Leaderboard.Leaderboard = Leaderboard.HeapPush(Leaderboard.Leaderboard, CustomPlayer, 5)
                # Add the UI to the Player
                CustomPlayer.AddUiToPlayer(Anchors,Margins)
                UpdateLeaderboard()
                
                # Update the UI of the Player
                InitUi(Player)

    #Clean up Data from leaving player to free up memory            
    OnPlayerLeft(PlayerLeaving : agent):void=
        var NewMap : [player]Custom_Player_Rank = map{}
        if(Player := player[PlayerLeaving]):
        for(Key -> Value : Custom_Player_Rank_Map, Key <> PlayerLeaving):
            set NewMap = ConcatenateMaps(NewMap, map{Key => Value})
        set Custom_Player_Rank_Map = NewMap     
        Print("Player Removed")

    # Function to Create a Custom_Player_Rank_UI for all players in the game
    InitPlayers():void=
        PlayerStatsManager.InitializeAllPlayers(GetPlayspace().GetPlayers())
        for(Player: GetPlayspace().GetPlayers()):
            OnPlayerJoined(Player)    


    
############## HELPER FUNCTIONS ####################
 
    # Helper Function to Determine Progress Bar Width
    CaculateProgressBarWidthForRank(EloRank:int, total_width:float, numerator:int, denominator:int):float=
        # Ensure the current rank is within the bounds of the array
        if (EloRank < 0 or EloRank >= EloDenominators.Length):
            return 0.0  # Return 0 width if the rank is invalid
        # Calculate the progress within the current rank
        previous_threshold  : int = if. Temp := EloDenominators[EloRank - 1] then.  Temp else.  0
        RealNumerator := (numerator - previous_threshold) * 1.0 
        RealDenominator := (denominator - previous_threshold)  * 1.0
        progress_within_rank :=  ( RealNumerator   / RealDenominator) 
        # Calculate the width of the progress bar
        width_image1 :=total_width *  progress_within_rank 
        # Print("Width: {width_image1}")
        # Print("{numerator} / {denominator}")
        return width_image1

    #Helper function to perform binary search
    DetermineRank(Elo:int):int=
        RankIndex :=BinarySearch(EloDenominators, Elo, 0, EloDenominators.Length-1)
        if(RankIndex = EloDenominators.Length ):
            return EloDenominators.Length -1
        else: 
            return RankIndex
         
    BinarySearch(arr: []int, target: int, left: int, right: int):int=
        if (left > right) {
            return left
        }
        var Mid:int=0
        if(mid : int = Floor((left + right) / 2)):
            set Mid = mid
        if (target < arr[Mid]):
            return BinarySearch(arr, target, left, Mid - 1)
        else:
            return BinarySearch(arr, target, Mid + 1, right)  
    RoundFloat(Value:float, DecimalPlaces:int):float =
        Multiplier := Pow(10.0, DecimalPlaces * 1.0)
        var RoundedValues : float = 0.0
        if(RoundedValuess := Round[Value * Multiplier] * 1.0):
                set RoundedValues  = RoundedValuess
        return RoundedValues / Multiplier
    FloorFloat2Decimals(Value:float):string=
        floatString := ToString(Value)
        var stringToReturn:string=""
        for(Char:floatString):
            if(stringToReturn.Length < 4):
                set stringToReturn += "{Char}"
        return stringToReturn
    # Helper Function to Convert a Numerator and Denominator to a Percentage
    ConvertToPercentage(numerator: int, denominator: int,EloRank:int): string =
        previous_threshold  : int = if. Temp := EloDenominators[EloRank - 1] then.  Temp else.  0
        RealNumerator := (numerator - previous_threshold) * 1.0 
        RealDenominator := (denominator - previous_threshold)  * 1.0
        decimal_value := (RealNumerator * 1.0) / (RealDenominator * 1.0)
        percentage := decimal_value * 100.0
        return "{RemoveExtraNumbers(percentage)}%"
     
    # Helper Function to Get the First Five Characters of a String
    RemoveExtraNumbers(input_float: float): string =
        input_string := "{input_float}"
        if(input_float < 10.0):
         return if. First5 := input_string.Slice[0, 3] then. First5 else. input_string
        else if(input_float < 100.0):
           return if. First5 := input_string.Slice[0, 5] then. First5 else. input_string
        else:   
           return if. First5 := input_string.Slice[0, 6] then. First5 else. input_string
       
      
################# CUSTOM PLAYER CLASS ####################



Min_Heap<public> := class:
    
        var Leaderboard<internal> : []Custom_Player_Rank = array{}
        var IndexMap: [player]int = map{}  #Map to keep track of player indices in the heap
    
        Swap(arr: []Custom_Player_Rank , i: int, j: int):[]Custom_Player_Rank =
            var  Arr : []Custom_Player_Rank = arr
            if:  
                temp := Arr[i]
               if. Temp := Arr[j] then. set Arr[i] = Temp
               if. set Arr[j] = temp
               iplayer := Arr[i].Player
               jplayer := Arr[j].Player
               if. set IndexMap[player[iplayer]]= i
               if. set IndexMap[player[jplayer]] = j
            return Arr 
      
        MinHeapify(arr: []Custom_Player_Rank, n: int, i: int):[]Custom_Player_Rank=
            var Arr : []Custom_Player_Rank = arr
            var Smallest : int = i
            var Left : int = 2 * i + 1
            var Right : int = 2 * i + 2
            if(Left < n and Arr[Left].Elo < Arr[Smallest].Elo):
                set Smallest = Left
            if(Right < n and Arr[Right].Elo < Arr[Smallest].Elo):
                set Smallest = Right
            if(Smallest <> i):
                set Arr = Swap(Arr, i, Smallest)
                set Arr = MinHeapify(Arr, n, Smallest)
            return Arr
    
        HeapPush(arr: []Custom_Player_Rank, Dude: Custom_Player_Rank,TopK:int):[]Custom_Player_Rank=
            var Arr: []Custom_Player_Rank = arr
            set Arr = Arr + array{Dude}
            var i :int= Arr.Length - 1 
            if. set IndexMap[player[Dude.Player]] = Arr.Length - 1
            if. i = 0 then. return Arr
                loop:
                   if(Parent := Floor((i - 1) / 2)): 
                    if(i > 0 and Arr[Parent].Elo > Arr[i].Elo):
                        set Arr =  Swap(Arr, i, Parent)
                        set i = Parent
                    else:
                        break
            if (Arr.Length > TopK):
              set Arr = HeapPop(Arr)            
            return Arr    
            
        HeapPop(arr: []Custom_Player_Rank):[]Custom_Player_Rank=
            var Arr : []Custom_Player_Rank = arr
            var n : int = Arr.Length
            if(n = 0):
                return Arr
            set Arr = Swap(Arr, 0, n - 1)
            if. Player := player[Arr[n - 1].Player] then. OnPlayerRemoved(Player)  else. Print("Failed to remove player") # Remove the player from the index map
            if. Sliced := Arr.Slice[0, n - 1] then. set Arr =  Sliced
            set Arr = MinHeapify(Arr, n - 1, 0)
            Print("Heappop Called")
           
    
            return Arr
    
        OnPlayerRemoved(PlayerLeaving : player):void=
            var NewMap : [player]int = map{}
            for(Key -> Value : IndexMap, Key <> PlayerLeaving):
                set NewMap = ConcatenateMaps(NewMap, map{Key => Value})
            set IndexMap = NewMap     
            Print("Player Removed")
        
        SiftUp(arr: []Custom_Player_Rank, i: int): []Custom_Player_Rank= 
            var I: int = i
            var Arr: []Custom_Player_Rank = arr
            loop:
                if(I > 0):
                  if( var Parent: int = Floor((I - 1) / 2)):
                    if (Arr[Parent].Elo > Arr[I].Elo):
                       set Arr = Swap(Arr, I, Parent)
                       set I = Parent
                    else: 
                        break
                else:
                    break
            return Arr
             
        UpdateScore(CustomPlayer:Custom_Player_Rank, NewElo: int):void= 
             Player  := CustomPlayer.Player
            if (Contains := IndexMap[Player]):
               if( var index :int= IndexMap[Player],var OldElo :int= Leaderboard[index].Elo):
                
                if. set Leaderboard[index].Elo = NewElo
                if (NewElo < OldElo):
                    set Leaderboard = SiftUp(Leaderboard, index)
                else:
                    set Leaderboard = MinHeapify(Leaderboard, Leaderboard.Length, index)
            else: 
              Print("Player not in top 5")
              set Leaderboard = HeapPush(Leaderboard ,CustomPlayer, 5)
           
    
        InsertionSort(Array: []Custom_Player_Rank): []Custom_Player_Rank =
            var Arr : []Custom_Player_Rank = Array
                 for (i := 1..Array.Length - 1):
                  if( key := Arr[i]):
                    var j :int= i - 1
                    loop:
                       if(j >= 0 and Arr[j].Elo < key.Elo):
                           if. Temp:= Arr[j] then. if. set Arr[j + 1] = Temp
                           set j -= 1
                       else:
                           break
                    if. set Arr[j + 1] = key        
                 return Arr
    
        GetSortedTopK():[]Custom_Player_Rank=
            var SortedHeap : []Custom_Player_Rank = InsertionSort(Leaderboard)
            return SortedHeap
    