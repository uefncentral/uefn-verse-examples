# Playtime Analytics Tracker
# This device tracks player session times and categorizes players as new or returning for analytics purposes. It automatically starts tracking when players join and stops when they leave, sending data t
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/playtimeanalitycs-1?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

playtime_analytics_time := class<concrete>():

    @editable NewPlayerAnalytic                 : analytics_device = analytics_device{}
    @editable ReturnPlayerAnalytic              : analytics_device = analytics_device{}
    @editable Time                              : float = 0.0

playtime_analytics_playerdata := class<concrete>():

    var StartTime                               : float = 0.0
    var IsReturningPlayer                       : logic = false

playtime_analytics_device := class(creative_device):

    var PlayerData                              : [player]playtime_analytics_playerdata = map{}
    @editable Analytics                         : []playtime_analytics_time = array{}
 
    OnBegin<override>()<suspends>:void=

        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerAdded)
        AllPlayers := GetPlayspace().GetPlayers()
        
        #start tracking players already connected
        for(Player : AllPlayers):
            OnPlayerAdded(Player)

        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerRemoved)
    
    OnTestRemoved(Agent:agent):void=
        if(MaybePlayer := player[Agent]):
            OnPlayerRemoved(MaybePlayer)

    #it is upon you to mark an agent as returning, however you decide to do this, from a save point through a trigger relay, or via verse code
    SetPlayerAsReturning(Agent:agent):void=
        if(CastedPlayer := player[Agent], MyPlayerData := PlayerData[CastedPlayer]):
            set MyPlayerData.IsReturningPlayer = true
            if(set PlayerData[CastedPlayer] = MyPlayerData):

    OnPlayerAdded(Player:player):void=
        CurrentTime := GetSimulationElapsedTime()
        if(set PlayerData[Player] = playtime_analytics_playerdata{ StartTime := CurrentTime }):

    OnPlayerRemoved(Player:player):void=
        if(not Player.IsActive[]):
            return

        CurrentTime := GetSimulationElapsedTime()
        if(MyPlayerData := PlayerData[Player]):
            DeltaTimeSeconds := CurrentTime - MyPlayerData.StartTime 
            var MaybeLastHigher : ?playtime_analytics_time = false
            for(AnalyticTime : Analytics):
                if(AnalyticTime.Time < DeltaTimeSeconds):
                    set MaybeLastHigher = option{AnalyticTime}
            if(LastHigher := MaybeLastHigher?):
                if(not MyPlayerData.IsReturningPlayer?):
                    LastHigher.NewPlayerAnalytic.Submit(Player)
                else:
                    LastHigher.ReturnPlayerAnalytic.Submit(Player)