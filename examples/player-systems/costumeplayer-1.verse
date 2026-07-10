# Player Ranking System
# This code creates a competitive ranking system with multiple tiers (Bronze, Silver, Gold, Platinum, Diamond, Elite, Champion, Unreal) that tracks player points and displays rank progression through HU
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/costumeplayer-1?ref=github

using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Devices } 

custom_player := class<unique>():
    StringToMessage<localizes>(String : string)<computes> : message = "{String}"

    Player : player
    ProgressCinematic : progress_cinematic
    
    BronzeHUD1 : hud_message_device
    BronzeHUD2 : hud_message_device
    BronzeHUD3 : hud_message_device
    
    SilverHUD1 : hud_message_device
    SilverHUD2 : hud_message_device
    SilverHUD3 : hud_message_device

    GoldHUD1 : hud_message_device
    GoldHUD2 : hud_message_device
    GoldHUD3 : hud_message_device

    PlatinumHUD1 : hud_message_device
    PlatinumHUD2 : hud_message_device
    PlatinumHUD3 : hud_message_device

    DiamondHUD1 : hud_message_device
    DiamondHUD2 : hud_message_device
    DiamondHUD3 : hud_message_device

    EliteHUD : hud_message_device
    ChampionHUD : hud_message_device
    UnrealHUD : hud_message_device

    # Ranking variables

    var MaxRankReached<private> : logic = false
    var CurrentPoints<private> : int = 0
    var RanksGoals<private> : []int = array{0,99999999999}

    var BronzeMaxPoints1P : int = 0
    var BronzeMaxPoints2P : int = 0
    var BronzeMaxPoints3P : int = 0

    var SilverMaxPoints1P : int = 0
    var SilverMaxPoints2P : int = 0
    var SilverMaxPoints3P : int = 0

    var GoldMaxPoints1P : int = 0
    var GoldMaxPoints2P : int = 0
    var GoldMaxPoints3P : int = 0

    var PlatinumMaxPoints1P : int = 0
    var PlatinumMaxPoints2P : int = 0
    var PlatinumMaxPoints3P : int = 0

    var DiamondMaxPoints1P : int = 0
    var DiamondMaxPoints2P : int = 0
    var DiamondMaxPoints3P : int = 0

    var EliteMaxPointsP : int = 0
    var ChampionMaxPointsP : int = 0
    var UnrealMaxPointsP : int = 0

    var PointsForEliminatedP : int = 0

    ProgressBarTextForUI<localizes>(ProgressBarText : string)<computes> : message = "{ProgressBarText}"

    InitCurrentPoints(TotalPoints : int): void=
        Print("InitCurrentPoints")
        set CurrentPoints = TotalPoints

        ProgressCinematic.ProgressCinematic.Play(Player)
        ProgressCinematic.ProgressCinematic.Pause(Player)

        spawn {UpdateRanking()}



    ProgressMaxAndPointsIns(BronzeMaxPoints1: int, BronzeMaxPoints2: int, BronzeMaxPoints3: int, SilverMaxPoints1: int, SilverMaxPoints2: int, SilverMaxPoints3: int, 
    GoldMaxPoints1: int, GoldMaxPoints2: int, GoldMaxPoints3: int, PlatinumMaxPoints1: int, PlatinumMaxPoints2: int, PlatinumMaxPoints3: int, DiamondMaxPoints1: int, DiamondMaxPoints2: int, DiamondMaxPoints3: int,
    EliteMaxPoints: int, ChampionMaxPoints: int, UnrealMaxPoints: int)<suspends>:void=

        Print("ProgressMaxAndPointsIns")
        set BronzeMaxPoints1P = BronzeMaxPoints1
        set BronzeMaxPoints2P = BronzeMaxPoints2
        set BronzeMaxPoints3P = BronzeMaxPoints3

        set SilverMaxPoints1P = SilverMaxPoints1
        set SilverMaxPoints2P = SilverMaxPoints2
        set SilverMaxPoints3P = SilverMaxPoints3
        
        set GoldMaxPoints1P = GoldMaxPoints1
        set GoldMaxPoints2P = GoldMaxPoints2
        set GoldMaxPoints3P = GoldMaxPoints3

        set PlatinumMaxPoints1P = PlatinumMaxPoints1
        set PlatinumMaxPoints2P = PlatinumMaxPoints2
        set PlatinumMaxPoints3P = PlatinumMaxPoints3

        set DiamondMaxPoints1P = DiamondMaxPoints1
        set DiamondMaxPoints2P = DiamondMaxPoints2
        set DiamondMaxPoints3P = DiamondMaxPoints3

        set EliteMaxPointsP = EliteMaxPoints
        set ChampionMaxPointsP = ChampionMaxPoints
        set UnrealMaxPointsP = UnrealMaxPoints


    OnElimination(PointsForElimination: int) : void=
        set CurrentPoints += PointsForElimination
        spawn {UpdateRanking()}

    OnEliminated(PointsForEliminated: int) : void=
        set PointsForEliminatedP = PointsForEliminated
        set CurrentPoints -= PointsForEliminated
        spawn {UpdateRanking()}


    OnSelfEliminated(PointsForElimination: int) : void=
        set CurrentPoints -= PointsForElimination
        spawn {UpdateRanking()}

    UpdateRanking()<suspends>:void=
        spawn {UpdateRankingUI()}
        if (MaxRankReached?){}

        else:
            var IDX : int = 0
            loop:
                if (IDX >= RanksGoals.Length) :
                    set MaxRankReached = true
                    Sleep(0.1)
                    spawn {UpdateRankingUI()}
                    break
                else:
                    if (CurrentGoal := RanksGoals[IDX]):
                        if(CurrentPoints = 0):
                            Sleep(0.1)
                            spawn {UpdateRankingUI()}
                            break
                        else if (CurrentPoints < CurrentGoal):
                            Sleep(0.1)
                            spawn {UpdateRankingUI()}
                            break
                        else:
                            set IDX += 1
                            Sleep(0.1)
                            spawn {UpdateRankingUI()}

    UpdateRankingUI()<suspends>:void=
        var ProgressBronze1P:float = ((4.8/(BronzeMaxPoints1P * 1.0)) * (CurrentPoints))
        var ProgressBronze2P:float = ((4.8/(BronzeMaxPoints2P * 1.0 - BronzeMaxPoints1P * 1.0)) * (CurrentPoints - BronzeMaxPoints1P))
        var ProgressBronze3P:float = ((4.8/(BronzeMaxPoints3P * 1.0 - BronzeMaxPoints2P * 1.0)) * (CurrentPoints - BronzeMaxPoints2P))

        var ProgressSilver1P:float = ((4.8/(SilverMaxPoints1P * 1.0 - BronzeMaxPoints3P * 1.0)) * (CurrentPoints - BronzeMaxPoints3P))
        var ProgressSilver2P:float = ((4.8/(SilverMaxPoints2P * 1.0 - SilverMaxPoints1P * 1.0)) * (CurrentPoints - SilverMaxPoints1P))
        var ProgressSilver3P:float = ((4.8/(SilverMaxPoints3P * 1.0 - SilverMaxPoints2P * 1.0)) * (CurrentPoints - SilverMaxPoints2P))

        var ProgressGold1P:float = ((4.8/(GoldMaxPoints1P * 1.0 - SilverMaxPoints3P * 1.0)) * (CurrentPoints - SilverMaxPoints3P))
        var ProgressGold2P:float = ((4.8/(GoldMaxPoints2P * 1.0 - GoldMaxPoints1P * 1.0)) * (CurrentPoints - GoldMaxPoints1P))
        var ProgressGold3P:float = ((4.8/(GoldMaxPoints3P * 1.0 - GoldMaxPoints2P * 1.0)) * (CurrentPoints - GoldMaxPoints2P))

        var ProgressPlatinum1P:float = ((4.8/(PlatinumMaxPoints1P * 1.0 - GoldMaxPoints3P * 1.0)) * (CurrentPoints - GoldMaxPoints3P))
        var ProgressPlatinum2P:float = ((4.8/(PlatinumMaxPoints2P * 1.0 - PlatinumMaxPoints1P * 1.0)) * (CurrentPoints - PlatinumMaxPoints1P))
        var ProgressPlatinum3P:float = ((4.8/(PlatinumMaxPoints3P* 1.0 - PlatinumMaxPoints2P * 1.0)) * (CurrentPoints - PlatinumMaxPoints2P))

        var ProgressDiamond1P:float = ((4.8/(DiamondMaxPoints1P * 1.0 - PlatinumMaxPoints3P * 1.0)) * (CurrentPoints - PlatinumMaxPoints3P))
        var ProgressDiamond2P:float = ((4.8/(DiamondMaxPoints2P * 1.0 - DiamondMaxPoints1P * 1.0)) * (CurrentPoints - DiamondMaxPoints1P))
        var ProgressDiamond3P:float = ((4.8/(DiamondMaxPoints3P * 1.0 - DiamondMaxPoints2P * 1.0)) * (CurrentPoints - DiamondMaxPoints2P))

        var ProgressEliteP:float = ((4.8/(EliteMaxPointsP * 1.0 - DiamondMaxPoints3P * 1.0)) * (CurrentPoints - DiamondMaxPoints3P))
        var ProgressChampionP:float = ((4.8/(ChampionMaxPointsP * 1.0 - EliteMaxPointsP * 1.0)) * (CurrentPoints - EliteMaxPointsP))
        var ProgressUnrealP:float = ((4.8/(UnrealMaxPointsP * 1.0 - ChampionMaxPointsP *1.0)) * (CurrentPoints - ChampionMaxPointsP))

