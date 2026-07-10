# Iron Man Superpower System
# Creates an Iron Man-themed superpower ability system that activates when players interact with a conditional button. The system spawns Iron Man props, creates explosive effects with damage volumes, an
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/ironman-superpower?ref=github


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

ironman_superpower := class(creative_device):

    @editable Hudmessage : hud_message_device = hud_message_device{}
    @editable RemoteRemover : item_remover_device = item_remover_device{}
    @editable IronManProps : []creative_prop = array{}
    @editable ExplosiveDevices : []explosive_device = array{}
    @editable DamageVolume : []damage_volume_device = array{}
    @editable Killfeed : elimination_feed_device = elimination_feed_device {}

    @editable AudioDeviceIron : audio_player_device = audio_player_device{}
    @editable EffectedStartPosition : vector3 = vector3{X:=0.0 , Y:=0.0 , Z:=0.0}
    @editable EffectedEndPosition : vector3 = vector3{X:=0.0 , Y:=0.0 , Z:=0.0}
    @editable Remote : signal_remote_manager_device = signal_remote_manager_device{}
    @editable ItemGranter : item_granter_device = item_granter_device{}
    @editable ConditionalButton : conditional_button_device = conditional_button_device{}
    OnBegin<override>()<suspends>:void=
        ConditionalButton.ActivatedEvent.Subscribe(Start)
        Remote.PrimarySignalEvent.Subscribe(SpawnSt)
    SpawnSt(Agent : agent):void=
        spawn{SpawnSt2(Agent)}
    Start(Agent : agent):void=
        Killfeed.Activate(Agent);
        RemoteRemover.Remove(Agent)
        ItemGranter.GrantItem(Agent)
        Hudmessage.Show(Agent)
    SpawnSt2(Agent : agent)<suspends>:void=
        if:
            PropN1 := IronManProps[0]
            PropN2 := IronManProps[1]
            PropN3 := IronManProps[2]
            PropN4 := IronManProps[3]
            PropN5 := IronManProps[4]
            PropN6 := IronManProps[5]
            PropN7 := IronManProps[6]
            PropN8 := IronManProps[7]
            DamageN1 := DamageVolume[0]
            DamageN2 := DamageVolume[1]
            DamageN3 := DamageVolume[2]
            DamageN4 := DamageVolume[3]
            DamageN5 := DamageVolume[4]
            DamageN6 := DamageVolume[5]
            DamageN7 := DamageVolume[6]
            DamageN8 := DamageVolume[7]

            ExplosiveN1 := ExplosiveDevices[0]
            ExplosiveN2 := ExplosiveDevices[1]
            ExplosiveN3 := ExplosiveDevices[2]
            ExplosiveN4 := ExplosiveDevices[3]
            ExplosiveN5 := ExplosiveDevices[4]
            ExplosiveN6 := ExplosiveDevices[5]
            ExplosiveN7 := ExplosiveDevices[6]
            ExplosiveN8 := ExplosiveDevices[7]


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
                                
                                X1:= GetRandomFloat(EffectedStartPosition.X,EffectedEndPosition.X)
                                Y1:= GetRandomFloat(EffectedStartPosition.Y,EffectedEndPosition.Y)
                                Z1:= GetRandomFloat(EffectedStartPosition.Z,EffectedEndPosition.Z)
                                X2:= GetRandomFloat(EffectedStartPosition.X,EffectedEndPosition.X)
                                Y2:= GetRandomFloat(EffectedStartPosition.Y,EffectedEndPosition.Y)
                                Z2:= GetRandomFloat(EffectedStartPosition.Z,EffectedEndPosition.Z)
                                X3:= GetRandomFloat(EffectedStartPosition.X,EffectedEndPosition.X)
                                Y3:= GetRandomFloat(EffectedStartPosition.Y,EffectedEndPosition.Y)
                                Z3:= GetRandomFloat(EffectedStartPosition.Z,EffectedEndPosition.Z)
                                X4:= GetRandomFloat(EffectedStartPosition.X,EffectedEndPosition.X)
                                Y4:= GetRandomFloat(EffectedStartPosition.Y,EffectedEndPosition.Y)
                                Z4:= GetRandomFloat(EffectedStartPosition.Z,EffectedEndPosition.Z)
                                X5:= GetRandomFloat(EffectedStartPosition.X,EffectedEndPosition.X)
                                Y5:= GetRandomFloat(EffectedStartPosition.Y,EffectedEndPosition.Y)
                                Z5:= GetRandomFloat(EffectedStartPosition.Z,EffectedEndPosition.Z)
                                X6:= GetRandomFloat(EffectedStartPosition.X,EffectedEndPosition.X)
                                Y6:= GetRandomFloat(EffectedStartPosition.Y,EffectedEndPosition.Y)
                                Z6:= GetRandomFloat(EffectedStartPosition.Z,EffectedEndPosition.Z)
                                X7:= GetRandomFloat(EffectedStartPosition.X,EffectedEndPosition.X)
                                Y7:= GetRandomFloat(EffectedStartPosition.Y,EffectedEndPosition.Y)
                                Z7:= GetRandomFloat(EffectedStartPosition.Z,EffectedEndPosition.Z)
                                X8:= GetRandomFloat(EffectedStartPosition.X,EffectedEndPosition.X)
                                Y8:= GetRandomFloat(EffectedStartPosition.Y,EffectedEndPosition.Y)
                                Z8:= GetRandomFloat(EffectedStartPosition.Z,EffectedEndPosition.Z)

                                NewPosition1 := vector3{X :=X1,Y:=Y1,Z:= 4224.0}
                                NewPosition2 := vector3{X :=X2,Y:=Y2,Z:= 4224.0}
                                NewPosition3 := vector3{X :=X3,Y:=Y3,Z:= 4224.0}
                                NewPosition4 := vector3{X :=X4,Y:=Y4,Z:= 4224.0}
                                NewPosition5 := vector3{X :=X5,Y:=Y5,Z:= 4224.0}
                                NewPosition6 := vector3{X :=X6,Y:=Y6,Z:= 4224.0}
                                NewPosition7 := vector3{X :=X7,Y:=Y7,Z:= 4224.0}
                                NewPosition8 := vector3{X :=X8,Y:=Y8,Z:= 4224.0}
        
                                FinishPosition1 := vector3{X :=X1,Y:=Y1,Z:= 494.981895}
                                FinishPosition2 := vector3{X :=X2,Y:=Y2,Z:= 494.981895}
                                FinishPosition3 := vector3{X :=X3,Y:=Y3,Z:= 494.981895}
                                FinishPosition4 := vector3{X :=X4,Y:=Y4,Z:= 494.981895}
                                FinishPosition5 := vector3{X :=X5,Y:=Y5,Z:= 494.981895}
                                FinishPosition6 := vector3{X :=X6,Y:=Y6,Z:= 494.981895}
                                FinishPosition7 := vector3{X :=X7,Y:=Y7,Z:= 494.981895}
                                FinishPosition8 := vector3{X :=X8,Y:=Y8,Z:= 494.981895}

                                FinishPositionDamage1 := vector3{X :=X1,Y:=Y1,Z:= 344.0}
                                FinishPositionDamage2 := vector3{X :=X2,Y:=Y2,Z:= 344.0}
                                FinishPositionDamage3 := vector3{X :=X3,Y:=Y3,Z:= 344.0}
                                FinishPositionDamage4 := vector3{X :=X4,Y:=Y4,Z:= 344.0}
                                FinishPositionDamage5 := vector3{X :=X5,Y:=Y5,Z:= 344.0}
                                FinishPositionDamage6 := vector3{X :=X6,Y:=Y6,Z:= 344.0}
                                FinishPositionDamage7 := vector3{X :=X7,Y:=Y7,Z:= 344.0}
                                FinishPositionDamage8 := vector3{X :=X8,Y:=Y8,Z:= 344.0}

                                PlayerRot := Fort.GetTransform().Rotation
                                if(PropN1.TeleportTo[NewPosition1,PlayerRot]){}
                                if(PropN2.TeleportTo[NewPosition2,PlayerRot]){}
                                if(PropN3.TeleportTo[NewPosition3,PlayerRot]){}
                                if(PropN4.TeleportTo[NewPosition4,PlayerRot]){}
                                if(PropN5.TeleportTo[NewPosition5,PlayerRot]){}
                                if(PropN6.TeleportTo[NewPosition6,PlayerRot]){}
                                if(PropN7.TeleportTo[NewPosition7,PlayerRot]){}
                                if(PropN8.TeleportTo[NewPosition8,PlayerRot]){}

                                if(ExplosiveN1.TeleportTo[NewPosition1,PlayerRot]){}
                                if(ExplosiveN2.TeleportTo[NewPosition2,PlayerRot]){}
                                if(ExplosiveN3.TeleportTo[NewPosition3,PlayerRot]){}
                                if(ExplosiveN4.TeleportTo[NewPosition4,PlayerRot]){}
                                if(ExplosiveN5.TeleportTo[NewPosition5,PlayerRot]){}
                                if(ExplosiveN6.TeleportTo[NewPosition6,PlayerRot]){}
                                if(ExplosiveN7.TeleportTo[NewPosition7,PlayerRot]){}
                                if(ExplosiveN8.TeleportTo[NewPosition8,PlayerRot]){}

                                if(DamageN1.TeleportTo[NewPosition1,PlayerRot]){}
                                if(DamageN2.TeleportTo[NewPosition2,PlayerRot]){}
                                if(DamageN3.TeleportTo[NewPosition3,PlayerRot]){}
                                if(DamageN4.TeleportTo[NewPosition4,PlayerRot]){}
                                if(DamageN5.TeleportTo[NewPosition5,PlayerRot]){}
                                if(DamageN6.TeleportTo[NewPosition6,PlayerRot]){}
                                if(DamageN7.TeleportTo[NewPosition7,PlayerRot]){}
                                if(DamageN8.TeleportTo[NewPosition8,PlayerRot]){}
                                sync:
                                    PropN1.MoveTo(FinishPosition1,PlayerRot,2.0)
                                    PropN2.MoveTo(FinishPosition2,PlayerRot,2.0)
                                    PropN3.MoveTo(FinishPosition3,PlayerRot,2.0)
                                    PropN4.MoveTo(FinishPosition4,PlayerRot,2.0)
                                    PropN5.MoveTo(FinishPosition5,PlayerRot,2.0)
                                    PropN6.MoveTo(FinishPosition6,PlayerRot,2.0)
                                    PropN7.MoveTo(FinishPosition7,PlayerRot,2.0)
                                    PropN8.MoveTo(FinishPosition8,PlayerRot,2.0)

                                    ExplosiveN1.MoveTo(FinishPosition1,PlayerRot,2.0)
                                    ExplosiveN2.MoveTo(FinishPosition2,PlayerRot,2.0)
                                    ExplosiveN3.MoveTo(FinishPosition3,PlayerRot,2.0)
                                    ExplosiveN4.MoveTo(FinishPosition4,PlayerRot,2.0)
                                    ExplosiveN5.MoveTo(FinishPosition5,PlayerRot,2.0)
                                    ExplosiveN6.MoveTo(FinishPosition6,PlayerRot,2.0)
                                    ExplosiveN7.MoveTo(FinishPosition7,PlayerRot,2.0)
                                    ExplosiveN8.MoveTo(FinishPosition8,PlayerRot,2.0)

                                    DamageN1.MoveTo(FinishPositionDamage1,PlayerRot,2.0)
                                    DamageN2.MoveTo(FinishPositionDamage2,PlayerRot,2.0)
                                    DamageN3.MoveTo(FinishPositionDamage3,PlayerRot,2.0)
                                    DamageN4.MoveTo(FinishPositionDamage4,PlayerRot,2.0)
                                    DamageN5.MoveTo(FinishPositionDamage5,PlayerRot,2.0)
                                    DamageN6.MoveTo(FinishPositionDamage6,PlayerRot,2.0)
                                    DamageN7.MoveTo(FinishPositionDamage7,PlayerRot,2.0)
                                    DamageN8.MoveTo(FinishPositionDamage8,PlayerRot,2.0)
                                ExplosiveN1.Explode(Agent)
                                ExplosiveN2.Explode(Agent)
                                ExplosiveN3.Explode(Agent)
                                ExplosiveN4.Explode(Agent)
                                ExplosiveN5.Explode(Agent)
                                ExplosiveN6.Explode(Agent)
                                ExplosiveN7.Explode(Agent)
                                ExplosiveN8.Explode(Agent)

                                AllPlayers := GetPlayspace().GetPlayers()
                                for(Playe : AllPlayers):
                                    if(FortC := Playe.GetFortCharacter[],NAgent := FortC.GetAgent[]):
                                        AudioDeviceIron.Register(NAgent)
                                        AudioDeviceIron.Play(NAgent)
                                if(PropN1.TeleportTo[vector3{X:=0.0,Y:=0.0,Z:=-1392.0},PropN1.GetTransform().Rotation]){}
                                if(PropN2.TeleportTo[vector3{X:=0.0,Y:=0.0,Z:=-1392.0},PropN2.GetTransform().Rotation]){}
                                if(PropN3.TeleportTo[vector3{X:=0.0,Y:=0.0,Z:=-1392.0},PropN3.GetTransform().Rotation]){}
                                if(PropN4.TeleportTo[vector3{X:=0.0,Y:=0.0,Z:=-1392.0},PropN4.GetTransform().Rotation]){}
                                if(PropN5.TeleportTo[vector3{X:=0.0,Y:=0.0,Z:=-1392.0},PropN5.GetTransform().Rotation]){}
                                if(PropN6.TeleportTo[vector3{X:=0.0,Y:=0.0,Z:=-1392.0},PropN6.GetTransform().Rotation]){}
                                if(PropN7.TeleportTo[vector3{X:=0.0,Y:=0.0,Z:=-1392.0},PropN7.GetTransform().Rotation]){}
                                if(PropN8.TeleportTo[vector3{X:=0.0,Y:=0.0,Z:=-1392.0},PropN8.GetTransform().Rotation]){}

                                if(ExplosiveN1.TeleportTo[vector3{X:=0.0,Y:=0.0,Z:=-1392.0},ExplosiveN1.GetTransform().Rotation]){}
                                if(ExplosiveN2.TeleportTo[vector3{X:=0.0,Y:=0.0,Z:=-1392.0},ExplosiveN2.GetTransform().Rotation]){}
                                if(ExplosiveN3.TeleportTo[vector3{X:=0.0,Y:=0.0,Z:=-1392.0},ExplosiveN3.GetTransform().Rotation]){}
                                if(ExplosiveN4.TeleportTo[vector3{X:=0.0,Y:=0.0,Z:=-1392.0},ExplosiveN4.GetTransform().Rotation]){}
                                if(ExplosiveN5.TeleportTo[vector3{X:=0.0,Y:=0.0,Z:=-1392.0},ExplosiveN5.GetTransform().Rotation]){}
                                if(ExplosiveN6.TeleportTo[vector3{X:=0.0,Y:=0.0,Z:=-1392.0},ExplosiveN6.GetTransform().Rotation]){}
                                if(ExplosiveN7.TeleportTo[vector3{X:=0.0,Y:=0.0,Z:=-1392.0},ExplosiveN7.GetTransform().Rotation]){}
                                if(ExplosiveN8.TeleportTo[vector3{X:=0.0,Y:=0.0,Z:=-1392.0},ExplosiveN8.GetTransform().Rotation]){}

                                if(DamageN1.TeleportTo[vector3{X:=0.0,Y:=0.0,Z:=-1392.0},DamageN1.GetTransform().Rotation]){}
                                if(DamageN2.TeleportTo[vector3{X:=0.0,Y:=0.0,Z:=-1392.0},DamageN2.GetTransform().Rotation]){}
                                if(DamageN3.TeleportTo[vector3{X:=0.0,Y:=0.0,Z:=-1392.0},DamageN3.GetTransform().Rotation]){}
                                if(DamageN4.TeleportTo[vector3{X:=0.0,Y:=0.0,Z:=-1392.0},DamageN4.GetTransform().Rotation]){}
                                if(DamageN5.TeleportTo[vector3{X:=0.0,Y:=0.0,Z:=-1392.0},DamageN5.GetTransform().Rotation]){}
                                if(DamageN6.TeleportTo[vector3{X:=0.0,Y:=0.0,Z:=-1392.0},DamageN6.GetTransform().Rotation]){}
                                if(DamageN7.TeleportTo[vector3{X:=0.0,Y:=0.0,Z:=-1392.0},DamageN7.GetTransform().Rotation]){}
                                if(DamageN8.TeleportTo[vector3{X:=0.0,Y:=0.0,Z:=-1392.0},DamageN8.GetTransform().Rotation]){}
                                ExplosiveN1.Reset()
                                ExplosiveN2.Reset()
                                ExplosiveN3.Reset()
                                ExplosiveN4.Reset()
                                ExplosiveN5.Reset()
                                ExplosiveN6.Reset()
                                ExplosiveN7.Reset()
                                ExplosiveN8.Reset()
                            else:
                        else:
                            Print("attitude isnt hostile or agents check failed");
            else:
                Print("failed to get own team or all teams");



