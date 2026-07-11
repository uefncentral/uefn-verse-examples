# Item Steal Power
# A proximity-based ability system that allows players to steal items from nearby players when activated. The system removes items from the target player's inventory and grants them to the ability user,
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/steal-power?ref=github

using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Game }


steal_loot_tuple := class<concrete>:
    @editable
    ConditionalButton: conditional_button_device = conditional_button_device{}

    @editable
    ItemRemover: item_remover_device = item_remover_device{}

    @editable
    ItemGranter: item_granter_device = item_granter_device{}

    RemoveIfPlayerNotHolding(TargetPlayer : player, AbilityAgent : agent):void=
        loop:
            if (not ConditionalButton.IsHoldingItem[TargetPlayer] and ConditionalButton.HasAllItems[TargetPlayer]):
                ItemRemover.Remove(TargetPlayer)
                ItemGranter.GrantItem(AbilityAgent)
            else:
                break

steal_power := class(power_class):

    @editable
    StealLootNoti : hud_message_device = hud_message_device{}

    @editable
    StealLootTuples: []steal_loot_tuple = array{}

    @editable
    StealCooldownTimer : timer_device = timer_device{}

    @editable
    RemoteItemGranter : item_granter_device = item_granter_device{}

    InitializePower<override>(Player: player)<suspends>: void =
        if(FortChar := Player.GetFortCharacter[]):
            CooldownTimer.InitTimer() # called for each power that needs a cooldown
            FortChar.Hide()
            Sleep(0.1)
            FortChar.Show()
        Print("Steal: Granting remote")
        RemoteItemGranter.GrantItem(Player)

    ActivatedRemote<override>(Agent : agent)<suspends>:void=
        if:
            Agent = GetAbilityPlayer[]
            IsPowerAvailable() = true
            FortChar := Agent.GetFortCharacter[]
        then:
            Print("Steal: Going to steal loot")
            SetPowerAvailable(false)
            # Trigger power
            MaybeNearestPlayer := FindNearestPlayer()
            if (NearestPlayer := MaybeNearestPlayer?):
                RunPowerTrigger.Trigger(NearestPlayer)
                for (StealTuple : StealLootTuples):
                    StealTuple.RemoveIfPlayerNotHolding(NearestPlayer, Agent)
                StealLootNoti.Show(NearestPlayer)
                
            Print("Steal: Power activated, starting cooldown timer")
            # Start cooldown timer
            CooldownTimer.StartTimer(10, 0)
            Print("Steal: Cooldown timer over")
            SetPowerAvailable(true)
            Print("Steal: Power is ready")

    
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
