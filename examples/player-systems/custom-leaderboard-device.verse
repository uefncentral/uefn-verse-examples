# Custom Team Leaderboard
# Creates a custom scoreboard system that tracks player kills and deaths across teams. The device displays leaderboard data when triggered by team win conditions or test triggers, with configurable disp
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/custom-leaderboard-device?ref=github


using { /Fortnite.com/UI }
using { /Fortnite.com/Game }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Colors }
using { /Verse.org/Assets }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }

agent_data := class:
    var Kills : int = 0
    var Deaths : int = 0
    var MaybeCustomLeaderboard : ?canvas = false

custom_leaderboard_device := class(creative_device):

    @editable
    PlayerSpawners : []player_spawner_device = array{}

    @editable
    ScoreboardTeam1WinsTrigger : trigger_device = trigger_device{}

    @editable
    ScoreboardTeam2WinsTrigger : trigger_device = trigger_device{}

    @editable
    ScoreboardTestTrigger : trigger_device = trigger_device{}

    @editable
    ScoreboardShowSeconds : float = 5.0

    TextForUI<localizes>(InText : string) : message = "{InText}"
    TextForUIPlayer<localizes>(InPlayer : player) : message = "{InPlayer}"

    var AgentMap : [agent]agent_data = map{}
    var bScoreboardAlive : logic = false

    OnBegin<override>()<suspends>:void=
        Print("OnBegin")

        for (Player : GetPlayspace().GetPlayers()):
            OnPlayerSpawned(Player)

        for (PlayerSpawner : PlayerSpawners):
            PlayerSpawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

        ScoreboardTeam1WinsTrigger.TriggeredEvent.Subscribe(OnScoreboardTeam1WinsTriggered)
        ScoreboardTeam2WinsTrigger.TriggeredEvent.Subscribe(OnScoreboardTeam2WinsTriggered)

        ScoreboardTestTrigger.TriggeredEvent.Subscribe(OnScoreboardTestTriggered)

    OnPlayerSpawned(Agent : agent):void=
        if (not AgentMap[Agent]):
            if (set AgentMap[Agent] = agent_data{}){}

            if (FortCharacter := Agent.GetFortCharacter[]):
                FortCharacter.EliminatedEvent().Subscribe(OnPlayerEliminated)

    OnPlayerEliminated(EliminationResult : elimination_result):void=
        if (EliminatingFortCharacter := EliminationResult.EliminatingCharacter?,
        EliminatingAgent := EliminatingFortCharacter.GetAgent[],
        EliminatedAgent := EliminationResult.EliminatedCharacter.GetAgent[],
        EliminatingAgentData := AgentMap[EliminatingAgent],
        EliminatedAgentData := AgentMap[EliminatedAgent]):

            set EliminatedAgentData.Deaths += 1

            if (EliminatedAgent = EliminatingAgent):
                return

            set EliminatingAgentData.Kills += 1

    OnScoreboardTeam1WinsTriggered(MaybeAgent : ?agent):void=
        OnScoreboardTriggered(true)

    OnScoreboardTeam2WinsTriggered(MaybeAgent : ?agent):void=
        OnScoreboardTriggered(false)

    OnScoreboardTriggered(bTeam1Wins : logic):void=
        if (bScoreboardAlive = true):
            return

        set bScoreboardAlive = true

        var Team1Players : []player = array{}
        var Team2Players : []player = array{}

        TeamCollection := GetPlayspace().GetTeamCollection()
        Teams := TeamCollection.GetTeams()
        for (Team1Agent : TeamCollection.GetAgents[Teams[0]]):
            if (Team1Player := player[Team1Agent]):
                set Team1Players += array{ Team1Player }

        for (Team2Agent : TeamCollection.GetAgents[Teams[1]]):
            if (Team2Player := player[Team2Agent]):
                set Team2Players += array{ Team2Player }

        for (Player : GetPlayspace().GetPlayers(), PlayerUI := GetPlayerUI[Player], AgentData := AgentMap[Player]):
            ScoreboardUI := CreateScoreboardUI(Team1Players, Team2Players, bTeam1Wins)
            set AgentData.MaybeCustomLeaderboard = option{ ScoreboardUI }
            PlayerUI.AddWidget(ScoreboardUI)

        spawn{ AsyncRemoveScoreboard() }

    AsyncRemoveScoreboard()<suspends>:void=
        Sleep(ScoreboardShowSeconds)
        for (Player : GetPlayspace().GetPlayers(), PlayerUI := GetPlayerUI[Player], AgentData := AgentMap[Player],
        ScoreboardUI := AgentData.MaybeCustomLeaderboard?):
            PlayerUI.RemoveWidget(ScoreboardUI)
            set AgentData.MaybeCustomLeaderboard = false

        set bScoreboardAlive = false

    OnScoreboardTestTriggered(MaybeAgent : ?agent):void=
        if (bScoreboardAlive = true):
            return

        set bScoreboardAlive = true

        bTeam1Wins := logic{ GetRandomInt(0,1) = 1 }
        Team1Size := GetRandomInt(1,4)
        Team2Size := GetRandomInt(1,4)

        var Team1Players : []player = array{}
        var Team2Players : []player = array{}

        if (FirstPlayer := GetPlayspace().GetPlayers()[0]):
            for (I := 1 .. Team1Size):
                set Team1Players += array{ FirstPlayer }

            for (I := 1 .. Team2Size):
                set Team2Players += array{ FirstPlayer }


        for (Player : GetPlayspace().GetPlayers(), PlayerUI := GetPlayerUI[Player], AgentData := AgentMap[Player]):
            ScoreboardUI := CreateScoreboardUI(Team1Players, Team2Players, bTeam1Wins)
            set AgentData.MaybeCustomLeaderboard = option{ ScoreboardUI }
            PlayerUI.AddWidget(ScoreboardUI)

        spawn{ AsyncRemoveScoreboard() }

    CreateScoreboardUI(Team1Players : []player, Team2Players : []player, bTeam1Wins : logic):canvas=
        var CustomCanvasSlots : []canvas_slot = array{}

        set CustomCanvasSlots += array
        {
            CanvasSlot0 := canvas_slot:
                Anchors := anchors{ Minimum := vector2{ X := 0.0, Y := 0.0 }, Maximum := vector2{ X := 1.0, Y := 1.0 } }
                Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                Alignment := vector2{ X := 0.0, Y := 0.0 }
                SizeToContent := true
                ZOrder := 1
                Widget := color_block{ DefaultColor := NamedColors.Black, DefaultOpacity := 0.6 }
        }

        CenterVector := vector2{ X := 0.5, Y := 0.5 }

        BaseHeight := 96.0
        HeightPerPlayer := 60.0
        TotalHeight := BaseHeight + HeightPerPlayer * (Team1Players.Length + Team2Players.Length)

        set CustomCanvasSlots += array
        {
            CanvasSlot1 := canvas_slot:
                Anchors := anchors{ Minimum := CenterVector, Maximum := CenterVector }
                Offsets := margin{ Top := 0.0, Left := -8.0, Right := 0.0, Bottom := 0.0 }
                Alignment := CenterVector
                SizeToContent := true
                ZOrder := 1
                Widget := texture_block{ DefaultImage := Textures.T_LeaderBoardBG,
                DefaultDesiredSize := vector2{ X := 768.0, Y := TotalHeight } }
        }

        LeaderboardTextureSizeX := 768.0/2.0
        LeaderboardTextureSizeY := 96.0
        set CustomCanvasSlots += array
        {
            CanvasSlot2 := canvas_slot:
                Anchors := anchors{ Minimum := CenterVector, Maximum := CenterVector }
                Offsets := margin{ Top := -(TotalHeight/2.0 + LeaderboardTextureSizeY/2.0 - 32.0), Left := 0.0, Right := 0.0, Bottom := 0.0 }
                Alignment := CenterVector
                SizeToContent := true
                ZOrder := 1
                Widget := texture_block{ DefaultImage := Textures.T_LeaderBoardText,
                DefaultDesiredSize := vector2{ X := LeaderboardTextureSizeX, Y := LeaderboardTextureSizeY } }
        }

        set CustomCanvasSlots += array
        {
            CanvasSlot3 := canvas_slot:
                Anchors := anchors{ Minimum := CenterVector, Maximum := CenterVector }
                Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                Alignment := CenterVector
                SizeToContent := true
                ZOrder := 1
                Widget := CreateTableUI(Team1Players, Team2Players, bTeam1Wins)
        }

        CustomCanvas : canvas = canvas:
            Slots := CustomCanvasSlots

        return CustomCanvas

    CreateTableUI(Team1Players : []player, Team2Players : []player, bTeam1Wins : logic):canvas=
        var CustomCanvasSlots : []canvas_slot = array{}
        var StackBoxSlots : []stack_box_slot = array{}

        LeftPadding := 8.0
        CellHorizontalSizes : []float = array{ 126.0, 228.0, 102.0, 140.0, 110.0 }
        CellVerticalSize := 40.0

        set StackBoxSlots += array
        {
            StackBoxSlot0 := stack_box_slot:
                HorizontalAlignment := horizontal_alignment.Left
                VerticalAlignment := vertical_alignment.Center
                Padding := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                Widget := CreateHeaderRowUI(LeftPadding, CellHorizontalSizes, CellVerticalSize)
        }

        var TopPadding : float = 0.0
        for (I := 0 .. Team1Players.Length-1, Team1Player := Team1Players[I], AgentData := AgentMap[Team1Player]):
            set TopPadding = if (I = 0)
            then 16.0
            else 8.0

            set StackBoxSlots += array
            {
                StackBoxSlot1 := stack_box_slot:
                    HorizontalAlignment := horizontal_alignment.Left
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{ Top := TopPadding, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Widget := CreateRowUI(Team1Player, true, AgentData.Kills, AgentData.Deaths,
                    LeftPadding, CellHorizontalSizes, CellVerticalSize)
            }

        for (I := 0 .. Team2Players.Length-1, Team2Player := Team2Players[I], AgentData := AgentMap[Team2Player]):
            set TopPadding = if (I = 0)
            then 16.0
            else 8.0

            set StackBoxSlots += array
            {
                StackBoxSlot2 := stack_box_slot:
                    HorizontalAlignment := horizontal_alignment.Left
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{ Top := TopPadding, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Widget := CreateRowUI(Team2Player, false, AgentData.Kills, AgentData.Deaths,
                    LeftPadding, CellHorizontalSizes, CellVerticalSize)
            }

        set CustomCanvasSlots += array
        {
            CanvasSlot0 := canvas_slot:
                Anchors := anchors{ Minimum := vector2{ X := 0.0, Y := 0.0 }, Maximum := vector2{ X := 0.0, Y := 0.0 } }
                Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                Alignment := vector2{ X := 0.0, Y := 0.0 }
                SizeToContent := true
                ZOrder := 1
                Widget := stack_box:
                    Orientation := orientation.Vertical
                        Slots := StackBoxSlots
        }

        CustomCanvas : canvas = canvas:
            Slots := CustomCanvasSlots

        return CustomCanvas

    CreateHeaderRowUI(LeftPadding : float, CellHorizontalSizes : []float, CellVerticalSize : float):canvas=
        var CustomCanvasSlots : []canvas_slot = array{}
        var StackBoxSlots : []stack_box_slot = array{}

        UITextures : []texture = array{ Textures.T_TeamText, Textures.T_PlayerText,
        Textures.T_KillsText, Textures.T_DeathsText, Textures.T_TeamKD }
        for (I := 0 .. UITextures.Length-1, UITexture := UITextures[I], CellHorizontalSize := CellHorizontalSizes[I]):
            CurrentLeftPad := if (I = 0)
            then 0.0
            else LeftPadding

            set StackBoxSlots += array
            {
                StackBoxSlot0 := stack_box_slot:
                    HorizontalAlignment := horizontal_alignment.Left
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{ Top := 0.0, Left := CurrentLeftPad, Right := 0.0, Bottom := 0.0 }
                    Widget := CreateCellUI(-1, false, option{UITexture},
                    vector2{ X := CellHorizontalSize, Y := CellVerticalSize }, false)
            }

        set CustomCanvasSlots += array
        {
            CanvasSlot0 := canvas_slot:
                Anchors := anchors{ Minimum := vector2{ X := 0.0, Y := 0.0 }, Maximum := vector2{ X := 0.0, Y := 0.0 } }
                Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                Alignment := vector2{ X := 0.0, Y := 0.0 }
                SizeToContent := true
                ZOrder := 1
                Widget := stack_box:
                    Orientation := orientation.Horizontal
                        Slots := StackBoxSlots
        }

        CustomCanvas : canvas = canvas:
            Slots := CustomCanvasSlots

        return CustomCanvas

    CreateRowUI(Player : player, bTeam1 : logic, Kills : int, Deaths : int,
    LeftPadding : float, CellHorizontalSizes : []float, CellVerticalSize : float):canvas=
        var CustomCanvasSlots : []canvas_slot = array{}
        var StackBoxSlots : []stack_box_slot = array{}

        TeamImage := if (bTeam1 = true)
        then Textures.T_Team1Text
        else Textures.T_Team2Text

        if (CellHorizontalSize := CellHorizontalSizes[0]):
            set StackBoxSlots += array
            {
                StackBoxSlot0 := stack_box_slot:
                    HorizontalAlignment := horizontal_alignment.Left
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Widget := texture_block{ DefaultImage := TeamImage,
                    DefaultDesiredSize := vector2{ X := CellHorizontalSize, Y := CellVerticalSize } }
            }

        NonZeroDeaths : int = if (Deaths = 0)
        then 1
        else Deaths

        KDValue := (Kills * 1.0) / (NonZeroDeaths * 1.0)
        var KDValueString : string = ""
        if (KDVlaueInt := Int[KDValue], KDValueFraction1 := Mod[Int[KDValue*10.0], 10],
        KDValueFraction2 := Mod[Int[KDValue*100.0], 10]):
            set KDValueString = "{KDVlaueInt}.{KDValueFraction1}{KDValueFraction2}"

        Messages : []message = array{ TextForUIPlayer(Player), TextForUI("{Kills}"),
        TextForUI("{Deaths}"), TextForUI("{KDValueString}") }

        CellTextureIndex := if (bTeam1 = true)
        then 0
        else 1

        for (I := 0 .. Messages.Length-1, Message := Messages[I], CellHorizontalSize := CellHorizontalSizes[I+1]):
            bTextCentral := logic{ I = 1 or I = 2 or I = 3 }
            set StackBoxSlots += array
            {
                StackBoxSlot1 := stack_box_slot:
                    HorizontalAlignment := horizontal_alignment.Left
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{ Top := 0.0, Left := LeftPadding, Right := 0.0, Bottom := 0.0 }
                    Widget := CreateCellUI(CellTextureIndex, option{Message}, false,
                    vector2{ X := CellHorizontalSize, Y := CellVerticalSize }, bTextCentral)
            }

        set CustomCanvasSlots += array
        {
            CanvasSlot0 := canvas_slot:
                Anchors := anchors{ Minimum := vector2{ X := 0.0, Y := 0.0 }, Maximum := vector2{ X := 0.0, Y := 0.0 } }
                Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                Alignment := vector2{ X := 0.0, Y := 0.0 }
                SizeToContent := true
                ZOrder := 1
                Widget := stack_box:
                    Orientation := orientation.Horizontal
                        Slots := StackBoxSlots
        }

        CustomCanvas : canvas = canvas:
            Slots := CustomCanvasSlots

        return CustomCanvas

    CreateCellUI(CellTextureIndex : int, MaybeMessage : ?message, MaybeTexture : ?texture,
    CellSize : vector2, bTextCentral : logic):canvas=
        var CustomCanvasSlots : []canvas_slot = array{}

        CellTextures : []texture = array{ Textures.T_Team1EmptyText, Textures.T_Team2EmptyText }

        if (CellTexture := CellTextures[CellTextureIndex]):
            set CustomCanvasSlots += array
            {
                CanvasSlot0 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.0, Y := 0.0 }, Maximum := vector2{ X := 0.0, Y := 0.0 } }
                    Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.0, Y := 0.0 }
                    SizeToContent := true
                    ZOrder := 1
                    Widget := texture_block{ DefaultImage := CellTexture, DefaultDesiredSize := CellSize }
            }

        if (Message := MaybeMessage?):
            LeftPadding := if (bTextCentral = true)
            then CellSize.X / 2.0
            else 10.0

            XAlignment := if (bTextCentral = true)
            then 0.5
            else 0.0

            set CustomCanvasSlots += array
            {
                CanvasSlot1 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.0, Y := 0.0 }, Maximum := vector2{ X := 0.0, Y := 0.0 } }
                    Offsets := margin{ Top := 0.0, Left := LeftPadding, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := XAlignment, Y := 0.0 }
                    SizeToContent := true
                    ZOrder := 1
                    Widget := text_block{ DefaultText := Message, DefaultTextColor := NamedColors.White,
                    DefaultShadowColor := NamedColors.Black, DefaultShadowOpacity := 1.0,
                    DefaultShadowOffset := option{vector2{ X := 2.0, Y := 2.0 }}, DefaultJustification := text_justification.Left }
            }

        if (Texture := MaybeTexture?):
            set CustomCanvasSlots += array
            {
                CanvasSlot2 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.0, Y := 0.0 }, Maximum := vector2{ X := 0.0, Y := 0.0 } }
                    Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.0, Y := 0.0 }
                    SizeToContent := true
                    ZOrder := 1
                    Widget := texture_block{ DefaultImage := Texture, DefaultDesiredSize := CellSize }
            }

        CustomCanvas : canvas = canvas:
            Slots := CustomCanvasSlots

        return CustomCanvas