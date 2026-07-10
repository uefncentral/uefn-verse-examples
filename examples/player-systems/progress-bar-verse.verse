# Progress Bar Verse
# Verse code for Progress Bar Verse - UEFN/Fortnite Creative implementation
# Difficulty: intermediate  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/progress-bar-verse?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }


BuildsResetCounter := class(creative_device):

    @editable
    Duration : float = 60.0

    @editable 
    ResetBuildsTimer : timer_device = timer_device{}

    @editable 
    ProgressBarSet : cinematic_sequence_device = cinematic_sequence_device{}

    @editable
    ExpDev : []explosive_device = array{}



    OnBegin<override>()<suspends>:void=
        ProgressBarSet.StoppedEvent.Subscribe(OnStopped)
        SetupTimerAndBar()
        ResetBuildsTimer.SetActiveDuration(Duration)
        TimerWorking()

    TimerWorking()<suspends>:void=
        loop:
            ResetBuildsTimer.Start()
            Sleep(Duration)
            AllPlayers := GetPlayspace().GetPlayers()
            if (Player := AllPlayers[0], Agent := agent[Player]):
                for(AllExplosives : ExpDev):
                    AllExplosives.Explode(Agent)
                    AllExplosives.Reset()
            ResetBuildsTimer.Reset()

    
    OnStopped():void=
        ProgressBarSet.Play()

    SetupTimerAndBar():void=
        ResetBuildsTimer.Start()
        ProgressBarSet.Play()