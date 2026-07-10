# Test Framework Runner
# Automatically executes test suites and test cases when the game begins, collecting results and displaying a formatted report with pass/fail statistics. Uses a factory pattern to load and run multiple 
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/test-factory-device-1?ref=github

using { /Verse.org/Colors }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/Colors/NamedColors }

using { Tableau }

test_factory_device := class(creative_device):

    OnBegin<override>()<suspends>:void=
        TestSuites := LoadTestDevices()

        var SuiteResults:[test_suite][]tuple(test_case, ?failure) = map{}
        for(Suite : TestSuites):
            TestCases := Suite.GetTests()
            TestCaseResults := for(TestCase:TestCases). (TestCase, TestCase.Test())
            if(set SuiteResults[Suite] = TestCaseResults) {}

        var PrintResults:string = ""
        var Passes:int = 0
        var Fails:int = 0
        var Total:int = 0
        for(Suite -> Results:SuiteResults):
            set PrintResults += "\n-\n✎ {Suite.GetName()}\n-"

            for(Result : Results):
                TestCase := Result(0)
                MaybeFail := Result(1)
                # (TestCase, MaybeFail) := Result
                if(Fail := MaybeFail?):
                    set Fails += 1
                    set PrintResults += "\n\t❌ {TestCase.Name}\n\t\t➥ {Fail.Msg}"
                else:
                    set Passes += 1
                    set PrintResults += "\n\t✔ {TestCase.Name}"
                set Total += 1

        set PrintResults += "\n-\n ✔ Pass  = {Passes}\n ❌ Fail  = {Fails}\n ➰ Total = {Total}\n-"
        if (TestSuites.Length = 0):
            set PrintResults += "\n➰ NONE\t➰ NONE\t➰ NONE\t➰ NONE\t➰ NONE\t➰\n-"
            set PrintResults += "\n "
        else:
            if (Fails <= 0):
                set PrintResults += "\n✔ PASS\t✔ PASS\t✔ PASS\t✔ PASS\t✔ PASS\t✔\n-"
            else:
                set PrintResults += "\n❌ FAIL\t❌ FAIL\t❌ FAIL\t❌ FAIL\t❌ FAIL\t❌\n-"
        ProjectLog(PrintResults)
