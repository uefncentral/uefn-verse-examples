# Interactive Computer Interface
# Creates a computer terminal that players can interact with, featuring progress bars, loading screens, and an upgrade system. Players can open the computer interface to view different progress bars wit
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/computer-manager?ref=github



using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Colors }
using { /Fortnite.com/Characters }
using { /Fortnite.com/UI }

#THIS DEVICE IS USED TO MAKE A COMPUTER THAT PLAYERS CAN OPEN AND DISPLAYS LOADING SCREENS

#Class for different upgrades
Upgrade := class<concrete>():
    @editable Trigger : trigger_device = trigger_device{}
    @editable ChangePropSettings : ChangePropSetting = ChangePropSetting{}
    @editable IncreaseType : increasetype = increasetype.Add
    @editable UpgradeAmount : float = 0.0
    @editable Reusable : logic = false
    @editable CostResources : []SpendableResource = array{}
    var IDX : int = 0

#Class for different progreess bars that appear on the PC
ProgressBar := class<concrete>():
    #UI Stuff
    var BarCanvas : canvas = canvas{}
    var BackgroundBarWid : color_block = color_block{}
    var ProgressBarWid : color_block = color_block{}
    var ProgressText : text_block = text_block{DefaultJustification := text_justification.Center}
    var TipTextWid : text_block = text_block{DefaultJustification := text_justification.Center}
    var MainBarText : text_block = text_block{DefaultJustification := text_justification.Center}

    #Settings
    @editable BarSettings : BarSetting = BarSetting{}
    @editable TextSettings : ComputerTextSetting = ComputerTextSetting{}
    @editable Upgrades : []Upgrade = array{}
    @editable BaseSpeed : float = 0.0

    #Other Stuff
    CancelEvent : event() = event(){}
    var CompleteEvent : event() = event(){}
    var BarSpeed : float = 0.0
    var XValue : float = 0.0
    var DotIDX : int = 0
    
    #Initializes all bars, text and UI
    Initialize() : void=
        #Text Stuff
        ProgressText.SetTextColor(TextSettings.ProgressTextColors.TextColor)
        ProgressText.SetShadowColor(TextSettings.ProgressTextColors.TextShadowColor)
        ProgressText.SetShadowOffset(option{TextSettings.ProgressTextColors.TextShadowOffset})
        TipTextWid.SetTextColor(TextSettings.TipTextColors.TextColor)
        TipTextWid.SetShadowColor(TextSettings.TipTextColors.TextShadowColor)
        TipTextWid.SetShadowOffset(option{TextSettings.TipTextColors.TextShadowOffset})
        MainBarText.SetTextColor(TextSettings.MainTextColors.TextColor)
        MainBarText.SetShadowColor(TextSettings.MainTextColors.TextShadowColor)
        MainBarText.SetShadowOffset(option{TextSettings.MainTextColors.TextShadowOffset})
        MainBarText.SetShadowOpacity(1.0)
        TipTextWid.SetShadowOpacity(1.0)
        ProgressText.SetShadowOpacity(1.0)
        MainBarText.SetText(StringToMessage(TextSettings.MainText))
        TipTextWid.SetText(StringToMessage(TextSettings.TipText))

        MainBarText.SetVisibility(widget_visibility.Hidden)
        TipTextWid.SetVisibility(widget_visibility.Hidden)
        ProgressText.SetVisibility(widget_visibility.Hidden)

        #Bar and Main UI
        set XValue = 0.0
        set DotIDX = 0
        BackgroundBarWid.SetColor(BarSettings.BackgroundBarColor)
        ProgressBarWid.SetColor(BarSettings.ProgressBarColor)
        set BarCanvas = CreateUI()

        
    #Sets up a canvas for each bar
    CreateUI() : canvas=
        NewCanvas := canvas:
            Slots := array:
                TextSettings.TipTextPosition.MakeCanvasSlot(TipTextWid, option{CanvasPosition{MaybeZOrder := option{2}}})
                TextSettings.MainTextPosition.MakeCanvasSlot(MainBarText, option{CanvasPosition{MaybeZOrder := option{2}}})
                TextSettings.ProgressTextPosition.MakeCanvasSlot(ProgressText, option{CanvasPosition{MaybeZOrder := option{2}}})


                BarSettings.BarPosition.MakeCanvasSlot(BackgroundBarWid, option{CanvasPosition{MaybeZOrder := option{0}}})
                BarSettings.BarPosition.MakeCanvasSlot(ProgressBarWid, option{CanvasPosition{MaybeRight := option{0.0},MaybeZOrder := option{1}}})

    #Makes the bar start moving and also controls loading "." animation
    Start(Agent:agent)<suspends> : void=
        #Set up variables used and shows text for bar
        MainBarText.SetVisibility(widget_visibility.Visible)
        TipTextWid.SetVisibility(widget_visibility.Visible)
        ProgressText.SetVisibility(widget_visibility.Visible)
        var MainString : string = TextSettings.MainText
        sync:
            #Controls loading . animation
            race:
                block:
                    CancelEvent.Await()
                    ProgressBarWid.SetVisibility(widget_visibility.Hidden)
                    BarCanvas.RemoveWidget(ProgressBarWid)
                    BarCanvas.RemoveWidget(MainBarText)
                    
                    
                block:
                    CompleteEvent.Await()
                    if(TextSettings.CompletedMainTextSettings.CompletedType = completetexttype.Hide):
                        MainBarText.SetVisibility(widget_visibility.Hidden)

                    else if(TextSettings.CompletedMainTextSettings.CompletedType = completetexttype.ChangeToCompletedText):
                        MainBarText.SetText(StringToMessage(TextSettings.CompletedMainTextSettings.CompletedText))
                        MainBarText.SetTextColor(TextSettings.CompletedMainTextSettings.CompletedTextColor.TextColor)
                        MainBarText.SetShadowColor(TextSettings.CompletedMainTextSettings.CompletedTextColor.TextShadowColor)
                        MainBarText.SetShadowOffset(option{TextSettings.CompletedMainTextSettings.CompletedTextColor.TextShadowOffset})
                loop:
                    Sleep(TextSettings.MainTextDotAnimationSpeed)
                    if(DotIDX = 3):
                        set MainString = TextSettings.MainText
                        set DotIDX = -1
                    else:
                        set MainString += "."
                    MainBarText.SetText(StringToMessage(MainString))
                    set DotIDX += 1
                    
            #Controls bar animation
            race:
                block:
                    CancelEvent.Await()
                    ProgressBarWid.SetVisibility(widget_visibility.Hidden)
                    BarCanvas.RemoveWidget(ProgressBarWid)

                block:
                    CompleteEvent.Await()
                    if(not BarSettings.AppearAfterCompleted?):
                        ProgressBarWid.SetVisibility(widget_visibility.Hidden)
                        BarCanvas.RemoveWidget(ProgressBarWid)
                loop:
                    Sleep(0.0)
                    set XValue += BarSpeed
                    ProgressBarWid.SetVisibility(widget_visibility.Hidden)
                    BarCanvas.RemoveWidget(ProgressBarWid)
                    ProgressBarWid.SetVisibility(widget_visibility.Visible)
                    BarCanvas.AddWidget(BarSettings.BarPosition.MakeCanvasSlot(ProgressBarWid, option{CanvasPosition{MaybeRight := option{XValue}}}))
                    if(Percentage := Int[(XValue / BarSettings.BarPosition.Right) * 100.0]):
                        ProgressText.SetText(StringToMessage("{Percentage}%"))

                    if(XValue >= BarSettings.BarPosition.Right):
                        CompleteEvent.Signal()

    #Resets the Bar
    Reset(Agent:agent): void=
        set XValue = 0.0
        set DotIDX = 0

        ProgressText.SetTextColor(TextSettings.ProgressTextColors.TextColor)
        ProgressText.SetShadowColor(TextSettings.ProgressTextColors.TextShadowColor)
        ProgressText.SetShadowOffset(option{TextSettings.ProgressTextColors.TextShadowOffset})
        TipTextWid.SetTextColor(TextSettings.TipTextColors.TextColor)
        TipTextWid.SetShadowColor(TextSettings.TipTextColors.TextShadowColor)
        TipTextWid.SetShadowOffset(option{TextSettings.TipTextColors.TextShadowOffset})
        MainBarText.SetTextColor(TextSettings.MainTextColors.TextColor)
        MainBarText.SetShadowColor(TextSettings.MainTextColors.TextShadowColor)
        MainBarText.SetShadowOffset(option{TextSettings.MainTextColors.TextShadowOffset})

        MainBarText.SetText(StringToMessage(TextSettings.MainText))
        TipTextWid.SetText(StringToMessage(TextSettings.TipText))

        MainBarText.SetVisibility(widget_visibility.Hidden)
        TipTextWid.SetVisibility(widget_visibility.Hidden)
        ProgressText.SetVisibility(widget_visibility.Hidden)

        ProgressBarWid.SetVisibility(widget_visibility.Hidden)
        BarCanvas.RemoveWidget(ProgressBarWid)
        ProgressBarWid.SetVisibility(widget_visibility.Visible)
        BarCanvas.AddWidget(BarSettings.BarPosition.MakeCanvasSlot(ProgressBarWid, option{CanvasPosition{MaybeRight := option{XValue}}}))

