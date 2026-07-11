# Battle Pass System
# A complete battle pass progression system with free and premium reward tiers. Players earn experience to level up and unlock rewards, with persistent data saving to track progress, claimed rewards, an
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/battlepass-main-device-1?ref=github

using {/Verse.org/Simulation}
using {/Verse.org/Assets}
using {/Verse.org/Colors}
using {/Verse.org/Random}
using {/Fortnite.com/Game}
using {/Fortnite.com/Characters}
using {/Fortnite.com/Devices}
using {/Fortnite.com/UI}
using {/Fortnite.com/Vehicles}
using {/Fortnite.com/FortPlayerUtilities}
using {/Fortnite.com/Devices/CreativeAnimation}
using {/Fortnite.com/Devices/CreativeAnimation/InterpolationTypes}
using {/UnrealEngine.com/Temporary/SpatialMath}
using {/UnrealEngine.com/Temporary/UI}
using {Textures}

CBPModule<public> := module:

    # NOTE(FROZENPAWN): YOU NEED TO FILL THESE TWO ARRAYS
    # WITH THE TEXTURES TO MATCH YOUR REWARDS.
    FreeRewardTextures<public> : []texture = array
    {
        Textures.T_FreeReward_0,
        Textures.T_FreeReward_1,
        Textures.T_FreeReward_2,
        Textures.T_FreeReward_3,
        Textures.T_FreeReward_4,
        Textures.T_FreeReward_5,
        Textures.T_FreeReward_6,
        Textures.T_FreeReward_7,
        Textures.T_FreeReward_8,
        Textures.T_FreeReward_9
    }

    PremiumRewardTextures<public> : []texture = array
    {
        Textures.T_PremiumReward_0,
        Textures.T_PremiumReward_1,
        Textures.T_PremiumReward_2,
        Textures.T_PremiumReward_3,
        Textures.T_PremiumReward_4,
        Textures.T_PremiumReward_5,
        Textures.T_PremiumReward_6,
        Textures.T_PremiumReward_7,
        Textures.T_PremiumReward_8,
        Textures.T_PremiumReward_9
    }

    var BPPlayerSavedData<public> : weak_map(player, bp_player_save_data) = map{}

    TextForUI<public><localizes>(InText : string) : message = "{InText}"

    bp_player_save_data<public> := class<final><persistable>:
        Level<public> : int
        Experience<public> : float
        bHasPremiumTicket<public> : logic
        UnlockedFreeGiftIndexes<public> : []int
        UnlockedPremiumGiftIndexes<public> : []int
        ClaimedFreeGiftIndexes<public> : []int
        ClaimedPremiumGiftIndexes<public> : []int

    bp_agent_data<public> := class:
        var Level<public> : int = 0
        var Experience<public> : float = 0.0
        var bHasPremiumTicket<public> : logic = false
        var UnlockedFreeGiftIndexes<public> : []int = array{}
        var UnlockedPremiumGiftIndexes<public> : []int = array{}
        var ClaimedFreeGiftIndexes<public> : []int = array{}
        var ClaimedPremiumGiftIndexes<public> : []int = array{}
        var BPCanvas<public> : canvas = canvas{}
        var BPData<public> : bp_data = bp_data{}


    bp_free_claim_button<public> := class:
        Index<public> : int
        BPDevice<public> : custom_bp_manager
        OnClaimButtonClicked<public>(Message : widget_message) : void =

            BaseSliderCount : int = 5
            if(Agent := Message.Player.GetFortCharacter[].GetAgent[], AgentData := BPDevice.BPAgentMap[Agent], Player := player[Agent]):
                if(FoundIndex := AgentData.UnlockedFreeGiftIndexes.Find[Index + (AgentData.BPData.PageIndex * BaseSliderCount)]):
                    if(ClaimedIndex := AgentData.ClaimedFreeGiftIndexes.Find[Index + (AgentData.BPData.PageIndex * BaseSliderCount)]){}
                    else:
                        if(NewArr := AgentData.ClaimedFreeGiftIndexes.Insert[AgentData.ClaimedFreeGiftIndexes.Length, array{Index + (AgentData.BPData.PageIndex * BaseSliderCount)}]):
                            set AgentData.ClaimedFreeGiftIndexes = NewArr

                        if(Trigger := BPDevice.BPFreeRewardTriggers[Index + (BaseSliderCount*AgentData.BPData.PageIndex)]):
                            Trigger.Trigger(Agent)

                        BPDevice.UpdateBattlePassHUD(Agent)

                        if(SavedData := BPPlayerSavedData[Player]):
                            if(set BPPlayerSavedData[Player] = bp_player_save_data{Level := AgentData.Level,
                                                                                    Experience := AgentData.Experience,
                                                                                    bHasPremiumTicket := AgentData.bHasPremiumTicket,
                                                                                    UnlockedFreeGiftIndexes := AgentData.UnlockedFreeGiftIndexes,
                                                                                    UnlockedPremiumGiftIndexes := AgentData.UnlockedPremiumGiftIndexes,
                                                                                    ClaimedFreeGiftIndexes := AgentData.ClaimedFreeGiftIndexes,
                                                                                    ClaimedPremiumGiftIndexes := AgentData.ClaimedPremiumGiftIndexes}){}

    bp_premium_claim_button<public> := class:
        Index<public> : int
        BPDevice<public> : custom_bp_manager
        OnClaimButtonClicked<public>(Message : widget_message) : void =

            BaseSliderCount : int = 5
            if(Agent := Message.Player.GetFortCharacter[].GetAgent[], AgentData := BPDevice.BPAgentMap[Agent], Player := player[Agent]):
                if(FoundIndex := AgentData.UnlockedPremiumGiftIndexes.Find[Index + (AgentData.BPData.PageIndex * BaseSliderCount)]):
                    if(ClaimedIndex := AgentData.ClaimedPremiumGiftIndexes.Find[Index + (AgentData.BPData.PageIndex * BaseSliderCount)]){}
                    else:
                        if(NewArr := AgentData.ClaimedPremiumGiftIndexes.Insert[AgentData.ClaimedPremiumGiftIndexes.Length, array{Index + (AgentData.BPData.PageIndex * BaseSliderCount)}]):
                            set AgentData.ClaimedPremiumGiftIndexes = NewArr

                        if(Trigger := BPDevice.BPPremiumRewardTriggers[Index + (BaseSliderCount*AgentData.BPData.PageIndex)]):
                            Trigger.Trigger(Agent)


                        BPDevice.UpdateBattlePassHUD(Agent)

                        if(SavedData := BPPlayerSavedData[Player]):
                            if(set BPPlayerSavedData[Player] = bp_player_save_data{Level := AgentData.Level,
                                                                                    Experience := AgentData.Experience,
                                                                                    bHasPremiumTicket := AgentData.bHasPremiumTicket,
                                                                                    UnlockedFreeGiftIndexes := AgentData.UnlockedFreeGiftIndexes,
                                                                                    UnlockedPremiumGiftIndexes := AgentData.UnlockedPremiumGiftIndexes,
                                                                                    ClaimedFreeGiftIndexes := AgentData.ClaimedFreeGiftIndexes,
                                                                                    ClaimedPremiumGiftIndexes := AgentData.ClaimedPremiumGiftIndexes}){}

    bp_data<public> := class:
        var PageIndex<public> : int = 0

    bp_reward_data<public> := class<concrete>:
        @editable
        FreeRewardTrigger<public> : trigger_device = trigger_device{}

        @editable
        PremiumRewardTrigger<public> : trigger_device = trigger_device{}

        @editable
        RewardTargetXPAmount<public> : type {_X:float where 0.0 <= _X } = 0.0

    bp_xp_granter<public> := class<concrete>:
        @editable
        BPXpGranterTrigger<public> : trigger_device = trigger_device{}

        @editable
        BPXPAmount<public> : float = 0.0

        var BPManagerOpt<public> : ?custom_bp_manager = false

        Init<public>(BPManager : custom_bp_manager) : void =
            set BPManagerOpt = option{BPManager}    
            BPXpGranterTrigger.TriggeredEvent.Subscribe(OnXPGrantTriggered)

        OnXPGrantTriggered<public>(Agent : ?agent) : void =
            if(MaybeAgent := Agent?):
                OnXPGrantRecursion(MaybeAgent, BPXPAmount)

        OnXPGrantRecursion(Agent : agent, Amount : float) : void = 
            if(BPM := BPManagerOpt?, AgentData := BPM.BPAgentMap[Agent], Player := player[Agent]):
                set AgentData.Experience += Amount
                if(SavedData := BPPlayerSavedData[Player]):
                    if(set BPPlayerSavedData[Player] = bp_player_save_data{Level := AgentData.Level,
                                                                            Experience := AgentData.Experience,
                                                                            bHasPremiumTicket := AgentData.bHasPremiumTicket,
                                                                            UnlockedFreeGiftIndexes := AgentData.UnlockedFreeGiftIndexes,
                                                                            UnlockedPremiumGiftIndexes := AgentData.UnlockedPremiumGiftIndexes,
                                                                            ClaimedFreeGiftIndexes := AgentData.ClaimedFreeGiftIndexes,
                                                                            ClaimedPremiumGiftIndexes := AgentData.ClaimedPremiumGiftIndexes}){}

                if(TargetXPAmount := BPM.BPLevelTargetXPAmounts[AgentData.Level]):
                    if(AgentData.Experience >= TargetXPAmount):
                        if(NewArr := AgentData.UnlockedFreeGiftIndexes.Insert[AgentData.UnlockedFreeGiftIndexes.Length, array{AgentData.Level}]):
                            set AgentData.UnlockedFreeGiftIndexes = NewArr

                        if(AgentData.bHasPremiumTicket = true):
                            if(NewArr := AgentData.UnlockedPremiumGiftIndexes.Insert[AgentData.UnlockedPremiumGiftIndexes.Length, array{AgentData.Level}]):
                                set AgentData.UnlockedPremiumGiftIndexes = NewArr

                        RemainingXP : float = AgentData.Experience - TargetXPAmount
                        set AgentData.Experience = 0.0
                        set AgentData.Level = Clamp(AgentData.Level + 1, 0, BPM.BPLevelTargetXPAmounts.Length)
                        if(SavedData := BPPlayerSavedData[Player]):
                            if(set BPPlayerSavedData[Player] = bp_player_save_data{Level := AgentData.Level,
                                                                                   Experience := AgentData.Experience,
                                                                                   bHasPremiumTicket := AgentData.bHasPremiumTicket,
                                                                                   UnlockedFreeGiftIndexes := AgentData.UnlockedFreeGiftIndexes,
                                                                                   UnlockedPremiumGiftIndexes := AgentData.UnlockedPremiumGiftIndexes,
                                                                                   ClaimedFreeGiftIndexes := AgentData.ClaimedFreeGiftIndexes,
                                                                                   ClaimedPremiumGiftIndexes := AgentData.ClaimedPremiumGiftIndexes}){}

                        if(RemainingXP > 0.0):
                            OnXPGrantRecursion(Agent, RemainingXP)

    custom_bp_manager<public> := class(creative_device):

        @editable
        SpawnPads<public> : []player_spawner_device = array{}

        @editable
        Rewards<public> : []bp_reward_data = array{}

        @editable
        BPXPGranters<public> : []bp_xp_granter = array{}

        @editable
        ShowBPHUDTrigger<public> : trigger_device = trigger_device{}

        @editable
        HideBPHUDTrigger<public> : trigger_device = trigger_device{}
        
        @editable
        BPPremiumTicketBuyButtonClickedTrigger<public> : trigger_device = trigger_device{}

        @editable
        BPPremiumTicketBuySuccessTrigger<public> : trigger_device = trigger_device{}

        var BPFreeRewardTriggers<public> : []trigger_device = array{}
        var BPPremiumRewardTriggers<public> : []trigger_device = array{}
        var BPLevelTargetXPAmounts<public> : []float = array{}

        var BPAgentMap<public> : [agent]bp_agent_data = map{}

        OnBegin<override>() : void =
            Print("BP Manager Begin")

            for(SpawnPad : SpawnPads):
                SpawnPad.SpawnedEvent.Subscribe(OnPlayerSpawned)                

            for(BPXPGranter : BPXPGranters):
                BPXPGranter.Init(Self)

            for (Reward : Rewards):
                set BPFreeRewardTriggers += array{ Reward.FreeRewardTrigger }
                set BPPremiumRewardTriggers += array{ Reward.PremiumRewardTrigger }
                set BPLevelTargetXPAmounts += array{ Reward.RewardTargetXPAmount }

            ShowBPHUDTrigger.TriggeredEvent.Subscribe(OnShowBPHUDTriggerCalled)
            BPPremiumTicketBuySuccessTrigger.TriggeredEvent.Subscribe(OnBPPremiumTicketBuySuccessCalled)
            HideBPHUDTrigger.TriggeredEvent.Subscribe(OnHideBPHUDTriggerCalled)

        OnPlayerSpawned<public>(Agent : agent) : void =
            Print("Player Spawned")
            if(AgentData := BPAgentMap[Agent]){}
            else:
                var NewAgentData : bp_agent_data = bp_agent_data{}

                set NewAgentData.BPCanvas = CreateBPHUD()

                if(Player := player[Agent]):
                    if(SavedData := BPPlayerSavedData[Player]):
                        set NewAgentData.Level = SavedData.Level
                        set NewAgentData.Experience = SavedData.Experience
                        set NewAgentData.bHasPremiumTicket = SavedData.bHasPremiumTicket
                        set NewAgentData.UnlockedFreeGiftIndexes = SavedData.UnlockedFreeGiftIndexes
                        set NewAgentData.UnlockedPremiumGiftIndexes = SavedData.UnlockedPremiumGiftIndexes
                        set NewAgentData.ClaimedFreeGiftIndexes = SavedData.ClaimedFreeGiftIndexes
                        set NewAgentData.ClaimedPremiumGiftIndexes = SavedData.ClaimedPremiumGiftIndexes
                    else:
                        if(set BPPlayerSavedData[Player] = bp_player_save_data{Level := NewAgentData.Level,
                                                                                Experience := NewAgentData.Experience,
                                                                                bHasPremiumTicket := NewAgentData.bHasPremiumTicket,
                                                                                UnlockedFreeGiftIndexes := NewAgentData.UnlockedFreeGiftIndexes,
                                                                                UnlockedPremiumGiftIndexes := NewAgentData.UnlockedPremiumGiftIndexes,
                                                                                ClaimedFreeGiftIndexes := NewAgentData.ClaimedFreeGiftIndexes,
                                                                                ClaimedPremiumGiftIndexes := NewAgentData.ClaimedPremiumGiftIndexes}){}

                if(set BPAgentMap[Agent] = NewAgentData){}


        OnBPPremiumTicketBuySuccessCalled<public>(Agent : ?agent) : void =
            if(MaybeAgent := Agent?, AgentData := BPAgentMap[MaybeAgent], Player := player[MaybeAgent], PlayerUI := GetPlayerUI[Player]):
                if(AgentData.bHasPremiumTicket = false):
                    set AgentData.bHasPremiumTicket = true
                    if(AgentData.Level > 0):
                        for(I:=0..AgentData.Level-1):
                            if(NewArr := AgentData.UnlockedPremiumGiftIndexes.Insert[AgentData.UnlockedPremiumGiftIndexes.Length, array{I}]):
                                set AgentData.UnlockedPremiumGiftIndexes = NewArr
                    if(SavedData := BPPlayerSavedData[Player]):
                        if(set BPPlayerSavedData[Player] = bp_player_save_data{Level := AgentData.Level,
                                                                                Experience := AgentData.Experience,
                                                                                bHasPremiumTicket := AgentData.bHasPremiumTicket,
                                                                                UnlockedFreeGiftIndexes := AgentData.UnlockedFreeGiftIndexes,
                                                                                UnlockedPremiumGiftIndexes := AgentData.UnlockedPremiumGiftIndexes,
                                                                                ClaimedFreeGiftIndexes := AgentData.ClaimedFreeGiftIndexes,
                                                                                ClaimedPremiumGiftIndexes := AgentData.ClaimedPremiumGiftIndexes}){}
                    UpdateBattlePassHUD(MaybeAgent)

        OnShowBPHUDTriggerCalled<public>(Agent : ?agent) : void =
            if(MaybeAgent := Agent?, AgentData := BPAgentMap[MaybeAgent], Player := player[MaybeAgent], PlayerUI := GetPlayerUI[Player]):
                UpdateBattlePassHUD(MaybeAgent)
                PlayerUI.AddWidget(AgentData.BPCanvas, player_ui_slot{InputMode := ui_input_mode.All})

        OnHideBPHUDTriggerCalled<public>(Agent : ?agent) : void =
            if(MaybeAgent := Agent?, AgentData := BPAgentMap[MaybeAgent], Player := player[MaybeAgent], PlayerUI := GetPlayerUI[Player]):
                PlayerUI.RemoveWidget(AgentData.BPCanvas)
                set AgentData.BPData.PageIndex = 0

        OnPlayerLeft<public>(Agent : agent) : void =
            Print("Player Left")
            if(AgentData := BPAgentMap[Agent]):

                var NewAgentMap : [agent]bp_agent_data = map{}
                for(Key -> Value : BPAgentMap, Key <> Agent):
                    set NewAgentMap = ConcatenateMaps(NewAgentMap, map{Key => Value})
                    set BPAgentMap = NewAgentMap 
            

        CreateFreeRewardCanvas<public>(Index : int) : canvas =
            LockedTextTex : texture = Textures.T_LockedText
            LockedIconTex : texture = T_LockedUI
            LockedFreeButtonTex : texture = Textures.T_FreeRewardButtonLocked
            LockedFreeRewardBG : texture = Textures.T_LockedFreeRewardItemBG
            DefaultRewardTex : texture = Textures.T_FreeReward_0 
            FreeRewardButton : button_quiet = button_quiet{DefaultText := TextForUI("                 ")}

            FreeRewardButton.OnClick().Subscribe(bp_free_claim_button{Index := Index, BPDevice := Self}.OnClaimButtonClicked)

            ResultCanvas := canvas:
                Slots := array:
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= 0.0, Left:= 0.0, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        ZOrder := 1
                        Widget := texture_block{DefaultImage := LockedFreeRewardBG, DefaultDesiredSize := vector2{X:=165.0,Y:=164.0}}
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= 0.0, Left:= 0.0, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        ZOrder := 2
                        Widget := texture_block{DefaultImage := DefaultRewardTex, DefaultDesiredSize := vector2{X:=150.0,Y:=120.0}}
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=1.0, Y:=0.0}, Maximum := vector2{X:=1.0,Y:=0.0}}
                        Offsets := margin{Top:= -20.0, Left:= 14.666664, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=1.0, Y:=0.0}
                        ZOrder := 3
                        Widget := texture_block{DefaultImage := LockedIconTex, DefaultDesiredSize := vector2{X:=80.666664,Y:=63.333332}}
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=1.0}, Maximum := vector2{X:=0.5, Y:=1.0}}
                        Offsets := margin{Top:= 65.0, Left:= 0.0, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=1.0}
                        ZOrder := 1
                        Widget := texture_block{DefaultImage := LockedFreeButtonTex, DefaultDesiredSize := vector2{X:=188.571426,Y:=58.285717}}
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=1.0}, Maximum := vector2{X:=0.5, Y:=1.0}}
                        Offsets := margin{Top:= 59.0, Left:= 0.0, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=1.0}
                        ZOrder := 2
                        Widget := texture_block{DefaultImage := LockedTextTex, DefaultDesiredSize := vector2{X:=127.0,Y:=45.0}}
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=1.0}, Maximum := vector2{X:=0.5, Y:=1.0}}
                        Offsets := margin{Top:= 65.0, Left:= 0.0, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=1.0}
                        SizeToContent := true
                        ZOrder := 2
                        Widget := FreeRewardButton

            return ResultCanvas


        CreatePremiumRewardCanvas<public>(Index : int) : canvas =
            LockedTextTex : texture = Textures.T_LockedText
            LockedIconTex : texture = T_LockedUI
            LockedPremiumButtonTex : texture = Textures.T_PremiumButtonLocked
            LockedPremiumRewardBG : texture = Textures.T_LockedPremiumRewardItemBG
            DefaultRewardTex : texture = Textures.T_FreeReward_0 
            PremiumRewardButton : button_quiet = button_quiet{DefaultText := TextForUI("                 ")}

            PremiumRewardButton.OnClick().Subscribe(bp_premium_claim_button{Index := Index, BPDevice := Self}.OnClaimButtonClicked)

            ResultCanvas := canvas:
                Slots := array:
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= 0.0, Left:= 0.0, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        ZOrder := 1
                        Widget := texture_block{DefaultImage := LockedPremiumRewardBG, DefaultDesiredSize := vector2{X:=165.0,Y:=164.0}}
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= 0.0, Left:= 0.0, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        ZOrder := 2
                        Widget := texture_block{DefaultImage := DefaultRewardTex, DefaultDesiredSize := vector2{X:=150.0,Y:=120.0}}
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=1.0, Y:=0.0}, Maximum := vector2{X:=1.0,Y:=0.0}}
                        Offsets := margin{Top:= -20.0, Left:= 14.666664, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=1.0, Y:=0.0}
                        ZOrder := 3
                        Widget := texture_block{DefaultImage := LockedIconTex, DefaultDesiredSize := vector2{X:=80.666664,Y:=63.333332}}
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=1.0}, Maximum := vector2{X:=0.5, Y:=1.0}}
                        Offsets := margin{Top:= 65.0, Left:= 0.0, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=1.0}
                        ZOrder := 1
                        Widget := texture_block{DefaultImage := LockedPremiumButtonTex, DefaultDesiredSize := vector2{X:=188.571426,Y:=58.285717}}
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=1.0}, Maximum := vector2{X:=0.5, Y:=1.0}}
                        Offsets := margin{Top:= 59.0, Left:= 0.0, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=1.0}
                        ZOrder := 2
                        Widget := texture_block{DefaultImage := LockedTextTex, DefaultDesiredSize := vector2{X:=127.0,Y:=45.0}}
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=1.0}, Maximum := vector2{X:=0.5, Y:=1.0}}
                        Offsets := margin{Top:= 65.0, Left:= 0.0, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=1.0}
                        SizeToContent := true
                        ZOrder := 2
                        Widget := PremiumRewardButton

            return ResultCanvas


        CreateSliderBarCanvas<public>() : canvas =
            SliderBarBG : texture = Textures.T_SliderBG
            SliderBarFG : texture = Textures.T_SliderFG

            ResultCanvas := canvas:
                Slots := array:
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= 0.0, Left:= -74.75, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.0, Y:=0.5}
                        Widget := texture_block{DefaultImage := SliderBarBG, DefaultDesiredSize := vector2{X:=149.5,Y:=22.0}}
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= 0.0, Left:= -74.75, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.0, Y:=0.5}
                        Widget := texture_block{DefaultImage := SliderBarFG, DefaultDesiredSize := vector2{X:=0.0,Y:=14.0}}

            return ResultCanvas

        CreateBPHUD<public>() : canvas =
            LockedIconTex : texture = T_LockedUI
            UnlockedIconTex : texture = T_UnlockedUI
            DefaultRewardTex : texture = Textures.T_FreeReward_0 
            BPBGTex : texture = Textures.T_BP_BG
            SliderBarBG : texture = Textures.T_SliderBG
            SliderBarFG : texture = Textures.T_SliderFG
            UnlockedItemIndexNode : texture = Textures.T_UnlockedLevelNode
            LockedItemIndexNode : texture = Textures.T_LockedLevelNode
            UnlockedFreeRewardBG : texture = Textures.T_UnlockedFreeRewardItemBG
            LockedFreeRewardBG : texture = Textures.T_LockedFreeRewardItemBG
            UnlockedPremiumRewardBG : texture = Textures.T_UnlockedPremiumRewardItemBG
            LockedPremiumRewardBG : texture = Textures.T_LockedPremiumRewardItemBG
            ClaimedTextTex : texture = Textures.T_ClaimedText
            ClaimTextTex : texture = Textures.T_ClaimText
            LockedTextTex : texture = Textures.T_LockedText
            UnlockedFreeButtonTex : texture = Textures.T_FreeRewardButtonUnlocked
            LockedFreeButtonTex : texture = Textures.T_FreeRewardButtonLocked
            UnlockedPremiumButtonTex : texture = Textures.T_PremiumButtonUnlocked
            LockedPremiumButtonTex : texture = Textures.T_PremiumButtonLocked
            FreeRewardSectionTex : texture = Textures.T_FreeRewardSection
            PremiumRewardSectionTex : texture = Textures.T_PremiumSection
            BuyPremiumButtonTex : texture = Textures.T_BuyPremiumButton
            LeftPageButtonTex : texture = Textures.T_LeftPageButton
            RightPageButtonTex : texture = Textures.T_RightPageButton

            BuyPremiumButton : button_quiet = button_quiet{DefaultText := TextForUI("                        ")}
            QuitButton : button_quiet = button_quiet{DefaultText := TextForUI("             \n             \n             \n             \n")}
            LeftPageButton : button_quiet = button_quiet{DefaultText := TextForUI("        \n        \n        \n        \n        \n        \n        \n        \n")}
            RightPageButton : button_quiet = button_quiet{DefaultText := TextForUI("        \n        \n        \n        \n        \n        \n        \n        \n")}

            BuyPremiumButton.OnClick().Subscribe(OnBuyPremiumButtonClicked)
            QuitButton.OnClick().Subscribe(OnQuitButtonClicked)
            LeftPageButton.OnClick().Subscribe(OnLeftPageButtonClicked)
            RightPageButton.OnClick().Subscribe(OnRightPageButtonClicked)
            
            ResultCanvas := canvas:
                Slots := array:
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= 0.0, Left:= 0.0, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        ZOrder := 0
                        Widget := texture_block{DefaultImage := BPBGTex, DefaultDesiredSize := vector2{X:=1686.300049,Y:=1011.450012}}
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= -140.0, Left:= -568.0, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        Widget := texture_block{DefaultImage := FreeRewardSectionTex, DefaultDesiredSize := vector2{X:=308.0,Y:=252.0}}
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= 228.0, Left:= -568.0, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        Widget := texture_block{DefaultImage := PremiumRewardSectionTex, DefaultDesiredSize := vector2{X:=308.0,Y:=244.0}}
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= 20.0, Left:= -784.0, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        Widget := texture_block{DefaultImage := LeftPageButtonTex, DefaultDesiredSize := vector2{X:=109.0,Y:=256.0}}
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= 20.0, Left:= 784.0, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        Widget := texture_block{DefaultImage := RightPageButtonTex, DefaultDesiredSize := vector2{X:=109.0,Y:=256.0}}
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= 36.0, Left:= -359.0, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        SizeToContent := true
                        Widget := CreateSliderBarCanvas()
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= 36.0, Left:= -148.3, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        SizeToContent := true
                        Widget := CreateSliderBarCanvas()
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= 36.0, Left:= 62.0, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        SizeToContent := true
                        Widget := CreateSliderBarCanvas()
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= 36.0, Left:= 273.0, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        SizeToContent := true
                        Widget := CreateSliderBarCanvas()
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= 36.0, Left:= 483.0, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        SizeToContent := true
                        Widget := CreateSliderBarCanvas()
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= 36.0, Left:= -254.0, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        Widget := texture_block{DefaultImage := LockedItemIndexNode, DefaultDesiredSize := vector2{X:=67.68,Y:=67.68}}
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= 36.0, Left:= -43.5, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        Widget := texture_block{DefaultImage := LockedItemIndexNode, DefaultDesiredSize := vector2{X:=67.68,Y:=67.68}}
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= 36.0, Left:= 167.0, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        Widget := texture_block{DefaultImage := LockedItemIndexNode, DefaultDesiredSize := vector2{X:=67.68,Y:=67.68}}
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= 36.0, Left:= 377.5, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        Widget := texture_block{DefaultImage := LockedItemIndexNode, DefaultDesiredSize := vector2{X:=67.68,Y:=67.68}}
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= 36.0, Left:= 588.0, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        Widget := texture_block{DefaultImage := LockedItemIndexNode, DefaultDesiredSize := vector2{X:=67.68,Y:=67.68}}                    
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= 33.0, Left:= -568.0, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        Widget := texture_block{DefaultImage := BuyPremiumButtonTex, DefaultDesiredSize := vector2{X:=252.0,Y:=72.0}}
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= 36.0, Left:= -254.0, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        SizeToContent := true
                        Widget := text_block{DefaultText := TextForUI("1"), DefaultTextColor := MakeColorFromSRGB(0.0, 0.0, 0.0),DefaultJustification := text_justification.Center}
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= 36.0, Left:= -43.5, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        SizeToContent := true
                        Widget := text_block{DefaultText := TextForUI("2"), DefaultTextColor := MakeColorFromSRGB(0.0, 0.0, 0.0),DefaultJustification := text_justification.Center}
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= 36.0, Left:= 167.0, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        SizeToContent := true
                        Widget := text_block{DefaultText := TextForUI("3"), DefaultTextColor := MakeColorFromSRGB(0.0, 0.0, 0.0),DefaultJustification := text_justification.Center}
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= 36.0, Left:= 377.5, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        SizeToContent := true
                        Widget := text_block{DefaultText := TextForUI("4"), DefaultTextColor := MakeColorFromSRGB(0.0, 0.0, 0.0),DefaultJustification := text_justification.Center}
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= 36.0, Left:= 588.0, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        SizeToContent := true
                        Widget := text_block{DefaultText := TextForUI("5"), DefaultTextColor := MakeColorFromSRGB(0.0, 0.0, 0.0),DefaultJustification := text_justification.Center}
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= -160.0, Left:= -254.0, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        SizeToContent := true
                        ZOrder := 1
                        Widget := CreateFreeRewardCanvas(0)
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= -160.0, Left:= -43.5, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        SizeToContent := true
                        ZOrder := 1
                        Widget := CreateFreeRewardCanvas(1)
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= -160.0, Left:= 167.0, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        SizeToContent := true
                        ZOrder := 1
                        Widget := CreateFreeRewardCanvas(2)
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= -160.0, Left:= 377.5, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        SizeToContent := true
                        ZOrder := 1
                        Widget := CreateFreeRewardCanvas(3)
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= -160.0, Left:= 588.0, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        SizeToContent := true
                        ZOrder := 1
                        Widget := CreateFreeRewardCanvas(4)
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= 185.0, Left:= -254.0, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        SizeToContent := true
                        ZOrder := 1
                        Widget := CreatePremiumRewardCanvas(0)
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= 185.0, Left:= -43.5, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        SizeToContent := true
                        ZOrder := 1
                        Widget := CreatePremiumRewardCanvas(1)
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= 185.0, Left:= 167.0, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        SizeToContent := true
                        ZOrder := 1
                        Widget := CreatePremiumRewardCanvas(2)
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= 185.0, Left:= 377.5, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        SizeToContent := true
                        ZOrder := 1
                        Widget := CreatePremiumRewardCanvas(3)
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= 185.0, Left:= 588.0, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        SizeToContent := true
                        ZOrder := 1
                        Widget := CreatePremiumRewardCanvas(4)
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= 33.0, Left:= -568.0, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        SizeToContent := true
                        Widget := BuyPremiumButton
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= 20.0, Left:= -784.0, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        SizeToContent := true
                        Widget := LeftPageButton
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= 20.0, Left:= 784.0, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        SizeToContent := true
                        Widget := RightPageButton
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:=0.5}, Maximum := vector2{X:=0.5,Y:=0.5}}
                        Offsets := margin{Top:= -398.0, Left:= 754.0, Right := 0.0, Bottom := 0.0}
                        Alignment := vector2{X:=0.5, Y:=0.5}
                        SizeToContent := true
                        Widget := QuitButton

            return ResultCanvas

        UpdateBattlePassHUD<public>(Agent : agent) : void =
            if(AgentData := BPAgentMap[Agent]):
                BaseSliderWidgetIndex : int = 5
                BaseLevelNodeTexWidgetIndex : int = 10
                BaseLevelNodeTextWidgetIndex : int = 16
                BaseFreeRewardItemWidgetIndex : int = 21
                BasePremiumRewardItemWidgetIndex: int = 26
                SliderCount : int = 5

                UnlockedFreeRewardBG : texture = Textures.T_UnlockedFreeRewardItemBG
                LockedFreeRewardBG : texture = Textures.T_LockedFreeRewardItemBG
                UnlockedPremiumRewardBG : texture = Textures.T_UnlockedPremiumRewardItemBG
                LockedPremiumRewardBG : texture = Textures.T_LockedPremiumRewardItemBG

                UnlockedFreeButtonTex : texture = Textures.T_FreeRewardButtonUnlocked
                LockedFreeButtonTex : texture = Textures.T_FreeRewardButtonLocked
                UnlockedPremiumButtonTex : texture = Textures.T_PremiumButtonUnlocked
                LockedPremiumButtonTex : texture = Textures.T_PremiumButtonLocked

                ClaimedTextTex : texture = Textures.T_ClaimedText
                ClaimTextTex : texture = Textures.T_ClaimText
                LockedTextTex : texture = Textures.T_LockedText

                if(CurrSliderIndex := Mod[AgentData.Level, SliderCount]):
                    Print("Current Slider Index: {CurrSliderIndex}")
                    for(I:=0..SliderCount-1):                  
                        CurrSliderWidgetIndex : int = BaseSliderWidgetIndex + I
                        CurrLevelNodeTexWidgetIndex : int = BaseLevelNodeTexWidgetIndex + I
                        CurrLevelNodeTextWidgetIndex : int = BaseLevelNodeTextWidgetIndex + I

                        CurrFreeRewardWidgetIndex : int = BaseFreeRewardItemWidgetIndex + I
                        CurrPremiumRewardWidgetIndex : int = BasePremiumRewardItemWidgetIndex + I

                        var bIsFreeItemUnlocked : logic = false
                        var bIsFreeItemClaimed : logic = false

                        var bIsPremiumItemUnlocked : logic = false
                        var bIsPremiumItemClaimed : logic = false

                        if(UnlockedIndex := AgentData.UnlockedFreeGiftIndexes.Find[I + (AgentData.BPData.PageIndex * BaseSliderWidgetIndex)]):
                            set bIsFreeItemUnlocked = true
                            if(ClaimedIndex := AgentData.ClaimedFreeGiftIndexes.Find[I + (AgentData.BPData.PageIndex * BaseSliderWidgetIndex)]):
                                set bIsFreeItemClaimed = true

                        if(UnlockedIndex := AgentData.UnlockedPremiumGiftIndexes.Find[I + (AgentData.BPData.PageIndex * BaseSliderWidgetIndex)]):
                            set bIsPremiumItemUnlocked = true
                            if(ClaimedIndex := AgentData.ClaimedPremiumGiftIndexes.Find[I + (AgentData.BPData.PageIndex * BaseSliderWidgetIndex)]):
                                set bIsPremiumItemClaimed = true

                        if(RootCanvasSlot := AgentData.BPCanvas.Slots[CurrFreeRewardWidgetIndex], FreeRewardItemCanvas := canvas[RootCanvasSlot.Widget]):
                            ItemBGTexIndex : int = 0
                            if(ItemTexSlot := FreeRewardItemCanvas.Slots[ItemBGTexIndex], ItemBGTexBlock := texture_block[ItemTexSlot.Widget]):
                                if(bIsFreeItemUnlocked = true):
                                    ItemBGTexBlock.SetImage(UnlockedFreeRewardBG)
                                else:
                                    ItemBGTexBlock.SetImage(LockedFreeRewardBG)

                        if(RootCanvasSlot := AgentData.BPCanvas.Slots[CurrPremiumRewardWidgetIndex], PremiumRewardItemCanvas := canvas[RootCanvasSlot.Widget]):
                            ItemBGTexIndex : int = 0
                            if(ItemTexSlot := PremiumRewardItemCanvas.Slots[ItemBGTexIndex], ItemBGTexBlock := texture_block[ItemTexSlot.Widget]):
                                if(bIsPremiumItemUnlocked = true):
                                    ItemBGTexBlock.SetImage(UnlockedPremiumRewardBG)
                                else:
                                    ItemBGTexBlock.SetImage(LockedPremiumRewardBG)

                        if(RootCanvasSlot := AgentData.BPCanvas.Slots[CurrFreeRewardWidgetIndex], FreeRewardItemCanvas := canvas[RootCanvasSlot.Widget]):
                            ItemTexIndex : int = 1
                            if(ItemTexSlot := FreeRewardItemCanvas.Slots[ItemTexIndex], ItemTexBlock := texture_block[ItemTexSlot.Widget], TargetTex := FreeRewardTextures[I + (AgentData.BPData.PageIndex * BaseSliderWidgetIndex)]):
                                ItemTexBlock.SetImage(TargetTex)

                        if(RootCanvasSlot := AgentData.BPCanvas.Slots[CurrPremiumRewardWidgetIndex], PremiumRewardItemCanvas := canvas[RootCanvasSlot.Widget]):
                            ItemTexIndex : int = 1
                            if(ItemTexSlot := PremiumRewardItemCanvas.Slots[ItemTexIndex], ItemTexBlock := texture_block[ItemTexSlot.Widget], TargetTex := PremiumRewardTextures[I + (AgentData.BPData.PageIndex * BaseSliderWidgetIndex)]):
                                ItemTexBlock.SetImage(TargetTex)

                        if(RootCanvasSlot := AgentData.BPCanvas.Slots[CurrFreeRewardWidgetIndex], FreeRewardItemCanvas := canvas[RootCanvasSlot.Widget]):
                            ClaimStatusTexIndex : int = 2
                            if(ItemTexSlot := FreeRewardItemCanvas.Slots[ClaimStatusTexIndex], ItemStatusTexBlock := texture_block[ItemTexSlot.Widget]):
                                if(bIsFreeItemClaimed = true):
                                    ItemStatusTexBlock.SetImage(Textures.T_UnlockedUI)
                                    WidgetVisibility : widget_visibility = ItemStatusTexBlock.GetVisibility()
                                    if(WidgetVisibility <> widget_visibility.Visible):
                                        ItemStatusTexBlock.SetVisibility(widget_visibility.Visible)
                                else if(bIsFreeItemUnlocked = true):
                                    WidgetVisibility : widget_visibility = ItemStatusTexBlock.GetVisibility()
                                    if(WidgetVisibility <> widget_visibility.Hidden):
                                        ItemStatusTexBlock.SetVisibility(widget_visibility.Hidden)
                                else:
                                    ItemStatusTexBlock.SetImage(Textures.T_LockedUI)
                                    WidgetVisibility : widget_visibility = ItemStatusTexBlock.GetVisibility()
                                    if(WidgetVisibility <> widget_visibility.Visible):
                                        ItemStatusTexBlock.SetVisibility(widget_visibility.Visible)

                        if(RootCanvasSlot := AgentData.BPCanvas.Slots[CurrPremiumRewardWidgetIndex], PremiumRewardItemCanvas := canvas[RootCanvasSlot.Widget]):
                            ClaimStatusTexIndex : int = 2
                            if(ItemTexSlot := PremiumRewardItemCanvas.Slots[ClaimStatusTexIndex], ItemStatusTexBlock := texture_block[ItemTexSlot.Widget]):
                                if(bIsPremiumItemClaimed = true):
                                    ItemStatusTexBlock.SetImage(Textures.T_UnlockedUI)
                                    WidgetVisibility : widget_visibility = ItemStatusTexBlock.GetVisibility()
                                    if(WidgetVisibility <> widget_visibility.Visible):
                                        ItemStatusTexBlock.SetVisibility(widget_visibility.Visible)
                                else if(bIsPremiumItemUnlocked = true):
                                    WidgetVisibility : widget_visibility = ItemStatusTexBlock.GetVisibility()
                                    if(WidgetVisibility <> widget_visibility.Hidden):
                                        ItemStatusTexBlock.SetVisibility(widget_visibility.Hidden)
                                else:
                                    ItemStatusTexBlock.SetImage(Textures.T_LockedUI)
                                    WidgetVisibility : widget_visibility = ItemStatusTexBlock.GetVisibility()
                                    if(WidgetVisibility <> widget_visibility.Visible):
                                        ItemStatusTexBlock.SetVisibility(widget_visibility.Visible)

                        if(RootCanvasSlot := AgentData.BPCanvas.Slots[CurrFreeRewardWidgetIndex], FreeRewardItemCanvas := canvas[RootCanvasSlot.Widget]):
                            ButtonTexIndex : int = 3
                            if(ItemTexSlot := FreeRewardItemCanvas.Slots[ButtonTexIndex], ItemBGTexBlock := texture_block[ItemTexSlot.Widget]):
                                if(bIsFreeItemUnlocked = true):
                                    ItemBGTexBlock.SetImage(UnlockedFreeButtonTex)
                                else:
                                    ItemBGTexBlock.SetImage(LockedFreeButtonTex)

                        if(RootCanvasSlot := AgentData.BPCanvas.Slots[CurrPremiumRewardWidgetIndex], PremiumRewardItemCanvas := canvas[RootCanvasSlot.Widget]):
                            ButtonTexIndex : int = 3
                            if(ItemTexSlot := PremiumRewardItemCanvas.Slots[ButtonTexIndex], ItemBGTexBlock := texture_block[ItemTexSlot.Widget]):
                                if(bIsPremiumItemUnlocked = true):
                                    ItemBGTexBlock.SetImage(UnlockedPremiumButtonTex)
                                else:
                                    ItemBGTexBlock.SetImage(LockedPremiumButtonTex)


                        if(RootCanvasSlot := AgentData.BPCanvas.Slots[CurrFreeRewardWidgetIndex], FreeRewardItemCanvas := canvas[RootCanvasSlot.Widget]):
                            ClaimTextTexIndex : int = 4
                            if(ItemTexSlot := FreeRewardItemCanvas.Slots[ClaimTextTexIndex], ClaimTexBlock := texture_block[ItemTexSlot.Widget]):
                                if(bIsFreeItemClaimed = true):
                                    ClaimTexBlock.SetImage(ClaimedTextTex)
                                else if(bIsFreeItemUnlocked = true):
                                    ClaimTexBlock.SetImage(ClaimTextTex)
                                else:
                                    ClaimTexBlock.SetImage(LockedTextTex)

                        if(RootCanvasSlot := AgentData.BPCanvas.Slots[CurrPremiumRewardWidgetIndex], PremiumRewardItemCanvas := canvas[RootCanvasSlot.Widget]):
                            ClaimTextTexIndex : int = 4
                            if(ItemTexSlot := PremiumRewardItemCanvas.Slots[ClaimTextTexIndex], ClaimTexBlock := texture_block[ItemTexSlot.Widget]):
                                if(bIsPremiumItemClaimed = true):
                                    ClaimTexBlock.SetImage(ClaimedTextTex)
                                else if(bIsPremiumItemUnlocked = true):
                                    ClaimTexBlock.SetImage(ClaimTextTex)
                                else:
                                    ClaimTexBlock.SetImage(LockedTextTex)

                        if(RootCanvasSlot := AgentData.BPCanvas.Slots[CurrLevelNodeTextWidgetIndex], LevelNodeTextBlock := text_block[RootCanvasSlot.Widget]):
                            LevelNodeTextBlock.SetText(TextForUI(ToString(I + 1 + (AgentData.BPData.PageIndex * BaseSliderWidgetIndex))))

                        if(bIsFreeItemUnlocked = true):
                            if(RootCanvasSlot := AgentData.BPCanvas.Slots[CurrLevelNodeTexWidgetIndex], LevelNodeTexBlock := texture_block[RootCanvasSlot.Widget]):
                                LevelNodeTexBlock.SetImage(Textures.T_UnlockedLevelNode)

                            if(RootCanvasSlot := AgentData.BPCanvas.Slots[CurrSliderWidgetIndex], SliderCanvas := canvas[RootCanvasSlot.Widget]):
                                if(SliderFGSlot := SliderCanvas.Slots[1], SliderFGTexBlock := texture_block[SliderFGSlot.Widget]):
                                    CurrSize : vector2 = SliderFGTexBlock.GetDesiredSize()
                                    MaxSliderXSize : float = 149.5
                                    TargetXSize : float = MaxSliderXSize
                                    SliderFGTexBlock.SetDesiredSize(vector2{X:=TargetXSize,Y:=CurrSize.Y})
                        else if((I + (SliderCount * AgentData.BPData.PageIndex)) = AgentData.Level):
                            if(RootCanvasSlot := AgentData.BPCanvas.Slots[CurrLevelNodeTexWidgetIndex], LevelNodeTexBlock := texture_block[RootCanvasSlot.Widget]):
                                LevelNodeTexBlock.SetImage(Textures.T_LockedLevelNode)

                            if(RootCanvasSlot := AgentData.BPCanvas.Slots[CurrSliderWidgetIndex], SliderCanvas := canvas[RootCanvasSlot.Widget]):
                                if(SliderFGSlot := SliderCanvas.Slots[1], SliderFGTexBlock := texture_block[SliderFGSlot.Widget], ExpThreshold := BPLevelTargetXPAmounts[AgentData.Level]):
                                    CurrSize : vector2 = SliderFGTexBlock.GetDesiredSize()
                                    MaxSliderXSize : float = 149.5
                                    TargetXSize : float = MaxSliderXSize * (AgentData.Experience/ExpThreshold) 
                                    SliderFGTexBlock.SetDesiredSize(vector2{X:=TargetXSize,Y:=CurrSize.Y})
                        else:
                            if(RootCanvasSlot := AgentData.BPCanvas.Slots[CurrLevelNodeTexWidgetIndex], LevelNodeTexBlock := texture_block[RootCanvasSlot.Widget]):
                                LevelNodeTexBlock.SetImage(Textures.T_LockedLevelNode)

                            if(RootCanvasSlot := AgentData.BPCanvas.Slots[CurrSliderWidgetIndex], SliderCanvas := canvas[RootCanvasSlot.Widget]):
                                if(SliderFGSlot := SliderCanvas.Slots[1], SliderFGTexBlock := texture_block[SliderFGSlot.Widget]):
                                    CurrSize : vector2 = SliderFGTexBlock.GetDesiredSize()
                                    TargetXSize : float = 0.0
                                    SliderFGTexBlock.SetDesiredSize(vector2{X:=TargetXSize,Y:=CurrSize.Y})
                        

        OnRightPageButtonClicked<public>(Message : widget_message) : void =
            if(Agent := Message.Player.GetFortCharacter[].GetAgent[], AgentData := BPAgentMap[Agent]):
                var MaxPageCount : int = 0
                SliderCount : int = 5
                if(TempPageCount := Ceil[(FreeRewardTextures.Length * 1.0)/(SliderCount*1.0)]):
                    Print("Max Page Count: {TempPageCount}")
                    set MaxPageCount = TempPageCount

                if(AgentData.BPData.PageIndex < MaxPageCount-1):
                    set AgentData.BPData.PageIndex = Clamp(AgentData.BPData.PageIndex + 1, 0, MaxPageCount-1)

                    UpdateBattlePassHUD(Agent)                

        OnLeftPageButtonClicked<public>(Message : widget_message) : void =
            if(Agent := Message.Player.GetFortCharacter[].GetAgent[], AgentData := BPAgentMap[Agent]):
                var MaxPageCount : int = 0
                SliderCount : int = 5
                if(TempPageCount := Ceil[(FreeRewardTextures.Length * 1.0)/(SliderCount*1.0)]):
                    Print("Max Page Count: {TempPageCount}")
                    set MaxPageCount = TempPageCount

                if(AgentData.BPData.PageIndex > 0):
                    set AgentData.BPData.PageIndex = Clamp(AgentData.BPData.PageIndex - 1, 0, MaxPageCount-1)

                    UpdateBattlePassHUD(Agent)

        OnQuitButtonClicked<public>(Message : widget_message) : void =
            if(Agent := Message.Player.GetFortCharacter[].GetAgent[], AgentData := BPAgentMap[Agent], PlayerUI := GetPlayerUI[Message.Player]):
                PlayerUI.RemoveWidget(AgentData.BPCanvas)
                set AgentData.BPData.PageIndex = 0

        OnBuyPremiumButtonClicked<public>(Message : widget_message) : void =
            if(Agent := Message.Player.GetFortCharacter[].GetAgent[], AgentData := BPAgentMap[Agent]):
                BPPremiumTicketBuyButtonClickedTrigger.Trigger(Agent)

