# Work Service Testing
# A comprehensive test suite for a work service system that validates work lifecycle operations including starting and completing work tasks. The code implements unit tests to ensure proper state transi
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/work-service-test?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }

using { Tableau }
using { TableauTesting }

work_service_test := class(creative_device, test_suite):
    GetName<override>():string = "Work Service"
    GetTests<override>():[]test_case = array:
        test_case:
            Name := "Should start work from default state"
            Test := DefaultStartWork
        test_case:
            Name := "Should start work when available"
            Test := AvailableStartWork
        test_case:
            Name := "Should not start work when in warm"
            Test := FailStartWork
        test_case:
            Name := "Should completed work when in warm up"
            Test := CompleteWork
        test_case:
            Name := "Should completed work when available"
            Test := FailCompleteWork

    DefaultStartWork():?failure =
        # Arrange
        Work := work{ ID := 13 }
        Repo := work_repository. Initial := array. Work
        Service := work_service. Repo := Repo
        Ev1 := Ev_WorkStarted(entity_work{}, 13)

        # Act
        Events := Service.StartWork(13)

        # Assert
        if(Events.Length <> 1). return fail("Not the right number of Domain Events")
        if(not Events.Includes[Ev1]). return fail("No work started event")

        # Pass
        return false

    AvailableStartWork():?failure =
        # Arrange
        Work := work{ ID := 13, Phase := phase.Available }
        Repo := work_repository. Initial := array. Work
        Service := work_service. Repo := Repo
        Ev1 := Ev_WorkStarted(entity_work{}, 13)

        # Act
        Events := Service.StartWork(13)

        # Assert
        if(Events.Length <> 1). return fail("Not the right number of Domain Events")
        if(not Events.Includes[Ev1]). return fail("No work started event")

        # Pass
        return false

    FailStartWork():?failure =
        # Arrange
        Work := work{ ID := 13, Phase := phase.WarmUp }
        Repo := work_repository. Initial := array. Work
        Service := work_service. Repo := Repo

        # Act
        Events := Service.StartWork(13)

        # Assert
        if(Events.Length <> 0). return fail("Not the right number of Domain Events")

        # Pass
        return false

    CompleteWork():?failure =
        # Arrange
        Work := work{ ID := 13, Phase := phase.WarmUp }
        Repo := work_repository. Initial := array. Work
        Service := work_service. Repo := Repo
        Ev1 := Ev_WorkCompleted(entity_work{}, 13)

        # Act
        Events := Service.CompleteWork(13)

        # Assert
        if(Events.Length <> 1). return fail("Not the right number of Domain Events")
        if(not Events.Includes[Ev1]). return fail("No work completed event")

        # Pass
        return false

    FailCompleteWork():?failure =
        # Arrange
        Work := work{ ID := 13, Phase := phase.Available }
        Repo := work_repository. Initial := array. Work
        Service := work_service. Repo := Repo

        # Act
        Events := Service.CompleteWork(13)

        # Assert
        if(Events.Length <> 0). return fail("Not the right number of Domain Events")

        # Pass
        return false
