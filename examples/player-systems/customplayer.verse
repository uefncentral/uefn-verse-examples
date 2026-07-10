# Team Score UI System
# Creates a custom player class that displays blue and red team scores with colored UI elements. The system manages individual player data including collected objects count and renders team score widget
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/customplayer?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Fortnite.com/UI }
using { /Verse.org/Colors }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }

using {UI}


CustomPlayer := class():

    var UniqueID:int = 0
    MyAgentObj:agent

    var CollectedObjectsCount:int = 0

    var BlueTeamScoreText:text_block = text_block{}
    var RedTeamScoreText:text_block = text_block{}
    BlueTeamTexture : texture_block = texture_block{DefaultImage := blue_team_ui, DefaultDesiredSize := vector2{X := 100.0, Y := 100.0}}
    RedTeamTexture : texture_block = texture_block{DefaultImage := red_team_ui, DefaultDesiredSize := vector2{X := 100.0, Y := 100.0}}

    StringToMessage<localizes>(value:string)<computes> : message = "{value}"

    var BlueTeamScore:int = 0
    var RedTeamScore:int = 0

    InitializePlayer(UID:int):void=
        set UniqueID = UID
        Print("new player in game")
        set BlueTeamScoreText = text_block{DefaultText := StringToMessage("{BlueTeamScore}"), DefaultTextColor:=NamedColors.Blue, DefaultShadowColor:=NamedColors.Black, DefaultShadowOffset:=option{vector2{X:=2.0, Y:=2.0}}}
        set RedTeamScoreText = text_block{DefaultText := StringToMessage("{RedTeamScore}"), DefaultTextColor:=NamedColors.Red, DefaultShadowColor:=NamedColors.Black, DefaultShadowOffset:=option{vector2{X:=2.0, Y:=2.0}}}

        ScoreWidget:canvas = CreateUserUI()
        if(PlayerObj:=player[MyAgentObj], PlayerUI := GetPlayerUI[PlayerObj]):
            PlayerUI.AddWidget(ScoreWidget)


    #
    CreateUserUI<private>() : canvas=
        UICanvas : canvas = canvas:
            Slots := array:
                canvas_slot:
                    Widget := BlueTeamTexture
                    Anchors := anchors{Minimum := vector2{X := 0.4, Y := 0.0 }, Maximum := vector2{X := 0.4, Y := 0.0 }}

                canvas_slot: 
                    Anchors := anchors{Minimum := vector2{X := 0.425, Y := 0.1}, Maximum := vector2{X := 0.425, Y := 0.1}}
                    Offsets := margin{Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 1.0}
                    SizeToContent := true
                    ZOrder := 30
                    Widget := overlay:
                        Slots := array:                                                    
                            overlay_slot:
                                Widget := BlueTeamScoreText

                canvas_slot:
                    Widget := RedTeamTexture
                    Anchors := anchors{Minimum := vector2{X := 0.6, Y := 0.0 }, Maximum := vector2{X := 0.6, Y := 0.0 }}

                canvas_slot: 
                    Anchors := anchors{Minimum := vector2{X := 0.625, Y := 0.1}, Maximum := vector2{X := 0.625, Y := 0.1}}
                    Offsets := margin{Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 1.0}
                    SizeToContent := true
                    ZOrder := 30
                    Widget := overlay:
                        Slots := array:                                                    
                            overlay_slot:
                                Widget := RedTeamScoreText


    #
    SetTeamScores(BlueTeam:int, RedTeam:int):void=
        set BlueTeamScore = BlueTeam
        set RedTeamScore = RedTeam

        BlueTeamScoreText.SetText(StringToMessage("{BlueTeamScore}"))
        RedTeamScoreText.SetText(StringToMessage("{RedTeamScore}"))

        SeeIfThereIsAWinner()

    SeeIfThereIsAWinner():void=
        if(BlueTeamScore <> RedTeamScore):
            if(BlueTeamScore > RedTeamScore):
                Print("Blue team wins")
            else:
                Print("Red team wins")




    GetCollectibleCount():int=
        Print("current count: {CollectedObjectsCount}")
        return CollectedObjectsCount

    ResetCollectibleCount():void=
        set CollectedObjectsCount = 0

    AddCollectible():void=
        set CollectedObjectsCount +=1
