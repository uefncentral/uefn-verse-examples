# Ranked Points System
# A comprehensive ranking system that tracks player eliminations and awards points based on performance tiers. The system includes Bronze, Silver, Gold, Platinum, Diamond, Elite, Champion, and Unreal ra
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/advancedranked-1?ref=github



using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Simulation/Tags }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }

spawner := class(tag){}


#CLASS FOR CINEMATIC DEVICES
progress_cinematic := class<concrete><unique>:

    @editable ProgressCinematic : cinematic_sequence_device = cinematic_sequence_device{}
    var IsAvailable : logic = true

game_manager_device := class(creative_device): 

    #CUSTOM PLAYER ARRAY AND CUSTOM TEXT DEFINED
    var CustomPlayers : [player]custom_player = map{}

    #VARIABLE THAT YOU CAN EDIT IN GAME_DEVICE_MANAGER
    @editable var PointsForElimination : int = 0
    @editable var PointsForEliminated : int = 0

    @editable var BronzeMaxPoints1 : int = 0
    @editable var BronzeMaxPoints2 : int = 0
    @editable var BronzeMaxPoints3 : int = 0

    @editable var SilverMaxPoints1 : int = 0
    @editable var SilverMaxPoints2 : int = 0
    @editable var SilverMaxPoints3 : int = 0

    @editable var GoldMaxPoints1 : int = 0
    @editable var GoldMaxPoints2 : int = 0
    @editable var GoldMaxPoints3 : int = 0

    @editable var PlatinumMaxPoints1 : int = 0
    @editable var PlatinumMaxPoints2 : int = 0
    @editable var PlatinumMaxPoints3 : int = 0

    @editable var DiamondMaxPoints1 : int = 0
    @editable var DiamondMaxPoints2 : int = 0
    @editable var DiamondMaxPoints3 : int = 0

    @editable var EliteMaxPoints : int = 0
    @editable var ChampionMaxPoints : int = 0
    @editable var UnrealMaxPoints : int = 0


    #BRONZE
    @editable BronzeHUD1 : hud_message_device = hud_message_device{}
    @editable BronzeHUD2 : hud_message_device = hud_message_device{}
    @editable BronzeHUD3 : hud_message_device = hud_message_device{}
    #SILVER
    @editable SilverHUD1 : hud_message_device = hud_message_device{}
    @editable SilverHUD2 : hud_message_device = hud_message_device{}
    @editable SilverHUD3 : hud_message_device = hud_message_device{}
    #GOLD
    @editable GoldHUD1 : hud_message_device = hud_message_device{}
    @editable GoldHUD2 : hud_message_device = hud_message_device{}
    @editable GoldHUD3 : hud_message_device = hud_message_device{}
    #PLATINUM
    @editable PlatinumHUD1 : hud_message_device = hud_message_device{}
    @editable PlatinumHUD2 : hud_message_device = hud_message_device{}
    @editable PlatinumHUD3 : hud_message_device = hud_message_device{}
    #DIAMOND
    @editable DiamondHUD1 : hud_message_device = hud_message_device{}
    @editable DiamondHUD2 : hud_message_device = hud_message_device{}
    @editable DiamondHUD3 : hud_message_device = hud_message_device{}
    #OTHER
    @editable EliteHUD : hud_message_device = hud_message_device{}
    @editable ChampionHUD : hud_message_device = hud_message_device{}
    @editable UnrealHUD : hud_message_device = hud_message_device{}   

    #BRONZE
    @editable BronzeT1 : trigger_device = trigger_device{}
    @editable BronzeT2 : trigger_device = trigger_device{}
    @editable BronzeT3 : trigger_device = trigger_device{}
    #SILVER
    @editable SilverT1 : trigger_device = trigger_device{}
    @editable SilverT2 : trigger_device = trigger_device{}
    @editable SilverT3 : trigger_device = trigger_device{}
    #GOLD
    @editable GoldT1 : trigger_device = trigger_device{}
    @editable GoldT2 : trigger_device = trigger_device{}
    @editable GoldT3 : trigger_device = trigger_device{}
    #PLATINUM
    @editable PlatinumT1 : trigger_device = trigger_device{}
    @editable PlatinumT2 : trigger_device = trigger_device{}
    @editable PlatinumT3 : trigger_device = trigger_device{}
    #DIAMOND
    @editable DiamondT1 : trigger_device = trigger_device{}
    @editable DiamondT2 : trigger_device = trigger_device{}
    @editable DiamondT3 : trigger_device = trigger_device{}
    #OTHER
    @editable EliteT : trigger_device = trigger_device{}
    @editable ChampionT : trigger_device = trigger_device{}
    @editable UnrealT : trigger_device = trigger_device{}
    
    #TRACKERS
    @editable EliminationTracker : tracker_device = tracker_device{}
    @editable EliminatedTracker : tracker_device = tracker_device{}

    #PLACE A # BEFORE EVERYTHING WITH "#For roundsystem" IF YOUR NOT USING A ROUND SYSTEM OR DELETE THEM ! ! !
    #SET ISLAND SETTING "LAST STANDING ENDS GAME" TO "OFF" IF USING ROUNDS ! ! !
    @editable TriggerOnePlayer : trigger_device = trigger_device{}                      #For roundsystem
    @editable var EndGameDevice : end_game_device = end_game_device{}                   #For roundsystem

    #CINEMATIC ARRAY
    @editable ProgressCinematics : []progress_cinematic = array{}


