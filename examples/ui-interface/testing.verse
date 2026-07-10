# Test Framework System
# This code implements a basic testing framework for UEFN/Verse that allows developers to create and organize test cases and test suites. It provides structures for defining individual tests with names 
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/testing?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation/Tags }

test_tag<public> := class(tag){}
test := type{_():?failure}
fail<public>(Msg:string)<transacts>:?failure = option. failure. Msg := Msg
failure<public> := struct:
    Msg<public>:string = "Fail"
# TODO: Add editable array checkmarks for skipping tests
test_case<public> := class():
    Name<public>:string = "<No Name>"
    Test<public>:test
test_suite<public> := interface<unique>():
    GetName<public>():string
    GetTests<public>():[]test_case
    # ShouldRun<public>():logic

LoadTestDevices<public>():[]test_suite=
    TaggedDevices := GetCreativeObjectsWithTag(test_tag{})
    for(Index -> Tagged : TaggedDevices, Device := test_suite[Tagged]). Device
