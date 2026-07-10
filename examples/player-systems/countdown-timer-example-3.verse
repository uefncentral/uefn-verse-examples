# Countdown Timer Example
# Creates a 30-second countdown timer that displays on screen and automatically ends the game when it reaches zero. Players can interact with a button to add 20 seconds to the remaining time.  **How to 
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/countdown-timer-example-3?ref=github

using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/UI }

countdown_timer_example := class(creative_device):

    @editable
    AddMoreTimeButton : button_device = button_device{}

    @editable
    EndGame : end_game_device = end_game_device{}

    var CountdownTimer : countdown_timer = countdown_timer{}
    InitialCountdownTime : float = 30.0

    OnBegin() : void =
        AddMoreTimeButton.InteractedWithEvent.Subscribe(OnButtonInteractedWith)

        if:
            FirstPlayer := Self.GetPlayspace().GetPlayers()[0]
            PlayerUI := GetPlayerUI[player[FirstPlayer]]
        then:
            set CountdownTimer = countdown_timer{MaybePlayerUI := option{PlayerUI}, RemainingTime := InitialCountdownTime}

            CountdownTimer.StartCountdown()

            CountdownTimer.CountdownEndedEvent.Await()

            EndGame.Activate(FirstPlayer)
        else:
            Print("Can't find player")

    OnButtonInteractedWith(Agent : agent) : void =
        TimeToAdd : float = 20.0
        CountdownTimer.AddRemainingTime(TimeToAdd)