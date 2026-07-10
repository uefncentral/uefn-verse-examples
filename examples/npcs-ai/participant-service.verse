# Participant Resource Manager
# A service class that manages resource allocation for game participants using domain-driven design patterns. It handles adding resources to individual participants or groups of participants while track
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/participant-service?ref=github

using { Tableau }
using { TableauProducer }

Ev_ResourcesGained<constructor>(ID:int) := domain_event:
    Entity := entity_participant{}
    EntityID := ID
    Event := ev_resources_gained{}

participant_service<public> := class(service):
    Repo<public>:participant_repository

    AddResources(ParticipantID:int, ResourceID:int, Count:num):[]domain_event=
        var DomainEvents:[]domain_event = array{}

        if (Participant := Repo.GetByID[ParticipantID]):
            NewParticipant := Participant.AddResources(ResourceID, Count)
            if (Repo.Update[NewParticipant]):
                set DomainEvents += array. Ev_ResourcesGained(Participant.ID)

        return DomainEvents

    AddResources(ParticipantIDs:[]int, ResourceID:int, Count:num):[]domain_event=
        Result := for(ParticipantID:ParticipantIDs). AddResources(ParticipantID, ResourceID,Count)
        return Concatenate(Result)