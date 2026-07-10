# Stats Device
# Verse code for Stats Device - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/stats-device?ref=github


using { /Fortnite.com/Game }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

String2Message<localizes>(String : string) : message = "{String}"
Player2Message<localizes>(Player : player) : message = "{Player}"

RemoveKeyFromMap2<public>(ExampleMap : [player]int, ElementToRemove : player) : [player]int =
    var NewMap : [player]int = map{}
    for (Key -> Value : ExampleMap, Key <> ElementToRemove):
        set NewMap = ConcatenateMaps(NewMap, map{Key => Value})
    return NewMap

custom_stat_board := class(creative_device):
    Data : player_data_manager = player_data_manager{}

    @editable
    Debug : debug_settings = debug_settings{}

    @editable
    StatButton : button_device = button_device{}
    
    @editable
    StatBoard : board_settings = board_settings{}

    var PlayerMap : [player]int = map{}
    var ActivePlayer : ?player = false

    BreakLoops : event(logic) = event(logic){}

    GetRoundedString<private>(Input : float, NumDigitsAfterDecimal : int) : string =
        if:
            Multiplier := Pow(10.0, NumDigitsAfterDecimal * 1.0)
            RoundedValue := RoundedTickRate := float[Round[Input*Multiplier]*1.0] / Multiplier
            BeforeDecimal := Floor[RoundedValue]
            AfterDecimal := Abs(Round[(RoundedValue - BeforeDecimal*1.0)*Multiplier])
            var AfterDecimalString : string = ToString(AfterDecimal)

            #pad with leading zeroes
            for (It := 0..(NumDigitsAfterDecimal-AfterDecimalString.Length-1)):
                set AfterDecimalString = array{'0'} + AfterDecimalString
        then:
            "{BeforeDecimal}.{AfterDecimalString}"
        else:
            ToString(Input)

    OnBegin<override>()<suspends> : void =
        Data.Init(GetPlayspace().GetPlayers())
        spawn{Debug.AwaitDebugs()}

        StatBoard.NameBoard.SetText(String2Message("-"))
        StatBoard.EliminationsBoard.SetText(String2Message("-"))
        StatBoard.EliminatedBoard.SetText(String2Message("-"))
        StatBoard.KDBoard.SetText(String2Message("NaN"))
        StatBoard.KillstreakBoard.SetText(String2Message("-"))
        StatBoard.PlaytimeBoard.SetText(String2Message("-"))

        for (Player : GetPlayspace().GetPlayers()):
            if:
                set PlayerMap[Player] = 0
                Char := Player.GetFortCharacter[]
            then:
                spawn{AwaitElim(Char)}

        spawn{HandleButton()}

        GetPlayspace().PlayerAddedEvent().Subscribe(OnJoin)

    OnJoin<public>(Player : player) : void =
        if:
            set PlayerMap[Player] = 0

    OnLeave<public>(Player : player) : void =
        RemoveKeyFromMap2(PlayerMap, Player)
        BreakLoops.Signal(true)

        if:
            Player = ActivePlayer?
        then:
            set ActivePlayer = false
            StatBoard.NameBoard.SetText(String2Message("N/A"))
            StatBoard.EliminationsBoard.SetText(String2Message("N/A"))
            StatBoard.EliminatedBoard.SetText(String2Message("N/A"))
            StatBoard.KDBoard.SetText(String2Message("N/A"))
            StatBoard.KillstreakBoard.SetText(String2Message("N/A"))
            StatBoard.PlaytimeBoard.SetText(String2Message("N/A"))

    AwaitElim<public>(Char : fort_character)<suspends> : void =
        Result := Char.EliminatedEvent().Await()
        HandleElim(Result)
        spawn{AwaitElim(Char)}

    HandleElim<public>(Result : elimination_result) : void =
        EliminatedCharacter := Result.EliminatedCharacter
        MaybeEliminatingCharacter := Result.EliminatingCharacter

        # Handling what to do when a player gets an elimination
        if:
            EliminatedCharacter <> MaybeEliminatingCharacter?
            Agent := MaybeEliminatingCharacter?.GetAgent[]
            Player := player[Agent]
            FortChar := Player.GetFortCharacter[]
        then:
            Data.AddEliminations(Player, 1)
            if:
                set PlayerMap[Player] += 1

        # Handling what to do when a player is eliminated
        if:
            Player := player[EliminatedCharacter.GetAgent[]]
            FortChar := Player.GetFortCharacter[]
        then:
            Data.AddEliminated(Player, 1)
            if:
                set PlayerMap[Player] = 0

    HandleButton<public>()<suspends> : void =
        loop:
            Agent := StatButton.InteractedWithEvent.Await()
            if:
                Player := player[Agent]
            then:
                set ActivePlayer = option{Player}
                BreakLoops.Signal(true)
                spawn{UpdateBoard(Player)}
                spawn{UpdatePlaytime(Player)}

    UpdateBoard<public>(Player : player)<suspends> : void =
        race:
            BreakLoops.Await()

            loop:
                Sleep(0.5)
                if:
                    PlayerData := Data.GetPlayerData[Player]
                then:
                    StatBoard.NameBoard.SetText(Player2Message(Player))
                    StatBoard.EliminationsBoard.SetText(String2Message("{PlayerData.Eliminations}"))
                    StatBoard.EliminatedBoard.SetText(String2Message("{PlayerData.Eliminated}"))
                    if:
                        PlayerData.KD = 0.0
                    then:
                        StatBoard.KDBoard.SetText(String2Message("0"))
                    else:
                        KDString := GetRoundedString(PlayerData.KD, 2)
                        StatBoard.KDBoard.SetText(String2Message("{KDString}"))
                    if:
                        Killstreak := PlayerMap[Player]
                    then:
                        StatBoard.KillstreakBoard.SetText(String2Message("{Killstreak}"))
                else:
                    break

    UpdatePlaytime<public>(Player : player)<suspends> : void =
        race:
            BreakLoops.Await()

            loop:
                if:
                    PlayerData := Data.GetPlayerData[Player]
                then:
                    Data.AddPlaytime(Player, 1)
                    if:
                        MinutesPlayed := Floor(PlayerData.Playtime / 60)
                    then:
                        if:
                            MinutesPlayed = 1
                        then:
                            StatBoard.PlaytimeBoard.SetText(String2Message("{MinutesPlayed}"))
                        else:
                            StatBoard.PlaytimeBoard.SetText(String2Message("{MinutesPlayed}"))
                    else:
                Sleep(1.0)

board_settings<public> := class<concrete>:
    @editable
    NameBoard : billboard_device = billboard_device{}

    @editable
    EliminatedBoard : billboard_device = billboard_device{}

    @editable
    EliminationsBoard : billboard_device = billboard_device{}

    @editable
    PlaytimeBoard : billboard_device = billboard_device{}

    @editable
    KDBoard : billboard_device = billboard_device{}

    @editable
    KillstreakBoard : billboard_device = billboard_device{}

debug_settings<public> := class<concrete>:
    Data : player_data_manager = player_data_manager{}

    @editable
    AddElim : button_device = button_device{}

    @editable
    AddDeath : button_device = button_device{}

    AwaitDebugs<public>()<suspends> : void =
        sync:
            loop:
                Sleep(0.0)
                Agent := AddElim.InteractedWithEvent.Await()
                if:
                    Player := player[Agent]
                then:
                    Data.AddEliminations(Player, 1)

            loop:
                Sleep(0.0)
                Agent := AddDeath.InteractedWithEvent.Await()
                if:
                    Player := player[Agent]
                then:
                    Data.AddEliminated(Player, 1)