# Everyone Power Transform
# This code creates a remote-activated power that transforms all players in the game when triggered. It includes visual and audio effects, grants items to players, and uses barriers and explosives as pa
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/make-everyone-power?ref=github

using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Game }
using { /Fortnite.com/FortPlayerUtilities }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }


make_everyone_power := class<concrete>(power_class):
    

    @editable
    RemoteItemGranter : item_granter_device = item_granter_device{}

    @editable
    NuggetPowerTimer : timer_device = timer_device{}

    @editable
    NuggetSFX : audio_player_device = audio_player_device{}

    @editable
    NuggetVFX : visual_effect_powerup_device = visual_effect_powerup_device{}

    @editable
    ClearVFXTrigger : trigger_device = trigger_device{}

    @editable
    WhiteBarrier : barrier_device = barrier_device{}

    @editable
    WhiteExplosive : explosive_device = explosive_device{}

    InitializePower<override>(Player: player)<suspends>: void =
        if(FortChar := Player.GetFortCharacter[]):
            CooldownTimer.InitTimer() # called for each power that needs a cooldown
            FortChar.Hide()
            Sleep(0.1)
            FortChar.Show()
            Print("DamageAround: Granting remote")
            RemoteItemGranter.GrantItem(Player)

    ActivatedRemote<override>(Agent : agent)<suspends>:void=
        if:
            Agent = GetAbilityPlayer[]
            IsPowerAvailable() = true
            FortChar := Agent.GetFortCharacter[]
            Location := FortChar.GetTransform()
            FortChar.IsActive[]
            WhiteBarrier.TeleportTo[vector3{X:=-4.0, Y:=28.0, Z:=12.0}, rotation{}]
        then:
            spawn:
                ExplodeReset(Agent)
            WhiteBarrier.Enable()
            spawn:
                TurnEveryoneIntoA()
            NuggetSFX.Play()
            Sleep(0.0)
            NuggetSFX.Play()
            SetPowerAvailable(false)
            # Trigger power
            TriggerPower()
            NuggetPowerTimer.Start(Agent)
            race:
                EndPowerTrigger.TriggeredEvent.Await()
                NuggetPowerTimer.SuccessEvent.Await()
            Sleep(0.0)
            WhiteBarrier.Disable()
            # TurnEveryoneBack()
            EndPowerTrigger.Trigger(Agent)
            Print("DamageAround: Power done running, starting cooldown timer")
            CooldownTimer.StartTimer(10, 0)
            Print("DamageAround: Cooldown timer over")
            SetPowerAvailable(true)
            Print("DamageAround: Power is ready")


    TurnEveryoneIntoA()<suspends>:void=
        PlayersList := GetAllPlayers()
        for (Index -> Agent : PlayersList):
            NuggetVFX.Pickup(Agent)
            Sleep(0.1)
            NuggetVFX.Pickup(Agent)
            Sleep(0.1)
            NuggetVFX.Pickup(Agent)


    ExplodeReset(Agent : agent)<suspends>:void=
        WhiteExplosive.Explode(Agent)
        Sleep(0.0)
        WhiteExplosive.Reset()

    
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