#START
    OnBegin<override>()<suspends>:void=
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerLeftServer )
        InitSpawners()
       # Print("begin")

#CREATE SPAWNER TAGS AND AND SUBSCRIBE TO ONPLAYERSPAWNED
    InitSpawners() : void=
       # Print("InitSpawners")
        Spawners := GetCreativeObjectsWithTag(spawner{})
        for (Obj : Spawners):
            if (Spawner := player_spawner_device[Obj]):
                Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)
            
#WHEN A PLAYER JOINS THE GAME
    OnPlayerSpawned(Agent : agent): void=
        #Print("OnPlayerSpawnedfunction")
        if (Player := player[Agent]):
            spawn {InitPlayer(Player)}
            spawn {UpdatingHUD(Player)}


#CHECKS WHEN ONE PLAYER IS ALIVE AT THE BEGIN 
    #CheckOneAlive() : tuple(logic, ?player) =                                                                                   #For roundsystem
    #    var Count : int = 0                                                                                                     #For roundsystem
    #    loop:                                                                                                                   #For roundsystem
    #        var LastIteratedPlayer : ?player = false                                                                            #For roundsystem
    #        for (Player : GetPlayspace().GetPlayers(), FortCharacter := Player.GetFortCharacter[], FortCharacter.IsActive[]):   #For roundsystem
    #            set Count += 1                                                                                                  #For roundsystem
    #            set LastIteratedPlayer = option{Player}                                                                         #For roundsystem
    #        return if(Count <= 1) then (true, LastIteratedPlayer) else (false, LastIteratedPlayer)                              #For roundsystem

    InitPlayer(Player : player)<suspends>:void=

        #calculating total points for every player
        TotalPoints := (PointsForElimination * EliminationTracker.GetValue(Player)) - (PointsForEliminated * EliminatedTracker.GetValue(Player))

        #calculating progress for every rank
        var ProgressBronze1:float = ((4.8/(BronzeMaxPoints1 * 1.0)) * (TotalPoints))
        var ProgressBronze2:float = ((4.8/(BronzeMaxPoints2 * 1.0 - BronzeMaxPoints1 * 1.0)) * (TotalPoints - BronzeMaxPoints1))
        var ProgressBronze3:float = ((4.8/(BronzeMaxPoints3 * 1.0 - BronzeMaxPoints2 * 1.0)) * (TotalPoints - BronzeMaxPoints2))

        var ProgressSilver1:float = ((4.8/(SilverMaxPoints1 * 1.0 - BronzeMaxPoints3 * 1.0)) * (TotalPoints - BronzeMaxPoints3))
        var ProgressSilver2:float = ((4.8/(SilverMaxPoints2 * 1.0 - SilverMaxPoints1 * 1.0)) * (TotalPoints - SilverMaxPoints1))
        var ProgressSilver3:float = ((4.8/(SilverMaxPoints3 * 1.0 - SilverMaxPoints2 * 1.0)) * (TotalPoints - SilverMaxPoints2))

        var ProgressGold1:float = ((4.8/(GoldMaxPoints1 * 1.0 - SilverMaxPoints3 * 1.0)) * (TotalPoints - SilverMaxPoints3))
        var ProgressGold2:float = ((4.8/(GoldMaxPoints2 * 1.0 - GoldMaxPoints1 * 1.0)) * (TotalPoints - GoldMaxPoints1))
        var ProgressGold3:float = ((4.8/(GoldMaxPoints3 * 1.0 - GoldMaxPoints2 * 1.0)) * (TotalPoints - GoldMaxPoints2))

        var ProgressPlatinum1:float = ((4.8/(PlatinumMaxPoints1 * 1.0 - GoldMaxPoints3 * 1.0)) * (TotalPoints - GoldMaxPoints3))
        var ProgressPlatinum2:float = ((4.8/(PlatinumMaxPoints2 * 1.0 - PlatinumMaxPoints1 * 1.0)) * (TotalPoints - PlatinumMaxPoints1))
        var ProgressPlatinum3:float = ((4.8/(PlatinumMaxPoints3* 1.0 - PlatinumMaxPoints2 * 1.0)) * (TotalPoints - PlatinumMaxPoints2))

        var ProgressDiamond1:float = ((4.8/(DiamondMaxPoints1 * 1.0 - PlatinumMaxPoints3 * 1.0)) * (TotalPoints - PlatinumMaxPoints3))
        var ProgressDiamond2:float = ((4.8/(DiamondMaxPoints2 * 1.0 - DiamondMaxPoints1 * 1.0)) * (TotalPoints - DiamondMaxPoints1))
        var ProgressDiamond3:float = ((4.8/(DiamondMaxPoints3 * 1.0 - DiamondMaxPoints2 * 1.0)) * (TotalPoints - DiamondMaxPoints2))

        var ProgressElite:float = ((4.8/(EliteMaxPoints * 1.0 - DiamondMaxPoints3 * 1.0)) * (TotalPoints - DiamondMaxPoints3))
        var ProgressChampion:float = ((4.8/(ChampionMaxPoints * 1.0 - EliteMaxPoints * 1.0)) * (TotalPoints - EliteMaxPoints))
        var ProgressUnreal:float = ((4.8/(UnrealMaxPoints * 1.0 - ChampionMaxPoints *1.0)) * (TotalPoints - ChampionMaxPoints))
        
       # Print("playerspawned")
        if:
            Fort := Player.GetFortCharacter[]
        then: 
            if (Existing := CustomPlayers[Player]):
                #Print("Bestaande player")
        
            else:
                #checking availible cinematics
                var AvailableCinematic : ?progress_cinematic = false
                var IDX : int = 0
                loop:
                    if (IDX >= ProgressCinematics.Length) {break}
                    
                    if (PC := ProgressCinematics[IDX], PC.IsAvailable?):
                        set AvailableCinematic = option{PC}
                        if (set ProgressCinematics[IDX].IsAvailable = false) {break}
                        #Print("checking if availible")
                    set IDX += 1
                #adding a new player
                if (ProgressCinematic := AvailableCinematic?):
                    Fort.EliminatedEvent().Subscribe(UpdateEliminations)
                    
                    CustomPlayer := custom_player{Player := Player, ProgressCinematic := ProgressCinematic, BronzeHUD1 := BronzeHUD1, BronzeHUD2 := BronzeHUD2, BronzeHUD3 := BronzeHUD3,
                    SilverHUD1 := SilverHUD1, SilverHUD2 := SilverHUD2, SilverHUD3 := SilverHUD3, GoldHUD1 := GoldHUD1, GoldHUD2 := GoldHUD2, GoldHUD3 := GoldHUD3,
                    PlatinumHUD1 := PlatinumHUD1, PlatinumHUD2 := PlatinumHUD2, PlatinumHUD3 := PlatinumHUD3, DiamondHUD1 := DiamondHUD1, DiamondHUD2 := DiamondHUD2, DiamondHUD3 := DiamondHUD3,
                    EliteHUD := EliteHUD, ChampionHUD := ChampionHUD, UnrealHUD := UnrealHUD}
                    CustomPlayer.ProgressMaxAndPointsIns(BronzeMaxPoints1, BronzeMaxPoints2, BronzeMaxPoints3, SilverMaxPoints1, SilverMaxPoints2, SilverMaxPoints3, 
                    GoldMaxPoints1, GoldMaxPoints2, GoldMaxPoints3, PlatinumMaxPoints1, PlatinumMaxPoints2, PlatinumMaxPoints3, DiamondMaxPoints1, DiamondMaxPoints2, DiamondMaxPoints3,
                    EliteMaxPoints, ChampionMaxPoints, UnrealMaxPoints) 
                    CustomPlayer.InitCurrentPoints(TotalPoints)

                    if (set CustomPlayers[Player] = CustomPlayer){}
                       # Print("CustomPlayers[Changed]")

        
        #locatie veranderdddd!!!!!!!!!!!!!!            
        #start the UpdatingHUD function

        spawn{UpdatingHUD(Player)}


