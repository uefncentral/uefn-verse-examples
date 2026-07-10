# Cinematic Game Intro
# Creates a timed cinematic sequence that plays at game start, freezing players during the intro and unfreezing them when complete. Uses two cinematic sequences - one for timing control and another for 
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/fov-device1?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
 
fov_device1 := class(creative_device):
 
    @editable GameManager : game_manager = game_manager{}
    @editable FadeSequence : cinematic_sequence_device = cinematic_sequence_device{}
    @editable TimeSequence : cinematic_sequence_device = cinematic_sequence_device{}
 
    OnBegin<override>()<suspends>:void=
        GameManager.FreezeAllPlayers()
 
        TimeSequence.Play()
        Sleep(5.0)
        TimeSequence.Stop()
 
        FadeSequence.Play()
        FadeSequence.StoppedEvent.Await()
 
        GameManager.UnfreezeAllPlayers()
        GameManager.OnStart()