#Class to hold and control the UI that gets shown to the player
ComputerUI := class():
    #Devices
    var GameManager : Game_Manager = Game_Manager{}
    var ComputerManager : Computer_Manager = Computer_Manager{}
    var OpenComputerCinematic : cinematic_sequence_device = cinematic_sequence_device{}
    var HUDController : hud_controller_device = hud_controller_device{}
   
    #Settings
    var CancelSettings : CancelSetting = CancelSetting{}
    var CompletionSettings : CompletionSetting = CompletionSetting{}
    var OpenSettings : OpenSetting = OpenSetting{}

    #UI Stuff
    var CancelButton : button_loud = button_loud{}
    var MainUI : canvas = canvas{}
    var ExitButton : button_loud = button_loud{}
    var StartButton : button_loud = button_loud{}
    var PopUp : PopUpCreator = PopUpCreator{}
    

    #Adds the UI to the player and Initializes Bars
    AddUI(Agent:agent) : void=
        CancelButton.SetText(StringToMessage("Cancel"))
        if(Player := player[Agent], PlayerUI := GetPlayerUI[Player] , PC := ComputerManager.PlayersComputerMap[Agent],CP := GameManager.PlayersMap[Agent]):
            for(B : PC.ProgressBars){B.Initialize()}
            if(OpenSettings.OpenType = opentype.AutoStart):
                if(CancelSettings.CancelType = canceltype.UI):
                    PlayerUI.AddWidget(MainUI , player_ui_slot{InputMode := ui_input_mode.All})
                else:
                    PlayerUI.AddWidget(MainUI)
                CP.MyUI.SetVisibility(widget_visibility.Hidden)
                spawn{PlayBars(Agent)}
                spawn{HandleCancel(Agent)}

            else if(OpenSettings.OpenType = opentype.Optional):
                StartButton.SetText(StringToMessage(OpenSettings.OptionalOpenStartButtonText))
                ExitButton.SetText(StringToMessage(OpenSettings.OptionalOpenExitButtonText))
                MainUI.AddWidget(OpenSettings.OptionalOpenStartButtonPosition.MakeCanvasSlot(StartButton,false))
                MainUI.AddWidget(OpenSettings.OptionalOpenExitButtonPosition.MakeCanvasSlot(ExitButton,false))
                StartButton.OnClick().Subscribe(HandleStart)
                ExitButton.OnClick().Subscribe(HandleExit)
                PlayerUI.AddWidget(MainUI , player_ui_slot{InputMode := ui_input_mode.All})
                CP.MyUI.SetVisibility(widget_visibility.Hidden)

    #Controls what happens if UI is set to optional and the Start button is selected
    HandleStart(Message : widget_message) : void=
        Player := Message.Player
        if(PlayerUI := GetPlayerUI[Player]):
            StartButton.SetVisibility(widget_visibility.Hidden)
            ExitButton.SetVisibility(widget_visibility.Hidden)
            MainUI.RemoveWidget(StartButton)
            MainUI.RemoveWidget(ExitButton)

            MainUI.SetVisibility(widget_visibility.Hidden)
            PlayerUI.RemoveWidget(MainUI)

            if(CancelSettings.CancelType = canceltype.UI):
                PlayerUI.AddWidget(MainUI , player_ui_slot{InputMode := ui_input_mode.All})
            else:
                PlayerUI.AddWidget(MainUI)
            spawn{PlayBars(Player)}
            spawn{HandleCancel(Player)}

    #Controls what happens if UI is set to optional and the Exit button is selected
    HandleExit(Message : widget_message) : void=
        Player := Message.Player
        if(PlayerUI := GetPlayerUI[Player], FC:= Player.GetFortCharacter[]):
            StartButton.SetVisibility(widget_visibility.Hidden)
            ExitButton.SetVisibility(widget_visibility.Hidden)
            MainUI.RemoveWidget(StartButton)
            MainUI.RemoveWidget(ExitButton)
            PlayerUI.RemoveWidget(MainUI)
            OpenComputerCinematic.Stop(Player)
            FC.ReleaseFromStasis()
            CancelSettings.CustomInputTrigger.Unregister(Player)
            HUDController.Disable()
    
    #Tracks for when a player cancels based on the cancel setting
    HandleCancel(Agent:agent)<suspends> : void=
        if(CancelSettings.CancelType = canceltype.UI):
            MainUI.AddWidget(CancelSettings.UIExitPosition.MakeCanvasSlot(CancelButton, false))
            CancelButton.OnClick().Subscribe(CancelUI)

        else if(CancelSettings.CancelType = canceltype.CustomInput):
            CancelSettings.CustomInputTrigger.Register(Agent)
            HUDController.UpdateAffectedTeam(Agent)
            HUDController.Enable()

            CancelSettings.CustomInputTrigger.PressedEvent.Subscribe(Cancel)

    #Starts playing all bars in succession
    PlayBars(Agent:agent)<suspends> : void=
        var BarIDX : int = 0
        if(PC := ComputerManager.PlayersComputerMap[Agent]):
            for(B : PC.ProgressBars):
                if(B.BarSettings.AppearBeforeStarted?):
                    MainUI.AddWidget(B.BarSettings.BarPosition.MakeCanvasSlot(B.BarCanvas, option{CanvasPosition{
                        MaybeZOrder := option{1}
                        MaybeLeft := option{0.0}
                        MaybeRight := option{0.0}
                        MaybeBottom := option{0.0}
                        MaybeTop := option{0.0}
                        MaybeAllignment := option{vector2{X:= 0.5,Y:= 0.5}}
                        }}))
            race:
                block:
                    for(B : PC.ProgressBars):
                        B.CancelEvent.Await()

                loop:
                    if(CurrentBar := PC.ProgressBars[BarIDX]):
                        CurrentBar.BarCanvas.SetVisibility(widget_visibility.Hidden)
                        MainUI.RemoveWidget(CurrentBar.BarCanvas)
                        CurrentBar.BarCanvas.SetVisibility(widget_visibility.Visible)

                        MainUI.AddWidget(CurrentBar.BarSettings.BarPosition.MakeCanvasSlot(CurrentBar.BarCanvas, option{CanvasPosition{
                            MaybeZOrder := option{1}
                            MaybeLeft := option{0.0}
                            MaybeRight := option{0.0}
                            MaybeBottom := option{0.0}
                            MaybeTop := option{0.0}
                            MaybeAllignment := option{vector2{X:= 0.5,Y:= 0.5}}
                            }}))

                        spawn{CurrentBar.Start(Agent)}
                        CurrentBar.CompleteEvent.Await()
                        set BarIDX += 1
                        if(not CurrentBar.BarSettings.AppearAfterCompleted?):
                            CurrentBar.BarCanvas.SetVisibility(widget_visibility.Hidden)
                            MainUI.RemoveWidget(CurrentBar.BarCanvas)

                        if(not CurrentBar.TextSettings.ShouldProgressTextAppearAfterComplete?):
                            CurrentBar.ProgressText.SetVisibility(widget_visibility.Hidden)
                    else:
                        Complete(Agent)
                        break

    #Used as a precurser to cancel for ui button
    CancelUI(Message : widget_message) : void=
        Player := Message.Player
        Cancel(Player)

    #Cancels the mechanic
    Cancel(Agent:agent) : void=
        if(FC := Agent.GetFortCharacter[], Player := player[Agent],PlayerUI := GetPlayerUI[Player],PC := ComputerManager.PlayersComputerMap[Agent], CP := GameManager.PlayersMap[Agent] ):
            MainUI.SetVisibility(widget_visibility.Hidden)
            PlayerUI.RemoveWidget(MainUI)
            CP.MyUI.SetVisibility(widget_visibility.Visible)
            OpenComputerCinematic.Stop(Agent)
            FC.ReleaseFromStasis()
            CancelSettings.CustomInputTrigger.Unregister(Agent)
            HUDController.Disable()
            for(B : PC.ProgressBars):
                B.CancelEvent.Signal()

    #Completes the mechanic and awards player
    Complete(Agent:agent) : void=
        if(FC := Agent.GetFortCharacter[], Player := player[Agent],PlayerUI := GetPlayerUI[Player], CP := GameManager.PlayersMap[Agent],PC := ComputerManager.PlayersComputerMap[Agent]):
            CP.Collect(CompletionSettings.CompleteResources)
            CompletionSettings.CompleteTrigger.Trigger(Agent)

            #Displays pop up if enabled
            if(CompletionSettings.PopUpSettings.Enabled?):
                if(DisplayResource := CompletionSettings.CompleteResources[CompletionSettings.PopUpSettings.ResourceIDX], NewAmount := DisplayResource.Amount):
                    set PopUp.PopUpAnimationSettings = CompletionSettings.PopUpSettings
                    set PopUp.Amount = NewAmount
                    spawn{PopUp.DisplayPopUp(Agent)}

            if(CompletionSettings.CompletionType = completiontype.Close):
                MainUI.SetVisibility(widget_visibility.Hidden)
                PlayerUI.RemoveWidget(MainUI)
                CP.MyUI.SetVisibility(widget_visibility.Visible)
                OpenComputerCinematic.Stop(Agent)
                FC.ReleaseFromStasis()
                CancelSettings.CustomInputTrigger.Unregister(Agent)
                HUDController.Disable()

            else if(CompletionSettings.CompletionType = completiontype.Loop):
                for(B : PC.ProgressBars){B.Reset(Agent)}
                spawn{PlayBars(Agent)}


            
          


