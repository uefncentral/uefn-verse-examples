# Player Data Persistence System
# This code creates a comprehensive player statistics and progression system with persistent data storage. It manages player currencies, purchased items (pets, doors, apparels, colors), equipment loadou
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/persistance-manager?ref=github



using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

#THIS SCRIPT HOLDS & ADDS ALL PERSISTABLE VARIABLES FOR PLAYERS

#Stat type that is persistable
player_stat := class<final><persistable>:
    CurrentValue:int = 0
    SetHighestValue(NewValue:int)<transacts>:int=
        CurrentValue

#Makes a new stat based off of the current value
MakeUpdatedPlayerStat<constructor>(OldStats:player_stat, NewValue:int)<transacts> := player_stat:
    CurrentValue := NewValue

#Table holding all of the different persistable variables
player_stats_table := class<final><persistable>:


    BoughtPets : []int = array {}
    BoughtDoors : []int = array {}
    BoughtApparels : []int = array{}
    BoughtColors : []int = array{}
    ClaimedRewards : []int = array{}
    
    EquippedPets : []int = array {}
    EquippedApparels : []int = array {0,0,0}

    Rebirths : float = 0.0
    Playtime : float = 0.0

    Bar1Upgrades : []int = array {}
    Bar2Upgrades : []int = array {}
    Bar3Upgrades : []int = array{}

    Currency1 : float = 0.0
    Currency2 : float = 0.0
    Currency3 : float = 0.0
    Currency4 : float = 0.0
    Currency5 : float = 0.0
    Currency6 : float = 0.0
    Currency7 : float = 0.0
    Currency8 : float = 0.0
    Currency9 : float = 0.0
    Currency10 : float = 0.0
    
#Player map to connect all of the values to a player
var PlayerStatsMap:weak_map(player, player_stats_table) = map{}

#Makes a new stats table from the current/old table
MakePlayerStatsTable<constructor>(OldTable:player_stats_table)<transacts> := player_stats_table:
    BoughtPets := OldTable.BoughtPets
    BoughtDoors := OldTable.BoughtDoors
    BoughtApparels := OldTable.BoughtApparels
    BoughtColors := OldTable.BoughtColors
    ClaimedRewards := OldTable.ClaimedRewards

    EquippedPets := OldTable.EquippedPets
    EquippedApparels := OldTable.EquippedApparels

    Rebirths := OldTable.Rebirths
    Playtime := OldTable.Playtime

    Bar1Upgrades := OldTable.Bar1Upgrades
    Bar2Upgrades := OldTable.Bar2Upgrades 
    Bar3Upgrades := OldTable.Bar3Upgrades

    Currency1 := OldTable.Currency1
    Currency2 := OldTable.Currency2
    Currency3 := OldTable.Currency3
    Currency4 := OldTable.Currency4
    Currency5 := OldTable.Currency5
    Currency6 := OldTable.Currency6
    Currency7 := OldTable.Currency7
    Currency8 := OldTable.Currency8
    Currency9 := OldTable.Currency9
    Currency10 := OldTable.Currency10


#Base stat type for each resource
stat_type := class<computes><unique><abstract>:

