# Class-Based Money Management System
# A game management system that tracks players across different classes and manages a money/scoring economy with tier-based rewards. Players can select from 4 different classes and earn money through zo
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/game-manager-device-1?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

game_manager_device := class(creative_device):

    var CustomPlayers : [player]custom_player = map{}
    var NbItem : int = 0
    var NbScore : int = 0
    var LaClasse : int = 0

    UITextBillboard<localizes>(pValue : int) : message = "${pValue}"

    @editable
    spawner : []player_spawner_device = array{}

    @editable
    selecteur_classe1 : class_and_team_selector_device = class_and_team_selector_device{}

    @editable
    selecteur_classe2 : class_and_team_selector_device = class_and_team_selector_device{}
    
    @editable
    selecteur_classe3 : class_and_team_selector_device = class_and_team_selector_device{}

    @editable
    selecteur_classe4 : class_and_team_selector_device = class_and_team_selector_device{}


    @editable
    score : score_manager_device = score_manager_device{}

    @editable
    billboard : []billboard_device = array{}

    @editable
    zone_give_money : []mutator_zone_device = array{}

    @editable
    Btn_Check_Amount : switch_device = switch_device{}

    @editable
    switch_free : []switch_device = array{}

    @editable
    switch_more8 : []switch_device = array{}

    @editable
    switch_more15 : []switch_device = array{}

    @editable
    switch_more30 : []switch_device = array{}

    @editable
    switch_more150 : []switch_device = array{}

    @editable
    switch_more1000 : []switch_device = array{}

    @editable
    switch_more5000 : []switch_device = array{}

    @editable
    switch_more100000 : []switch_device = array{}

    @editable
    switch_more10000000 : []switch_device = array{}


    OnBegin<override>()<suspends>:void=
        for (lSpawner : spawner) :
            lSpawner.SpawnedEvent.Subscribe(OnSpawnedEvent)

        for (lZone : zone_give_money) :
            lZone.AgentEntersEvent.Subscribe(OnPlayerWantMoney)

        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerLeftServer)

        selecteur_classe1.ClassSwitchedEvent.Subscribe(OnClass1Changed)
        selecteur_classe2.ClassSwitchedEvent.Subscribe(OnClass2Changed)
        selecteur_classe3.ClassSwitchedEvent.Subscribe(OnClass3Changed)
        selecteur_classe4.ClassSwitchedEvent.Subscribe(OnClass4Changed)

        Btn_Check_Amount.TurnedOnEvent.Subscribe(RefreshMoney)
        Btn_Check_Amount.TurnedOffEvent.Subscribe(RefreshMoney)
    

        for (lSwitch : switch_free) :
            lSwitch.TurnedOnEvent.Subscribe(OnSwitchFreeTurnedOn)
    
        for (lSwitch : switch_more8) :
            lSwitch.TurnedOnEvent.Subscribe(OnSwitchMore8TurnedOn)

        for (lSwitch : switch_more15) :
           lSwitch.TurnedOnEvent.Subscribe(OnSwitchMore15TurnedOn)

        for (lSwitch : switch_more30) :
            lSwitch.TurnedOnEvent.Subscribe(OnSwitchMore30TurnedOn)

        for (lSwitch : switch_more150) :
            lSwitch.TurnedOnEvent.Subscribe(OnSwitchMore150TurnedOn)

        for (lSwitch : switch_more1000) :
            lSwitch.TurnedOnEvent.Subscribe(OnSwitchMore1000TurnedOn)

        for (lSwitch : switch_more5000) :
            lSwitch.TurnedOnEvent.Subscribe(OnSwitchMore5000TurnedOn)

        for (lSwitch : switch_more100000) :
            lSwitch.TurnedOnEvent.Subscribe(OnSwitchMore100000TurnedOn)
            
        for (lSwitch : switch_more10000000) :
            lSwitch.TurnedOnEvent.Subscribe(OnSwitchMore10000000TurnedOn)    


    OnSwitchFreeTurnedOn(pAgent : agent) : void=
        if (lPlayer := player[pAgent]) :
            if (lExisting := CustomPlayers[lPlayer]) :
                lExisting.SetMoneyToAdd(1)


    OnSwitchMore8TurnedOn(pAgent : agent) : void=
        if (lPlayer := player[pAgent]) :
            if (lExisting := CustomPlayers[lPlayer]) :
                lExisting.SetMoneyToAdd(lExisting.GetMoneyToAdd() + 5)

    OnSwitchMore15TurnedOn(pAgent : agent) : void=
        if (lPlayer := player[pAgent]) :
            if (lExisting := CustomPlayers[lPlayer]) :
                lExisting.SetMoneyToAdd(lExisting.GetMoneyToAdd() + 10)

    OnSwitchMore30TurnedOn(pAgent : agent) : void=
        if (lPlayer := player[pAgent]) :
            if (lExisting := CustomPlayers[lPlayer]) :
                lExisting.SetMoneyToAdd(lExisting.GetMoneyToAdd() + 30)

    OnSwitchMore150TurnedOn(pAgent : agent) : void=
        if (lPlayer := player[pAgent]) :
            if (lExisting := CustomPlayers[lPlayer]) :
                lExisting.SetMoneyToAdd(lExisting.GetMoneyToAdd() + 150)

    OnSwitchMore1000TurnedOn(pAgent : agent) : void=
        if (lPlayer := player[pAgent]) :
            if (lExisting := CustomPlayers[lPlayer]) :
                lExisting.SetMoneyToAdd(lExisting.GetMoneyToAdd() + 1000)

    OnSwitchMore5000TurnedOn(pAgent : agent) : void=
        if (lPlayer := player[pAgent]) :
            if (lExisting := CustomPlayers[lPlayer]) :
                lExisting.SetMoneyToAdd(lExisting.GetMoneyToAdd() + 5000)
                
    OnSwitchMore100000TurnedOn(pAgent : agent) : void=
        if (lPlayer := player[pAgent]) :
            if (lExisting := CustomPlayers[lPlayer]) :
                lExisting.SetMoneyToAdd(lExisting.GetMoneyToAdd() + 100000)
                
    OnSwitchMore10000000TurnedOn(pAgent : agent) : void=
        if (lPlayer := player[pAgent]) :
            if (lExisting := CustomPlayers[lPlayer]) :
                lExisting.SetMoneyToAdd(lExisting.GetMoneyToAdd() + 10000000)            


    RefreshMoney(pAgent : agent) : void=
        if (lPlayer := player[pAgent]) :
            if (lExisting := CustomPlayers[lPlayer]) :
                set NbItem = score.GetCurrentScore(pAgent)
                lExisting.SetUIPlayerMoney(NbItem)

    OnClass1Changed(pAgent : agent) : void=
        ChangePlayerClass(pAgent, 0)

    OnClass2Changed(pAgent : agent) : void=
        ChangePlayerClass(pAgent, 1)

    OnClass3Changed(pAgent : agent) : void=
        ChangePlayerClass(pAgent, 2)

    OnClass4Changed(pAgent : agent) : void=
        ChangePlayerClass(pAgent, 3)

    ChangePlayerClass(pAgent : agent, pClass : int) : void=
        if (lPlayer := player[pAgent]) :
            if (lExisting := CustomPlayers[lPlayer]) :
                lExisting.SetClass(pClass)

                spawn:
                    UpdateMoney(pAgent) 

    OnSpawnedEvent(pAgent : agent) : void=
        if (lPlayer := player[pAgent]) :
            if (lExisting := CustomPlayers[lPlayer]) :
                Print("player exist")
            else :
                Print("player new")

                CustomPlayer := custom_player{Player := lPlayer}
                CustomPlayer.Init()

                if (set CustomPlayers[lPlayer] = CustomPlayer) {}

    UpdateMoney(pAgent : agent)<suspends> : void=
        if (lPlayer := player[pAgent]) :
            if (lExisting := CustomPlayers[lPlayer]) :
                lExisting.SetPlayerMoney(lExisting.GetPlayerMoney() + lExisting.GetMoneyToAdd())

                set LaClasse = lExisting.GetClass()

                if (lBillboard := billboard[LaClasse]) :
                    lBillboard.SetText(UITextBillboard(lExisting.GetPlayerMoney()))

                spawn:
                    SetUpdateMoney(pAgent)

    SetUpdateMoney(pAgent : agent)<suspends> : void=
        if (lPlayer := player[pAgent]) :
            if (lExisting := CustomPlayers[lPlayer]) :
                Sleep(1.2)
                spawn:
                    UpdateMoney(pAgent)

    OnPlayerWantMoney(pAgent : agent) : void=
        Print("Je suis le bon joueur dans la zone")
        if (lPlayer := player[pAgent]) :
            if (lExisting := CustomPlayers[lPlayer]) :
                set NbItem = lExisting.GetPlayerMoney()

                score.SetScoreAward(NbItem)
                score.Activate(pAgent)

                set NbScore = score.GetCurrentScore(pAgent)

                lExisting.SetUIPlayerMoney(NbScore)

                lExisting.SetPlayerMoney(0)

                set LaClasse = lExisting.GetClass()

                if (lBillboard := billboard[LaClasse]) :
                    lBillboard.SetText(UITextBillboard(0))

    OnPlayerLeftServer(pPlayerLeaving : player) : void=
        if (Existing := CustomPlayers[pPlayerLeaving]) :
            set LaClasse = Existing.GetClass()

            if (lBillboard := billboard[LaClasse]) :
                lBillboard.SetText(UITextBillboard(0))

            # Remove the player from our map to free up memory
            var NewCustomPlayerMap : [player]custom_player = map{}

            for (Key -> Value : CustomPlayers, Key <> pPlayerLeaving):
                set NewCustomPlayerMap = ConcatenateMaps( NewCustomPlayerMap, map{Key => Value})

            set CustomPlayers = NewCustomPlayerMap    