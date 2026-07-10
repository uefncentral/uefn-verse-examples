# Work Entity Framework
# Defines a basic work entity and associated events for tracking work lifecycle. Creates foundational classes for a work-started event and work-completed event that can be used in larger game systems.  
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/entities-and-events?ref=github

using { Tableau }

entity_work<public> := class(entity):
    Name<override>()<computes>:string = "Work"

ev_work_started<public> := class(ev):
    Name<override>()<computes>:string = "Work Started"

ev_work_completed<public> := class(ev):
    Name<override>()<computes>:string = "Work Commpleted"
