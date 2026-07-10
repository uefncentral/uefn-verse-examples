# Statsbord
# Verse code for Statsbord - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/statsbord?ref=github


using { /Fortnite.com/Devices }

using { /Verse.org/Random }
using { /Verse.org/Simulation }

using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }


SM<localizes>(Message: string): message = "{Message}"
AM<localizes>(Agent : agent): message = "{Agent}"


Stats_Board_Manager := class(creative_device):

    @editable SB_Trackers : []tracker_device = array{}
    @editable SB_Boards : []billboard_device = array{}
    @editable SB_Ref : player_reference_device = player_reference_device{}
    
    @editable SB_Button : button_device = button_device{}

    @editable SB_Ranks : []creative_prop = array{}
    @editable SB_BG : creative_prop = creative_prop{}

    @editable PlayerSpawners : []player_spawner_device = array{}

    OnBegin<override>()<suspends>:void=
        SB_Button.InteractedWithEvent.Subscribe(ButtonClicked)

    ButtonClicked(Agent :agent):void=
        ShowScoreBoard(Agent)
        spawn{RemoveScoreBoard(Agent)}
        
    ShowScoreBoard(Agent :agent):void=
        if:
            ElimTracker := SB_Trackers[0]
            DeathTracker := SB_Trackers[1]
            NameBill := SB_Boards[0]
            ElimBill := SB_Boards[1]
            DeathBill := SB_Boards[2]
            KDBill := SB_Boards[3]
            RankBill := SB_Boards[4]
        then:
            SB_BG.Show()
            SB_Ref.Register(Agent)

            NameBill.SetText(AM(Agent))
            NameBill.ShowText()

            ElimBill.SetText(SM("Eliminations: {ElimTracker.GetValue(Agent)}"))
            ElimBill.ShowText()

            DeathBill.SetText(SM("Deaths: {DeathTracker.GetValue(Agent)}"))
            DeathBill.ShowText()

            KDRatio := (ElimTracker.GetValue(Agent) * 1.0) / (DeathTracker.GetValue(Agent) * 1.0)

            KDBill.SetText(SM("K/D: {GetRoundedString(KDRatio, 2)}"))
            KDBill.ShowText()

            RankBill.SetText(SM("Rank"))
            RankBill.ShowText()

            if(ElimTracker.GetValue(Agent) <= 5):
                if(BRank := SB_Ranks[0]):
                    BRank.Show()
                else if (ElimTracker.GetValue(Agent) > 5):
                    if(SRank := SB_Ranks[1]):
                        SRank.Show()

    RemoveScoreBoard(Agent : agent)<suspends>: void=
        Sleep(15.0)
        for (Boards : SB_Boards):
            Boards.HideText()

        for (Rank : SB_Ranks):
            Rank.Hide()

        SB_Ref.Clear()
        SB_BG.Hide()

    GetRoundedString<private>(Input : float, NumDigitsAfterDecimal : int) : string =
        if:
            Multiplier := Pow(10.0, NumDigitsAfterDecimal * 1.0)
            RoundedValue := RoundedTickRate := float[Round[Input*Multiplier]*1.0] / Multiplier
            BeforeDecimal := Floor[RoundedValue]
            AfterDecimal := Abs(Round[(RoundedValue - BeforeDecimal*1.0)*Multiplier])
            var AfterDecimalString : string = ToString(AfterDecimal)

            #pad with leading zeroes
            for (It := 0..(NumDigitsAfterDecimal-AfterDecimalString.Length-1)):
                set AfterDecimalString = array{'0'} + AfterDecimalString
        then:
            "{BeforeDecimal}.{AfterDecimalString}"
        else:
            ToString(Input)