#CHECKING WHEN AN ELIMINATION HAPPENS & WHEN YOU ARE ELIMINATED ALSO WHEN YOU KILLED YOURSELF
    UpdateEliminations(Result : elimination_result) :void=
        if:
            Eliminator := Result.EliminatingCharacter?
            Agent := Eliminator.GetAgent[ ]
            Player := player[Agent]
            CustomPlayer := CustomPlayers[Player]
        then:
            CustomPlayer.OnElimination(PointsForElimination)
            spawn{UpdatingHUD(Player)}
        if:
            Eliminated := Result.EliminatedCharacter
            Agent := Eliminated.GetAgent[ ]
            Player := player[Agent]
            CustomPlayer := CustomPlayers[Player]
        then:
            CustomPlayer.OnEliminated(PointsForEliminated)
            if(Result.EliminatingCharacter? = Result.EliminatedCharacter):
                CustomPlayer.OnSelfEliminated(PointsForElimination)
            spawn{UpdatingHUD(Player)}
            
    
#LOOPING UPDATING HUD FOR EVERY PLAYER CINEMATIC NOT INCLUDED
    UpdatingHUD(Player: player)<suspends>:void=
        #var BeginPlayerIsOne : int = 0                                              #For roundsystem
        #var EndPlayerIsOne : int = 0                                                #For roundsystem


        Sleep(0.1)
        #calculating total points for every player
        TotalPoints := (PointsForElimination * EliminationTracker.GetValue(Player)) - (PointsForEliminated * EliminatedTracker.GetValue(Player))
        #calculating progress for every rank
        var ProgressBronze1:float = ((4.8/(BronzeMaxPoints1 * 1.0)) * (TotalPoints))
        var ProgressBronze2:float = ((4.8/(BronzeMaxPoints2 * 1.0 - BronzeMaxPoints1 * 1.0)) * (TotalPoints - BronzeMaxPoints1))
        var ProgressBronze3:float = ((4.8/(BronzeMaxPoints3 * 1.0 - BronzeMaxPoints2 * 1.0)) * (TotalPoints - BronzeMaxPoints2))
        
        var ProgressSilver1:float = ((4.8/(SilverMaxPoints1 * 1.0 - BronzeMaxPoints3 * 1.0)) * (TotalPoints - BronzeMaxPoints3))
        var ProgressSilver2:float = ((4.8/(SilverMaxPoints2 * 1.0 - SilverMaxPoints1 * 1.0)) * (TotalPoints - SilverMaxPoints1))
        var ProgressSilver3:float = ((4.8/(SilverMaxPoints3 * 1.0 - SilverMaxPoints2 * 1.0)) * (TotalPoints - SilverMaxPoints2))

        var ProgressGold1:float = ((4.8/(GoldMaxPoints1 * 1.0 - SilverMaxPoints3 * 1.0)) * (TotalPoints - SilverMaxPoints3))
        var ProgressGold2:float = ((4.8/(GoldMaxPoints2 * 1.0 - GoldMaxPoints1 * 1.0)) * (TotalPoints - GoldMaxPoints1))
        var ProgressGold3:float = ((4.8/(GoldMaxPoints3 * 1.0 - GoldMaxPoints2 * 1.0)) * (TotalPoints - GoldMaxPoints2))

        var ProgressPlatinum1:float = ((4.8/(PlatinumMaxPoints1 * 1.0 - GoldMaxPoints3 * 1.0)) * (TotalPoints - GoldMaxPoints3))
        var ProgressPlatinum2:float = ((4.8/(PlatinumMaxPoints2 * 1.0 - PlatinumMaxPoints1 * 1.0)) * (TotalPoints - PlatinumMaxPoints1))
        var ProgressPlatinum3:float = ((4.8/(PlatinumMaxPoints3* 1.0 - PlatinumMaxPoints2 * 1.0)) * (TotalPoints - PlatinumMaxPoints2))

        var ProgressDiamond1:float = ((4.8/(DiamondMaxPoints1 * 1.0 - PlatinumMaxPoints3 * 1.0)) * (TotalPoints - PlatinumMaxPoints3))
        var ProgressDiamond2:float = ((4.8/(DiamondMaxPoints2 * 1.0 - DiamondMaxPoints1 * 1.0)) * (TotalPoints - DiamondMaxPoints1))
        var ProgressDiamond3:float = ((4.8/(DiamondMaxPoints3 * 1.0 - DiamondMaxPoints2 * 1.0)) * (TotalPoints - DiamondMaxPoints2))

        var ProgressElite:float = ((4.8/(EliteMaxPoints * 1.0 - DiamondMaxPoints3 * 1.0)) * (TotalPoints - DiamondMaxPoints3))
        var ProgressChampion:float = ((4.8/(ChampionMaxPoints * 1.0 - EliteMaxPoints * 1.0)) * (TotalPoints - EliteMaxPoints))
        var ProgressUnreal:float = ((4.8/(UnrealMaxPoints * 1.0 - ChampionMaxPoints *1.0)) * (TotalPoints - ChampionMaxPoints))
        #sleep(0.2)
