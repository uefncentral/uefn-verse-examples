# Thor Hammer Superpower
# Creates a Thor-themed superpower system that grants players a hammer weapon with explosive abilities. When activated, it removes the player's current items, grants Thor's hammer, displays HUD messages
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/thor-superpower-1?ref=github


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
Thor_superpower := class(creative_device):
    @editable Hudmessage : hud_message_device = hud_message_device{}
    @editable RemoteRemover : item_remover_device = item_remover_device{}

    @editable ThorHammer : creative_prop = creative_prop{}
    @editable ExplosiveDeviceTHOR : explosive_device = explosive_device{}
    @editable DamageZone : damage_volume_device = damage_volume_device{}
    @editable AudioDeviceTHOR : audio_player_device = audio_player_device{}
    @editable VFXTHOR : vfx_spawner_device = vfx_spawner_device{}

    @editable Killfeed : elimination_feed_device = elimination_feed_device {}
    @editable Remote : signal_remote_manager_device = signal_remote_manager_device{}
    @editable ItemGranter : item_granter_device = item_granter_device{}
    @editable ConditionalButton : conditional_button_device = conditional_button_device{}
    OnBegin<override>()<suspends>:void=

        ConditionalButton.ActivatedEvent.Subscribe(Start)
        Remote.PrimarySignalEvent.Subscribe(RandomExplode)
    RandomExplode(Agent : agent):void=
        spawn{RandomExplode2(Agent)}
    Start(Agent : agent):void=
        Killfeed.Activate(Agent);
        RemoteRemover.Remove(Agent)
        ItemGranter.GrantItem(Agent)
        Hudmessage.Show(Agent)
    RandomExplode2(Agent : agent)<suspends>:void=
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

                                PlayerPos := Fort.GetTransform().Translation
                                UpPosition := vector3{X:=PlayerPos.X,Y:=PlayerPos.Y,Z:=5000.0}
                                DownPosition := vector3{X:=PlayerPos.X,Y:=PlayerPos.Y,Z:=615.0}
                                PlayerForward := Fort.GetViewRotation().GetLocalForward() * 900.0
                                Print("{PlayerForward}")
                                CrSpawn := PlayerPos + PlayerForward
                                SpawnPos := vector3 { X := CrSpawn.X, Y := CrSpawn.Y, Z :=5000.0}
                                CrFinish := PlayerPos + PlayerForward
                                FinishPos := vector3 { X := CrFinish.X, Y := CrFinish.Y, Z :=615.0}
                                FinishPo2 := vector3 { X := CrFinish.X, Y := CrFinish.Y, Z :=368.0}

                                PlayerRot := Fort.GetTransform().Rotation
                                if(ThorHammer.TeleportTo[SpawnPos,PlayerRot]){}
                                if(VFXTHOR.TeleportTo[SpawnPos,PlayerRot]){}
                                if(DamageZone.TeleportTo[SpawnPos,PlayerRot]){}
                                if(ExplosiveDeviceTHOR.TeleportTo[SpawnPos,PlayerRot]){}
                                Sleep(0.1)
                                sync:
                                    ThorHammer.MoveTo(FinishPos,PlayerRot,2.0)
                                    VFXTHOR.MoveTo(FinishPos,PlayerRot,2.0)
                                    DamageZone.MoveTo(FinishPo2,PlayerRot,2.0)
                                    ExplosiveDeviceTHOR.MoveTo(FinishPos,PlayerRot,2.0)
                                Sleep(0.1)
                                VFXTHOR.Enable()
                                ExplosiveDeviceTHOR.Explode(Agent)
                                AllPlayers := GetPlayspace().GetPlayers()
                                for(Playe : AllPlayers):
                                    if(FortC := Playe.GetFortCharacter[],NAgent := FortC.GetAgent[]):
                                        AudioDeviceTHOR.Register(NAgent)
                                        AudioDeviceTHOR.Play(NAgent)
                                Sleep(0.3)
                                VFXTHOR.Disable()
                                if(VFXTHOR.TeleportTo[vector3{X:=0.0,Y:=0.0,Z:=-392.0},VFXTHOR.GetTransform().Rotation]){}
                                if(ThorHammer.TeleportTo[vector3{X:=0.0,Y:=0.0,Z:=-392.0},ThorHammer.GetTransform().Rotation]){}
                                if(ExplosiveDeviceTHOR.TeleportTo[vector3{X:=0.0,Y:=0.0,Z:=-392.0},ExplosiveDeviceTHOR.GetTransform().Rotation]){}
                                if(DamageZone.TeleportTo[vector3{X:=0.0,Y:=0.0,Z:=-392.0},DamageZone.GetTransform().Rotation]){}

                                ExplosiveDeviceTHOR.Reset()
                            else:
                        else:
                            Print("attitude isnt hostile or agents check failed");
            else:
                Print("failed to get own team or all teams");