#Class to hold players individual bars and track upgrades
PlayerComputers := class():
    Player : player
    PersistanceManager : Persistance_Manager = Persistance_Manager{}
    var GameManager : Game_Manager = Game_Manager{}
    var PlotManager : Plot_Manager = Plot_Manager{}
    var ProgressBars : []ProgressBar = array{}
    ResetEvent : event() = event(){}

    LoadTriggerEvent : event() = event(){}
    
    #Sets up all bars upgrades
    SetUpUpgrades() : void=
        for(ProgressIDX -> P : ProgressBars):
            set P.BarSpeed = P.BaseSpeed
            for(idx -> U : P.Upgrades):
                set U.IDX = idx + 1
                spawn{UpgradeWait(P, U, ProgressIDX)}
        spawn{LoadSavedData()}

    #Loads the saved data for a player when they load a plot
    LoadSavedData()<suspends> : void=
        Agent:=PlotManager.PlotLoadEvent.Await()
        if(Player = Agent):
            if(CP := GameManager.PlayersMap[Player] , PlayerStats := PersistanceManager.GetPlayerStats[Player]):
                for(idx -> P : ProgressBars):
                    if(idx = 0):
                        for(BoughtUp : PlayerStats.Bar1Upgrades):
                            for(Up : P.Upgrades):
                                if(Up.IDX = BoughtUp):
                                    LoadTriggerEvent.Signal()
                                 
                    else if(idx = 1):
                        for(BoughtUp : PlayerStats.Bar2Upgrades):
                            for(Up : P.Upgrades):
                                if(Up.IDX = BoughtUp):
                                    LoadTriggerEvent.Signal()
                    
                    
                    else if(idx = 2):
                        for(BoughtUp : PlayerStats.Bar3Upgrades):
                            for(Up : P.Upgrades):
                                if(Up.IDX = BoughtUp):
                                    LoadTriggerEvent.Signal()




    #Adds persistence to different resources
    AddToPersistence(idx : int,Amount : int) : void=
        if(CP := GameManager.PlayersMap[Player] , PlayerStats := PersistanceManager.GetPlayerStats[Player]):
            if(idx = 0 , not PlayerStats.Bar1Upgrades.Find[Amount]){PersistanceManager.RecordPlayerArrStat(Player, StatType.Bar1Upgrades, ?Score := Amount)}
            else if(idx = 1 , not PlayerStats.Bar2Upgrades.Find[Amount]){PersistanceManager.RecordPlayerArrStat(Player, StatType.Bar2Upgrades, ?Score := Amount)}
            else if(idx = 2 , not PlayerStats.Bar3Upgrades.Find[Amount]){PersistanceManager.RecordPlayerArrStat(Player, StatType.Bar3Upgrades, ?Score := Amount)}
      



    #Waits for upgrades to be activated and upgrades the bar when they are
    UpgradeWait(PB : ProgressBar , Up : Upgrade, ProgressIDX : int)<suspends> : void=
        if(CP := GameManager.PlayersMap[Player] , PlayerStats := PersistanceManager.GetPlayerStats[Player]):
            race:
                block:
                    loop:
                        LeavingPlayer := GameManager.GetPlayspace().PlayerRemovedEvent().Await()
                        if(LeavingPlayer = Player):
                            break
                block:
                    ResetEvent.Await()

                block:
                    loop:
                        LoadTriggerEvent.Await()
                        if(Up.IncreaseType = increasetype.Add):
                            set PB.BarSpeed += Up.UpgradeAmount
                        else if(Up.IncreaseType = increasetype.Set):
                            set PB.BarSpeed = Up.UpgradeAmount

                        if(not Up.Reusable?):
                            break
                
                loop:
                    Up.Trigger.TriggeredEvent.Await()
                    HasEnough := CP.Check(Up.CostResources)
                    if(HasEnough?):
                        AddToPersistence(ProgressIDX, Up.IDX)

                        CP.Spend(Up.CostResources)
                        if(Up.IncreaseType = increasetype.Add):
                            set PB.BarSpeed += Up.UpgradeAmount
                        else if(Up.IncreaseType = increasetype.Set):
                            set PB.BarSpeed = Up.UpgradeAmount

                        if(Up.ChangePropSettings.Enabled?):
                            Up.ChangePropSettings.Cinematic.Play(Player)
                            Sleep(Up.ChangePropSettings.HideShowDelay)
                            Up.ChangePropSettings.Trigger.Enable()
                            Up.ChangePropSettings.Trigger.Trigger(Player)

                        if(not Up.Reusable?):
                            break