#Classes of all different stat types
StatType := module:
    doors<public> := class<computes><unique>(stat_type):
    pets<public> := class<computes><unique>(stat_type):
    apparels<public> := class<computes><unique>(stat_type):
    colors<public> := class<computes><unique>(stat_type):
    rewards<public> := class<computes><unique>(stat_type):


    equippedpets<public> := class<computes><unique>(stat_type):
    equippedapparels<public> := class<computes><unique>(stat_type):


    rebirths<public> := class<computes><unique>(stat_type):
    playtime<public> := class<computes><unique>(stat_type):

    bar1upgrades<public> := class<computes><unique>(stat_type):
    bar2upgrades<public> := class<computes><unique>(stat_type):
    bar3upgrades<public> := class<computes><unique>(stat_type):

    currency1<public> := class<computes><unique>(stat_type):
    currency2<public> := class<computes><unique>(stat_type):
    currency3<public> := class<computes><unique>(stat_type):
    currency4<public> := class<computes><unique>(stat_type):
    currency5<public> := class<computes><unique>(stat_type):
    currency6<public> := class<computes><unique>(stat_type):
    currency7<public> := class<computes><unique>(stat_type):
    currency8<public> := class<computes><unique>(stat_type):
    currency9<public> := class<computes><unique>(stat_type):
    currency10<public> := class<computes><unique>(stat_type):


    # Instances of each stat_type you can use in your experience

    Doors <public>:doors = doors{}
    Pets <public>:pets = pets{}
    Apparels <public>:apparels = apparels{}
    Colors <public>:colors = colors{}
    ClaimedRewards<public>:rewards = rewards{}

    EquippedPets <public>:equippedpets = equippedpets{}
    EquippedApparels <public>:equippedapparels = equippedapparels{}

    Rebirths <public>:rebirths = rebirths{}
    Playtime <public>:playtime = playtime{}

    Bar1Upgrades <public>:bar1upgrades = bar1upgrades{}
    Bar2Upgrades <public>:bar2upgrades = bar2upgrades{}
    Bar3Upgrades <public>:bar3upgrades = bar3upgrades{}


    Currency1 <public>:currency1 = currency1{}
    Currency2<public>:currency2 = currency2{}
    Currency3<public>:currency3 = currency3{}
    Currency4<public>:currency4 = currency4{}
    Currency5<public>:currency5 = currency5{}
    Currency6<public>:currency6 = currency6{}
    Currency7<public>:currency7 = currency7{}
    Currency8<public>:currency8 = currency8{}
    Currency9<public>:currency9 = currency9{}
    Currency10<public>:currency10 = currency10{}

    


