# Data Manager Device
# Verse code for Data Manager Device - UEFN/Fortnite Creative implementation
# Difficulty: intermediate  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/data-manager-device?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }


player_data_manager := class(creative_device):
    var PlayerDataMap : weak_map(player, player_data) = map{}

    DataVersion : int = 0

    RoundToDecimalPlaces(Value:float, DecimalPlaces:int)<decides><transacts> : float =
        DecimalPlaces >= 0
        Multiplier := Pow(10.0, DecimalPlaces * 1.0)
        RoundedValues := Round[Value * Multiplier] * 1.0
        return RoundedValues / Multiplier

    Init(Players : []player) : void =
        for (Player : Players):
            InitPlayer(Player)

    InitPlayer(Player : player) : void =
        if:
            not PlayerDataMap[Player]
            set PlayerDataMap[Player] = player_data{}
        
        if:
            PlayerData := GetPlayerData[Player]
        then:
            UpdateKD(Player)
            VersionCheck(Player, PlayerData)

    VersionCheck(Player : player, PlayerData : player_data) : void =
        if:
            PlayerData.Version <> DataVersion
        then:
            UpdateVersion(Player, DataVersion)

    GetPlayerData(Player: player)<decides><transacts> : player_data =
        Player.IsActive[]
        Data := PlayerDataMap[Player]
        return Data


    # All the update functions
    UpdateVersion(Player : player, NewVersion : int) : void =
        if:
            PlayerData := GetPlayerData[Player]

            set PlayerDataMap[Player] = player_data:
                PlayerDataConstructor<constructor>(PlayerData)
                Version := NewVersion

    UpdatePlaytime(Player : player, NewPlaytime : int) : void =
        if:
            PlayerData := GetPlayerData[Player]

            set PlayerDataMap[Player] = player_data:
                PlayerDataConstructor<constructor>(PlayerData)
                Playtime := NewPlaytime

    UpdateEliminations(Player : player, NewEliminations : int) : void =
        if:
            PlayerData := GetPlayerData[Player]

            set PlayerDataMap[Player] = player_data:
                PlayerDataConstructor<constructor>(PlayerData)
                Eliminations := NewEliminations
        then:
            UpdateKD(Player)

    UpdateEliminated(Player : player, NewEliminated : int) : void =
        if:
            PlayerData := GetPlayerData[Player]

            set PlayerDataMap[Player] = player_data:
                PlayerDataConstructor<constructor>(PlayerData)
                Eliminated := NewEliminated
        then:
            UpdateKD(Player)

    UpdateKD(Player : player) : void =
        if:
            PlayerData := GetPlayerData[Player]

            Elims := PlayerData.Eliminations * 1.0
            Deaths := PlayerData.Eliminated * 1.0
        then:
            var KD : float = 0.0
            if:
                Deaths < 1.0
            then:
                set KD = Elims
            else:
                set KD = (Elims / Deaths)
            
            if:
                NewKD := RoundToDecimalPlaces[KD, 2]
                set PlayerDataMap[Player] = player_data:
                    PlayerDataConstructor<constructor>(PlayerData)
                    KD := NewKD

    # All the functions we can use to do certain things to the stats
    AddPlaytime(Player : player, Amount : int)<suspends> : void =
        if:
            PlayerData := GetPlayerData[Player]
        then:
            UpdatePlaytime(Player, PlayerData.Playtime + Amount)

    AddEliminations(Player : player, Amount : int) : void =
        if:
            PlayerData := GetPlayerData[Player]
        then:
            UpdateEliminations(Player, PlayerData.Eliminations + Amount)
    
    TakeEliminations(Player : player, Amount : int) : void =
        if:
            PlayerData := GetPlayerData[Player]
        then:
            UpdateEliminations(Player, PlayerData.Eliminations - Amount)

    AddEliminated(Player : player, Amount : int) : void =
        if:
            PlayerData := GetPlayerData[Player]
        then:
            UpdateEliminated(Player, PlayerData.Eliminated + Amount)

    TakeEliminated(Player : player, Amount : int) : void =
        if:
            PlayerData := GetPlayerData[Player]
        then:
            UpdateEliminated(Player, PlayerData.Eliminated - Amount)


PlayerDataConstructor<constructor>(Data : player_data)<transacts> := player_data:
    Version := Data.Version
    Playtime := Data.Playtime
    Eliminations := Data.Eliminations
    Eliminated := Data.Eliminated
    KD := Data.KD

player_data := class<persistable><final>:
    Version : int = 0
    Playtime : int = 0
    Eliminations : int = 0
    Eliminated : int = 0
    KD : float = 0.00