#BRONZE      
        if (TotalPoints < 0): # because of this you cant drop below 0 points
            EliminatedTracker.Decrement(Player)
            #bronze1        
        if (TotalPoints >= 0 and TotalPoints < BronzeMaxPoints1): 
            BronzeT1.Trigger(Player)
            #bronze1 
        if (TotalPoints >= BronzeMaxPoints1 and TotalPoints < BronzeMaxPoints2):
            BronzeT2.Trigger(Player)
            #bronze2
        if (TotalPoints >= BronzeMaxPoints2 and TotalPoints < BronzeMaxPoints3):
            BronzeT3.Trigger(Player)
            #bronze3
#SILVER
        if (TotalPoints >= BronzeMaxPoints3 and TotalPoints < SilverMaxPoints1):
            SilverT1.Trigger(Player)
            #silver1
        if (TotalPoints >= SilverMaxPoints1 and TotalPoints < SilverMaxPoints2):
            SilverT2.Trigger(Player)
            #silver2
        if (TotalPoints >= SilverMaxPoints2 and TotalPoints < SilverMaxPoints3):
            SilverT3.Trigger(Player)
            #silver3
#GOLD
        if (TotalPoints >= SilverMaxPoints3 and TotalPoints < GoldMaxPoints1):
            GoldT1.Trigger(Player)
            #gold1
        if (TotalPoints >= GoldMaxPoints1 and TotalPoints < GoldMaxPoints2):
            GoldT2.Trigger(Player)
            #gold2
        if (TotalPoints >= GoldMaxPoints2 and TotalPoints < GoldMaxPoints3):
            GoldT3.Trigger(Player)
            #gold3