#Main Class
Persistance_Manager := class():
    #Initializes a player into the player map
    InitializePlayer(Player:player):void=
        if:
            not PlayerStatsMap[Player]
            set PlayerStatsMap[Player] = player_stats_table{}

    #Gets the players current stats
    GetPlayerStats(Agent:agent)<decides><transacts>:player_stats_table=
        var PlayerStats:player_stats_table = player_stats_table{}
        if:
            Player := player[Agent]
            PlayerStatsTable := PlayerStatsMap[Player]
            set PlayerStats = MakePlayerStatsTable(PlayerStatsTable)
        PlayerStats

    #Increases a stat by a specific amount
    RecordPlayerStat(Agent:agent, Stat:stat_type, ?Score:float = 0.0):void=
        if:
            Player := player[Agent]
            PlayerStatsTable := PlayerStatsMap[Player]

            if(Stat = StatType.Rebirths):
                RebirthsStat := PlayerStatsTable.Rebirths
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Rebirths := RebirthsStat + Score


            if(Stat = StatType.Playtime):
                PlaytimeStat := PlayerStatsTable.Playtime
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Playtime := PlaytimeStat + Score
                    

            else if(Stat = StatType.Currency1):
                Currency1Stat := PlayerStatsTable.Currency1
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Currency1 := Currency1Stat + Score

            else if(Stat = StatType.Currency2):
                Currency2Stat := PlayerStatsTable.Currency2
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Currency2 := Currency2Stat + Score

            else if(Stat = StatType.Currency3):
                Currency3Stat := PlayerStatsTable.Currency3
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Currency3 := Currency3Stat + Score

            else if(Stat = StatType.Currency4):
                Currency4Stat := PlayerStatsTable.Currency4
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Currency4 := Currency4Stat + Score

            else if(Stat = StatType.Currency5):
                Currency5Stat := PlayerStatsTable.Currency5
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Currency5 := Currency5Stat + Score

            else if(Stat = StatType.Currency6):
                Currency6Stat := PlayerStatsTable.Currency6
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Currency6 := Currency6Stat + Score

            else if(Stat = StatType.Currency7):
                Currency7Stat := PlayerStatsTable.Currency7
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Currency7 := Currency7Stat + Score

            else if(Stat = StatType.Currency8):
                Currency8Stat := PlayerStatsTable.Currency8
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Currency8 := Currency8Stat + Score

            else if(Stat = StatType.Currency9):
                Currency9Stat := PlayerStatsTable.Currency9
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Currency9 := Currency9Stat + Score

            else if(Stat = StatType.Currency10):
                Currency10Stat := PlayerStatsTable.Currency10
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Currency10 := Currency10Stat + Score

    #Adds a specific number into an array stat
    RecordPlayerArrStat(Agent:agent, Stat:stat_type, ?Score:int = 0):void=
        if:
            Player := player[Agent]
            PlayerStatsTable := PlayerStatsMap[Player]

            if(Stat = StatType.Doors):
                DoorsStat := PlayerStatsTable.BoughtDoors
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    BoughtDoors := DoorsStat + array{Score}

            else if(Stat = StatType.Pets):
                PetsStat := PlayerStatsTable.BoughtPets
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    BoughtPets := PetsStat + array{Score}

            else if(Stat = StatType.Apparels):
                ApparelsStat := PlayerStatsTable.BoughtApparels
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    BoughtApparels := ApparelsStat + array{Score}

            else if(Stat = StatType.Colors):
                ColorsStat := PlayerStatsTable.BoughtColors
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    BoughtColors := ColorsStat + array{Score}        

            else if(Stat = StatType.ClaimedRewards):
                ClaimedRewardsStat := PlayerStatsTable.ClaimedRewards
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    ClaimedRewards := ClaimedRewardsStat + array{Score}

            else if(Stat = StatType.EquippedPets):
                EquippedPetsStat := PlayerStatsTable.EquippedPets
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    EquippedPets := EquippedPetsStat + array{Score}

            else if(Stat = StatType.EquippedApparels):
                EquippedApparelsStat := PlayerStatsTable.EquippedApparels
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    EquippedApparels := EquippedApparelsStat + array{Score}



            else if(Stat = StatType.Bar1Upgrades):
                Bar1UpgradesStat := PlayerStatsTable.Bar1Upgrades
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Bar1Upgrades := Bar1UpgradesStat + array{Score}

            else if(Stat = StatType.Bar2Upgrades):
                Bar2UpgradesStat := PlayerStatsTable.Bar2Upgrades
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Bar2Upgrades := Bar2UpgradesStat + array{Score}

            else if(Stat = StatType.Bar3Upgrades):
                Bar3UpgradesStat := PlayerStatsTable.Bar3Upgrades
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Bar3Upgrades := Bar3UpgradesStat + array{Score}

    #Resets a specific array stat
    ResetPlayerArrStat(Agent:agent, Stat:stat_type):void=
        if:
            Player := player[Agent]
            PlayerStatsTable := PlayerStatsMap[Player]

            if(Stat = StatType.Doors):
                DoorsStat := PlayerStatsTable.BoughtDoors
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    BoughtDoors := array{}
        
            else if(Stat = StatType.Pets):
                PetsStat := PlayerStatsTable.BoughtPets
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    BoughtPets := array{}

            else if(Stat = StatType.Apparels):
                ApparelsStat := PlayerStatsTable.BoughtApparels
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    BoughtApparels := array{}

            else if(Stat = StatType.ClaimedRewards):
                ClaimedRewardsStat := PlayerStatsTable.ClaimedRewards
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    ClaimedRewards := array{}



            else if(Stat = StatType.EquippedPets):
                EquippedPetsStat := PlayerStatsTable.EquippedPets
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    EquippedPets := array{}

            else if(Stat = StatType.EquippedApparels):
                EquippedApparelsStat := PlayerStatsTable.EquippedApparels
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    EquippedApparels := array{0,0,0}


            else if(Stat = StatType.Bar1Upgrades):
                Bar1UpgradesStat := PlayerStatsTable.Bar1Upgrades
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Bar1Upgrades := array{}

            else if(Stat = StatType.Bar2Upgrades):
                Bar2UpgradesStat := PlayerStatsTable.Bar2Upgrades
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Bar2Upgrades := array{}

            else if(Stat = StatType.Bar3Upgrades):
                Bar3UpgradesStat := PlayerStatsTable.Bar3Upgrades
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Bar3Upgrades := array{}

    #Removes a specific number from an array stat
    RemovePlayerArrStat(Agent:agent, Stat:stat_type, ?Score:int = 0):void=
        if:
            Player := player[Agent]
            PlayerStatsTable := PlayerStatsMap[Player]
            if(Stat = StatType.EquippedPets):
                EquippedPetsStat := PlayerStatsTable.EquippedPets
                NewArray := EquippedPetsStat.RemoveFirstElement[Score]
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    EquippedPets := NewArray
          
    #Replaces a specific number from an array stat with another specific number
    ReplacePlayerArrStat(Agent:agent, Stat:stat_type, ?ReplaceInt:int = 0 , ?Score:int = 0):void=
        if:
            Player := player[Agent]
            PlayerStatsTable := PlayerStatsMap[Player]
            if(Stat = StatType.EquippedApparels):
                EquippedApparelsStat := PlayerStatsTable.EquippedApparels
                NewArray := EquippedApparelsStat.ReplaceElement[ReplaceInt , Score]
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    EquippedApparels := NewArray