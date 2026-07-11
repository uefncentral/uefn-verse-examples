# Agent Participant Possession System
# Manages the assignment and transfer of agents to participants in a multiplayer environment. It handles possession events, clears old assignments when agents switch participants, and generates domain e
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/agent-service?ref=github

using { /Verse.org/Simulation }

using { Tableau }
using { TableauParticipant }

Ev_Possessed<constructor>(ID:int) := domain_event:
    Entity := entity_participant{}
    EntityID := ID
    Event := ev_participant_possessed{}

Ev_Abandoned<constructor>(ID:int) := domain_event:
    Entity := entity_participant{}
    EntityID := ID
    Event := ev_participant_abandoned{}

agent_service<public> := class(service):
    Repo<public>:agent_repository

    PossessParticipant<public>(Agent:agent, ParticipantID:int):[]domain_event=
        var DomainEvents:[]domain_event = array{}
        if (OldParticipantID := Repo.GetParticipant[Agent]?):
            Repo.ClearAgent(OldParticipantID)
            set DomainEvents += array. Ev_Abandoned(OldParticipantID)

        Repo.UpdateAgent(Agent, ParticipantID)
        set DomainEvents += array. Ev_Possessed(ParticipantID)

        return DomainEvents
