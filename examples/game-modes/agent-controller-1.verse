# Agent Possession Controller
# This code creates a controller that manages agent possession through possession devices. It listens for possession commands from multiple devices and dispatches them to an agent service to handle part
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/agent-controller-1?ref=github

using { /Verse.org/Simulation }

using { Tableau }

agent_controller<public> := class(controller):
    Dispatcher<public>:dispatcher
    AgentService<public>:agent_service
    Devices<public>:[]possession_device

    Triage<override>()<suspends>:void =
        if (Devices.Length <= 0). return
        loop:
            # race:
                # Commands
                Command_Possess()

    Command_Possess()<suspends>:void=
        Commands := for(Device:Devices). Device.PossessCommand

        MaybeCommand := Commands.Race()
        if:
            Command := MaybeCommand?
            NewAgent := Command(0)
            NewParticipant := Command(1)
        then:
            Dispatcher.Dispatch(AgentService.PossessParticipant(NewAgent, NewParticipant))