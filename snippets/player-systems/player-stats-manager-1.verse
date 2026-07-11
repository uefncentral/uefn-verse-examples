# Player Stats Persistence Manager
# A comprehensive system for managing persistent player statistics across game sessions. It defines various stat types (money, resources, rebirths, pets, doors, apparels) with a type-safe class hierarch
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/player-stats-manager-1?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

#THIS CODE IS A MANAGER FOR ALL PLAYER STAT PERSISTENCE

stat_type := class<computes><unique><abstract>:
    DebugString():string

StatType := module:
    money_stat<public> := class<computes><unique>(stat_type):
        DebugString<override>():string = "Money"

    idlemoney_stat<public> := class<computes><unique>(stat_type):
        DebugString<override>():string = "IdleMoney"

    resource2_stat<public> := class<computes><unique>(stat_type):
        DebugString<override>():string = "Resource2"

    idleresource2_stat<public> := class<computes><unique>(stat_type):
        DebugString<override>():string = "IdleResource2"
    
    rebirth_stat<public> := class<computes><unique>(stat_type):
        DebugString<override>():string = "Rebirth"

    pets_stat<public> := class<computes><unique>(stat_type):
        DebugString<override>():string = "Pets"

    door_stat<public> := class<computes><unique>(stat_type):
        DebugString<override>():string = "Doors"

    apparel_stat<public> := class<computes><unique>(stat_type):
        DebugString<override>():string = "Apparels"

    # Instances of each stat_type you can use in your experience

    Money<public>:money_stat = money_stat{}
    IdleMoney<public>:idlemoney_stat = idlemoney_stat{}
    Resource2<public>:resource2_stat = resource2_stat{}
    IdleResource2<public>:idleresource2_stat = idleresource2_stat{}
    Rebirth<public>:rebirth_stat = rebirth_stat{}
    Pets<public>:pets_stat = pets_stat{}
    Doors<public>:door_stat = door_stat{}
    Apparels<public>:apparel_stat = apparel_stat{}



player_stats_manager := class():
    InitializePlayer(Player:player):void=
        if:
            not PlayerStatsMap[Player]
            set PlayerStatsMap[Player] = player_stats_table{}

    GetPlayerStats(Agent:agent)<decides><transacts>:player_stats_table=
        var PlayerStats:player_stats_table = player_stats_table{}
        if:
            Player := player[Agent]
            PlayerStatsTable := PlayerStatsMap[Player]
            set PlayerStats = MakePlayerStatsTable(PlayerStatsTable)
        PlayerStats

        
    RecordPlayerStat(Agent:agent, Stat:stat_type, ?Score:float = 0.0):void=
        if:
            Player := player[Agent]
            PlayerStatsTable := PlayerStatsMap[Player]

            if(Stat = StatType.Money):
                MoneyStat := PlayerStatsTable.MoneyAmount
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    MoneyAmount := MoneyStat + Score

            else if(Stat = StatType.IdleMoney):
                IdleMoneyStat := PlayerStatsTable.IdleMoneyAmount
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    IdleMoneyAmount := IdleMoneyStat + Score

            else if(Stat = StatType.Resource2):
                Resource2Stat := PlayerStatsTable.Resource2Amount
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    Resource2Amount := Resource2Stat + Score

            else if(Stat = StatType.IdleResource2):
                IdleResource2Stat := PlayerStatsTable.IdleResource2Amount
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    IdleResource2Amount := IdleResource2Stat + Score

            else if(Stat = StatType.Rebirth):
                RebirthtStat := PlayerStatsTable.RebirthAmount
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    RebirthAmount := RebirthtStat + Score


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
                ApparelStat := PlayerStatsTable.BoughtApparels
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    BoughtApparels := ApparelStat + array{Score}

                    
    ResetPlayerArrStat(Agent:agent, Stat:stat_type):void=
        if:
            Player := player[Agent]
            PlayerStatsTable := PlayerStatsMap[Player]

            if(Stat = StatType.Doors):
                DoorsStat := PlayerStatsTable.BoughtDoors
                set PlayerStatsMap[Player] = player_stats_table:
                    MakePlayerStatsTable<constructor>(PlayerStatsTable)
                    BoughtDoors := array{}

        
        