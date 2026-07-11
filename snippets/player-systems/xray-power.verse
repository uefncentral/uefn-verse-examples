# X-Ray Vision Power
# Creates an x-ray vision power that allows players to see other players through walls using VFX effects. When activated, it spawns visual effects that follow other players and makes them visible throug
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/xray-power?ref=github


using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Game }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }


xray_power := class<concrete>(power_class):

    @editable
    VFXSpawners : []vfx_spawner_device = array{}

    var ActivePlayersMap : [player]logic = map{}

    var PlayerToVFXMap : [player]vfx_spawner_device = map{}

    TimeBetweenXrayRefresh : float = 0.01

    XrayFollow(Player : player)<suspends>:void=
        loop:
            Sleep(TimeBetweenXrayRefresh)
            if:
                FortChar := Player.GetFortCharacter[]
                ActivePlayersMap[Player] = true
                VFXSpawner := PlayerToVFXMap[Player]
                VFXSpawner.TeleportTo[FortChar.GetTransform()]
            then:
                if (not ActivePlayersMap[Player] or not FortChar.IsActive[]):
                    VFXSpawner.Disable()
                    break
                else:
                    VFXSpawner.Enable()

    InitializePower<override>(Player: player)<suspends>: void =
        if(FortChar := Player.GetFortCharacter[]):
            FortChar.Hide()
            Sleep(0.1)
            FortChar.Show()
        PlayersList := GetAllPlayers()
        for (Index -> Agent : PlayersList, Agent <> Player):
            if:
                FortChar := Agent.GetFortCharacter[]
                set ActivePlayersMap[Agent] = true
                VFXSpawner := VFXSpawners[Index]
                set PlayerToVFXMap[Agent] = VFXSpawner
            then:
                Print("Going to follow player")
                spawn:
                    XrayFollow(Agent)

    PlayerEliminated<override>(EliminationResult : elimination_result):void=
        Print("XRay: Player eliminated")
        EliminatedFortChar := EliminationResult.EliminatedCharacter
        if:
            Player := player[EliminatedFortChar]
            VFXSpawner := PlayerToVFXMap[Player]
            set ActivePlayersMap[Player] = false
        then:
            Print("Removing VFXSpawner")
            VFXSpawner.Disable()
            DeathAudio.Play(Player)


    PlayerLeftServer<override>(Player : player):void=
        Print("XRay: Player left server")
        if:
            VFXSpawner := PlayerToVFXMap[Player]
            set ActivePlayersMap[Player] = false
        then:
            Print("XRay: Removing VFXSpawner")
            VFXSpawner.Disable()
