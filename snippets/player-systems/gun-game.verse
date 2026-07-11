# Gun Game
# Verse code for Gun Game - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/gun-game?ref=github


using { /Fortnite.com/UI }
using { /Fortnite.com/Game }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }

custom_game_action_causer := class(game_action_causer){}

persistable_agent_data := class<final><persistable>:
    Prestige : int
    WeaponIndex : int
    Speed : int
    Kills : int
    Deaths : int

agent_data := class:
    var Prestige : int = 0
    var WeaponIndex : int = 0
    var Speed : int = 0
    var Kills : int = 0
    var Deaths : int = 0
    var MaybeScreenCanvas : ?canvas = false
    var MaybeKDCanvas : ?canvas = false

var PersistentAgentMap:weak_map(player, persistable_agent_data) = map{}

gun_game_device := class(creative_device):

    @editable
    PlayerSpawners : []player_spawner_device = array{}

    @editable
    MovementModulators : []movement_modulator_device = array{}

    @editable
    WeaponGranter : item_granter_device = item_granter_device{}

    @editable
    AmountOfWeapons : int = 0
    
    TextForUI<localizes>(InText : string) : message = "{InText}"
    TextForUIPlayer<localizes>(InPlayer : player) : message = "{InPlayer}"

    var AgentMap : [agent]agent_data = map{}

    OnBegin<override>()<suspends>:void=
        Print("OnBegin")

        for (Spawner : PlayerSpawners):
            Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

    OnPlayerSpawned(Agent : agent):void=
        if (AgentData := AgentMap[Agent]):
            if (KDCanvas := AgentData.MaybeKDCanvas?, Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
                PlayerUI.RemoveWidget(KDCanvas)

            WeaponGranter.SetNextItem(AgentData.WeaponIndex)
            WeaponGranter.GrantItem(Agent)

        else:
            var bLoadDataSuccess : logic = false
            if (Player := player[Agent]):
                if (PersistableAgentData := PersistentAgentMap[Player]):
                    if (set AgentMap[Agent] = AgentDataPersistentToTmp(PersistableAgentData)):
                        set bLoadDataSuccess = true

            if (bLoadDataSuccess = false):
                if (set AgentMap[Agent] = agent_data{}){}
            
            ScreenCanvas := CreateScreenCanvas()
            KDCanvas := CreateKDCanvas()

            if (Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
                PlayerUI.AddWidget(ScreenCanvas)

            if (AgentData := AgentMap[Agent]):
                set AgentData.MaybeScreenCanvas = option{ ScreenCanvas }
                set AgentData.MaybeKDCanvas = option{ KDCanvas }

                WeaponGranter.SetNextItem(AgentData.WeaponIndex)
                WeaponGranter.GrantItem(Agent)

            UpdateUI(Agent)

            if (FortCharacter := Agent.GetFortCharacter[]):
                FortCharacter.DamagedEvent().Subscribe(OnPlayerDamaged)
                FortCharacter.DamagedShieldEvent().Subscribe(OnPlayerDamaged)
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
        EliminatingAgentData := AgentMap[EliminatingAgent],
        EliminatedAgentData := AgentMap[EliminatedAgent]):
            if (EliminatingAgent = EliminatedAgent):
                return

            if ((EliminatingAgentData.WeaponIndex+1) = AmountOfWeapons):
                set EliminatingAgentData.WeaponIndex = 0
                set EliminatingAgentData.Prestige += 1
            else:
                set EliminatingAgentData.WeaponIndex += 1

            set EliminatingAgentData.Kills += 1
            if (EliminatingAgentData.Speed < MovementModulators.Length):
                set EliminatingAgentData.Speed += 1

            set EliminatedAgentData.Speed = 0
            set EliminatedAgentData.Deaths += 1

            if (EliminatingPlayer := player[EliminatingAgent], EliminatedPlayer := player[EliminatedAgent]):
                if (set PersistentAgentMap[EliminatingPlayer] = AgentDataTmpToPersistent(EliminatingAgentData)){}
                if (set PersistentAgentMap[EliminatedPlayer] = AgentDataTmpToPersistent(EliminatedAgentData)){}

            if (MovementModulator := MovementModulators[EliminatingAgentData.Speed-1]):
                MovementModulator.Activate(EliminatingAgent)

            UpdateUI(EliminatingAgent)
            UpdateUI(EliminatedAgent)
            ShowKD(EliminatedAgent, EliminatingAgent)

            WeaponGranter.SetNextItem(EliminatingAgentData.WeaponIndex)
            WeaponGranter.GrantItem(EliminatingAgent)

    AgentDataPersistentToTmp(PersistableAgentData : persistable_agent_data)<transacts>:agent_data=
        return agent_data
        {
            Prestige := PersistableAgentData.Prestige,
            WeaponIndex := PersistableAgentData.WeaponIndex,
            Speed := PersistableAgentData.Speed,
            Kills := PersistableAgentData.Kills,
            Deaths := PersistableAgentData.Deaths
        }

    AgentDataTmpToPersistent(AgentData : agent_data)<transacts>:persistable_agent_data=
        return persistable_agent_data
        {
            Prestige := AgentData.Prestige,
            WeaponIndex := AgentData.WeaponIndex,
            Speed := AgentData.Speed,
            Kills := AgentData.Kills,
            Deaths := AgentData.Deaths
        }

    CreateScreenCanvas():canvas=
        var CustomCanvasSlots : []canvas_slot = array{}
        Uplift := 96.0

        set CustomCanvasSlots += array
        {
            CanvasSlot0 := canvas_slot:
                Anchors := anchors{ Minimum := vector2{ X := 1.0, Y := 1.0 }, Maximum := vector2{ X := 1.0, Y := 1.0 } }
                Offsets := margin{ Top := -472.0-Uplift, Left := -394.0, Right := 0.0, Bottom := 0.0 }
                Alignment := vector2{ X := 0.0, Y := 0.0 }
                SizeToContent := true
                ZOrder := 1
                Widget := texture_block { DefaultImage := Textures.T_PrestigeUI, DefaultDesiredSize := vector2{ X := 380.0, Y := 95.0 } }
            CanvasSlot1 := canvas_slot:
                Anchors := anchors{ Minimum := vector2{ X := 1.0, Y := 1.0 }, Maximum := vector2{ X := 1.0, Y := 1.0 } }
                Offsets := margin{ Top := -380.0-Uplift, Left := -394.0, Right := 0.0, Bottom := 0.0 }
                Alignment := vector2{ X := 0.0, Y := 0.0 }
                SizeToContent := true
                ZOrder := 1
                Widget := texture_block { DefaultImage := Textures.T_WeaponUI, DefaultDesiredSize := vector2{ X := 380.0, Y := 107.0 } }
            CanvasSlot2 := canvas_slot:
                Anchors := anchors{ Minimum := vector2{ X := 1.0, Y := 1.0 }, Maximum := vector2{ X := 1.0, Y := 1.0 } }
                Offsets := margin{ Top := -270.0-Uplift, Left := -394.0, Right := 0.0, Bottom := 0.0 }
                Alignment := vector2{ X := 0.0, Y := 0.0 }
                SizeToContent := true
                ZOrder := 1
                Widget := texture_block { DefaultImage := Textures.T_SpeedUI, DefaultDesiredSize := vector2{ X := 380.0, Y := 89.0 } }
        }

        set CustomCanvasSlots += array
        {
            CanvasSlot3 := canvas_slot:
                Anchors := anchors{ Minimum := vector2{ X := 1.0, Y := 1.0 }, Maximum := vector2{ X := 1.0, Y := 1.0 } }
                Offsets := margin{ Top := -418.0-Uplift, Left := -285.0, Right := 0.0, Bottom := 0.0 }
                Alignment := vector2{ X := 0.0, Y := 0.5 }
                SizeToContent := true
                ZOrder := 1
                Widget := text_block { DefaultText := TextForUI("Prestige: 0"), DefaultShadowColor := NamedColors.Black,
                DefaultShadowOpacity := 1.0, DefaultShadowOffset := option{ vector2{ X := 2.0, Y := 2.0 }}, DefaultTextColor := NamedColors.White}
            CanvasSlot4 := canvas_slot:
                Anchors := anchors{ Minimum := vector2{ X := 1.0, Y := 1.0 }, Maximum := vector2{ X := 1.0, Y := 1.0 } }
                Offsets := margin{ Top := -318.0-Uplift, Left := -306.0, Right := 0.0, Bottom := 0.0 }
                Alignment := vector2{ X := 0.0, Y := 0.5 }
                SizeToContent := true
                ZOrder := 1
                Widget := text_block { DefaultText := TextForUI("Weapon: 0/0"), DefaultShadowColor := NamedColors.Black,
                DefaultShadowOpacity := 1.0, DefaultShadowOffset := option{ vector2{ X := 2.0, Y := 2.0 }}, DefaultTextColor := NamedColors.White }
            CanvasSlot5 := canvas_slot:
                Anchors := anchors{ Minimum := vector2{ X := 1.0, Y := 1.0 }, Maximum := vector2{ X := 1.0, Y := 1.0 } }
                Offsets := margin{ Top := -224.0-Uplift, Left := -278.0, Right := 0.0, Bottom := 0.0 }
                Alignment := vector2{ X := 0.0, Y := 0.5 }
                SizeToContent := true
                ZOrder := 1
                Widget := text_block { DefaultText := TextForUI("Speed: 0/0"), DefaultShadowColor := NamedColors.Black,
                DefaultShadowOpacity := 1.0, DefaultShadowOffset := option{ vector2{ X := 2.0, Y := 2.0 }}, DefaultTextColor := NamedColors.White}
        }

        CustomCanvas : canvas = canvas:
            Slots := CustomCanvasSlots

        return CustomCanvas

    CreateKDCanvas():canvas=
        var CustomCanvasSlots : []canvas_slot = array{}

        set CustomCanvasSlots += array
        {
            CanvasSlot0 := canvas_slot:
                Anchors := anchors{ Minimum := vector2{ X := 0.0, Y := 0.0 }, Maximum := vector2{ X := 1.0, Y := 1.0 } }
                Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                Alignment := vector2{ X := 0.5, Y := 0.5 }
                SizeToContent := true
                ZOrder := 2
                Widget := texture_block { DefaultImage := Textures.T_EliminatedOverlay }
        }

        set CustomCanvasSlots += array
        {
            CanvasSlot1 := canvas_slot:
                Anchors := anchors{ Minimum := vector2{ X := 0.5, Y := 0.54 }, Maximum := vector2{ X := 0.5, Y := 0.54 } }
                Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                Alignment := vector2{ X := 0.5, Y := 0.5 }
                SizeToContent := true
                ZOrder := 2
                Widget := text_block { DefaultText := TextForUI("PLAYER NAME"), DefaultShadowColor := NamedColors.Black,
                DefaultShadowOpacity := 1.0, DefaultShadowOffset := option{ vector2{ X := 2.0, Y := 2.0 }}, DefaultTextColor := NamedColors.White }
        }

        set CustomCanvasSlots += array
        {
            CanvasSlot2 := canvas_slot:
                Anchors := anchors{ Minimum := vector2{ X := 0.34, Y := 0.875 }, Maximum := vector2{ X := 0.34, Y := 0.875 } }
                Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                Alignment := vector2{ X := 0.5, Y := 0.5 }
                SizeToContent := true
                ZOrder := 2
                Widget := text_block { DefaultText := TextForUI("0"), DefaultShadowColor := NamedColors.Black,
                DefaultShadowOpacity := 1.0, DefaultShadowOffset := option{ vector2{ X := 2.0, Y := 2.0 }}, DefaultTextColor := NamedColors.White }
        }

        set CustomCanvasSlots += array
        {
            CanvasSlot3 := canvas_slot:
                Anchors := anchors{ Minimum := vector2{ X := 0.505, Y := 0.875 }, Maximum := vector2{ X := 0.505, Y := 0.875 } }
                Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                Alignment := vector2{ X := 0.5, Y := 0.5 }
                SizeToContent := true
                ZOrder := 2
                Widget := text_block { DefaultText := TextForUI("0"), DefaultShadowColor := NamedColors.Black,
                DefaultShadowOpacity := 1.0, DefaultShadowOffset := option{ vector2{ X := 2.0, Y := 2.0 }}, DefaultTextColor := NamedColors.White }
        }

        set CustomCanvasSlots += array
        {
            CanvasSlot4 := canvas_slot:
                Anchors := anchors{ Minimum := vector2{ X := 0.658, Y := 0.875 }, Maximum := vector2{ X := 0.658, Y := 0.875 } }
                Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                Alignment := vector2{ X := 0.5, Y := 0.5 }
                SizeToContent := true
                ZOrder := 2
                Widget := text_block { DefaultText := TextForUI("0.0"), DefaultShadowColor := NamedColors.Black,
                DefaultShadowOpacity := 1.0, DefaultShadowOffset := option{ vector2{ X := 2.0, Y := 2.0 }}, DefaultTextColor := NamedColors.White }
        }

        CustomCanvas : canvas = canvas:
            Slots := CustomCanvasSlots

        return CustomCanvas

    UpdateUI(Agent : agent):void=
        if (AgentData := AgentMap[Agent], ScreenCanvas := AgentData.MaybeScreenCanvas?):
            PrestigeTextBlockIndex := 3
            WeaponTextBlockIndex := 4
            SpeedTextBlockIndex := 5

            if (PrestigeTextBlock := text_block[ScreenCanvas.Slots[PrestigeTextBlockIndex].Widget]):
                PrestigeTextBlock.SetText(TextForUI("Prestige: {AgentData.Prestige}"))

            if (WeaponTextBlock := text_block[ScreenCanvas.Slots[WeaponTextBlockIndex].Widget]):
                WeaponTextBlock.SetText(TextForUI("Weapon: {AgentData.WeaponIndex+1}/{AmountOfWeapons}"))

            if (SpeedTextBlock := text_block[ScreenCanvas.Slots[SpeedTextBlockIndex].Widget]):
                SpeedTextBlock.SetText(TextForUI("Speed: {AgentData.Speed}/{MovementModulators.Length}"))

    ShowKD(AgentToShow : agent, EliminatingAgent : agent):void=
        if (EliminatingPlayer := player[EliminatingAgent], EliminatingAgentData := AgentMap[EliminatingAgent],
        AgentToShowData := AgentMap[AgentToShow], KDCanvas := AgentToShowData.MaybeKDCanvas?,
        PlayerToShow := player[AgentToShow], PlayerUI := GetPlayerUI[PlayerToShow]):

            PlayerNameTextBlockIndex := 1
            KillsTextBlockIndex := 2
            DeathsTextBlockIndex := 3
            KDTextBlockIndex := 4

            Deaths : int = if (EliminatingAgentData.Deaths = 0)
            then 1
            else EliminatingAgentData.Deaths

            KDValue := (EliminatingAgentData.Kills * 1.0) / (Deaths * 1.0)
            var KDValueString : string = ""
            if (KDValueInt := Int[KDValue], KDValueFraction1 := Mod[Int[KDValue*10.0], 10],
            KDValueFraction2 := Mod[Int[KDValue*100.0], 10]):
                set KDValueString = "{KDValueInt}.{KDValueFraction1}{KDValueFraction2}"

            if (PlayerNameTextBlock := text_block[KDCanvas.Slots[PlayerNameTextBlockIndex].Widget]):
                PlayerNameTextBlock.SetText(TextForUIPlayer(EliminatingPlayer))

            if (KillsTextBlock := text_block[KDCanvas.Slots[KillsTextBlockIndex].Widget]):
                KillsTextBlock.SetText(TextForUI("{EliminatingAgentData.Kills}"))

            if (DeathsTextBlock := text_block[KDCanvas.Slots[DeathsTextBlockIndex].Widget]):
                DeathsTextBlock.SetText(TextForUI("{EliminatingAgentData.Deaths}"))

            if (KDTextBlock := text_block[KDCanvas.Slots[KDTextBlockIndex].Widget]):
                KDTextBlock.SetText(TextForUI(KDValueString))

            PlayerUI.AddWidget(KDCanvas)