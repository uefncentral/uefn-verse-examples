# Gold Button Purchase System
# A class-based purchasing system where players can buy and activate golden buttons using in-game currency. The system checks player eligibility, required switches, and manages button visibility and mov
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/gold-button-device?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

gold_button_device := class(creative_device):

    var CustomPlayers : [player]custom_player = map{}
    var NbMoney : int = 0
    var LaClasse : int = 0
    
    @editable
    Amount : int = 0

    @editable
    Button_To_Move : creative_prop = creative_prop{}

    @editable
    Zone_To_Activate : mutator_zone_device = mutator_zone_device{}

    @editable
    Switch_To_Activate : switch_device = switch_device{}

    @editable
    Score : score_manager_device = score_manager_device{}

    @editable
    Required_Switch : []switch_device = array{}

    @editable
    Player_Class : int = 0

    @editable
    Claim_Zone : class_and_team_selector_device = class_and_team_selector_device{}

    @editable
    button_start_Position : float = 400.0

    @editable
    button_end_position : float = 0.0

    @editable
    Item_start_Position : float = 400.0

    @editable
    Item_end_position : float = 0.0

    @editable
    base_item : creative_prop = creative_prop{}

    @editable
    item_to_move : creative_prop = creative_prop{}

    @editable
    Audio_error : audio_player_device = audio_player_device{}

    @editable
    Btn_Check_Amount : switch_device = switch_device{}

    OnBegin<override>()<suspends>:void=
        HidePrincipalButton()
        HideButtonItem()

        Claim_Zone.ClassSwitchedEvent.Subscribe(OnZoneClaim)
        Zone_To_Activate.AgentEntersEvent.Subscribe(OnZoneActivated)

        for (lSwitch: Required_Switch) :
            lSwitch.TurnedOnEvent.Subscribe(OnSwitchRequiredOn)

        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerLeftServer)

    OnSwitchRequiredOn(pAgent : agent) : void=
        ShowButtonPrincipal(pAgent)

    OnZoneActivated(pAgent : agent) : void=
        CheckSwitchToActivate(pAgent)

    OnZoneClaim(pAgent : agent) : void=
        if (lPlayer := player[pAgent]) :
            if (lExisting := CustomPlayers[lPlayer]) :
                Print("player exist")
            else :
                Print("player new")
                CustomPlayer := custom_player{Player := lPlayer}
                CustomPlayer.SetClass(Player_Class)

                if (set CustomPlayers[lPlayer] = CustomPlayer) {}

        if (Required_Switch.Length = 0) :
            ShowButtonPrincipal(pAgent)
        else:
            HidePrincipalButton()

    ShowButtonPrincipal(pAgent : agent) : void=
        ShowItems(Button_To_Move, button_end_position)

    HidePrincipalButton() : void=
        Switch_To_Activate.Disable()
        HideItems(Button_To_Move, button_start_Position)

    HideButtonItem() : void=
        HideItems(item_to_move, Item_start_Position)

    ShowButtonItem() : void=
        ShowItems(item_to_move, Item_end_position)

    CheckSwitchToActivate(pAgent : agent) : void=
        set NbMoney = Score.GetCurrentScore(pAgent)
        Print("Montant du joueur : {NbMoney}")
        Print("Montant requis :{Amount}")
        if (NbMoney >= Amount) :
            Print("J'active le bouton")
            Switch_To_Activate.Enable()
            Switch_To_Activate.TurnOn(pAgent)

            Score.SetScoreAward(Amount * -1)
            Score.Activate(pAgent)

            set NbMoney = Score.GetCurrentScore(pAgent)
            Print("Montant du joueur2 : {NbMoney}")

            HidePrincipalButton()
            ShowButtonItem()

            Btn_Check_Amount.ToggleState(pAgent)
        else:
            Audio_error.Play(pAgent)

    ShowItems(item_to_show : creative_prop, pEndPosition : float) : void=
        if (# item_to_show.IsValid[]  # TODO: use type cast (e.g., player[Agent]?) instead) :
            BasePosition := base_item.GetTransform().Translation
            WallPosition := item_to_show.GetTransform().Translation + vector3{Z := (BasePosition.Z - item_to_show.GetTransform().Translation.Z)} + vector3{Z := pEndPosition}

            Scale := 1.0
            Trans := transform{Rotation := item_to_show.GetTransform().Rotation, Translation := WallPosition, Scale := vector3 {X := Scale, Y := Scale, Z := Scale}}

            spawn:
                item_to_show.MoveTo(Trans, 2.0)

    HideItems(item_to_hide : creative_prop, pStartPosition : float) : void=
        if (# item_to_hide.IsValid[]  # TODO: use type cast (e.g., player[Agent]?) instead) :
            BasePosition := base_item.GetTransform().Translation
            WallPosition := item_to_hide.GetTransform().Translation - vector3{Z := (BasePosition.Z - item_to_hide.GetTransform().Translation.Z)} - vector3{Z := pStartPosition}

            Scale := 1.0
            Trans := transform{Rotation := item_to_hide.GetTransform().Rotation, Translation := WallPosition, Scale := vector3 {X := Scale, Y := Scale, Z := Scale}}

            spawn:
                item_to_hide.MoveTo(Trans, 1.0)

    OnPlayerLeftServer(pPlayerLeaving : player) : void=
        if (Existing := CustomPlayers[pPlayerLeaving]) :
            set LaClasse = Existing.GetClass()
            if (LaClasse = Player_Class) :
                HidePrincipalButton()
                HideButtonItem()

            # Remove the player from our map to free up memory
            var NewCustomPlayerMap : [player]custom_player = map{}

            for (Key -> Value : CustomPlayers, Key <> pPlayerLeaving):
                set NewCustomPlayerMap = ConcatenateMaps( NewCustomPlayerMap, map{Key => Value})

            set CustomPlayers = NewCustomPlayerMap
    