#VALUE SET TO PROCENT
        var ProgressBronze1R:float = 0.0
        var ProgressBronze2R:float = 0.0
        var ProgressBronze3R :float = 0.0
    
        var ProgressSilver1R:float = 0.0
        var ProgressSilver2R:float = 0.0
        var ProgressSilver3R:float = 0.0
    
        var ProgressGold1R:float = 0.0
        var ProgressGold2R:float = 0.0
        var ProgressGold3R:float = 0.0
        
        var ProgressPlatinum1R:float = 0.0
        var ProgressPlatinum2R:float = 0.0
        var ProgressPlatinum3R:float = 0.0
    
        var ProgressDiamond1R:float = 0.0
        var ProgressDiamond2R:float = 0.0
        var ProgressDiamond3R:float = 0.0
    
        var ProgressEliteR:float = 0.0
        var ProgressChampionR:float = 0.0
        var ProgressUnrealR:float = 0.0

#VALUE PROCETN ROUNDED
        var ProgressBronze1Round:int = 0
        var ProgressBronze2Round:int = 0
        var ProgressBronze3Round :int = 0
    
        var ProgressSilver1Round:int = 0
        var ProgressSilver2Round:int = 0
        var ProgressSilver3Round:int = 0
    
        var ProgressGold1Round:int = 0
        var ProgressGold2Round:int = 0
        var ProgressGold3Round:int = 0
        
        var ProgressPlatinum1Round:int = 0
        var ProgressPlatinum2Round:int = 0
        var ProgressPlatinum3Round:int = 0
    
        var ProgressDiamond1Round:int = 0
        var ProgressDiamond2Round:int = 0
        var ProgressDiamond3Round:int = 0
    
        var ProgressEliteRound:int = 0
        var ProgressChampionRound:int = 0
        var ProgressUnrealRound:int = 0


        set ProgressBronze1R = ((ProgressBronze1P/4.8) * 100)
        set ProgressBronze2R = ((ProgressBronze2P/4.8) * 100)
        set ProgressBronze3R = ((ProgressBronze3P/4.8) * 100)

        set ProgressSilver1R = ((ProgressSilver1P/4.8) * 100)
        set ProgressSilver2R = ((ProgressSilver2P/4.8) * 100)
        set ProgressSilver3R = ((ProgressSilver3P/4.8) * 100)

        set ProgressGold1R = ((ProgressGold1P/4.8) * 100)
        set ProgressGold2R = ((ProgressGold2P/4.8) * 100)
        set ProgressGold3R = ((ProgressGold3P/4.8) * 100)

        set ProgressPlatinum1R = ((ProgressPlatinum1P/4.8) * 100)
        set ProgressPlatinum2R = ((ProgressPlatinum2P/4.8) * 100)
        set ProgressPlatinum3R = ((ProgressPlatinum3P/4.8) * 100)

        set ProgressDiamond1R = ((ProgressDiamond1P/4.8) * 100)
        set ProgressDiamond2R = ((ProgressDiamond2P/4.8) * 100)
        set ProgressDiamond3R = ((ProgressDiamond3P/4.8) * 100)

        set ProgressEliteR = ((ProgressEliteP/4.8) * 100)
        set ProgressChampionR = ((ProgressChampionP/4.8) * 100)
        set ProgressUnrealR = ((ProgressUnrealP/4.8) * 100)
        
