# Game Manager 2
# Verse code for Game Manager 2 - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/game-manager-2-1?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Simulation/Tags}
using { /Verse.org/Random }
using { /Fortnite.com/FortPlayerUtilities }

player_spawners := class(tag){}

custom_player := class<unique>():

    var VoteIndex : ?int = false 

custom_player2 := class<concrete>:

    var Eliminations : int = 0

Arenas12 := class<concrete>:

    @editable Teleporters : []teleporter_device = array{}

    @editable Barriers : []barrier_device = array{}


game_manager := class(creative_device):

    var AllPlayers2 : [player]custom_player = map{}  

    @editable Switches : []switch_device = array{}

    @editable ScoreManagers : []score_manager_device = array{}

    @editable Teleporters2 : []teleporter_device = array{}



    var AllPlayers : [player]custom_player2 = map{}  

    var GameStarted : logic = false

    @editable MyArenas1 : []Arenas12 = array{}

    @editable EndTeleporter : teleporter_device = teleporter_device{}

    @editable StartTeleporter : teleporter_device = teleporter_device{}

    @editable YourWinsTracker : tracker_device = tracker_device{}
    @editable YourLossesTracker : tracker_device = tracker_device{}

    @editable TimerDeviceLoadoutVote : timer_device = timer_device{}

    @editable TimerDeviceDropBarriers : timer_device = timer_device{}

    var PlayedArenas1 : []int = array{}

    @editable ItemGranters : []item_granter_device = array{}

    var LoadoutIndex : int = 100


    OnBegin<override>()<suspends>:void=

        YourWinsTracker.SetValue(0)
        YourLossesTracker.SetValue(0)

        AllPlayers33:=GetPlayspace().GetPlayers()
        for(Player:AllPlayers33):

            if(FortCharacter:=Player.GetFortCharacter[]):
                FortCharacter.EliminatedEvent().Subscribe(EliminatedEvent)
                
            CustomPlayer := custom_player2{}
            if (set AllPlayers[Player] = CustomPlayer){}
            
            StartTeleporter.Teleport(Player)

            if(AllPlayers.Length=2 and GameStarted=false):
                set GameStarted=true
                spawn{StartGame()}
        
        SubscribeToSpawners()
        SubscribeToTeleporters()
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerLeftServer)


    SubscribeToTeleporters():void=

        for(Index->Teleporter:Teleporters2):
            Teleporter.EnterEvent.SubscribeAgent(PlayerVoted,Index)


    PlayerVoted(Agent:agent,Index:int):void=

        if (Player := player[Agent]):

            if (CustomPlayer := AllPlayers2[Player]):

                Print("Player Existing")

                if:
                    OldVoteIndex := CustomPlayer.VoteIndex?
                    OldVoteIndex <> Index
                    ScoreManagerOld:=ScoreManagers[OldVoteIndex]
                    SwitchOld:=Switches[OldVoteIndex]
                    ScoreManagerNew:=ScoreManagers[Index]
                    SwitchNew:=Switches[Index]
                then:
                    ScoreManagerOld.Decrement()
                    SwitchOld.TurnOff(Agent)
                    ScoreManagerNew.Increment()
                    SwitchNew.TurnOn(Agent)
                    set CustomPlayer.VoteIndex = option{Index}

                    Print("Remove old and add new vote")

            else:

                Print("Register Player")

                CustomPlayer := custom_player{}

                set CustomPlayer.VoteIndex = option{Index}
                
                if:
                    set AllPlayers2[Player] = CustomPlayer
                    ScoreManager:=ScoreManagers[Index]
                    Switch:=Switches[Index]
                then:
                    ScoreManager.Increment()
                    Switch.TurnOn(Agent)

                    Print("Add Vote")

                    
    GetIndexWithMostVotes():int=

        var Location : int = 0

        var HighestVote : int = -1
        
        for(Index->ScoreManager:ScoreManagers):

            NumbVotes:=ScoreManager.GetScoreAward()

            if(NumbVotes>HighestVote):
                set Location = Index
                set HighestVote = NumbVotes

            else if (NumbVotes=HighestVote, GetRandomInt(0,1)=1):

                set Location = Index
                set HighestVote = NumbVotes
        
        Print("Winner Index = {Location}")

        return Location

    SubscribeToSpawners():void=
        Spawners := GetCreativeObjectsWithTag(player_spawners{}) 
        for (Each : Spawners):
            if (Spawner := player_spawner_device[Each]):
                Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)


    OnPlayerSpawned(Agent : agent):void= 
        
        
        if (Player := player[Agent]):

            if (Existing := AllPlayers[Player]):

            else:

                if(FortCharacter:=Agent.GetFortCharacter[]):
                    FortCharacter.EliminatedEvent().Subscribe(EliminatedEvent)
                    
                CustomPlayer := custom_player2{}
                if (set AllPlayers[Player] = CustomPlayer){}

                StartTeleporter.Teleport(Player)

        if(AllPlayers.Length=2 and GameStarted=false):
            set GameStarted=true
            spawn{StartGame()}


    OnPlayerLeftServer(Player : player):void=

        var TempMap : [player]custom_player2 = map{}

        for (Key -> Value : AllPlayers, Key <> Player):
            set TempMap = ConcatenateMaps(TempMap, map{Key => Value})
        
        set AllPlayers = TempMap    

        #end round 


    EliminatedEvent(Result : elimination_result) : void=
        
        EliminatedFort := Result.EliminatedCharacter
        Killer := Result.EliminatingCharacter

        if:
            KillerFort := Killer? 
            KillerAgent:=KillerFort.GetAgent[]
            EliminatedAgent:=EliminatedFort.GetAgent[]

            KillerPlayer:=player[KillerAgent]
            KillerCustomPlayer:=AllPlayers[KillerPlayer]

            EliminatedPlayer:=player[EliminatedAgent]
            EliminatedCustomPlayer:=AllPlayers[EliminatedPlayer]
            
        then:

            if(EliminatedAgent = KillerAgent):
            else:
                set KillerCustomPlayer.Eliminations += 1

                if(KillerCustomPlayer.Eliminations>=10):
                    Print("Done")
                    spawn{Respawn()}
                            
                else:
                    spawn{TeleportToArena()}
            
                YourWinsTracker.Increment(KillerAgent)
                YourLossesTracker.Increment(EliminatedAgent)

    Respawn()<suspends>:void=
        Sleep(1.0)
        for(Key->Index : AllPlayers):
            if(FortCharacter:=Key.GetFortCharacter[],FortCharacter.IsActive[]):
                Print("Teleport")
                EndTeleporter.Teleport(Key)
            else:
                Print("Respawn")
                Key.Respawn(EndTeleporter.GetTransform().Translation+vector3{X:=0.0,Y:=200.0,Z:=0.0}, EndTeleporter.GetTransform().Rotation)


    StartGame()<suspends>:void=

        TimerDeviceLoadoutVote.Start()
        TimerDeviceLoadoutVote.SuccessEvent.Await()

        set LoadoutIndex = GetIndexWithMostVotes()
        Print("{LoadoutIndex}")

        TeleportToArena()


    TeleportToArena()<suspends>:void=

        Sleep(0.1)

        var rand : int = 0
        var check : logic = false

        loop:
            set rand = GetRandomInt(0,MyArenas1.Length-1)
            set check = false

            for(numb:PlayedArenas1):
                if(numb=rand):
                    set check = true

            if(check=false):
                set PlayedArenas1 = PlayedArenas1 + array{rand}
                break
            
            Print("Looking For Rand (Free Arena) {rand}")

        if:
            Teleporters:=MyArenas1[rand].Teleporters
            Barriers:=MyArenas1[rand].Barriers
        then:

            var brojo : int = 0

            for(Key->Index : AllPlayers):
            
                if:
                    Teleporter:=Teleporters[brojo]
                    ItemGranter:=ItemGranters[LoadoutIndex]
                    FortCharacter:=Key.GetFortCharacter[]
                then:
                    if(FortCharacter.IsActive[]):
                        Teleporter.Teleport(Key)
                    else:
                        Key.Respawn(Teleporter.GetTransform().Translation, Teleporter.GetTransform().Rotation)
                    ItemGranter.GrantItem(Key)
                    FortCharacter.Heal(100.0)
                    FortCharacter.SetShield(100.0)

                set brojo += 1

            TimerDeviceDropBarriers.Start()
            TimerDeviceDropBarriers.SuccessEvent.Await()
            TimerDeviceDropBarriers.Reset()

            for(Barrier:Barriers):
                Barrier.Disable()




(Listenable : listenable(agent)).SubscribeAgent(OutputFunc : tuple(agent, t)->void, ExtraData : t where t:type) : cancelable =
    Wrapper := wrapper_agent(t){ExtraData := ExtraData, OutputFunc := OutputFunc}
    Listenable.Subscribe(Wrapper.InputFunc)
    
wrapper_agent(t : type) := class():
    ExtraData : t;
    OutputFunc : tuple(agent, t) -> void
    InputFunc(Agent : agent):void = OutputFunc(Agent, ExtraData)