#PLATINUM
        if (TotalPoints >= GoldMaxPoints3 and TotalPoints < PlatinumMaxPoints1):
            PlatinumT1.Trigger(Player)
            #platinum1              
        if (TotalPoints >= PlatinumMaxPoints1 and TotalPoints < PlatinumMaxPoints2):
            PlatinumT2.Trigger(Player)
            #platinum2
        if (TotalPoints >= PlatinumMaxPoints2 and TotalPoints < PlatinumMaxPoints3):
            PlatinumT3.Trigger(Player)
            #platinum3
#DIAMOND
        if (TotalPoints >= PlatinumMaxPoints3 and TotalPoints < DiamondMaxPoints1):
            DiamondT1.Trigger(Player)
            #diamond1             
        if (TotalPoints >= DiamondMaxPoints1 and TotalPoints < DiamondMaxPoints2):
            DiamondT2.Trigger(Player)
            #diamond2
        if (TotalPoints >= DiamondMaxPoints2 and TotalPoints < DiamondMaxPoints3):
            DiamondT3.Trigger(Player)
            #diamond3
#OTHERS
        if (TotalPoints >= DiamondMaxPoints3 and TotalPoints < EliteMaxPoints):
            EliteT.Trigger(Player)
            #elite
        if (TotalPoints >= EliteMaxPoints and TotalPoints < ChampionMaxPoints):
            ChampionT.Trigger(Player)
            #champion
        if (TotalPoints >= ChampionMaxPoints and TotalPoints < UnrealMaxPoints):
            UnrealT.Trigger(Player)
            #unreal
        Sleep(0.2)
        
