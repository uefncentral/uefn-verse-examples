# Rng Auto Team Select
# Verse code for Rng Auto Team Select - UEFN/Fortnite Creative implementation
# Difficulty: intermediate  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/rng-auto-team-select?ref=github

using { /Verse.org/Random }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

RNG_device1 := class(creative_device):

    var Players : []player = array{}
    @editable Trigger:trigger_device = trigger_device{}
    @editable var team1:trigger_device = trigger_device{}
    @editable var team2:trigger_device = trigger_device{}
 
    OnBegin<override>()<suspends>:void=
        Trigger.TriggeredEvent.Subscribe(RNGLoadout)

        set Players = GetPlayspace().GetPlayers()

    RNGLoadout(OptionalAgent : ?agent):void=
        if (Agent := OptionalAgent?):
            rngInt : int = GetRandomInt(1, 2)

            if (rngInt = 1):
                team1.Trigger(Agent)

            if (rngInt = 2):
                team2.Trigger(Agent)

          