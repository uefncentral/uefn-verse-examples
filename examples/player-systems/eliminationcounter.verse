# Team Elimination Counter
# Displays a real-time elimination counter for up to 4 teams with customizable colors and UI positioning. Shows kill counts for each team with optional color-coded backgrounds or team images.  **How to 
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/eliminationcounter?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Colors }
using { /Fortnite.com/UI }
using { /Verse.org/Assets }
using { /Fortnite.com/Game }
using { /Fortnite.com/Characters }

EliminationCounter := class(creative_device):

    @editable
    Team1Color : color = color{ R := 0.5, G := 0.0, B := 0.0 }

    @editable
    Team2Color : color = color{ R := 0.0, G := 0.0, B := 0.5 }

    @editable
    Team3Color : color = color{ R := 0.5, G := 0.0, B := 0.5 }

    @editable
    Team4Color : color = color{ R := 0.0, G := 0.5, B := 0.0 }


    @editable
    Team1TextColor : color = color{ R := 0.5, G := 0.0, B := 0.0 }

    @editable
    Team2TextColor : color = color{ R := 0.0, G := 0.0, B := 0.5 }

    @editable
    Team3TextColor : color = color{ R := 0.5, G := 0.0, B := 0.5 }

    @editable
    Team4TextColor : color = color{ R := 0.0, G := 0.5, B := 0.0 }



    @editable
    UseColors : logic = false

    @editable
    UseImages : logic = true



    @editable
    EliminationCountOpacity : type{ X : float where X >= 0.0, X <= 1.0 } = 0.0

    @editable
    EliminationCountHeight : type{ X : float where X >= 0.0, X <= 1.0 } = 0.0

    @editable
    EliminationCountSize_Color : type{ X : float where X >= 0.0, X <= 1.0 } = 0.06

    @editable
    EliminationCountSize_Image : type{ X : float where X >= 0.0, X <= 1000.0 } = 120.0

    @editable
    EliminationCountSpace : type{ X : float where X >= 0.0, X <= 1.0 } = 0.02



    Team1BG : texture = purplebg
    Team2BG : texture = redbg
    Team3BG : texture = bluebg
    Team4BG : texture = greenbg



    var PlayerCanvas : [agent]canvas = map{}
    var PlayerTexts : [agent]tuple(text_block, text_block, text_block, text_block) = map{}

    var TeamKillCounts : []int = array{ 0, 0, 0, 0 }



    Text <localizes> (Txt : string) : message = "{Txt}"

    OnBegin<override>()<suspends>:void=

        GetPlayspace().PlayerAddedEvent().Subscribe(AddHUD)
        for(Player : GetPlayspace().GetPlayers()):
            AddHUD(Player)

        UpdateKillCounts()



    AddHUD(Player : player) : void =

        if(Character := Player.GetFortCharacter[]):
            Character.EliminatedEvent().Subscribe(PlayerEliminated)

        if(PlayerHUD := GetPlayerUI[Player], OldCanvas := PlayerCanvas[Player], set PlayerCanvas[Player] = canvas{}):
            PlayerHUD.RemoveWidget(OldCanvas)

        Canvas := ElimsAndGoldHUD(Player)

        if(PlayerHUD := GetPlayerUI[Player], set PlayerCanvas[Player] = Canvas):
            PlayerHUD.AddWidget(Canvas, player_ui_slot{InputMode := ui_input_mode.None})

        UpdateKillCounts()



    ElimsAndGoldHUD(Agent : agent) : canvas =

        T1Text := text_block{DefaultText := Text("?"), DefaultTextColor := Team1TextColor}
        T2Text := text_block{DefaultText := Text("?"), DefaultTextColor := Team2TextColor}
        T3Text := text_block{DefaultText := Text("?"), DefaultTextColor := Team3TextColor}
        T4Text := text_block{DefaultText := Text("?"), DefaultTextColor := Team4TextColor}

        if(set PlayerTexts[Agent] = (T1Text, T2Text, T3Text, T4Text)):

        Team1Backgroud := color_block{DefaultColor := Team1Color, DefaultOpacity := EliminationCountOpacity}
        Team2Backgroud := color_block{DefaultColor := Team2Color, DefaultOpacity := EliminationCountOpacity}
        Team3Backgroud := color_block{DefaultColor := Team3Color, DefaultOpacity := EliminationCountOpacity}
        Team4Backgroud := color_block{DefaultColor := Team4Color, DefaultOpacity := EliminationCountOpacity}

        Team1BGImage := texture_block{DefaultImage := Team1BG, DefaultDesiredSize := vector2{ X := EliminationCountSize_Image, Y := EliminationCountSize_Image }}
        Team2BGImage := texture_block{DefaultImage := Team2BG, DefaultDesiredSize := vector2{ X := EliminationCountSize_Image, Y := EliminationCountSize_Image }}
        Team3BGImage := texture_block{DefaultImage := Team3BG, DefaultDesiredSize := vector2{ X := EliminationCountSize_Image, Y := EliminationCountSize_Image }}
        Team4BGImage := texture_block{DefaultImage := Team4BG, DefaultDesiredSize := vector2{ X := EliminationCountSize_Image, Y := EliminationCountSize_Image }}


        Team1HUD := (0.5 - (EliminationCountSpace * 1.5) - (EliminationCountSize_Color * 2.0), 0.5 - (EliminationCountSpace * 1.5) - EliminationCountSize_Color)
        Team1Text := (Team1HUD(0) + Team1HUD(1)) / 2.0
        Team2HUD := (0.5 - (EliminationCountSpace * 0.5) - EliminationCountSize_Color, 0.5 - (EliminationCountSpace * 0.5))
        Team2Text := (Team2HUD(0) + Team2HUD(1)) / 2.0
        Team3HUD := (0.5 + (EliminationCountSpace * 0.5), 0.5 + (EliminationCountSpace * 0.5) + EliminationCountSize_Color)
        Team3Text := (Team3HUD(0) + Team3HUD(1)) / 2.0
        Team4HUD := (0.5 + (EliminationCountSpace * 1.5) + EliminationCountSize_Color, 0.5 + (EliminationCountSpace * 1.5) + (EliminationCountSize_Color * 2.0))
        Team4Text := (Team4HUD(0) + Team4HUD(1)) / 2.0

        if(UseColors = false):
            Team1Backgroud.SetVisibility(widget_visibility.Hidden)
            Team2Backgroud.SetVisibility(widget_visibility.Hidden)
            Team3Backgroud.SetVisibility(widget_visibility.Hidden)
            Team4Backgroud.SetVisibility(widget_visibility.Hidden)

        if(UseImages = false):
            Team1BGImage.SetVisibility(widget_visibility.Hidden)
            Team2BGImage.SetVisibility(widget_visibility.Hidden)
            Team3BGImage.SetVisibility(widget_visibility.Hidden)
            Team4BGImage.SetVisibility(widget_visibility.Hidden)

        CanvasMenu : canvas = canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors{Minimum := vector2 {X := Team1Text, Y := EliminationCountHeight}, Maximum := vector2 {X := Team1Text, Y := EliminationCountHeight}}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := T1Text

                canvas_slot:
                    Anchors := anchors{Minimum := vector2 {X := Team1HUD(0), Y := EliminationCountHeight}, Maximum := vector2 {X := Team1HUD(1), Y := EliminationCountHeight}}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := Team1Backgroud

                canvas_slot:
                    Anchors := anchors{Minimum := vector2 {X := Team1Text, Y := EliminationCountHeight}, Maximum := vector2 {X := Team1Text, Y := EliminationCountHeight}}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := Team1BGImage
    
                canvas_slot:
                    Anchors := anchors{Minimum := vector2 {X := Team2Text, Y := EliminationCountHeight}, Maximum := vector2 {X := Team2Text, Y := EliminationCountHeight}}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := T2Text

                canvas_slot:
                    Anchors := anchors{Minimum := vector2 {X := Team2HUD(0), Y := EliminationCountHeight}, Maximum := vector2 {X := Team2HUD(1), Y := EliminationCountHeight}}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := Team2Backgroud

                canvas_slot:
                    Anchors := anchors{Minimum := vector2 {X := Team2Text, Y := EliminationCountHeight}, Maximum := vector2 {X := Team2Text, Y := EliminationCountHeight}}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := Team2BGImage

                canvas_slot:
                    Anchors := anchors{Minimum := vector2 {X := Team3Text, Y := EliminationCountHeight}, Maximum := vector2 {X := Team3Text, Y := EliminationCountHeight}}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := T3Text

                canvas_slot:
                    Anchors := anchors{Minimum := vector2 {X := Team3HUD(0), Y := EliminationCountHeight}, Maximum := vector2 {X := Team3HUD(1), Y := EliminationCountHeight}}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := Team3Backgroud

                canvas_slot:
                    Anchors := anchors{Minimum := vector2 {X := Team3Text, Y := EliminationCountHeight}, Maximum := vector2 {X := Team3Text, Y := EliminationCountHeight}}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := Team3BGImage

                canvas_slot:
                    Anchors := anchors{Minimum := vector2 {X := Team4Text, Y := EliminationCountHeight}, Maximum := vector2 {X := Team4Text, Y := EliminationCountHeight}}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := T4Text

                canvas_slot:
                    Anchors := anchors{Minimum := vector2 {X := Team4HUD(0), Y := EliminationCountHeight}, Maximum := vector2 {X := Team4HUD(1), Y := EliminationCountHeight}}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := Team4Backgroud

                canvas_slot:
                    Anchors := anchors{Minimum := vector2 {X := Team4Text, Y := EliminationCountHeight}, Maximum := vector2 {X := Team4Text, Y := EliminationCountHeight}}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := Team4BGImage


                
    PlayerEliminated(EliminationResult : elimination_result) : void =

        Teams := GetPlayspace().GetTeamCollection().GetTeams()
        var PlayerTeam : int = -1

        if(Eliminator := EliminationResult.EliminatingCharacter?.GetAgent[]):
            for(Index := 0..Teams.Length):
                if(GetPlayspace().GetTeamCollection().IsOnTeam[Eliminator, Teams[Index]], set PlayerTeam = Index):
                    if(set TeamKillCounts[Index] += 1):
                        Print("Team {PlayerTeam} kill count updated.")
                    else:
                        Print("Error when trying to update team {PlayerTeam +1}'s kill count.")

            if(PlayerTeam <> -1):
                Print("The eliminator is on team {PlayerTeam +1}.")
            else:
                Print("The eliminator has no team.")

        else:
            Print("Eliminator not found.")
        UpdateKillCounts()



    UpdateKillCounts() : void =

        Team1KillCount := TeamKillCounts[0] or 0
        Team2KillCount := TeamKillCounts[1] or 0
        Team3KillCount := TeamKillCounts[2] or 0
        Team4KillCount := TeamKillCounts[3] or 0

        for(Player : GetPlayspace().GetPlayers()):
            if(Texts := PlayerTexts[Player]):
                Texts(0).SetText(Text("{Team1KillCount}"))
                Texts(1).SetText(Text("{Team2KillCount}"))
                Texts(2).SetText(Text("{Team3KillCount}"))
                Texts(3).SetText(Text("{Team4KillCount}"))
            else:
                Print("Player texts not found, unable to update them.")