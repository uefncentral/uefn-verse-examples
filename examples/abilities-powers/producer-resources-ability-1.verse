# Command Factory Class
# Creates a factory class for generating command objects with subject, target, and magnitude parameters. The class stores after-effects and provides a Make method to construct commands with specified pa
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/producer-resources-ability-1?ref=github

using { Tableau }
using { TableauParticipant }

command_maker<public> := class():
    AfterEffects<public>:[]effect

    Make<public>(Subject:int, Target:int, Magnitude:num):command=
        command:
            Subjects := array. Subject
            Targets := array. Target
            Magnitudes := array. Magnitude
            AfterEffects := AfterEffects