#Creative Device class
Computer_Manager := class(creative_device):
    #Devices
    @editable GameManager : Game_Manager = Game_Manager{}
    @editable PlotManager : Plot_Manager = Plot_Manager{}
    @editable OpenComputerButton : button_device = button_device{}
    @editable OpenComputerCinematic : cinematic_sequence_device = cinematic_sequence_device{}
    @editable HUDController : hud_controller_device = hud_controller_device{}
    @editable Teleporter : teleporter_device = teleporter_device{}

    #Settings
    @editable ProgressBars : []ProgressBar = array{}
    @editable CancelSettings : CancelSetting = CancelSetting{}
    @editable OpenSettings : OpenSetting = OpenSetting{}
    @editable CompletionSettings : CompletionSetting = CompletionSetting{}

    #Map of all players info
    var PlayersComputerMap : [player]PlayerComputers = map{}      

    OnBegin<override>()<suspends>:void=
        #Opens pc when button is interacted with
        OpenComputerButton.InteractedWithEvent.Subscribe(OpenPC)

        #Initializes players when they join
        Sleep(0.1)
        spawn{InitiatePlayer()}
        spawn{Reset()}


    #Used to reset computers for each player
    Reset()<suspends> : void=
        loop:
            Agent := PlotManager.ResetPlotEvent.Await()
            if(CustomPlayer := PlayersComputerMap[Agent]):
                CustomPlayer.ResetEvent.Signal()
                CustomPlayer.SetUpUpgrades()

    #Opens the Computer UI and activate other devices
    OpenPC(Agent:agent) : void=
        if(FC := Agent.GetFortCharacter[]):
            NewPC := ComputerUI{
                GameManager := GameManager
                OpenComputerCinematic := OpenComputerCinematic
                ComputerManager := Self
                CancelSettings := CancelSettings
                HUDController:= HUDController
                OpenSettings := OpenSettings
                CompletionSettings := CompletionSettings
            }
            NewPC.AddUI(Agent)
        
            spawn{TeleportStasis(Agent)}

    #Opens cinematic for player, teleports player into pc location, and freezes player
    TeleportStasis(Agent:agent)<suspends> : void=
        if(FC := Agent.GetFortCharacter[]):
            OpenComputerCinematic.Play(Agent)
            Teleporter.Teleport(Agent)
            Sleep(0.1)
            FC.PutInStasis(stasis_args{})
            
    #Initiates the players bar info
    InitiatePlayer()<suspends>: void=
        loop:
            Agent:=PlotManager.PlotClaimEvent.Await()
            if(Player := player[Agent]):    
                if(PlayerExists := PlayersComputerMap[Player]):      
                else:
                    if(set PlayersComputerMap[Player] = PlayerComputers{        
                        Player := Player
                        ProgressBars := ProgressBars
                        GameManager := GameManager
                        PlotManager := PlotManager
                        }){}
                        if(CustomPlayer := PlayersComputerMap[Player]){CustomPlayer.SetUpUpgrades()}
         

