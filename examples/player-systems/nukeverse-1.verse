# Nuke Drop Device
# Creates a nuclear bomb drop sequence with visual effects, explosions, and cinematic elements. The device teleports a nuke prop above the target area and triggers an explosive sequence with HUD message
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/nukeverse-1?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

AgentMess<localizes>(Agent : agent, Str : string) : message = "{Agent}{Str}"

CustomWinner := class():
    MyAgentObj:agent
    
    var Winner : logic = false

    GetWinner():logic=
        return Winner

    SetWinner(W:logic):void=
        set Winner = W

nuke_device := class(creative_device):

    var PlayersWinMap:[agent]CustomWinner=map{}

    @editable
    Trigger : trigger_device = trigger_device{}

    @editable
    NukeBomb : creative_prop = creative_prop{}

    @editable
    GasTank : creative_prop = creative_prop{}

    @editable
    Hud : hud_message_device = hud_message_device{}

    @editable
    ExplosiveDevice : explosive_device = explosive_device{}

    @editable
    VFXSpawner : vfx_spawner_device = vfx_spawner_device{}

    @editable
    VFXCreator : vfx_creator_device = vfx_creator_device{}

    @editable
    CS : cinematic_sequence_device = cinematic_sequence_device{}

    @editable
    PropManipulator : prop_manipulator_device = prop_manipulator_device{}
    
    OnBegin<override>()<suspends>:void=
        VFXSpawner.Disable()
        VFXCreator.Disable()
        AllPlayers := GetPlayspace().GetPlayers()
        for (Player : AllPlayers):
            if(AnAgent := agent[Player]):
                OnStart(AnAgent)

        NukeTransform := NukeBomb.GetTransform()
        NukePosition := NukeTransform.Translation
        NukeRotation := NukeTransform.Rotation  
        NukePosVector := vector3{X:=NukePosition.X, Y:=NukePosition.Y, Z:=NukePosition.Z+3000.0}
        if (NukeBomb.TeleportTo[NukePosVector, NukeRotation]){}
        if (PropManipulator.TeleportTo[NukePosition, NukeRotation]) {}
        PropManipulator.HideProps()

        NewNukePosVector := vector3{X:=NukePosition.X, Y:=NukePosition.Y, Z:=NukePosition.Z-300.0}
        if (VFXSpawner.TeleportTo[NukePosVector, NukeRotation]) {}
        if (ExplosiveDevice.TeleportTo[NukePosition, NukeRotation]) {}
        if (GasTank.TeleportTo[NukePosition, NukeRotation]) {}

        Agent := Trigger.TriggeredEvent.Await()
        OnTriggered(Agent)


    OnStart(Agent: agent):void=
        if(PlayerExists :=PlayersWinMap[Agent]):
            #do nothing
        else:
            CW:CustomWinner = CustomWinner{MyAgentObj:= Agent}
            option:
                set PlayersWinMap[Agent] = CW

    OnTriggered(Agent : ?agent)<suspends>:void=
        Print("The trigger time")
        if (TheAgent := Agent?, FC := TheAgent.GetFortCharacter[]):
            if (CW:CustomWinner = PlayersWinMap[Agent]):
                CW.SetWinner(true)
            FC.Heal(100.0)
            S:stasis_args = stasis_args{}
            if (S.AllowEmotes = false, S.AllowFalling = false, S.AllowTurning = false):
                FC.PutInStasis(S)
            
            AllPlayers := GetPlayspace().GetPlayers()
            for (Player : AllPlayers):
                if (Agentik := agent[Player]):
                    CS.Play(Agentik)
                    Hud.Show(Agentik, AgentMess(TheAgent, " has dropped the Nuke!"))

            Transform := FC.GetTransform()
            NewNukePos := Transform.Translation
            NewNukeRot := Transform.Rotation  
            NukePosVector := vector3{X:=NewNukePos.X+1000.0, Y:=NewNukePos.Y+100.0, Z:=NewNukePos.Z+3000.0}
            FallingNukePosVector := vector3{X:=NewNukePos.X+1000.0, Y:=NewNukePos.Y+100.0, Z:=NewNukePos.Z+300.0}
            if (NukeBomb.TeleportTo[NukePosVector, NewNukeRot]){}
            if (VFXSpawner.TeleportTo[NukePosVector ,NewNukeRot]) {}
            if (VFXCreator.TeleportTo[FallingNukePosVector, NewNukeRot]) {}
            if (ExplosiveDevice.TeleportTo[FallingNukePosVector, NewNukeRot]) {}
            if (GasTank.TeleportTo[FallingNukePosVector, NewNukeRot]) {}

            PropManipulator.ShowProps()
            VFXSpawner.Enable()
            sync:
                NukeBomb.MoveTo(FallingNukePosVector, NewNukeRot, 3.0)
                VFXSpawner.MoveTo(FallingNukePosVector, NewNukeRot, 3.0)
                VFXStart(TheAgent)
            VFXSpawner.Disable()

            Sleep(4.0)
            for (APlayer : AllPlayers):
                if (AFC := APlayer.GetFortCharacter[]):
                    if (CW:CustomWinner = PlayersWinMap[Agent]):
                        winner_m := CW.GetWinner()
                        if (winner_m = false):
                            AFC.Damage(200.0)


    VFXStart(Agent : agent)<suspends>:void=
        Print("VFX has been started")
        Sleep(2.2)
        VFXCreator.Enable()
        Sleep(0.8)
        ExplosiveDevice.Explode(Agent)    
        PropManipulator.HideProps()
        if (FC := Agent.GetFortCharacter[]):
            FC.ReleaseFromStasis()
        Sleep(3.0)
        VFXCreator.Disable()