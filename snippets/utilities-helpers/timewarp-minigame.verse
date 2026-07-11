# Timewarp Minigame
# Verse code for Timewarp Minigame - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/timewarp-minigame?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }

timewarp_minigame := class(creative_device):

    @editable OctoSpeed:cinematic_sequence_device = cinematic_sequence_device{}
    @editable QuadSpeed:cinematic_sequence_device = cinematic_sequence_device{}
    @editable DoubleSpeed:cinematic_sequence_device = cinematic_sequence_device{}
    @editable HalfSlomo:cinematic_sequence_device = cinematic_sequence_device{}
    @editable QuarterSlomo:cinematic_sequence_device = cinematic_sequence_device{}
    @editable OctoSlomo:cinematic_sequence_device = cinematic_sequence_device{}

    var InProgress:logic = false
    var CurrentCinematic:cinematic_sequence_device = cinematic_sequence_device{}

    StartMinigame():void=
        set InProgress = true
        if(TaggedObject := GetCreativeObjectsWithTag(UtilsTag{})[0], UtilsSystem := utils_system[TaggedObject]):
            UtilsSystem.GrantStandardItems()

        spawn{MinigameLoop()}

    MinigameLoop()<suspends>:void=
        race:
            block:
                if(TaggedObject := GetCreativeObjectsWithTag(GameManagerTag{})[0], GameManager := game_manager[TaggedObject]):
                    GameManager.NewMinigameEvent.Await()
            block:
                Sleep(3.0)
                loop:
                    if(InProgress = true):
                        RandomInt := GetRandomInt(1, 6)
                        TimeToWait:float = 10.0
                        Print("RandomInt: {RandomInt}")
                        if(RandomInt = 1):
                            CurrentCinematic.Stop()
                            set CurrentCinematic = OctoSpeed
                            CurrentCinematic.Play()
                            Sleep(TimeToWait*8)
                        else if(RandomInt = 2):
                            CurrentCinematic.Stop()
                            set CurrentCinematic = QuadSpeed
                            CurrentCinematic.Play()
                            Sleep(TimeToWait*4)
                        else if(RandomInt = 3):
                            CurrentCinematic.Stop()
                            set CurrentCinematic = DoubleSpeed
                            CurrentCinematic.Play()
                            Sleep(TimeToWait*2)
                        else if(RandomInt = 4):
                            CurrentCinematic.Stop()
                            set CurrentCinematic = HalfSlomo
                            CurrentCinematic.Play()
                            Sleep(TimeToWait/2.0)
                        else if(RandomInt = 5):
                            CurrentCinematic.Stop()
                            set CurrentCinematic = QuarterSlomo
                            CurrentCinematic.Play()
                            Sleep(TimeToWait/4.0)
                        else if(RandomInt = 6):
                            CurrentCinematic.Stop()
                            set CurrentCinematic = OctoSlomo
                            CurrentCinematic.Play()
                            Sleep(TimeToWait/8.0)
                    else:
                        break

    ResetMinigame():void=
        set InProgress = false
        CurrentCinematic.Stop()
        set CurrentCinematic = cinematic_sequence_device{}