#BRONZE ROUND NUMBERS
        if (Value1 := Round[ProgressBronze1R]):
            set ProgressBronze1Round = Value1
        if (Value2 := Round[ProgressBronze2R]):
            set ProgressBronze2Round = Value2
        if (Value3 := Round[ProgressBronze3R]):
            set ProgressBronze3Round = Value3
#SILVER ROUND NUMBERS
        if (Value4 := Round[ProgressSilver1R]):
            set ProgressSilver1Round = Value4
        if (Value5 := Round[ProgressSilver2R]):
            set ProgressSilver2Round = Value5
        if (Value6 := Round[ProgressSilver3R]):
            set ProgressSilver3Round = Value6
#GOLD ROUND NUMBERS
        if (Value7 := Round[ProgressGold1R]):
            set ProgressGold1Round = Value7
        if (Value8 := Round[ProgressGold2R]):
            set ProgressGold2Round = Value8
        if (Value9 := Round[ProgressGold3R]):
            set ProgressGold3Round = Value9
#PLATINUM ROUND NUMBERS
        if (Value10 := Round[ProgressPlatinum1R]):
            set ProgressPlatinum1Round = Value10
        if (Value11 := Round[ProgressPlatinum2R]):
            set ProgressPlatinum2Round = Value11
        if (Value12 := Round[ProgressPlatinum3R]):
            set ProgressPlatinum3Round = Value12