#Enums for different settings
increasetype := enum:
    Add
    Set

canceltype := enum:
    UI
    CustomInput

completetexttype := enum:
    ChangeToCompletedText
    Hide

opentype := enum:
    AutoStart
    Optional

completiontype := enum:
    Close
    Loop




#Setting for what happens upon completing when the bars fill
CompletionSetting := class<concrete>():
    @editable CompletionType : completiontype = completiontype.Close
    @editable CompleteResources : []GainableResource = array{}
    @editable CompleteTrigger : trigger_device = trigger_device{}
    @editable PopUpSettings : PopUpAnimationSetting = PopUpAnimationSetting{}

#Settings for changing props upon upgrade
ChangePropSetting := class<concrete>():
    @editable Enabled : logic = false
    @editable Cinematic : cinematic_sequence_device = cinematic_sequence_device{}
    @editable Trigger : trigger_device = trigger_device{}
    @editable HideShowDelay : float = 0.0

#Settings for when the Computer is opened
OpenSetting := class<concrete>():
    @editable OpenType : opentype = opentype.AutoStart

    @editable OptionalOpenStartButtonPosition : CanvasPosition = CanvasPosition{}
    @editable OptionalOpenStartButtonText : string = ""

    @editable OptionalOpenExitButtonPosition : CanvasPosition = CanvasPosition{}
    @editable OptionalOpenExitButtonText : string = ""

