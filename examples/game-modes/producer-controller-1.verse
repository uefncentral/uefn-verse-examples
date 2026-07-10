# Producer Management Controller
# A controller class that manages producer-related operations in a game economy system. It handles buying producers and triggering production through command dispatching with asynchronous event handling
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/producer-controller-1?ref=github

using { Tableau }
using { TableauAgent }

producer_controller<public> := class(controller):
    Dispatcher<public>:dispatcher
    ProducerService<public>:producer_service
    BuyEffect<public>:buy_producer_effect
    ProduceEffect<public>:produce_effect

    Triage<override>()<suspends>:void =
        loop:
            race:
                # Commands
                Command_Buy()
                Command_Produce()

    Command_Buy()<suspends>:void=
        Command := BuyEffect.BuyProducerCommand.Await()
        if:
            ProducerID := Command.Subjects[0]
            BuyerID := Command.Targets[0]
        then:
            Dispatcher.Dispatch(ProducerService.Buy(ProducerID, BuyerID))

    Command_Produce()<suspends>:void=
        Command := ProduceEffect.ProduceCommand.Await()
        if:
            ProducerID := Command.Subjects[0]
            ParticipantID:= Command.Targets[0]
        then:
            Dispatcher.Dispatch(ProducerService.Produce(ProducerID, ParticipantID))
