# Team Elimination Score Tracker
# Tracks and displays team scores based on player eliminations in real-time. When a player is eliminated, their team's score increases by 1 and the current scores are displayed on the HUD with Team 1 sc
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/score-tracker-device?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }


score_tracker_device := class(creative_device):

    @editable ScoreHUD : hud_message_device = hud_message_device{}
    @editable ElimManager : elimination_manager_device = elimination_manager_device{}

    var Team1Score : int = 0
    var Team2Score : int = 0

    ScoreUI<localizes>(Score : string)<computes> : message = "{Score}"
    
    OnBegin<override>()<suspends>:void=
        ElimManager.EliminationEvent.Subscribe(OnElimination)


    OnElimination(MaybeAgent : ?agent):void=
        if:
            Agent := MaybeAgent?
            # Player := player[Agent]            
        then:
            UpdateScore(Agent)

    UpdateScore(Agent : agent):void=
        TeamCollection := GetPlayspace().GetTeamCollection()
        if:
            AgentTeam := TeamCollection.GetTeam[Agent]        
        then:
            Teams := TeamCollection.GetTeams()
            for (TeamNumber->Team : Teams):
                if (AgentTeam = Team):
                    if (TeamNumber = 0):
                        set Team1Score += 1
                    else:
                        set Team2Score += 1
        else:
            set Team2Score += 1
        ScoreMessage : string = "{Team1Score} \n{Team2Score}"
        ScoreHUD.SetText(ScoreUI(ScoreMessage))
        ScoreHUD.Show()