# Tycoon Plot Manager
# Manages plot ownership and ATM money collection in a tycoon-style game mode. Handles plot claiming mechanics, team assignment, money tracking, and player progress through various interconnected system
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/plot-manager-1?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }

#This Code is a Plot/ATM Manager for a Tycoon Game Mode

Plot_Manager := class(creative_device):
    #Other Creative/Verse devices
    @editable ButtonManager : Button_Manager = Button_Manager{}
    @editable GameManager : Game_Manager = Game_Manager{}
    @editable CrateManager : Crate_Manager = Crate_Manager{}
    @editable FarmManager : Farm_Manager = Farm_Manager{}
    PlayerStatManager : player_stats_manager = player_stats_manager{}

    @editable ClaimPlotMutator : mutator_zone_device = mutator_zone_device{}   #Mutator to claim a plot

    @editable ClaimPlotSelector : class_and_team_selector_device = class_and_team_selector_device{}   #Selector to change class/team to plot team

    @editable ClaimMoneyHUD : hud_message_device = hud_message_device{}   #HUD message device that shows when claiming ATM Money

    @editable ClaimMoneyMutator : mutator_zone_device = mutator_zone_device{}      #Mutator device for claiming ATM Money

    @editable ClaimMoneyBillboard : billboard_device = billboard_device{}      #Bilboard device for displaying ATM Money

    @editable ClaimPlotPlayerRef : player_reference_device = player_reference_device{}      #Player reference to show player skin/name above/infront of plot

    @editable ClaimPlotCinematic : cinematic_sequence_device = cinematic_sequence_device{}      #Cinematic to play when player claims a plot

    @editable ClaimPlotHud : hud_message_device = hud_message_device{}      #Hud msg to show to player when they claim a plot

    @editable ClaimPlotTracker : tracker_device = tracker_device{}      #Tracker device to increment when a player claims a plot
 
    @editable ScoreManager : score_manager_device = score_manager_device{}      #Score Manager to track a players score for in-game scoreboard

    var ATMAmount : float = 0.0   #Amount in ATM

    var PlotsPlayer : []agent = array{} #Holds the agent who owns plot

    ResetPlotEvent<public> : event() = event(){}    #Event used to disable the atm loop whenever the plot is reset

    StringToMessage<localizes>(value:float) : message = "{value}"  #Convert a float to message for billboard
    
    var MaybeMyUIPerPlayer : [player]?canvas = map{}                #Map to store players UI

    OnBegin<override>()<suspends>:void=
        ClaimPlotMutator.AgentEntersEvent.Subscribe(ClaimPlotSetup)       #Claims plot when in mutator
        ClaimMoneyMutator.AgentEntersEvent.Subscribe(ClaimMoney)            #Claims Money when in mutator
        GetPlayspace().PlayerRemovedEvent().Subscribe(PlayerLeft)

    ClaimPlotSetup(Agent:agent) : void=
        spawn:
            ATMStart(Agent)        #Starts producing money in the ATM for the player
        spawn:
            ClaimPlot(Agent)        #Does various things for the plot claim
 
    ClaimPlot(Agent:agent)<suspends> : void=
        if(Player := player[Agent], CustomPlayer := GameManager.PlayersMap[Player]):
            ClaimPlotSelector.ChangeTeam(Agent)     #Changes the players team to the plot team
            ClaimPlotPlayerRef.Register(Agent)      #Adds a player to the player reference
            ClaimPlotCinematic.Play(Agent)          #Plays plot cinematic
            ClaimPlotHud.Show(Agent)                #Shows plot HUD msg
            ClaimPlotTracker.Increment(Agent)       #Increments Claim Plot Tracker
            set PlotsPlayer = array{}
            set PlotsPlayer += array {Agent}        #Assigns plot's player to player who claimed

            
            if(CustomPlayer.BoughtDoors.Length > 1): #If they've already bought doors before          
                ChooseToUnlock(Agent)
            else:
                if(FirstButton := ButtonManager.ButtonsArray[0]):
                    FirstButton.ButtonContent(Player)
                    ClaimPlotMutator.Disable()

    ChooseToUnlock(Agent:agent) : void=
        if(Player := player[Agent],PlayerUI := GetPlayerUI[Player]):
            UnlockUI := CreateUnlockUI()
            PlayerUI.AddWidget(UnlockUI,player_ui_slot{InputMode := ui_input_mode.All})
            if(set MaybeMyUIPerPlayer[Player] = option{UnlockUI}){}



  

    PlayerLeft(Agent:agent ) : void=            #Resets the plot
        if(OwnedPlayer := PlotsPlayer[0], CP := GameManager.PlayersMap[Agent]):
            if(OwnedPlayer = Agent):
                for(B : ButtonManager.ButtonsArray):       
                    spawn{B.ResetButton(Agent)}
    
                #Resets ATM
                ResetPlotEvent.Signal()
                set ATMAmount = 0.0
                ClaimMoneyBillboard.SetText(StringToMessage(ATMAmount))     
                         
               
                #Shows the first button again
                if(FirstButton := ButtonManager.ButtonsArray[0]):
                    FirstButton.MutatorZone.Enable()
                    for(idx -> Item : FirstButton.ItemsToHide):
                        PropPos := Item.GetTransform().Translation
                        PropRot := Item.GetTransform().Rotation
                        if(Item.TeleportTo[vector3{X:=PropPos.X,Y:=PropPos.Y,Z:=PropPos.Z + 100000.0},PropRot]){}

                CrateManager.ResetLevel()       #Resets Crate Level
                FarmManager.ResetAllCrops()
    


    ATMStart(Agent:agent)<suspends> : void=
        if(Player := player[Agent], CustomPlayer := GameManager.PlayersMap[Player]):
            race:
                block:  
                    ResetPlotEvent.Await()      #Ends loop when plot is reset


                loop:      #loops every second and claims resources for player
                    Sleep(1.0)

                    #Adds current boosts to the amount to increase
                    IncAmount := CustomPlayer.IdleMoneyAmount * (CustomPlayer.CurrentMoneyBoost + (CustomPlayer.RebirthAmount * CustomPlayer.RebirthBoostAmount))      
                    

                    # Collect Resources every second here, example that collects Resource2: 
                    
                    # IncResource2Amount := CustomPlayer.IdleResource2Amount * CustomPlayer.CurrentResource2Boost
                    # CustomPlayer.Collect(IncResource2Amount,"Resource2")                                                     
                    
                    set ATMAmount += IncAmount                                  #Adds increase amount to ATM

                    ClaimMoneyBillboard.SetText(StringToMessage(ATMAmount))     #Sets ATM billboard to new ATM amount

                    #Adds Score to Player for in-game leaderboard Un-commit all this code below to enable

                    # if(NewAmount := Int[CustomPlayer.#Put the resource the will be counted on scoreboard here(Ex. Resource2Amount)]):
                    #     ScoreManager.SetScoreAward(NewAmount)
                    #     ScoreManager.Activate(Agent)



    ClaimMoney(Agent:agent) : void=      #Activates when player enters ATM Mutator
        if(Player := player[Agent], CustomPlayer := GameManager.PlayersMap[Player]):
            ClaimMoneyHUD.Show(Agent)   #Shows HUD msg when money is claimed 
            CustomPlayer.Collect(ATMAmount,"Money")    #Collects the money in ATM
            set ATMAmount = 0.0         #Resets the ATM amount back to 0

    ToMessage<localizes>(String : string) : message = "{String}"

    #Creates UI For player to choose load or reset saved plot progress
    CreateUnlockUI() : canvas=
        var LoadButton : button_loud = button_loud{}
        var ResetButton : button_loud = button_loud{}
        LoadButton.SetText(ToMessage("Load"))
        ResetButton.SetText(ToMessage("Reset"))
        LoadButton.OnClick().Subscribe(Load)
        ResetButton.OnClick().Subscribe(Reset)
        NewUnlockUI : canvas = canvas:
            Slots := array:
                canvas_slot:   #Slot for your text
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Left := 0.0, Top := -150.0, Right := 1000.0, Bottom := 400.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := false
                    Widget := texture_block:
                        DefaultImage := MONEYUI
                canvas_slot:   #Resest button
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Left := 260.0, Top := 170.0, Right := 300.0, Bottom := 65.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := false
                    Widget := ResetButton
                canvas_slot:    #Load button
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                    Offsets := margin{Left := -260.0, Top := 170.0, Right := 300.0, Bottom := 65.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := false
                    Widget := LoadButton

    #Loads the saved progress for the player
    Load(Message : widget_message) : void=
        Player := Message.Player
        if (PlayerUI := GetPlayerUI[Message.Player], PlayerWidget := MaybeMyUIPerPlayer[Player]?,CP := GameManager.PlayersMap[Player]):
            PlayerUI.RemoveWidget(PlayerWidget)
            if(set MaybeMyUIPerPlayer[Player] = false){}
            for(BoughtDoor : CP.BoughtDoors):      #Unlocks all doors from the players persistence data

                if(TempB := ButtonManager.ButtonsArray[BoughtDoor]):
                    spawn:
                        TempB.CheckForUniques(Player)  #checks for any unique actions

                    TempB.Cinematic.Play()    #Plays button cinematic
                    
                    CP.Collect(TempB.IncreaseResourceAmount, TempB.IncreaseResourceType)
                    TempB.UniqueTrigger.Trigger(Player)    #Triggers to do unique action
            
                    for(idx -> Item: TempB.ItemsToShow, B := TempB.ItemsToShowMap[idx]):      #Shows all items to show
                        if(CurrentValueInt := Int[B.Prop.GetTransform().Translation.Z],HiddenValueInt := Int[B.HiddenZLocation]):
                            if(CurrentValueInt = HiddenValueInt):
                                PropPos := B.Prop.GetTransform().Translation
                                PropRot := B.Prop.GetTransform().Rotation
                                if(B.Prop.TeleportTo[vector3{X:=PropPos.X,Y:=PropPos.Y,Z:=B.InitialZLocation},PropRot]){}
            
                            
                    for(idx -> Item: TempB.ItemsToHide):      #Shows all items to show
                        PropPos := Item.GetTransform().Translation
                        PropRot := Item.GetTransform().Rotation
                        if(Item.TeleportTo[vector3{X:=PropPos.X,Y:=PropPos.Y,Z:=PropPos.Z -100000.0}, PropRot]):

                    
                    TempB.MutatorZone.Disable()        #Disables the Buttons Own Mutator
            
                    
                    for(Zone: TempB.ShownMutatorZones):   #Enables new buttons mutators
                        Zone.Enable()


    
    #resets the saved progress for the player
    Reset(Message : widget_message) : void=
        Player := Message.Player
        if (PlayerUI := GetPlayerUI[Message.Player], PlayerWidget := MaybeMyUIPerPlayer[Player]?,CP := GameManager.PlayersMap[Player]):
            PlayerUI.RemoveWidget(PlayerWidget)
            if(set MaybeMyUIPerPlayer[Player] = false){}
            set CP.BoughtDoors = array{}
            PlayerStatManager.ResetPlayerArrStat(Player, StatType.Doors)
            if(FirstButton := ButtonManager.ButtonsArray[0]):
                spawn:
                    FirstButton.UnlockButtonContent(Player,true)
                ClaimPlotMutator.Disable()