#CHECK IF THERE IS ONE PLAYER IN THE GAME CHECKS BUT IF THERE ARE 2 PLAYERS IN THE FIRST 0.5s IT WILL NOT BE ACTIVATED  
        #    Result := CheckOneAlive()                                                   #For roundsystem
        #    IsCountUnderOne := Result(0)                                                #For roundsystem
        #    FoundPlayer := Result(1)                                                    #For roundsystem

        #    if(IsCountUnderOne?):                                                       #For roundsystem
        #        if(_FoundPlayer := FoundPlayer? and BeginPlayerIsOne = 0):              #For roundsystem
        #            Sleep(0.5)                                                          #For roundsystem
        #            TriggerOnePlayer.Trigger(Player)                                    #For roundsystem
        #        else:                                                                   #For roundsystem
        #            TriggerOnePlayer.Trigger(Player)                                    #For roundsystem
        #    else:                                                                       #For roundsystem
        #        set EndPlayerIsOne += 1                                                 #For roundsystem
        #        set BeginPlayerIsOne += 1                                               #For roundsystem

        #    if(IsCountUnderOne? and EndPlayerIsOne >= 1):                               #For roundsystem
        #        if(_FoundPlayer := FoundPlayer?):                                       #For roundsystem
        #            Sleep(0.5)                                                          #For roundsystem
        #            EndGameDevice.Activate(Player)                                      #For roundsystem
        #        else:                                                                   #For roundsystem
        #            EndGameDevice.Activate(Player)                                      #For roundsystem


#CHECKS WHEN A PLAYER LEFT
    OnPlayerLeftServer(PlayerLeaving : player) :void=
        
        if (CustomPlayer := CustomPlayers[PlayerLeaving]):
            var NewCustomPlayerMap : [player]custom_player = map{}
            for (IDX := 0..ProgressCinematics.Length - 1):
                
                if(Device := ProgressCinematics[IDX], Device = CustomPlayer.ProgressCinematic):
                    if(set ProgressCinematics[IDX].IsAvailable = true){}

            for (Key -> Value : CustomPlayers, Key <> PlayerLeaving):
                set NewCustomPlayerMap = ConcatenateMaps(NewCustomPlayerMap, map{Key => Value})
            set CustomPlayers = NewCustomPlayerMap

        