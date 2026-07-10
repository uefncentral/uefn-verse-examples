# Player Pull Power
# Creates a combat ability that pulls damaged opponents toward the attacker's location with visual effects. When a player damages an enemy, it triggers a teleportation effect that moves the victim close
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/pull-power?ref=github


using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Game }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

pull_power := class(power_class):

    @editable
    PullVFX : vfx_spawner_device = vfx_spawner_device{}

    @editable
    PullMovementModulator : movement_modulator_device = movement_modulator_device{}

    var PullCooldown : float = 0.0


    InitializePower<override>(Player: player)<suspends>: void =
        if(FortChar := Player.GetFortCharacter[]):
            FortChar.Hide()
            Sleep(0.1)
            FortChar.Show()

    DamagedPlayer<override>(AgentDoingDamage : agent, AgentReceivingDamage : agent, Amount : float, Source : ?game_action_causer)<suspends>:void=
        # I damaged the player, let's put them in stasis, then set a cooldown of CooldownTimer
        if:
            AgentDoingDamage = GetAbilityPlayer[]
            EnemyFortChar := AgentReceivingDamage.GetFortCharacter[]
            EnemyLocation := EnemyFortChar.GetTransform()
            FortChar := AgentDoingDamage.GetFortCharacter[]
            Location := FortChar.GetTransform()
            IsPowerAvailable() = true
        then:
            SetPowerAvailable(false)
            PullVFX.Enable()
            spawn:
                FollowFX(PullVFX, AgentReceivingDamage, 0.1)
            Print("Pull: Activating power")
            RunPowerTrigger.Trigger(AgentReceivingDamage)
            PullOpponent(AgentReceivingDamage, Location)
            SetPowerAvailable(true)
            Sleep(2.0)
            PullVFX.Disable()
            # spawn:
            #     ResetPowerStatus()

    PullOpponent(EnemyAgent : agent, AgentLocation : transform): void=
        NewRotation := AgentLocation.Rotation.ApplyYaw(3.14)
        Location := AgentLocation.Translation
        if (PullMovementModulator.TeleportTo[PullMovementModulator.GetTransform().Translation, NewRotation]):
            Print("Pull: Rotated movement modulator")
            PullMovementModulator.Activate(EnemyAgent)

    
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
