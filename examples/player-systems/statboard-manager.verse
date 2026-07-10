# Player Statistics Leaderboard
# Creates interactive player statboards that display real-time player statistics including level, high score, all-time score, and time played. Uses billboard devices to show player data and names with a
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/statboard-manager?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/Colors }
using { /Verse.org/Colors/NamedColors }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation/Tags }
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /Verse.org/Assets }

StatboardManagerTag := class(tag){}

statboard := class<concrete><unique>:
    @editable Hologram:player_reference_device = player_reference_device{}
    @editable Name:player_reference_device = player_reference_device{}

    @editable TextAgentBillboard:billboard_device = billboard_device{}
    @editable TextLevelBillboard:billboard_device = billboard_device{}
    @editable TextHighScoreBillboard:billboard_device = billboard_device{}
    @editable TextATSBillboard:billboard_device = billboard_device{}
    @editable TextTimePlayedBillboard:billboard_device = billboard_device{}

    @editable LevelDataBillboard:billboard_device = billboard_device{}
    @editable HighScoreDataBillboard:billboard_device = billboard_device{}
    @editable ATSDataBillboard:billboard_device = billboard_device{}
    @editable TimePlayedDataBillboard:billboard_device = billboard_device{}

statboard_manager := class(creative_device):

    var StatsManager<public> : stats_manager = stats_manager{}

    @editable Button:button_device = button_device{}

    @editable Statboards:[]statboard = array{}

    Text<localizes>(Value:string):message = "{Value}"
    TextAgent<localizes>(Agent:agent):message = "{Agent}"
    RankedLevelText<localizes>():message = "Level:"
    RankedHighScoreText<localizes>():message = "High Score:"
    RankedATSText<localizes>():message = "All Time Score:"
    RankedTimePlayedText<localizes>():message = "Time Played:"

    RankedLevelText<localizes>(Level:int):message = "{Level}"
    RankedHighScoreDataText<localizes>(HighScore:int):message = "{HighScore}"
    RankedATSDataText<localizes>(AllTimeScore:int):message = "{AllTimeScore}"
    RankedTimePlayedDataText<localizes>(Hours:int,Minutes:int):message = "{Hours}hrs {Minutes}m"
    


    OnBegin<override>()<suspends>:void=
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerRemoved)
        Button.InteractedWithEvent.Subscribe(HandleButton)
        SpawnPadPoints := GetCreativeObjectsWithTag(SpawnPadTag{})
    
        for(Statboard:Statboards):
            ClearStatboard(Statboard)

        for (SpawnPads : SpawnPadPoints, SpawnPad := player_spawner_device[SpawnPads]):
            SpawnPad.SpawnedEvent.Subscribe(OnPlayerSpawned)

    HandleButton(Agent:agent):void=
        spawn:
            BoardLoop(Agent)

    BoardLoop(Agent:agent)<suspends>:void=
        if(Index:=PlayersArray.Find[Agent], Statboard:=Statboards[Index]):

            UpdateAgentStatboard(Agent)

    UpdateAgentStatboard(Agent:agent):void=
        if (Index:=PlayersArray.Find[Agent], Statboard:=Statboards[Index]):
            var Level:int = StatsManager.GetStat("Level", Agent)
            var HighScore:int = StatsManager.GetStat("HighScore", Agent)
            var AllTimeScore:int = StatsManager.GetStat("AllTimeScore", Agent)
            var TimePlayed:int = StatsManager.GetStat("Playtime", Agent)

            var Minutes : int = 0
            var Hours : int = 0

            if (Minutess := Mod[TimePlayed, 60]):
                set Minutes = Minutess

            if (Hourss := Floor(TimePlayed / 60)):
                set Hours = Hourss

            Statboard.LevelDataBillboard.SetText(RankedLevelText(Level))
            Statboard.HighScoreDataBillboard.SetText(RankedHighScoreDataText(HighScore))
            Statboard.ATSDataBillboard.SetText(RankedATSDataText(AllTimeScore))
            Statboard.TimePlayedDataBillboard.SetText(RankedTimePlayedDataText(Hours,Minutes))


            Statboard.TextAgentBillboard.SetText(TextAgent(Agent))
            Statboard.TextLevelBillboard.SetText(RankedLevelText())
            Statboard.TextHighScoreBillboard.SetText(RankedHighScoreText())
            Statboard.TextATSBillboard.SetText(RankedATSText())
            Statboard.TextTimePlayedBillboard.SetText(RankedTimePlayedText())

            Statboard.Hologram.Register(Agent)
            Statboard.Name.Register(Agent)

    ClearStatboard(Statboard:statboard):void=
        Statboard.Hologram.Clear()
        Statboard.Name.Clear()
        Statboard.LevelDataBillboard.SetText(Text(" "))
        Statboard.HighScoreDataBillboard.SetText(Text(" "))
        Statboard.ATSDataBillboard.SetText(Text(""))
        Statboard.TimePlayedDataBillboard.SetText(Text(" "))

        Statboard.TextAgentBillboard.SetText(Text(" "))
        Statboard.TextLevelBillboard.SetText(Text(" "))
        Statboard.TextHighScoreBillboard.SetText(Text(" "))
        Statboard.TextATSBillboard.SetText(Text(" "))
        Statboard.TextTimePlayedBillboard.SetText(Text(" "))

    var PlayersArray:[]agent = array{}

    OnPlayerSpawned(Agent:agent):void=
        set PlayersArray = PlayersArray + array{Agent}

    OnPlayerRemoved(Player:player):void=
        if(Agent:=agent[Player]):
            if(Index:=PlayersArray.Find[Agent]):
                if(TempArray:=PlayersArray.RemoveElement[Index]):
                    set PlayersArray = TempArray

    ApproximateFloat<public>(Value : float , decimalplace : float): float =
        factor := Pow(10.0,decimalplace)
        if(Rounded := Int[Value*factor]*1.0/factor):
            return Rounded
        else:
            return 0.0