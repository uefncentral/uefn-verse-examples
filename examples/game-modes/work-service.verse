# Work Management Service
# A domain-driven service that manages work entities with start and complete operations. It uses repository pattern to persist work state changes and generates domain events when work transitions betwee
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/work-service?ref=github

using { Tableau }
using { TableauParticipant }

Ev_WorkStarted<constructor>(Type:entity, ID:int) := domain_event:
    Entity := Type
    EntityID := ID
    Event := ev_work_started{}
Ev_WorkCompleted<constructor>(Type:entity, ID:int) := domain_event:
    Entity := Type
    EntityID := ID
    Event := ev_work_completed{}

work_service<public> := class(service):
    Repo<public>:work_repository

    StartWork<public>(WorkID:int):[]domain_event=
        var DomainEvents:[]domain_event = array{}

        if:
            Work := Repo.GetByID[WorkID]
            NewWork := Work.StartWork[]
            Repo.Update[NewWork]
        then:
            set DomainEvents += array:
                Ev_WorkStarted(entity_work{}, NewWork.ID)

        return DomainEvents

    CompleteWork<public>(WorkID:int):[]domain_event=
        var DomainEvents:[]domain_event = array{}

        if:
            Work := Repo.GetByID[WorkID]
            NewWork := Work.CompleteWork[]
            Repo.Update[NewWork]
        then:
            set DomainEvents += array:
                Ev_WorkCompleted(entity_work{}, NewWork.ID)

        return DomainEvents
