# Battle Bus Drop System
# Creates an automated battle bus experience that plays cinematic sequences for bus movement and camera views. When players jump from the bus, they are teleported to a designated exit location and the c
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/uefn-verse-battlebus?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Playspaces }
# A Verse-authored creative device that can be placed in a level
BattleBusController := class(creative_device):
    @editable ExitLocation : teleporter_device = teleporter_device{}
    @editable BattleBusMovemement : cinematic_sequence_device = cinematic_sequence_device{}
    @editable CameraMovemement : cinematic_sequence_device = cinematic_sequence_device{}
    var MapInput1 : [fort_character]logic = map{}
    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        AllPlayers := GetPlayspace().GetPlayers()
        for (Agent : AllPlayers, pPlayer := player[Agent], FortCharacter := pPlayer.GetFortCharacter[]):
            if(set MapInput1[FortCharacter] = false) {}
            BattleBusMovemement.Play()
            CameraMovemement.Play()
            FortCharacter.JumpedEvent().Subscribe(OnPlayerJumpBattleBus)

    OnPlayerJumpBattleBus(aPlayer:fort_character):void=
        if (PlayerAgent : agent = aPlayer.GetAgent[]):
            if (MapInput1[aPlayer] = false):
                if (set MapInput1[aPlayer] = true) {}
                ExitLocation.Teleport(PlayerAgent)
                CameraMovemement.Stop()
