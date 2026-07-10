# Random Team Assignment
# Automatically assigns one random player as 'infected/seeker' and all other players as 'uninfected/hiders' at game start. Uses class and team selector devices to handle team assignments for hide-and-se
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/random-1?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/Playspaces }
using { /Fortnite.com/Teams }
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Playspaces }
 
PlayerTeamRandomizer := class(creative_device) :
        @editable
        InfectedClassSelector:class_and_team_selector_device = class_and_team_selector_device{}
        @editable
        UninfectedClassSelector:class_and_team_selector_device = class_and_team_selector_device{}

        # Runs when the device is started in a running game
        OnBegin<override>()<suspends>:void=
            #Game mode helpers
            ChooseRandomInfected()

        ChooseRandomInfected():void=
             for (Index -> Player : Shuffle(GetPlayspace().GetPlayers()), Player.IsActive[]):
                  if (Index = 0):
                    InfectedClassSelector.ChangeTeam(Player)
                    InfectedClassSelector.ChangeClass(Player)
                    Print("The Seekers has been chosen!")
                 else:
                  Print("The hiders has been chosen!")
                    UninfectedClassSelector.ChangeTeam(Player)
                    UninfectedClassSelector.ChangeClass(Player)