#Settings for how a player cancels
CancelSetting := class<concrete>():
    @editable CancelType : canceltype = canceltype.UI
    @editable UIExitPosition : CanvasPosition = CanvasPosition{}
    @editable CustomInputTrigger : input_trigger_device = input_trigger_device{}

#Settings for the texts for each bar
ComputerTextSetting := class<concrete>():

    @editable MainText : string = ""

    @editable MainTextDotAnimationSpeed : float = 0.0

    @editable TipText : string = ""

    @editable TipTextPosition : CanvasPosition = CanvasPosition{}
    @editable TipTextColors : TextSetting = TextSetting{}
    

    @editable MainTextPosition : CanvasPosition = CanvasPosition{}
    @editable MainTextColors : TextSetting = TextSetting{}

    @editable ProgressTextColors : TextSetting = TextSetting{}
    @editable ProgressTextPosition : CanvasPosition = CanvasPosition{}
    @editable ShouldProgressTextAppearAfterComplete : logic = false

    @editable CompletedMainTextSettings : CompletedTextSetting = CompletedTextSetting{}

#Settings for what happens to the text upon completion
CompletedTextSetting := class<concrete>():
    @editable CompletedType : completetexttype = completetexttype.ChangeToCompletedText
    @editable CompletedText : string = ""
    @editable CompletedTextColor : TextSetting = TextSetting{}

#Settings for the bar
BarSetting := class<concrete>():
    @editable AppearBeforeStarted : logic = false
    @editable AppearAfterCompleted : logic = false


    @editable BackgroundBarColor : color = color{}
    @editable ProgressBarColor : color = color{}

    @editable BarPosition : CanvasPosition = CanvasPosition{}