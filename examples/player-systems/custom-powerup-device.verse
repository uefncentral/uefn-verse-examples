# Damage Amplifier Powerup
# Creates a powerup system that amplifies player damage by a configurable multiplier when they collect a visual effect powerup. Players who pick up the powerup deal significantly more damage to other pl
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/custom-powerup-device?ref=github


using { /Fortnite.com/Game }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

custom_game_action_causer := class(game_action_causer){}

custom_powerup_device := class(creative_device):

    @editable
    VisualEffectPowerUpDevice : visual_effect_powerup_device = visual_effect_powerup_device{}

    @editable
    DamageAmplify : float = 10.0

    var PoweredUpAgents : []agent = array{}

    OnBegin<override>()<suspends>:void=
        Print("OnBegin")

        for (Player : GetPlayspace().GetPlayers()):
            OnPlayerJoined(Player)

        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerJoined)
        VisualEffectPowerUpDevice.ItemPickedUpEvent.Subscribe(OnPowerUpPicked)

    OnPlayerJoined(Player : player):void=
        if (FortCharacter := Player.GetFortCharacter[]):
            FortCharacter.DamagedEvent().Subscribe(OnPlayerDamaged)

    OnPlayerDamaged(DamageResult : damage_result):void=
        if (DamageSource := custom_game_action_causer[DamageResult.Source?]):
            return

        if (InstigatorFortCharacter := fort_character[DamageResult.Instigator?],
        InstigatorAgent := InstigatorFortCharacter.GetAgent[],
        PoweredUpAgents.Find[InstigatorAgent],
        TargetFortCharacter := fort_character[DamageResult.Target],
        TargetFortCharacter.GetHealth() > 0.0):

            TotalDamage : float = DamageResult.Amount * DamageAmplify
            DamageToSend : float = TotalDamage - DamageResult.Amount

            CustomGameActionCauser := custom_game_action_causer{}
            DamageArgs := damage_args { Instigator := DamageResult.Instigator,
            Source := option{ CustomGameActionCauser }, Amount := DamageToSend }
            TargetFortCharacter.Damage(DamageArgs)

    OnPowerUpPicked(Agent : agent):void=
        if (PoweredUpAgents.Find[Agent]){}
        else:
            set PoweredUpAgents += array{ Agent }
            spawn { AsyncPowerUpDisable(VisualEffectPowerUpDevice.GetDuration(), Agent) }

    AsyncPowerUpDisable(SleepTime : float, Agent : agent)<suspends>:void=
        Sleep(SleepTime)
        if (NewArray := PoweredUpAgents.RemoveFirstElement[Agent]):
            set PoweredUpAgents = NewArray