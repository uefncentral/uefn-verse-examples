# Hide and Seek Game
# Automatically manages a hide and seek game by randomly assigning players to hider/seeker teams when enough players join. Teleports hiders to hiding spots immediately, then releases seekers after a tim
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/game-device?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random}


Game_Device := class(creative_device):

    @editable
    HiderTeleporter:teleporter_device = teleporter_device{}
    @editable
    SeekerTeleporterZone:mutator_zone_device = mutator_zone_device{}
    @editable
    SeekerTeleport:teleporter_device = teleporter_device{}

    @editable
    HiderTimer:timer_device = timer_device{}
    
    @editable
    InfectedClassSelector:class_and_team_selector_device = class_and_team_selector_device{}
    @editable
    UninfectedClassSelector:class_and_team_selector_device = class_and_team_selector_device{}

    
    OnBegin<override>()<suspends>:void=
        
        HiderTimer.SuccessEvent.Subscribe(ReleaseTheSeekers)
        SeekerTeleporterZone.AgentEntersEvent.Subscribe(TeleportTheSeekers)
        LobbyChecker()



    LobbyChecker()<suspends>:void=

        Print("Lobby Checker")

        loop:
            Print("Player Count: " + ToString(GetPlayspace().GetPlayers().Length))
            Sleep(1.0)

            if(GetPlayspace().GetPlayers().Length >= 1):

                for (Index -> Player : Shuffle(GetPlayspace().GetPlayers()), Player.IsActive[]):
                    if (Index = 0 or Index = 1):
                      InfectedClassSelector.ChangeTeam(Player)
                      InfectedClassSelector.ChangeClass(Player)
                   else:
                      UninfectedClassSelector.ChangeTeam(Player)
                      UninfectedClassSelector.ChangeClass(Player)
                      HiderTeleporter.Teleport(Player)

                HiderTimer.Start()
            
                break

    ReleaseTheSeekers(Agent : ?agent):void=

        SeekerTeleporterZone.Enable()

    TeleportTheSeekers(Player : agent):void=
        SeekerTeleport.Teleport(Player)