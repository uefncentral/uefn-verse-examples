# Dr Doom Superpower System
# Creates a superhero power activation system that grants special abilities to players when they interact with a conditional button. The system provides teleportation powers via a remote device, visual 
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/drdoom-superpower-1?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters }
using { /Verse.org/Random }
using { /Verse.org/Colors/NamedColors }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /Fortnite.com/Teams }

DrDoomsuperpower := class(creative_device):


    @editable Hudmessage : hud_message_device = hud_message_device{}
    @editable RemoteRemover : item_remover_device = item_remover_device{}
    @editable StartPosition : vector3 = vector3{X:=0.0 , Y:=0.0 , Z:=0.0}
    @editable EndPosition : vector3 = vector3{X:=0.0 , Y:=0.0 , Z:=0.0}
    @editable Remote : signal_remote_manager_device = signal_remote_manager_device{}
    @editable ItemGranter : item_granter_device = item_granter_device{}
    @editable ConditionalButton : conditional_button_device = conditional_button_device{}
    @editable VFXPowr :visual_effect_powerup_device  = visual_effect_powerup_device{}
    @editable Killfeed : elimination_feed_device = elimination_feed_device {}

    OnBegin<override>()<suspends>:void=

        ConditionalButton.ActivatedEvent.Subscribe(Start)
        Remote.PrimarySignalEvent.Subscribe(RandomTeleport)
    RandomTeleport(Agent : agent):void=
        spawn{RandomTeleport2(Agent)}
    Start(Agent : agent):void=
        Killfeed.Activate(Agent);
        RemoteRemover.Remove(Agent)
        ItemGranter.GrantItem(Agent)
        VFXPowr.Pickup(Agent)
        Hudmessage.Show(Agent)
    RandomTeleport2(Agent : agent)<suspends>:void=
        if:
            Player := player[Agent]
            Fort := Player.GetFortCharacter[]
        then:
            TeamColl := GetPlayspace().GetTeamCollection();
            if:
                OurTeam := TeamColl.GetTeam[Agent]
                AllTeams := TeamColl.GetTeams()
            then:
                for (TeamNum->Team: AllTeams):
                    if (Team = OurTeam) { Print("Found our team ({TeamNum})") }
                    else:
                        Print("Found a team that isnt ours");
                        Print("Team: {TeamNum}");
    
                        if:
                            Agents := TeamColl.GetAgents[Team]
                            Attitude := TeamColl.GetTeamAttitude[Team, OurTeam]
                            Attitude = team_attitude.Hostile
                        then:
                            Print("Team {TeamNum} is hostile");
                            if (TeamNum = 1):
                                Xs:= GetRandomFloat(StartPosition.X,EndPosition.X)
                                Ys:= GetRandomFloat(StartPosition.Y,EndPosition.Y)
                                Zs:= GetRandomFloat(StartPosition.Z,EndPosition.Z)
                                NewPosition := vector3{X :=Xs,Y:=Ys,Z:= Zs}
                                NewRotation : rotation = Fort.GetViewRotation()
                                Sleep(0.1)
                                if(Fort.TeleportTo[Position:vector3 = NewPosition,Rotation : rotation = NewRotation]){Print("New Player Position is {NewPosition}")}
                            else:
                        else:
                            Print("attitude isnt hostile or agents check failed");
            else:
                Print("failed to get own team or all teams");


            


