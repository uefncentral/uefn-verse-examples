# Admin Panel Controller
# Verse code for Admin Panel Controller - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/admin-panel-controller?ref=github

using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors/NamedColors }
using { /Verse.org/Simulation }


AdminTrigger := class<concrete>():
    @editable SelectedTrigger : trigger_device = trigger_device{}
    @editable Name : string = ""


AdminPanelController := class(creative_device):

    
    var AdminAbusePlayerMap : [player]logic = map{}

    @editable EnableAdminAbuseTrigger : trigger_device = trigger_device{}
    @editable DisableAdminAbuseTrigger : trigger_device = trigger_device{}
    @editable OpenAdminPanelTrigger : trigger_device = trigger_device{}
    @editable AdminTriggers : []AdminTrigger = array{}
    @editable MainTP : teleporter_device = teleporter_device{}
    @editable FlightClassSelector : class_and_team_selector_device = class_and_team_selector_device{}
    @editable NonFlightClassSelector : class_and_team_selector_device = class_and_team_selector_device{}


    OnBegin<override>()<suspends>:void=
        for(Player : GetPlayspace().GetPlayers()):
            InitializePlayer(Player)
        GetPlayspace().PlayerAddedEvent().Subscribe(InitializePlayer)
        EnableAdminAbuseTrigger.TriggeredEvent.Subscribe(EnableAdminAbuse)
        DisableAdminAbuseTrigger.TriggeredEvent.Subscribe(DisableAdminAbuse)
        OpenAdminPanelTrigger.TriggeredEvent.Subscribe(OpenAdminPanel)

    EnableAdminAbuse(MAgent : ?agent) : void=
        if(Agent := MAgent?):
            if:
                set AdminAbusePlayerMap[player[Agent]] = true

    DisableAdminAbuse(MAgent : ?agent) : void=
        if(Agent := MAgent?):
            if:
                set AdminAbusePlayerMap[player[Agent]] = false


    InitializePlayer(Player : player) : void=
        if(not AdminAbusePlayerMap[Player]):
            if:
                set AdminAbusePlayerMap[Player] = false


    OpenAdminPanel(MAgent : ?agent) : void=
        if(Agent := MAgent?):
            if(HasAdminAbuse := AdminAbusePlayerMap[player[Agent]]):
                if(HasAdminAbuse?):
                    NewAdminPanel := AdminPanelClass{AdminPanelControllerDevice := Self}
                    NewAdminPanel.AddUI(Agent)




PlayerSelectClass := class():
    Player : player
    PlayerCanvas : canvas
    PlayerNameText : text_block
    ActivateButton : button_loud

TriggerSelectClass := class():
    Trigger : trigger_device
    TriggerCanvas : canvas
    ActivateButton : button_loud


