# Hulk Transformation System
# Creates a Hulk-like superpower transformation for players that includes special abilities, visual effects, audio feedback, and explosive contact damage. Players can activate the transformation through
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/hulk-superpower?ref=github


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

Hulk_superpower := class(creative_device):

    @editable Hudmessage : hud_message_device = hud_message_device{}
    @editable RemoteRemover : item_remover_device = item_remover_device{}
    @editable HulkSpeed : float = 0.0
    @editable HulkProp : creative_prop = creative_prop{}
    @editable HulkSound : audio_player_device = audio_player_device{}
    @editable HulkDMG : damage_volume_device = damage_volume_device{}
    @editable Killfeed : elimination_feed_device = elimination_feed_device {}


    var EndExploding : logic = false
    @editable HulkExplodeVFX : vfx_spawner_device = vfx_spawner_device{}
    @editable HulkContactExplosive : explosive_device = explosive_device{}
    @editable HulkConstantExplosive : explosive_device = explosive_device{}
    @editable HulkContactSound : audio_player_device = audio_player_device{}

    @editable Remote : signal_remote_manager_device = signal_remote_manager_device{}
    @editable ItemGranter : item_granter_device = item_granter_device{}
    @editable ConditionalButton : conditional_button_device = conditional_button_device{}

    OnBegin<override>()<suspends>:void=

        ConditionalButton.ActivatedEvent.Subscribe(Start)
        Remote.PrimarySignalEvent.Subscribe(HulkPower)
    HulkPower(Agent : agent):void=
        spawn{HulkPower2(Agent)}
    Start(Agent : agent):void=
        Killfeed.Activate(Agent);
        RemoteRemover.Remove(Agent)
        ItemGranter.GrantItem(Agent)
        Hudmessage.Show(Agent)


    HulkPower2(Agent:agent)<suspends> : void=
        if(Player := player[Agent],FC:=Player.GetFortCharacter[]):
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
                                    PlayerRot := FC.GetTransform().Rotation
                                    PlayerPos := FC.GetTransform().Translation
                                    PlayerForward := FC.GetViewRotation().GetLocalForward() * 300.0
                                    HulkFinishLocation := FC.GetViewRotation().GetLocalForward() * 30000.0
                                    FinishPos := PlayerPos + HulkFinishLocation
                                    SpawnPos := PlayerPos + PlayerForward
                                    HulkHandRota := HulkProp.GetTransform().Rotation
                                    AllPlayers := GetPlayspace().GetPlayers()
                                    for(Playe : AllPlayers):
                                        if(FortC := Playe.GetFortCharacter[],NAgent := FortC.GetAgent[]):
                                            HulkSound.Register(NAgent)
                                            HulkSound.Play(NAgent)
                                    if(HulkConstantExplosive.TeleportTo[SpawnPos,PlayerRot]){}
                                    if(HulkProp.TeleportTo[SpawnPos,PlayerRot]){}
                                    if(HulkDMG.TeleportTo[SpawnPos,PlayerRot]){}
                                    if(HulkExplodeVFX.TeleportTo[SpawnPos,PlayerRot]){}
                                    spawn:
                                        ExplodingHulk(Agent)
                                    spawn:
                                        HulkExplodeVFX.MoveTo(FinishPos,PlayerRot,HulkSpeed)
                                    spawn:
                                        HulkConstantExplosive.MoveTo(FinishPos,PlayerRot,HulkSpeed)
                                    spawn:
                                        HulkDMG.MoveTo(FinishPos,PlayerRot,HulkSpeed)
                                    spawn:
                                        HulkProp.MoveTo(FinishPos,PlayerRot,HulkSpeed)
                                else:
                            else:
                                Print("attitude isnt hostile or agents check failed");
                else:
                    Print("failed to get own team or all teams");


    ExplodingHulk(Agent:agent)<suspends> : void=
        HulkDMG.AgentEntersEvent.Subscribe(HandleHulkHitPlayer)
        set EndExploding = false
        spawn:
            ExplodeTimer()
        loop:
            Sleep(0.0)
            HulkExplodeVFX.Enable()
            HulkExplodeVFX.Disable()
            HulkConstantExplosive.Explode(Agent)
            HulkConstantExplosive.Reset()

            if(EndExploding = true):
                break


    ExplodeTimer()<suspends>: void=
        Sleep(HulkSpeed)
        set EndExploding = true

    HandleHulkHitPlayer(Agent:agent) : void=
        spawn:
            HulkHitPlayer(Agent)
    HulkHitPlayer(Agent:agent)<suspends>: void=
        if(HulkContactExplosive.TeleportTo[HulkProp.GetTransform().Translation,HulkProp.GetTransform().Rotation]):
            HulkContactExplosive.Explode(Agent)
            HulkContactExplosive.Reset()
        if(HulkExplodeVFX.TeleportTo[HulkProp.GetTransform().Translation,HulkProp.GetTransform().Rotation]):
            HulkExplodeVFX.Enable()
        AllPlayers := GetPlayspace().GetPlayers()
        for(Playe : AllPlayers):
            if(FortC := Playe.GetFortCharacter[],NAgent := FortC.GetAgent[]):
                HulkContactSound.Register(NAgent)
                HulkContactSound.Play(NAgent)
        Sleep(0.1)
        HulkExplodeVFX.Disable()
        if(HulkContactExplosive.TeleportTo[vector3{X:= 10000.0, Y:=10000.0, Z:= -10000.0},HulkContactExplosive.GetTransform().Rotation]){}
        if(HulkProp.TeleportTo[vector3{X:= 10000.0, Y:=10000.0, Z:= -10000.0},HulkProp.GetTransform().Rotation]){}
        if(HulkDMG.TeleportTo[vector3{X:= 10000.0, Y:=10000.0, Z:= -10000.0},HulkDMG.GetTransform().Rotation]){}
            
