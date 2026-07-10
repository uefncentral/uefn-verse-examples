# Player Stats Scoreboard
# Creates an interactive scoreboard system that displays player statistics including eliminations, deaths, and kill/death ratio when a button is pressed. The stats are tracked using tracker devices and 
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/statsboard?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/UI}
using { /Verse.org/Random}
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }

SM<localizes>(Message : string): message ="{Message}"
AM<localizes>(Agent:agent): message ="{Agent}"


Stats_board := class(creative_device):

    # SB Devices
    @editable TrackerElim : tracker_device = tracker_device{}
    @editable TrackerDeath : tracker_device = tracker_device{}
    @editable SB_Boards : []billboard_device = array{}
    @editable SB_Ref : player_reference_device = player_reference_device{}
    
    # Button
    @editable SB_Button : button_device = button_device{}

    # Creative Props
    @editable SB_Ranks : []creative_prop = array{}

    # Spawner Devices
    @editable PlayerSpawneres : []player_spawner_device = array{}

    #OLESZYK START
    OnBegin<override>()<suspends>:void=
        SB_Button.InteractedWithEvent.Subscribe(ButtonClicked)

    #ON BUTTON CLICK
    ButtonClicked(Agent: agent):void=
        ShowScoreBoard(Agent)
        spawn{RemoveScoreBoard(Agent)}

    #SHOWS SCORE BOARD
    ShowScoreBoard(Agent:agent):void=
        if:
            ElimTracker := TrackerElim
            DeathTracker := TrackerDeath
            NameBill := SB_Boards[0]
            ElimBill := SB_Boards[1]
            DeathBill := SB_Boards[2]
            KDBill := SB_Boards[3]
            RankBill := SB_Boards[4]
        then:
            # Show prop background and register agent to player reference device
            SB_Ref.Register(Agent)

            # Set Agent Name
            NameBill.SetText(AM(Agent))
            NameBill.ShowText()

            # Set elims text
            ElimBill.SetText(SM("Eliminations: {ElimTracker.GetValue(Agent)}"))
            ElimBill.ShowText()

            # Set deaths text
            DeathBill.SetText(SM("Deaths: {DeathTracker.GetValue(Agent)}"))
            DeathBill.ShowText()

            # Calculate Kills per Death ratio and set K/D text
            KDRatio := (ElimTracker.GetValue(Agent) * 1.0) / (DeathTracker.GetValue(Agent) * 1.0)
            KDBill.SetText(SM("K/D: {RoundFloat(KDRatio, 2)}"))
            KDBill.ShowText()
            
            # Set Rank text
            RankBill.SetText(SM("Rank"))
            RankBill.ShowText()
            
            #Show player rank
            #You can change the numbers if you have different rank system    
                if(ElimTracker.GetValue(Agent) <= 10):
                    if(BRank := SB_Ranks[0]):
                        BRank.Show()

                else if (ElimTracker.GetValue(Agent) > 10 <= 50 ):
                    if(SRank:= SB_Ranks[1]):
                        SRank.Show()

                else if (ElimTracker.GetValue(Agent) > 50 <= 150 ):
                    if(GRank:= SB_Ranks[2]):
                        GRank.Show()
    
                else  if (ElimTracker.GetValue(Agent) > 150 <= 250 ):
                    if(PRank:= SB_Ranks[3]):
                        PRank.Show()

                else  if (ElimTracker.GetValue(Agent) > 250 <= 450 ):
                    if(DRank:= SB_Ranks[4]):
                        DRank.Show()

                else if (ElimTracker.GetValue(Agent) > 450 <= 600 ):
                    if(ERank:= SB_Ranks[5]):
                        ERank.Show()

                else if (ElimTracker.GetValue(Agent) > 600 <= 800 ):
                    if(CRank:= SB_Ranks[6]):
                        CRank.Show()

                else if (ElimTracker.GetValue(Agent) >= 800 ):
                    if(URank:= SB_Ranks[7]):
                        URank.Show()

    #OLESZYK END
    RemoveScoreBoard(Agent:agent)<suspends>:void=
        # Hide everything
        Sleep(15.0)
        
        for (Boards : SB_Boards):
            Boards.HideText()
        for (Rank : SB_Ranks):
            Rank.Hide()
        SB_Ref.Clear()

    #ROUND FLOAT
    RoundFloat<private>(Input : float, NumDigitsAfterDecimal : int) : string =
            if:
                Multiplier := Pow(10.0, NumDigitsAfterDecimal * 1.0)
                RoundedValue := RoundedTickRate := float[Round[Input*Multiplier]*1.0] / Multiplier
                BeforeDecimal := Floor[RoundedValue]
                AfterDecimal := Abs(Round[(RoundedValue - BeforeDecimal*1.0)*Multiplier])
                var AfterDecimalString : string = ToString(AfterDecimal)

                 #Pad with leading zeroes
                 for (It := 0..(NumDigitsAfterDecimal-AfterDecimalString.Length-1)):
                    set AfterDecimalString = array{'0'} + AfterDecimalString
        then:
                "{BeforeDecimal}.{AfterDecimalString}"
        else:
                ToString(Input)