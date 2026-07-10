# Work Command Controller
# Manages work-related commands by listening for start and complete work signals from multiple work devices. It dispatches these commands through a service using a race condition to handle the first ava
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/work-controller-1?ref=github

using { Tableau }
using { TableauAgent }

work_controller<public> := class(controller):
    Dispatcher<public>:dispatcher
    Service<public>:work_service
    Devices<public>:[]work_device

    Triage<override>()<suspends>:void =
        if (Devices.Length <= 0). return
        loop:
            race:
                # Commands
                Command_StartWork()
                Command_CompleteWork()

    Command_StartWork()<suspends>:void=
        StartCommands := for(Device:Devices). Device.StartWorkCommand

        MaybeCommand := StartCommands.Race()
        if:
            Command := MaybeCommand?
            WorkID := Command.Subjects[0]
        then:
            Dispatcher.Dispatch(Service.StartWork(WorkID))

    Command_CompleteWork()<suspends>:void=
        CompleteCommands := for(Device:Devices). Device.CompleteWorkCommand

        MaybeCommand := CompleteCommands.Race()
        if:
            Command := MaybeCommand?
            WorkID := Command.Subjects[0]
        then:
            Dispatcher.Dispatch(Service.CompleteWork(WorkID))
