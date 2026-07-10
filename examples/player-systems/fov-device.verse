# Cinematic Intro Sequence
# Creates a timed cinematic introduction that freezes players, plays two sequential cinematic sequences (a 5-second timer followed by a fade effect), then unfreezes players and starts the game. This pro
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/fov-device?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
 
fov_device := class(creative_device):
 
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