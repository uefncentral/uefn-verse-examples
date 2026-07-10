# Cinematic Tab Navigation
# Creates a navigation system for jumping between specific timestamps in a cinematic sequence. Players use Previous and Next buttons to move between three predefined sections of the cinematic at timesta
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/leaderboard-1?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Simulation/Tags }

CineMatic_Manager := class(creative_device):

    @editable cinematic : cinematic_sequence_device = cinematic_sequence_device{}

    @editable PrevButton : button_device = button_device{}
    @editable NextButton : button_device = button_device{}

    var Tab : float = 1.0

    OnBegin<override>()<suspends>:void=
        cinematic.Play()
        cinematic.Pause()

        PrevButton.InteractedWithEvent.Subscribe(PrevTab)
        NextButton.InteractedWithEvent.Subscribe(NextTab)
    
    PrevTab(Agent :agent):void=
        if(Tab = 1.0){}
        if(Tab = 2.0):
            cinematic.SetPlaybackTime(1.0)
            set Tab = 1.0
        if(Tab = 3.0):
            cinematic.SetPlaybackTime(1.9)
            set Tab = 2.0

    NextTab(Agent :agent):void=
        if(Tab = 3.0){}
        if(Tab = 2.0):
            cinematic.SetPlaybackTime(3.0)
            set Tab = 3.0
        if(Tab = 1.0):
            cinematic.SetPlaybackTime(1.9)
            set Tab = 2.0