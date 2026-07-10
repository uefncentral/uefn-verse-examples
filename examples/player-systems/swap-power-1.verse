# Player Position Swap Power
# Creates a special ability that allows a player to instantly swap positions with the nearest enemy player. The power includes a cooldown timer to prevent spam usage and grants a remote item to activate
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/swap-power-1?ref=github

using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Game }


swap_power := class<concrete>(power_class):


    @editable
    SwapCooldownTimer : timer_device = timer_device{}

    @editable
    RemoteItemGranter : item_granter_device = item_granter_device{}

    @editable
    MyTeleporter : teleporter_device = teleporter_device{}

    @editable
    EnemyTeleporter : teleporter_device = teleporter_device{}

    InitializePower<override>(Player: player)<suspends>: void =
        if(FortChar := Player.GetFortCharacter[]):
            CooldownTimer.InitTimer() # called for each power that needs a cooldown
            FortChar.Hide()
            Sleep(0.1)
            FortChar.Show()
        RemoteItemGranter.GrantItem(Player)

    ActivatedRemote<override>(Agent : agent)<suspends>:void=
        if:
            Agent = GetAbilityPlayer[]
            IsPowerAvailable() = true
            FortChar := Agent.GetFortCharacter[]
        then:
            Print("SwapPower: Going to start power")
            SetPowerAvailable(false)
            # Trigger power
            MaybeNearestPlayer := FindNearestPlayer()
            Print("SwapPower : after FindNearestPlayer")
            if:
                NearestPlayer := MaybeNearestPlayer?
                Location := FortChar.GetTransform()
                EnemyFortChar := NearestPlayer.GetFortCharacter[]
                EnemyLocation := EnemyFortChar.GetTransform()
                EnemyAgent := agent [NearestPlayer]
            then:
                TriggerPower()
                RunPowerTrigger.Trigger(NearestPlayer)
                if(MyTeleporter.TeleportTo[EnemyLocation]):
                    Print("Teleported my teleporter")
                    MyTeleporter.Teleport(Agent)
                if (EnemyTeleporter.TeleportTo[Location]):
                    Print("Teleported enemy teleporter")
                    EnemyTeleporter.Teleport(NearestPlayer)
            # Start cooldown timer
            CooldownTimer.StartTimer(10, 0)
            Print("SwapPower: Cooldown timer over")
            SetPowerAvailable(true)
            Print("SwapPower: Power is ready")
    

    PlayerEliminated<override>(EliminationResult : elimination_result):void=
        if:
            Player := GetAbilityPlayer[]
            FortChar := Player.GetFortCharacter[]
            FortChar = EliminationResult.EliminatedCharacter
        then:
            DeathAudio.Play(Player)
            spawn:
                EliminationVFX()



    EliminationVFX()<suspends>:void=
        ElimVFX.Enable()
        Sleep(2.0)
        ElimVFX.Disable()
