# Ranks
# Verse code for Ranks - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/ranks?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /Verse.org/Colors/NamedColors }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Assets }



# A Verse-authored creative device that can be placed in a level
WafflezFNOnTwitter := class(creative_device):
 
    S2M<localizes>(S:string):message="{S}"
 
    @editable PlayerSpawners : []player_spawner_device = array{}
    @editable RefreshRate : float = 0.1
    @editable TrackerDevice : tracker_device = tracker_device{}
    
    var myMap : [agent]int = map{}
 
    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        for(PS:PlayerSpawners):
            PS.SpawnedEvent.Subscribe(PlayerSpawned)

    PlayerSpawned(Agent:agent):void=
        Print("Player Spawned")
        if(T:=PlayerRanks[Agent]){}
        else:
            AssignUI(Agent)
 
    AssignUI(Agent:agent):void=
        Print("Assigning UI")
        MyCanvas:=MakeCanvas(Agent)
        if:
            PlayerUI:=GetPlayerUI[player[Agent]]
        then:
            PlayerUI.AddWidget(MyCanvas)
            spawn{RefreshUI(Agent)}
 
    var currRankImage : texture = Ranks.Unranked

    RefreshUI(Agent:agent)<suspends>:void=
        Print("Starting to Refresh")
        TrackerDevice.Load(Agent)
        if(T := PlayerRanks[Agent]):
            var CurrRank: string = "Bronze I "
            var Goal: string = " / 20"
            var Gap : string = ""
            var Gap1 : string = ""
            loop:
                WafflezFNTwitter := TrackerDevice.GetValue(Agent)
                Sleep(RefreshRate)
                if(WafflezFNTwitter >= 0 and WafflezFNTwitter < 20):
                    set CurrRank = "Bronze I "
                    set currRankImage = Ranks.Bronze1
                    set Goal = " / 20"
                    set Gap = ""
                    set Gap1 = " "
                else if(WafflezFNTwitter >= 20 and WafflezFNTwitter < 50):
                    set CurrRank = "Bronze II "
                    set currRankImage = Ranks.Bronze2
                    set Goal = " / 50"
                    set Gap = ""
                    set Gap1 = " "
                else if(WafflezFNTwitter >= 50 and WafflezFNTwitter < 100):
                    set CurrRank = "Bronze III "
                    set currRankImage = Ranks.Bronze3
                    set Goal = " / 100"
                    set Gap = ""
                    set Gap1 = " "
                else if(WafflezFNTwitter >= 100 and WafflezFNTwitter < 160):
                    set CurrRank = "Silver I "
                    set currRankImage = Ranks.Silver1
                    set Goal = " / 160"
                    set Gap = " "
                    set Gap1 = ""
                else if(WafflezFNTwitter >= 160 and WafflezFNTwitter < 225):
                    set CurrRank = "Silver II "
                    set currRankImage = Ranks.Silver2
                    set Goal = " / 225"
                    set Gap = " "
                    set Gap1 = ""
                else if(WafflezFNTwitter >= 225 and WafflezFNTwitter < 300):
                    set CurrRank = "Silver III "
                    set currRankImage = Ranks.Silver3
                    set Goal = " / 300"
                    set Gap = " "
                    set Gap1 = ""
                else if(WafflezFNTwitter >= 300 and WafflezFNTwitter < 400):
                    set CurrRank = "Gold I "
                    set currRankImage = Ranks.Gold1
                    set Goal = " / 400"
                    set Gap = "   "
                    set Gap1 = ""
                else if(WafflezFNTwitter >= 400 and WafflezFNTwitter < 500):
                    set CurrRank = "Gold II "
                    set currRankImage = Ranks.Gold2
                    set Goal = " / 500"
                    set Gap = "  "
                    set Gap1 = ""
                else if(WafflezFNTwitter >= 500 and WafflezFNTwitter < 600):
                    set CurrRank = "Gold III "
                    set currRankImage = Ranks.Gold3
                    set Goal = " / 600"
                    set Gap = "  "
                    set Gap1 = ""
                else if(WafflezFNTwitter >= 600 and WafflezFNTwitter < 750):
                    set CurrRank = "Platinum I "
                    set currRankImage = Ranks.Plat1
                    set Goal = " / 750"
                    set Gap = ""
                    set Gap1 = ""
                else if(WafflezFNTwitter >= 750 and WafflezFNTwitter < 850):
                    set CurrRank = "Platinum II "
                    set currRankImage = Ranks.Plat2
                    set Goal = " / 850"
                    set Gap = ""
                    set Gap1 = ""
                else if(WafflezFNTwitter >= 850 and WafflezFNTwitter < 1000):
                    set CurrRank = "Platinum III "
                    set currRankImage = Ranks.Plat2
                    set Goal = " / 1K"
                    set Gap = ""
                    set Gap1 = " "
                else if(WafflezFNTwitter >= 1000 and WafflezFNTwitter < 1150):
                    set CurrRank = "Diamond I "
                    set currRankImage = Ranks.Diamond1
                    set Goal = " / 1.15K"
                    set Gap = " "
                    set Gap1 = ""
                else if(WafflezFNTwitter >= 1150 and WafflezFNTwitter < 1300):
                    set CurrRank = "Diamond II "
                    set currRankImage = Ranks.Diamond1
                    set Goal = " / 1.3K"
                    set Gap = ""
                    set Gap1 = ""
                else if(WafflezFNTwitter >= 1300 and WafflezFNTwitter < 1500):
                    set CurrRank = "Diamond III "
                    set currRankImage = Ranks.Diamond1
                    set Goal = " / 1.5K"
                    set Gap = ""
                    set Gap1 = ""
                else if(WafflezFNTwitter >= 1500 and WafflezFNTwitter < 1800):
                    set CurrRank = "Elite "
                    set currRankImage = Ranks.Elite
                    set Goal = " / 1.8K"
                    set Gap = "     "
                else if(WafflezFNTwitter >= 1800 and WafflezFNTwitter < 2000):
                    set CurrRank = "Champion "
                    set currRankImage = Ranks.Champion
                    set Goal = " / 2K"
                    set Gap = ""
                    set Gap1 = ""
                else if(WafflezFNTwitter >= 2000):
                    set CurrRank = "Unreal "
                    set currRankImage = Ranks.Unreal
                    set Goal = ""
                    set Gap = ""
                    set Gap1 = " "

                TextBlock := T(0)
                ImageRank := T(1)
                TextBlock.SetText(S2M("{Gap}{CurrRank} \n{Gap1}{WafflezFNTwitter}{Goal}"))
                ImageRank.SetImage(currRankImage)
                TrackerDevice.Save(Agent)
               
    var PlayerRanks: [player]tuple(text_block, texture_block) = map{}

    MakeCanvas(Agent:agent):canvas=
        Print("Making Canvas")
        MyTextBlock:=text_block:
            DefaultTextColor:=White

        RankImage := texture_block:
            DefaultImage := currRankImage
            DefaultDesiredSize := vector2{X := 80.0, Y := 80.0}

        if(Player := player[Agent]):
            if:
                set PlayerRanks[Player] = (MyTextBlock, RankImage)

        MyCanvas:=canvas:
            Slots:=array:
                canvas_slot:
                    Widget:= RankImage
                    Anchors := anchors{ Minimum := vector2{X := 0.005, Y := 0.6}, Maximum := vector2{X := 0.005, Y := 0.6}}
                    Offsets := margin{Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.0, Y := 0.6}
                    SizeToContent := true
                    ZOrder := 3
                canvas_slot:
                    Widget:=MyTextBlock
                    Anchors := anchors{ Minimum := vector2{X := 0.05, Y := 0.6}, Maximum := vector2{X := 0.05, Y := 0.6}}
                    Offsets := margin{Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.0, Y := 0.6}
                    SizeToContent := true
                    ZOrder := 2
 
        return MyCanvas