NAText<localizes>:message = "N/A"
AdminPanelClass := class():
    var AdminPanelControllerDevice : AdminPanelController = AdminPanelController{}
    var MainPanelCanvas : canvas = canvas{}
    var BackgroundColorBlock : color_block = color_block{DefaultColor := Black, DefaultOpacity := 0.5}
    var PlayerStackBox : stack_box = stack_box{Orientation := orientation.Vertical}

    var TriggerStackBox : stack_box = stack_box{Orientation := orientation.Vertical}
    var TriggerSelectClasses : []TriggerSelectClass = array{}

    var CurrentlySelectedText : text_block = text_block{DefaultText := NAText , DefaultTextColor := White}

    var TeleportToButton : button_loud = button_loud{}
    var TeleportToYouButton : button_loud = button_loud{}
    var FreezeButton : button_loud = button_loud{}
    var UnFreezeButton : button_loud = button_loud{}
    var KillButton : button_loud = button_loud{}
    var FlightOn : button_loud = button_loud{}
    var FlightOff : button_loud = button_loud{}
    var InvisOn : button_loud = button_loud{}
    var InvisOff : button_loud = button_loud{}
    var InvinceOn : button_loud = button_loud{}
    var InvinceOff : button_loud = button_loud{}
    var ActivateForAllButton : button_loud = button_loud{}
    var CloseButton : button_loud = button_loud{}


    UIClosedEvent : event() = event(){}
    


    StringToMessage<localizes>(String : string) : message = "{String}"
    AgentToMessage<localizes>(Agent : agent) : message = "{Agent}"

    AddUI(Agent : agent) : void=
        if(Player := player[Agent] , PlayerUI := GetPlayerUI[Player]):
            MainPanelCanvas.AddWidget(
                canvas_slot{Anchors := anchors{Minimum := vector2{X := 0.5, Y:= 0.5} , Maximum := vector2{X := 0.5, Y:= 0.5}} ,Alignment := vector2{X:= 0.5 , Y:= 0.5} ,  SizeToContent := false , ZOrder := 0 ,
                    Widget := BackgroundColorBlock,
                    Offsets := margin{Left := 0.0 , Top := 0.0 , Right := 1920.0 , Bottom := 1080.0}})
            MainPanelCanvas.AddWidget(
                canvas_slot{Anchors := anchors{Minimum := vector2{X := 0.5, Y:= 0.5} , Maximum := vector2{X := 0.5, Y:= 0.5}} ,Alignment := vector2{X:= 0.5 , Y:= 0.5} ,  SizeToContent := false , ZOrder := 1 ,
                    Widget := PlayerStackBox,
                    Offsets := margin{Left := 575.0 , Top := 100.0 , Right := 700.0 , Bottom := 800.0}})
            MainPanelCanvas.AddWidget(
                canvas_slot{Anchors := anchors{Minimum := vector2{X := 0.5, Y:= 0.5} , Maximum := vector2{X := 0.5, Y:= 0.5}} ,Alignment := vector2{X:= 0.5 , Y:= 0.5} ,  SizeToContent := false , ZOrder := 1 ,
                    Widget := TriggerStackBox,
                    Offsets := margin{Left := -763.0 , Top := 30.0 , Right := 300.0 , Bottom := 925.0}})
            MainPanelCanvas.AddWidget(
                canvas_slot{Anchors := anchors{Minimum := vector2{X := 0.5, Y:= 0.5} , Maximum := vector2{X := 0.5, Y:= 0.5}} ,Alignment := vector2{X:= 0.5 , Y:= 0.5} ,  SizeToContent := false , ZOrder := 1 ,
                    Widget := CurrentlySelectedText,
                    Offsets := margin{Left := -220.0 , Top := -480.0 , Right := 165.0 , Bottom := 40.0}})
            MainPanelCanvas.AddWidget(
                canvas_slot{Anchors := anchors{Minimum := vector2{X := 0.5, Y:= 0.5} , Maximum := vector2{X := 0.5, Y:= 0.5}} ,Alignment := vector2{X:= 0.5 , Y:= 0.5} ,  SizeToContent := false , ZOrder := 1 ,
                    Widget := TeleportToButton,
                    Offsets := margin{Left := -395.0 , Top := -365.0 , Right := 375.0 , Bottom := 60.0}})
            MainPanelCanvas.AddWidget(
                canvas_slot{Anchors := anchors{Minimum := vector2{X := 0.5, Y:= 0.5} , Maximum := vector2{X := 0.5, Y:= 0.5}} ,Alignment := vector2{X:= 0.5 , Y:= 0.5} ,  SizeToContent := false , ZOrder := 1 ,
                    Widget := TeleportToYouButton,
                    Offsets := margin{Left := -20.0 , Top := -365.0 , Right := 375.0 , Bottom := 60.0}})
            MainPanelCanvas.AddWidget(
                canvas_slot{Anchors := anchors{Minimum := vector2{X := 0.5, Y:= 0.5} , Maximum := vector2{X := 0.5, Y:= 0.5}} ,Alignment := vector2{X:= 0.5 , Y:= 0.5} ,  SizeToContent := false , ZOrder := 1 ,
                    Widget := FreezeButton,
                    Offsets := margin{Left := -395.0 , Top := -250.0 , Right := 375.0 , Bottom := 60.0}})
            MainPanelCanvas.AddWidget(
                canvas_slot{Anchors := anchors{Minimum := vector2{X := 0.5, Y:= 0.5} , Maximum := vector2{X := 0.5, Y:= 0.5}} ,Alignment := vector2{X:= 0.5 , Y:= 0.5} ,  SizeToContent := false , ZOrder := 1 ,
                    Widget := UnFreezeButton,
                    Offsets := margin{Left := -20.0 , Top := -250.0 , Right := 375.0 , Bottom := 60.0}})
            MainPanelCanvas.AddWidget(
                canvas_slot{Anchors := anchors{Minimum := vector2{X := 0.5, Y:= 0.5} , Maximum := vector2{X := 0.5, Y:= 0.5}} ,Alignment := vector2{X:= 0.5 , Y:= 0.5} ,  SizeToContent := false , ZOrder := 1 ,
                    Widget := KillButton,
                    Offsets := margin{Left := -395.0 , Top := 102.0 , Right := 375.0 , Bottom := 60.0}})
            MainPanelCanvas.AddWidget(
                canvas_slot{Anchors := anchors{Minimum := vector2{X := 0.5, Y:= 0.5} , Maximum := vector2{X := 0.5, Y:= 0.5}} ,Alignment := vector2{X:= 0.5 , Y:= 0.5} ,  SizeToContent := false , ZOrder := 1 ,
                    Widget := FlightOn,
                    Offsets := margin{Left := -395.0 , Top := -140.0 , Right := 375.0 , Bottom := 60.0}})
            MainPanelCanvas.AddWidget(
                canvas_slot{Anchors := anchors{Minimum := vector2{X := 0.5, Y:= 0.5} , Maximum := vector2{X := 0.5, Y:= 0.5}} ,Alignment := vector2{X:= 0.5 , Y:= 0.5} ,  SizeToContent := false , ZOrder := 1 ,
                    Widget := FlightOff,
                    Offsets := margin{Left := -20.0 , Top := -140.0 , Right := 375.0 , Bottom := 60.0}})
            MainPanelCanvas.AddWidget(
                canvas_slot{Anchors := anchors{Minimum := vector2{X := 0.5, Y:= 0.5} , Maximum := vector2{X := 0.5, Y:= 0.5}} ,Alignment := vector2{X:= 0.5 , Y:= 0.5} ,  SizeToContent := false , ZOrder := 1 ,
                    Widget := InvisOn,
                    Offsets := margin{Left := -395.0 , Top := -13.0 , Right := 375.0 , Bottom := 60.0}})
            MainPanelCanvas.AddWidget(
                canvas_slot{Anchors := anchors{Minimum := vector2{X := 0.5, Y:= 0.5} , Maximum := vector2{X := 0.5, Y:= 0.5}} ,Alignment := vector2{X:= 0.5 , Y:= 0.5} ,  SizeToContent := false , ZOrder := 1 ,
                    Widget := InvisOff,
                    Offsets := margin{Left := -20.0 , Top := -13.0 , Right := 375.0 , Bottom := 60.0}})
            MainPanelCanvas.AddWidget(
                canvas_slot{Anchors := anchors{Minimum := vector2{X := 0.5, Y:= 0.5} , Maximum := vector2{X := 0.5, Y:= 0.5}} ,Alignment := vector2{X:= 0.5 , Y:= 0.5} ,  SizeToContent := false , ZOrder := 1 ,
                    Widget := InvinceOn,
                    Offsets := margin{Left := -395.0 , Top := 215.0 , Right := 375.0 , Bottom := 60.0}})
            MainPanelCanvas.AddWidget(
                canvas_slot{Anchors := anchors{Minimum := vector2{X := 0.5, Y:= 0.5} , Maximum := vector2{X := 0.5, Y:= 0.5}} ,Alignment := vector2{X:= 0.5 , Y:= 0.5} ,  SizeToContent := false , ZOrder := 1 ,
                    Widget := InvinceOff,
                    Offsets := margin{Left := -20.0 , Top := 215.0 , Right := 375.0 , Bottom := 60.0}})
            MainPanelCanvas.AddWidget(
                canvas_slot{Anchors := anchors{Minimum := vector2{X := 0.5, Y:= 0.5} , Maximum := vector2{X := 0.5, Y:= 0.5}} ,Alignment := vector2{X:= 0.5 , Y:= 0.5} ,  SizeToContent := false , ZOrder := 1 ,
                    Widget := ActivateForAllButton,
                    Offsets := margin{Left := 560.0 , Top := 440.0 , Right := 580.0 , Bottom := 60.0}})
            MainPanelCanvas.AddWidget(
                canvas_slot{Anchors := anchors{Minimum := vector2{X := 0.5, Y:= 0.5} , Maximum := vector2{X := 0.5, Y:= 0.5}} ,Alignment := vector2{X:= 0.5 , Y:= 0.5} ,  SizeToContent := false , ZOrder := 1 ,
                    Widget := CloseButton,
                    Offsets := margin{Left := -220.0 , Top := 440.0 , Right := 580.0 , Bottom := 60.0}})
            
            for(PlayerInGame : AdminPanelControllerDevice.GetPlayspace().GetPlayers()):
                NewPlayerSelect := PlayerSelectClass{
                    Player := PlayerInGame
                    PlayerCanvas := canvas{}
                    PlayerNameText := text_block{DefaultText := AgentToMessage(PlayerInGame)}
                    ActivateButton := button_loud{DefaultText := StringToMessage("Select")}
                }
                NewPlayerSelect.PlayerCanvas.AddWidget(
                    canvas_slot{Anchors := anchors{Minimum := vector2{X := 0.5, Y:= 0.5} , Maximum := vector2{X := 0.5, Y:= 0.5}} ,Alignment := vector2{X:= 0.5 , Y:= 0.5} ,  SizeToContent := false , ZOrder := 1 ,
                        Widget := NewPlayerSelect.PlayerNameText,
                        Offsets := margin{Left := -255.0 , Top := 0.0 , Right := 200.0 , Bottom := 40.0}})
                NewPlayerSelect.PlayerCanvas.AddWidget(
                    canvas_slot{Anchors := anchors{Minimum := vector2{X := 0.5, Y:= 0.5} , Maximum := vector2{X := 0.5, Y:= 0.5}} ,Alignment := vector2{X:= 0.5 , Y:= 0.5} ,  SizeToContent := false , ZOrder := 1 ,
                        Widget := NewPlayerSelect.ActivateButton,
                        Offsets := margin{Left := 200.0 , Top := 0.0 , Right := 300.0 , Bottom := 40.0}})
                PlayerStackBox.AddWidget(stack_box_slot{Widget := NewPlayerSelect.PlayerCanvas})
                spawn{TrackPlayerSelectedButton(NewPlayerSelect)}

            for(AdminTrig : AdminPanelControllerDevice.AdminTriggers):
                NewTriggerSelect := TriggerSelectClass{
                    Trigger := AdminTrig.SelectedTrigger
                    TriggerCanvas := canvas{}
                    ActivateButton := button_loud{DefaultText := StringToMessage(AdminTrig.Name)}
                }
                NewTriggerSelect.TriggerCanvas.AddWidget(
                    canvas_slot{Anchors := anchors{Minimum := vector2{X := 0.5, Y:= 0.5} , Maximum := vector2{X := 0.5, Y:= 0.5}} ,Alignment := vector2{X:= 0.5 , Y:= 0.5} ,  SizeToContent := false , ZOrder := 1 ,
                        Widget := NewTriggerSelect.ActivateButton,
                        Offsets := margin{Left := 0.0 , Top := 0.0 , Right := 300.0 , Bottom := 40.0}})
                TriggerStackBox.AddWidget(stack_box_slot{Widget := NewTriggerSelect.TriggerCanvas})
                spawn{TrackTriggerSelectedButton(NewTriggerSelect)}
                set TriggerSelectClasses += array{NewTriggerSelect}

            TeleportToButton.SetText(StringToMessage("Teleport To"))
            TeleportToYouButton.SetText(StringToMessage("Teleport To You"))
            FreezeButton.SetText(StringToMessage("Freeze"))
            UnFreezeButton.SetText(StringToMessage("Unfreeze"))
            KillButton.SetText(StringToMessage("Kill"))
            FlightOn.SetText(StringToMessage("Flight On"))
            FlightOff.SetText(StringToMessage("Flight Off"))
            InvisOn.SetText(StringToMessage("Invisibility On"))
            InvisOff.SetText(StringToMessage("Invisibility Off"))
            InvinceOn.SetText(StringToMessage("Invincibility On"))
            InvinceOff.SetText(StringToMessage("Invincibility Off"))
            ActivateForAllButton.SetText(StringToMessage("Activate For All"))
            CloseButton.SetText(StringToMessage("Close Admin Panel"))
            spawn{TrackAllButtons()}
            PlayerUI.AddWidget(MainPanelCanvas , player_ui_slot{InputMode := ui_input_mode.All})
            
    TrackAllButtons()<suspends> : void=
        race:
            block:
                loop:
                    TeleportToButton.OnClick().Await()
                    HandleButtonSelection(TeleportToButton.GetText())
            block:
                loop:
                    TeleportToYouButton.OnClick().Await()
                    HandleButtonSelection(TeleportToYouButton.GetText())
            block:
                loop:
                    FreezeButton.OnClick().Await()
                    HandleButtonSelection(FreezeButton.GetText())
            block:
                loop:
                    UnFreezeButton.OnClick().Await()
                    HandleButtonSelection(UnFreezeButton.GetText())
            block:
                loop:
                    KillButton.OnClick().Await()
                    HandleButtonSelection(KillButton.GetText())
            block:
                loop:
                    FlightOn.OnClick().Await()
                    HandleButtonSelection(FlightOn.GetText())
            block:
                loop:
                    FlightOff.OnClick().Await()
                    HandleButtonSelection(FlightOff.GetText())
            block:
                loop:
                    InvisOn.OnClick().Await()
                    HandleButtonSelection(InvisOn.GetText())
            block:
                loop:
                    InvisOff.OnClick().Await()
                    HandleButtonSelection(InvisOff.GetText())
            block:
                loop:
                    InvinceOn.OnClick().Await()
                    HandleButtonSelection(InvinceOn.GetText())
            block:
                loop:
                    InvinceOff.OnClick().Await()
                    HandleButtonSelection(InvinceOff.GetText())
            block:
                loop:
                    Message := ActivateForAllButton.OnClick().Await()
                    for(NewPlayer : AdminPanelControllerDevice.GetPlayspace().GetPlayers() , NewPlayer <> Message.Player):
                        HandlePlayerSelection(Message.Player , NewPlayer)
            block:
                loop:
                    Message := CloseButton.OnClick().Await()
                    HandleUIClose(Message.Player)

            block:
                UIClosedEvent.Await()

    HandleUIClose(Player : player) : void=
        if(PlayerUI := GetPlayerUI[Player]):
            PlayerUI.RemoveWidget(MainPanelCanvas)
            UIClosedEvent.Signal()

    TrackTriggerSelectedButton(NewTriggerSelect : TriggerSelectClass)<suspends> : void=
        race:
            block:
                loop:
                    NewTriggerSelect.ActivateButton.OnClick().Await()
                    HandleButtonSelection(NewTriggerSelect.ActivateButton.GetText())

            block:
                UIClosedEvent.Await()

    TrackPlayerSelectedButton(NewPlayerSelect : PlayerSelectClass)<suspends> : void=
        race:
            block:
                loop:
                    Message := NewPlayerSelect.ActivateButton.OnClick().Await()
                    HandlePlayerSelection(Message.Player , NewPlayerSelect.Player)

            block:
                UIClosedEvent.Await()


    HandleButtonSelection(NewName : string) : void=
        CurrentlySelectedText.SetText(StringToMessage(NewName))

    HandlePlayerSelection(AdminPlayer : player , SelectedPlayer : player) : void=
        SelectedText := CurrentlySelectedText.GetText()
        if(AdminFC := AdminPlayer.GetFortCharacter[] , SelectedFC := SelectedPlayer.GetFortCharacter[]):
            if(SelectedText = "Teleport To"):
                AdminPanelControllerDevice.MainTP.TeleportTo[SelectedFC.GetTransform()] or Print("Teleport Failed")
                AdminPanelControllerDevice.MainTP.Teleport(AdminPlayer)
            if(SelectedText = "Teleport To You"):
                AdminPanelControllerDevice.MainTP.TeleportTo[AdminFC.GetTransform()] or Print("Teleport Failed")
                AdminPanelControllerDevice.MainTP.Teleport(SelectedPlayer)
            if(SelectedText = "Freeze"):
                SelectedFC.PutInStasis(stasis_args{})
            if(SelectedText = "Unfreeze"):
                SelectedFC.ReleaseFromStasis()
            if(SelectedText = "Kill"):
                SelectedFC.Damage(10000.0)
            if(SelectedText = "Flight On"):
                AdminPanelControllerDevice.FlightClassSelector.ChangeClass(SelectedPlayer)
            if(SelectedText = "Flight Off"):
                AdminPanelControllerDevice.NonFlightClassSelector.ChangeClass(SelectedPlayer)
            if(SelectedText = "Invisibility On"):
                SelectedFC.Hide()
            if(SelectedText = "Invisibility Off"):
                SelectedFC.Show()
            if(SelectedText = "Invincibility On"):
                SelectedFC.SetVulnerability(false)
            if(SelectedText = "Invincibility Off"):
                SelectedFC.SetVulnerability(true)
            for(Trig : TriggerSelectClasses):
                TriggerText := Trig.ActivateButton.GetText()
                if(SelectedText = TriggerText):
                    Trig.Trigger.Trigger(SelectedPlayer)