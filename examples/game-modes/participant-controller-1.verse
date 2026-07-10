# Resource Grant Controller
# A controller class that listens for resource addition commands and processes them through a dispatcher system. It manages adding specified amounts of resources to participants when triggered by extern
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/participant-controller-1?ref=github

using { Tableau }

participant_controller<public> := class(controller):
    Dispatcher<public>:dispatcher
    ParticipantService<public>:participant_service
    Effect<public>:grant_resources_effect

    Triage<override>()<suspends>:void =
        loop:
            # race:
                # Commands
                Command_AddResources()

    Command_AddResources()<suspends>:void=
        Command := Effect.AddResourcesCommand.Await()
        if:
            ParticipantIDs := Command.Subjects
            ResourceID := Command.Targets[0]
            Count := Command.Magnitudes[0]
        then:
            Dispatcher.Dispatch(ParticipantService.AddResources(ParticipantIDs, ResourceID, Count))
