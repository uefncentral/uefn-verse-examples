# Sword Power Enhancement
# Creates a special sword power-up system that grants a pickle sword item with visual effects and 10x damage amplification. When players pick up the sword, they receive enhanced damage capabilities alon
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/one-shot-power-1?ref=github

using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Game }

one_shot_power := class<concrete>(power_class):

    @editable
    VFXClearTriggerHead : trigger_device = trigger_device{}

    @editable
    VFXClearTrigger : trigger_device = trigger_device{}

    @editable
    PickleSwordGranter : item_granter_device = item_granter_device{}

    @editable
    PickleSwordConditional : conditional_button_device = conditional_button_device{}

    @editable
    SwordVFX : visual_effect_powerup_device = visual_effect_powerup_device{}

    @editable
    DrakeHeadVFX : visual_effect_powerup_device = visual_effect_powerup_device{}

    @editable
    DamageAmp : damage_amplifier_powerup_device = damage_amplifier_powerup_device{}

    @editable
    DrakeSFX : audio_player_device = audio_player_device{}

    var HoldingSword : logic = false



    InitializePower<override>(Player: player)<suspends>: void =
        if(FortChar := Player.GetFortCharacter[]):
            Print("power started putin")
            FortChar.Hide()
            Sleep(0.1)
            FortChar.Show()
            DrakeHeadVFX.Pickup(Player)
            Sleep(0.0)
            SwordVFX.Pickup(Player)
            Sleep(0.1)
            DrakeHeadVFX.Pickup(Player)
            Sleep(0.0)
            PickleSwordGranter.GrantItem(Player)
            SwordHolding(Player)

    

    SwordHolding(Agent : agent)<suspends>:void=
        SubscribeToDeath()
        DamageAmp.SetMagnitude(10.0)
        race:
            loop:
                if (PickleSwordConditional.IsHoldingItem[Agent], HoldingSword = false):
                    Print("Picking Up VFX")
                    DamageAmp.Pickup(Agent)
                    SwordVFX.SetDuration(99999.0)
                    SwordVFX.Pickup(Agent)
                    Sleep(0.1)
                    SwordVFX.Pickup(Agent)
                    set HoldingSword = true
                Sleep(0.01)

            loop:
                if (not PickleSwordConditional.IsHoldingItem[Agent], HoldingSword = true):
                    Print("Clearing VFX")
                    VFXClearTrigger.Trigger(Agent)
                    set HoldingSword = false
                Sleep(0.01)


    PlayAudio(Result : elimination_result) : void=
        if:
            FortChar := Result.EliminatingCharacter?
            DrakeSFX.TeleportTo[FortChar.GetTransform()]
        then:
            Print("playing audio")
            DrakeSFX.Play()

    SubscribeToDeath()<suspends>:void=
        PlayersList := GetAllPlayers()
        for (Index -> Agent : PlayersList):
            if:
                FortChar := Agent.GetFortCharacter[]
            then:
                Print("subscribed to death")
                FortChar.EliminatedEvent().Subscribe(PlayAudio)
            

    
    PlayerEliminated<override>(EliminationResult : elimination_result):void=
        if:
            Player := GetAbilityPlayer[]
            FortChar := Player.GetFortCharacter[]
            FortChar = EliminationResult.EliminatedCharacter
        then:
            VFXClearTriggerHead.Trigger(Player)
            VFXClearTrigger.Trigger(Player)
            DeathAudio.Play(Player)
            spawn:
                EliminationVFX()



    EliminationVFX()<suspends>:void=
        ElimVFX.Enable()
        Sleep(2.0)
        ElimVFX.Disable()
