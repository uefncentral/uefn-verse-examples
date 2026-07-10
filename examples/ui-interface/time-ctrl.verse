# Time Ctrl
# Verse code for Time Ctrl - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/time-ctrl?ref=github


using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /Fortnite.com/Characters }

using { /UnrealEngine.com/Assets }
using { /Verse.org/Simulation }
using { /Verse.org/Colors/NamedColors }
using { /Verse.org/Assets }

using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Game }
	
using{/Verse.org/Colors}
cp1 := class():
    test : int = 0

timectrl := class(creative_device):
    var PMap : [agent]cp = map{}
    @editable RoundTime : float = 0.0
    @editable RoundSettings1 : round_settings_device = round_settings_device{}
    @editable Trackerr : tracker_device = tracker_device{}
    @editable butttt : buttons = buttons{}
    @editable HUDWinner : hud_message_device = hud_message_device{}
    @editable rankS : RankManager = RankManager{}
    @editable WinnerPlayer : player_reference_device = player_reference_device{}
    
    
    OnBegin<override>()<suspends>:void=
        GetPlayspace().PlayerAddedEvent().Subscribe(InitPlRef)
        RoundSettings1.RoundBeginEvent.Subscribe(InitTime)
        
        butttt.Elim.EliminationEvent.Subscribe(CompValues)

        
    CompValues(Ag : ?agent): void=
        Pl := WinnerPlayer.GetAgent()
        if (A := butttt.PlayersMap[Ag?], Ag1 : agent = Ag?):
            if (Trackerr.GetValue(A.Agent1) >= Trackerr.GetValue(Ag1)):
                WinnerPlayer.Register(A.Agent1)
            else:
                WinnerPlayer.Register(Ag1)

    InitPlRef(Ag : agent): void=
        WinnerPlayer.Register(Ag)


    InitTime(t : tuple()): void=
        spawn:
            InitT()
    
    InitT()<suspends>: void=
        var ti : float = RoundTime
        for (Pl -> CP : butttt.PlayersMap):
            Trackerr.SetValue(Pl, 0)
        
        
        loop:
            Print("{ti}")
            Sleep(1.0)
            set ti -= 1.0
            if (ti < 10.0 ):
                Print("INSIDE LOOP")
                var max : int = 0
                var Message : message = SM("")
                
                Ag := WinnerPlayer.GetAgent()
                if (Ag1 : agent = Ag?):
                    Print("Getting Player")
                    set Message = SMA(Ag1, SM("Has won the round!!"))
                    if (Pl := player[Ag1]):
                        rankS.IncWinStreak(Pl)
                        HUDWinner.SetText(Message)
                        HUDWinner.Show()
                        Sleep(10.0)
                        
                        RoundSettings1.EndRound(Ag1)

                
                






