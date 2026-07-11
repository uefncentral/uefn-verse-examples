# Player Score Tracking System
# This code creates a comprehensive scoring system that tracks player actions (jumps, deaths, finishes) and awards points accordingly. When the game completes, it ranks all players by score, awards acco
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/progress-extensions-1?ref=github

using { CollectionExtensions }
using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }

ProgressExtensions<public> := module:
    CompareScores(First:tuple(int, player), Second:tuple(int, player))<computes>:int =
        if (First(0) > Second(0)):
            1
        else if (First(0) = Second(0)):
            0
        else:
            -1

    progress_reporter<public> := class:
        ScoreAccolades<public>:[]accolades_device
        ScoreTracker<public>:score_manager_device
        EndGameDevice<public>:end_game_device

        RegisterJump<public>(Player:player):void =
            ScoreTracker.SetScoreAward(1)
            ScoreTracker.Activate(Player)

        RegisterDeath<public>(Player:player):void =
            ScoreTracker.SetScoreAward(-1)
            ScoreTracker.Activate(Player)

        RegisterFinish<public>(Player:player):void =
            ScoreTracker.SetScoreAward(10)
            ScoreTracker.Activate(Player)
            
        Complete<public>(Players:[]player)<suspends>:void =
            Scores := for:
                Index -> Player : Players
                Accolade := ScoreAccolades[Index]
                Score := ScoreTracker.GetCurrentScore(Player)
            do:
                Accolade.Award(Player)
                (Score, Player)
            SortedScores := Sort(Scores, false, CompareScores)
            for (Index -> Score : SortedScores, Accolade := ScoreAccolades[Index]):
                Accolade.Award(Score(1))
            Sleep(5.0)
            if (First := SortedScores[0]):
                EndGameDevice.Activate(First(1))
