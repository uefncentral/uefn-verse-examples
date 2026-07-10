# Player Revival System
# Creates an automatic revival system that monitors players of a specific class and revives them after a set delay when they're downed. The system uses class tracking to determine which players are elig
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/rebirth?ref=github

<#
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }


Rebirth := class(creative_device):

    @editable var Class : int = 0
    @editable ClassTracker : tracker_device = tracker_device{}
    @editable HUDablity : hud_message_device = hud_message_device{}

    @editable SecondLifeTimeUntilRevive : float = 1.0
    @editable SecondLifeDownDevice : down_but_not_out_device = down_but_not_out_device{}

    OnBegin<override>()<suspends>:void=
        InitSpawners()
        SecondLifeDownDevice.Disable()
        SecondLifeDownDevice.Enable()

    InitSpawners() : void=
        Spawners := GetCreativeObjectsWithTag(spawner{})
        for (Obj : Spawners):
            if (Spawner := player_spawner_device[Obj]):
                Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

    OnPlayerSpawned(Agent : agent): void=
        if (Player := player[Agent]):
            spawn{OnPlayerSpawnedSleep(Agent)}

    OnPlayerSpawnedSleep(Agent : agent)<suspends>: void=
        Sleep(1.0)
        if(ClassTracker.GetValue(Agent) = Class):
            CheckClass()
            HUDablity.Show(Agent)
            
    CheckClass():void=
        for (Player : GetPlayspace().GetPlayers()):
            if(FC := Player.GetFortCharacter[], Agent := FC.GetAgent[]):
                    spawn:
                        CheckForDowned(FC)
                        
    CheckForDowned(FC : fort_character)<suspends> : void=
        if(Agent := FC.GetAgent[]):
            loop:
                Sleep(0.1)
                if(FC.IsDownButNotOut[]):
                    Sleep(SecondLifeTimeUntilRevive)
                    SecondLifeDownDevice.Revive(Agent)
                    SecondLifeDownDevice.Disable()
                    break
#>
