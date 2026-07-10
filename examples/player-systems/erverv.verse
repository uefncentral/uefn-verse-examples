# Player Damage Score System
# This system tracks player damage events and awards escalating scores when players deal damage to other players. It uses spawners to detect when players join, grants random items, and monitors damage e
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/erverv?ref=github


using { /Fortnite.com/Game }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

custom_game_action_causer := class(game_action_causer){}

agent_data := class:
    var ScoreAward : int = 1

one_shot_device := class(creative_device):

    @editable
    PlayerSpawners : []player_spawner_device = array{}

    @editable
    ItemGranter : item_granter_device = item_granter_device{}

    @editable
    ScoreManager : score_manager_device = score_manager_device{}    

    @editable
    MaxScoreAward : int = 5

    var AgentMap : [agent]agent_data = map{}

    OnBegin<override>()<suspends>:void=
        Print("OnBegin")

        for (Spawner : PlayerSpawners):
            Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

    OnPlayerSpawned(Agent : agent):void=
        if (AgentData := AgentMap[Agent]):
            set AgentData.ScoreAward = 1
        else:
            if (set AgentMap[Agent] = agent_data{}){}

            ItemGranter.CycleToRandomItem(Agent)
            if (FortCharacter := Agent.GetFortCharacter[]):
                FortCharacter.DamagedEvent().Subscribe(OnPlayerDamaged)
                FortCharacter.EliminatedEvent().Subscribe(OnPlayerEliminated)

    OnPlayerDamaged(DamageResult : damage_result):void=
        if (DamageSource := custom_game_action_causer[DamageResult.Source?]):
            return

        if (InstigatorFortCharacter := fort_character[DamageResult.Instigator?],
        InstigatorAgent := InstigatorFortCharacter.GetAgent[],
        TargetFortCharacter := fort_character[DamageResult.Target],
        TargetAgent := TargetFortCharacter.GetAgent[]):
            if (TargetAgent = InstigatorAgent):
                return

            if (TargetFortCharacter.GetHealth() > 0.0):
                CustomGameActionCauser := custom_game_action_causer{}

                DamageArgs := damage_args{ Instigator := DamageResult.Instigator,
                Source := option{CustomGameActionCauser}, Amount := TargetFortCharacter.GetMaxHealth() }
                TargetFortCharacter.Damage(DamageArgs)

    OnPlayerEliminated(EliminationResult : elimination_result):void=
        if (EliminatingFortCharacter := EliminationResult.EliminatingCharacter?,
        EliminatingAgent := EliminatingFortCharacter.GetAgent[],
        EliminatedAgent := EliminationResult.EliminatedCharacter.GetAgent[],
        EliminatingAgentData := AgentMap[EliminatingAgent]):
            if (EliminatingAgent = EliminatedAgent):
                return

            ScoreManager.SetScoreAward(EliminatingAgentData.ScoreAward)
            ScoreManager.Activate(EliminatingAgent)

            if (EliminatingAgentData.ScoreAward < MaxScoreAward):
                set EliminatingAgentData.ScoreAward += 1

            ItemGranter.CycleToRandomItem(EliminatingAgent)