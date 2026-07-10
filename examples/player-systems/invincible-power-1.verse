# Invincible Sleep Power
# Creates a sleep-based invincibility power system where players can activate a temporary invincible state. When activated, it plays audio/visual effects, shows a bed prop, and grants the player invinci
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/invincible-power-1?ref=github

using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Game }


invincible_power := class<concrete>(power_class):

    @editable
    SleepAudio : audio_player_device = audio_player_device{}

    @editable
    SleepVFX : vfx_spawner_device = vfx_spawner_device{}

    @editable
    BedProp : creative_prop = creative_prop{}

    @editable
    ItemsMover : creative_prop = creative_prop{}

    @editable
    PlayerReference : player_reference_device = player_reference_device{}

    @editable
    HealthStopTrigger : trigger_device = trigger_device{}

    @editable
    HealthRegen : health_powerup_device = health_powerup_device{}

    @editable
    PopUp : popup_dialog_device = popup_dialog_device{}
    
    @editable
    InvincibleDurationTimer : timer_device = timer_device{}

    @editable
    RemoteItemGranter : item_granter_device = item_granter_device{}

    InitializePower<override>(Player: player)<suspends>: void =
        if(FortChar := Player.GetFortCharacter[]):
            CooldownTimer.InitTimer() # called for each power that needs a cooldown
            FortChar.Hide()
            Sleep(0.1)
            FortChar.Show()
            Sleep(0.0)
            Print("Initiating invincible")
            Print("Granting remote")
            RemoteItemGranter.GrantItem(Player)
            PlayerReference.Register(Player)


    ActivatedRemote<override>(Agent : agent)<suspends>:void=
        if:
            Agent = GetAbilityPlayer[]
            IsPowerAvailable() = true
            FortChar := Agent.GetFortCharacter[]
        then:
            SleepAudio.Play()
            SleepVFX.Enable()
            BedProp.Show()
            PlayerReference.Enable()
            Location := FortChar.GetTransform()
            Print("Going to make player invincible")
            SetPowerAvailable(false)
            MovePropToSelf(ItemsMover)
            FortChar.Hide()
            FortChar.SetVulnerability(false)
            HealthRegen.Pickup(Agent)
            InvincibleDurationTimer.Start(Agent)
            PopUp.Show(Agent)
            race:
                PopUp.RespondingButtonEvent.Await()
                InvincibleDurationTimer.SuccessEvent.Await()
            SleepAudio.Stop()
            SleepVFX.Disable()
            BedProp.Hide()
            PlayerReference.Disable()
            InvincibleDurationTimer.Complete(Agent)
            HealthStopTrigger.Trigger(Agent)
            PopUp.Hide(Agent)
            FortChar.SetVulnerability(true)
            FortChar.Show()
            Print("Made invincible player vulnerable again, starting cooldown timer")
            # Start cooldown timer
            CooldownTimer.StartTimer(15, 0)
            Print("Invincible cooldown timer over")
            SetPowerAvailable(true)
            Print("Invincible power is ready")

    
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