#DIAMOND ROUND NUMBERS
        if (Value13 := Round[ProgressDiamond1R]):
            set ProgressDiamond1Round = Value13
        if (Value14 := Round[ProgressDiamond2R]):
            set ProgressDiamond2Round = Value14
        if (Value15 := Round[ProgressDiamond3R]):
            set ProgressDiamond3Round = Value15
#OTHERS ROUND NUMBERS
        if (Value10 := Round[ProgressEliteR]):
            set ProgressEliteRound = Value10
        if (Value11 := Round[ProgressChampionR]):
            set ProgressChampionRound = Value11
        if (Value12 := Round[ProgressUnrealR]):
            set ProgressUnrealRound = Value12

#DISPLAY CINEMATIC & YOUR PROCENT
        if (CurrentPoints < 0): 
            set CurrentPoints += PointsForEliminatedP

        if (CurrentPoints >= 0 and CurrentPoints < BronzeMaxPoints1P): 
            ProgressCinematic.ProgressCinematic.SetPlaybackTime(ProgressBronze1P)
            Print("{ProgressBronze1P}")
            BronzeHUD1.SetText(StringToMessage("{ProgressBronze1Round}%"))
            BronzeHUD1.Show(Player)

        if (CurrentPoints >= BronzeMaxPoints1P and CurrentPoints < BronzeMaxPoints2P): 
            ProgressCinematic.ProgressCinematic.SetPlaybackTime(ProgressBronze2P)
            BronzeHUD2.SetText(StringToMessage("{ProgressBronze2Round}%"))
            BronzeHUD2.Show(Player)

        if (CurrentPoints >= BronzeMaxPoints2P and CurrentPoints < BronzeMaxPoints3P): 
            ProgressCinematic.ProgressCinematic.SetPlaybackTime(ProgressBronze3P)
            BronzeHUD3.SetText(StringToMessage("{ProgressBronze3Round}%"))
            BronzeHUD3.Show(Player)

            

        if (CurrentPoints >= BronzeMaxPoints3P and CurrentPoints < SilverMaxPoints1P):
            ProgressCinematic.ProgressCinematic.SetPlaybackTime(ProgressSilver1P)
            SilverHUD1.SetText(StringToMessage("{ProgressSilver1Round}%"))
            SilverHUD1.Show(Player)

        if (CurrentPoints >= SilverMaxPoints1P and CurrentPoints < SilverMaxPoints2P):
            ProgressCinematic.ProgressCinematic.SetPlaybackTime(ProgressSilver2P)
            SilverHUD2.SetText(StringToMessage("{ProgressSilver2Round}%"))
            SilverHUD2.Show(Player)

        if (CurrentPoints >= SilverMaxPoints2P and CurrentPoints < SilverMaxPoints3P):
            ProgressCinematic.ProgressCinematic.SetPlaybackTime(ProgressSilver3P)
            SilverHUD3.SetText(StringToMessage("{ProgressSilver3Round}%"))
            SilverHUD3.Show(Player)



        if (CurrentPoints >= SilverMaxPoints3P and CurrentPoints < GoldMaxPoints1P):
            ProgressCinematic.ProgressCinematic.SetPlaybackTime(ProgressGold1P)
            GoldHUD1.SetText(StringToMessage("{ProgressGold1Round}%"))
            GoldHUD1.Show(Player)

        if (CurrentPoints >= GoldMaxPoints1P and CurrentPoints < GoldMaxPoints2P):
            ProgressCinematic.ProgressCinematic.SetPlaybackTime(ProgressGold2P)
            GoldHUD2.SetText(StringToMessage("{ProgressGold2Round}%"))
            GoldHUD2.Show(Player)

        if (CurrentPoints >= GoldMaxPoints2P and CurrentPoints < GoldMaxPoints3P):
            ProgressCinematic.ProgressCinematic.SetPlaybackTime(ProgressGold3P)
            GoldHUD3.SetText(StringToMessage("{ProgressGold3Round}%"))
            GoldHUD3.Show(Player)



        if (CurrentPoints >= GoldMaxPoints3P and CurrentPoints < PlatinumMaxPoints1P):
            ProgressCinematic.ProgressCinematic.SetPlaybackTime(ProgressPlatinum1P)
            PlatinumHUD1.SetText(StringToMessage("{ProgressPlatinum1Round}%"))
            PlatinumHUD1.Show(Player)

        if (CurrentPoints >= PlatinumMaxPoints1P and CurrentPoints < PlatinumMaxPoints2P):
            ProgressCinematic.ProgressCinematic.SetPlaybackTime(ProgressPlatinum2P)
            PlatinumHUD2.SetText(StringToMessage("{ProgressPlatinum2Round}%"))
            PlatinumHUD2.Show(Player)

        if (CurrentPoints >= PlatinumMaxPoints2P and CurrentPoints < PlatinumMaxPoints3P):
            ProgressCinematic.ProgressCinematic.SetPlaybackTime(ProgressPlatinum3P)
            PlatinumHUD3.SetText(StringToMessage("{ProgressPlatinum3Round}%"))
            PlatinumHUD3.Show(Player)



        if (CurrentPoints >= PlatinumMaxPoints3P and CurrentPoints < DiamondMaxPoints1P):
            ProgressCinematic.ProgressCinematic.SetPlaybackTime(ProgressDiamond1P)
            DiamondHUD1.SetText(StringToMessage("{ProgressDiamond1Round}%"))
            DiamondHUD1.Show(Player)

        if (CurrentPoints >= DiamondMaxPoints1P and CurrentPoints < DiamondMaxPoints2P):
            DiamondHUD2.SetText(StringToMessage("{ProgressDiamond2Round}%"))
            ProgressCinematic.ProgressCinematic.SetPlaybackTime(ProgressDiamond2P)
            DiamondHUD2.Show(Player)

        if (CurrentPoints >= DiamondMaxPoints2P and CurrentPoints < DiamondMaxPoints3P):
            ProgressCinematic.ProgressCinematic.SetPlaybackTime(ProgressDiamond3P)
            DiamondHUD3.SetText(StringToMessage("{ProgressDiamond3Round}%"))
            DiamondHUD3.Show(Player)



        if (CurrentPoints >= DiamondMaxPoints3P and CurrentPoints < EliteMaxPointsP):
            ProgressCinematic.ProgressCinematic.SetPlaybackTime(ProgressEliteP)
            EliteHUD.SetText(StringToMessage("{ProgressEliteRound}%"))
            EliteHUD.Show(Player)

        if (CurrentPoints >= EliteMaxPointsP and CurrentPoints < ChampionMaxPointsP):
            ProgressCinematic.ProgressCinematic.SetPlaybackTime(ProgressChampionP)
            ChampionHUD.SetText(StringToMessage("{ProgressChampionRound}%"))
            ChampionHUD.Show(Player)

        if (CurrentPoints >= ChampionMaxPointsP and CurrentPoints < UnrealMaxPointsP):
            ProgressCinematic.ProgressCinematic.SetPlaybackTime(ProgressUnrealP)
            UnrealHUD.SetText(StringToMessage("{ProgressUnrealRound}%"))
            UnrealHUD.Show(Player)

        #ProgressCinematic.ProgressCinematic.SetPlaybackTime(1.0 * CurrentPoints - 1.0)
        




            