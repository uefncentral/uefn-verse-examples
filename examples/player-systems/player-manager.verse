# Player Manager System
# This code creates a comprehensive player management system that tracks players, handles team assignments, monitors playtime, and manages scoring events. It uses team selectors for player organization,
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/player-manager?ref=github


using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Assets}
using { player_class }
using { helpers.MyUtils }

var PlayerProfileDataMap:weak_map(player, player_profile_data) = map{}

score_event<public> := struct:
    Agent<public>:agent
    Score<public>:int = 0


player_manager<public> := class<concrete>():
    @editable 
    OrderedTeamSelectors : []class_and_team_selector_device = array{}

    @editable 
    PlayTimeTimer : timer_device = timer_device{}

    @editable 
    PlayTimeAccolade : accolades_device = accolades_device{}

    var AllPlayers : [agent]player_info = map{}

    var Inited : logic = false

    ScoreEvent:event(score_event) = event(score_event){}
    PlayerAddedEvent:event(player_info) = event(player_info){}

    Init(CreativeDeviceInterface: creative_object_interface)<suspends>:void=
        CreativeDeviceInterface.GetPlayspace().PlayerAddedEvent().Subscribe(AddPlayer)
        CreativeDeviceInterface.GetPlayspace().PlayerRemovedEvent().Subscribe(RemovePlayer)
        FetchedPlayers := CreativeDeviceInterface.GetPlayspace().GetPlayers()
        for (FetchedPlayer : FetchedPlayers):
            AddPlayer(FetchedPlayer)
        var indexer : int = 1
        for ( TeamSelector : OrderedTeamSelectors ):
            TeamSelector.TeamSwitchedEvent.SubscribeAgent(TeamSelectorListener, indexer)
            set indexer += 1
        PlayTimeTimer.SuccessEvent.Subscribe(GrantPlayTimeAccolade)
        # spawn{PlayerTeamEnumerator()}
        # spawn{PlayerScoreGranter()}
        # spawn{PlayerSave()}
        set Inited = true

    PlayerScoreGranter()<suspends>:void=
        loop:
            ThisScoreEvent := ScoreEvent.Await()
            if ( PlayerData := AllPlayers[ThisScoreEvent.Agent] ):
                set PlayerData.Score += ThisScoreEvent.Score

    PlayerSave()<suspends>:void=
        loop:
            PlayerSaveSingle()
            Sleep(15.0)

    PlayerSaveSingle():void=
        Print("Saving Data")
        for ( Agent->PInfo : AllPlayers ):
            PlayerData := PInfo
            if:
                Player := player[Agent]
                SourceData := PlayerProfileDataMap[Player]
                set PlayerProfileDataMap[Player] = player_profile_data:
                    MakePlayerProfileData<constructor>(SourceData)
                    Score := PlayerData.Score
                    Elims := PlayerData.Elims


    GrantPlayTimeAccolade(MaybeDude: ?agent):void=
        for ( Player : AllPlayers ):
            PlayTimeAccolade.Award(Player.AgentRef)

    TriggerAddEvent(PInfo: player_info)<suspends>:void=
        PlayerAddedEvent.Signal(PInfo)

    AddPlayer(Dude: agent):void=
        Print("In add new player")
        if ( IsPlayerNew(Dude)? ):
            Print("It is a new player, adding to all players")
            if (DudesPlayer := player[Dude], DudesAgent:= agent[Dude], DudesCharacter := fort_character[Dude.GetFortCharacter[]], DudesCharacter.IsActive[]):
                if:
                    not PlayerProfileDataMap[DudesPlayer]
                    set PlayerProfileDataMap[DudesPlayer] = player_profile_data{}
                    var OurPlayer : player_info = player_info{AgentRef:=DudesAgent,PlayerRef:=DudesPlayer,CharRef:=DudesCharacter, Profile:=PlayerProfileDataMap[DudesPlayer]}
                    if (set AllPlayers[Dude] = OurPlayer) {}
                then:
                    spawn{TriggerAddEvent(OurPlayer)}
                else:
                    if:
                        var OurPlayer : player_info = player_info{AgentRef:=DudesAgent,PlayerRef:=DudesPlayer,CharRef:=DudesCharacter, Profile:=PlayerProfileDataMap[DudesPlayer]}
                        set OurPlayer.Score = OurPlayer.Profile.Score
                        set OurPlayer.Elims = OurPlayer.Profile.Elims
                        if (set AllPlayers[Dude] = OurPlayer) {}
                    then:
                        Print("Found Saved Data for player")
                        spawn{TriggerAddEvent(OurPlayer)}
            else:
                Print("Failing to get the infos")
                AddPlayer(Dude)
        else:
            Print("This Player is not new")

    RemovePlayer(Dude: agent):void=
        var NewMap:[agent]player_info = map{}
        for (Key -> Value : AllPlayers, Key <> Dude):
            set NewMap = ConcatenateMaps(NewMap, map{Key => Value})
        set AllPlayers = NewMap

    IsPlayerNew(Dude : agent)<transacts>:logic=
        for (Agent -> PInfo : AllPlayers):
            if (PInfo.AgentRef = Dude):
                return false
        return true

    TeamSelectorListener(Dude: agent, TeamInt: int):void=
        for (Agent -> PInfo : AllPlayers):
            if ( PInfo.AgentRef = Dude ):
                Print("Setting Team Slot")
                set PInfo.PlayerTeamSlot = TeamInt
                return

    PlayerTeamEnumerator()<suspends>:void=
        loop:
            # Print("Currently have {AllPlayers.Length} players")
            for (Agent -> PInfo : AllPlayers):
                # Print("Player's team {PInfo.PlayerTeamSlot}")
                Print("Player's Coins: {PInfo.Profile.Coins}")
            Sleep(15.0)

    GetPlayers():[agent]player_info=
        return AllPlayers

    RevokeRespawnForTeam(TeamIndex: int):void=
        for ( p_info : AllPlayers):
            if (p_info.PlayerTeamSlot = TeamIndex):
                set p_info.CanRespawn = false
                return

    RevokeRespawnForPlayer(Dude: agent):void=
        for ( p_info : AllPlayers):
            if (p_info.AgentRef = Dude):
                set p_info.CanRespawn = false
                return

    GetPlayerInfo(Dude:agent):?player_info=
        for ( Player : AllPlayers ):
            if ( Player.AgentRef = Dude ):
                return option{Player}
        return false

    SetClass(Dude:agent, PowerName: string):void=
        for ( Player : AllPlayers ):
            if ( Player.AgentRef = Dude ):
                set Player.PlayerClassName = PowerName
                return

    GetClass(Dude:agent):string=
        for ( Player : AllPlayers ):
            if ( Player.AgentRef = Dude ):
                return Player.PlayerClassName
        return ""
                
    GetPlayerInfoFromCharacter(TheCharacter : fort_character)<transacts>:?player_info=
        for ( p_info : AllPlayers):
            if ( p_info.CharRef = TheCharacter ):
                return option{p_info}
        return false

    GetPlayerAgentFromTeam(TeamInt: int):?agent=
        for ( p_info : AllPlayers):
            if (p_info.PlayerTeamSlot = TeamInt):
                return option{p_info.AgentRef}
        return false

    GetPlayerAgentsFromTeam(TeamInt: int):[]agent=
        var Agents : []agent = array{}
        for ( p_info : AllPlayers):
            if (p_info.PlayerTeamSlot = TeamInt):
                set Agents += array{p_info.AgentRef}
        return Agents


    GetPlayerStats(Agent:agent)<decides><transacts>:player_profile_data=
        var PlayerStats:player_profile_data = player_profile_data{}
        if:
            Player := player[Agent]
            PlayerStatsTable := PlayerProfileDataMap[Player]
            set PlayerStats = MakePlayerProfileData(PlayerStatsTable)
        PlayerStats

    SetPlayerStat(Agent:agent, Stat:string, Value:int):void=
        if:
            Player := player[Agent]
            PlayerStatsTable := PlayerProfileDataMap[Player]

            if(Stat = "Coins"):
                set PlayerProfileDataMap[Player] = player_profile_data:
                    MakePlayerProfileData<constructor>(PlayerStatsTable)
                    Coins := Value
            else if(Stat = "HighScore"):
                set PlayerProfileDataMap[Player] = player_profile_data:
                    MakePlayerProfileData<constructor>(PlayerStatsTable)
                    HighScore := Value
            else if(Stat = "AllTimeScore"):
                set PlayerProfileDataMap[Player] = player_profile_data:
                    MakePlayerProfileData<constructor>(PlayerStatsTable)
                    AllTimeScore := Value
            else if(Stat = "Playtime"):
                set PlayerProfileDataMap[Player] = player_profile_data:
                    MakePlayerProfileData<constructor>(PlayerStatsTable)
                    Playtime := Value
            else if(Stat = "Score"):
                set PlayerProfileDataMap[Player] = player_profile_data:
                    MakePlayerProfileData<constructor>(PlayerStatsTable)
                    Score := Value
            else if(Stat = "Level"):
                set PlayerProfileDataMap[Player] = player_profile_data:
                    MakePlayerProfileData<constructor>(PlayerStatsTable)
                    Level := Value

    RecordPlayerStat(Agent:agent, Stat:string, ?Value:int = 0):void=
        if:
            Player := player[Agent]
            PlayerStatsTable := PlayerProfileDataMap[Player]

            if(Stat = "Coins"):
                CoinsStat := PlayerStatsTable.Coins
                set PlayerProfileDataMap[Player] = player_profile_data:
                    MakePlayerProfileData<constructor>(PlayerStatsTable)
                    Coins := CoinsStat + Value
            else if(Stat = "HighScore"):
                HighScoreStat := PlayerStatsTable.HighScore
                set PlayerProfileDataMap[Player] = player_profile_data:
                    MakePlayerProfileData<constructor>(PlayerStatsTable)
                    HighScore := HighScoreStat + Value
            else if(Stat = "AllTimeScore"):
                AllTimeScoreStat := PlayerStatsTable.AllTimeScore
                set PlayerProfileDataMap[Player] = player_profile_data:
                    MakePlayerProfileData<constructor>(PlayerStatsTable)
                    AllTimeScore := AllTimeScoreStat + Value
            else if(Stat = "Playtime"):
                PlaytimeStat := PlayerStatsTable.Playtime
                set PlayerProfileDataMap[Player] = player_profile_data:
                    MakePlayerProfileData<constructor>(PlayerStatsTable)
                    Playtime := PlaytimeStat + Value
            else if(Stat = "Score"):
                ScoreStat := PlayerStatsTable.Score
                set PlayerProfileDataMap[Player] = player_profile_data:
                    MakePlayerProfileData<constructor>(PlayerStatsTable)
                    Score := ScoreStat + Value
            else if(Stat = "Level"):
                LevelStat := PlayerStatsTable.Level
                set PlayerProfileDataMap[Player] = player_profile_data:
                    MakePlayerProfileData<constructor>(PlayerStatsTable)
                    Level := LevelStat + Value
