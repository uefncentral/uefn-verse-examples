# Phone Teleporter UI
# Creates a phone-style UI interface with teleportation buttons that allow players to quickly travel to different locations in the map. The interface includes multiple teleport options and an exit butto
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/phone-device-1?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors/NamedColors }
using { /UnrealEngine.com/Temporary/SpatialMath }


Phone := class():
    var MainCanvas : canvas = canvas{}
    var PhoneImage : color_block = color_block{DefaultColor := Black}
    var TeleportButton1 : button_quiet = button_quiet{}
    var TeleportButton2 : button_quiet = button_quiet{}
    var TeleportButton3 : button_quiet = button_quiet{}
    var ExitButton : button_loud = button_loud{}

    var Teleporter1 : teleporter_device = teleporter_device{}
    var Teleporter2 : teleporter_device = teleporter_device{}
    var Teleporter3 : []teleporter_device = array{}

    ToMessage<localizes>(String : string) : message = "{String}"
    
    AddUI(Agent : agent) : void=
        if(Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
            set MainCanvas = CreateUI()
            PlayerUI.AddWidget(MainCanvas , player_ui_slot{InputMode := ui_input_mode.All})

    HandleExit(Message : widget_message) : void=
        Player := Message.Player
        if(PlayerUI := GetPlayerUI[Player]):
            PlayerUI.RemoveWidget(MainCanvas)

    Teleport1Player(Message : widget_message) : void=
        Player := Message.Player
        Teleporter1.Teleport(Player)
        if(PlayerUI := GetPlayerUI[Player]):
            PlayerUI.RemoveWidget(MainCanvas)

    Teleport2Player(Message : widget_message) : void=
        Player := Message.Player
        Teleporter2.Teleport(Player)
        if(PlayerUI := GetPlayerUI[Player]):
            PlayerUI.RemoveWidget(MainCanvas)

    Teleport3Player(Message : widget_message) : void=
        Player := Message.Player
        
        for(Teleporter : Teleporter3):
            Teleporter.Teleport(Player)

        if(PlayerUI := GetPlayerUI[Player]):
            PlayerUI.RemoveWidget(MainCanvas)

    CreateUI() : canvas=
        TeleportButton1.SetText(ToMessage("Teleport 1"))
        TeleportButton2.SetText(ToMessage("Teleport 2"))
        TeleportButton3.SetText(ToMessage("Teleport 3"))
        ExitButton.SetText(ToMessage("Exit"))

        ExitButton.OnClick().Subscribe(HandleExit)
        TeleportButton1.OnClick().Subscribe(Teleport1Player)
        TeleportButton2.OnClick().Subscribe(Teleport2Player)
        TeleportButton3.OnClick().Subscribe(Teleport3Player)

        

        NewUI : canvas = canvas{
            Slots := array:
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:= 0.5, Y:= 0.5}, Maximum := vector2{X:= 0.5, Y:= 0.5}}
                    Offsets := margin{Left := 0.0, Top := 0.0, Right := 640.0 , Bottom:= 800.0}
                    Alignment := vector2{X:= 0.5, Y:= 0.5}
                    ZOrder := 0
                    SizeToContent := false
                    Widget := PhoneImage
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:= 0.5, Y:= 0.5}, Maximum := vector2{X:= 0.5, Y:= 0.5}}
                    Offsets := margin{Left := 0.0, Top := -150.0, Right := 330.0 , Bottom:= 120.0}
                    Alignment := vector2{X:= 0.5, Y:= 0.5}
                    ZOrder := 1
                    SizeToContent := false
                    Widget := TeleportButton1
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:= 0.5, Y:= 0.5}, Maximum := vector2{X:= 0.5, Y:= 0.5}}
                    Offsets := margin{Left := 0.0, Top := 0.0, Right := 330.0 , Bottom:= 120.0}
                    Alignment := vector2{X:= 0.5, Y:= 0.5}
                    ZOrder := 1
                    SizeToContent := false
                    Widget := TeleportButton2
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:= 0.5, Y:= 0.5}, Maximum := vector2{X:= 0.5, Y:= 0.5}}
                    Offsets := margin{Left := 0.0, Top := 150.0, Right := 330.0 , Bottom:= 120.0}
                    Alignment := vector2{X:= 0.5, Y:= 0.5}
                    ZOrder := 1
                    SizeToContent := false
                    Widget := TeleportButton3
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:= 0.5, Y:= 0.5}, Maximum := vector2{X:= 0.5, Y:= 0.5}}
                    Offsets := margin{Left := 0.0, Top := 300.0, Right := 330.0 , Bottom:= 120.0}
                    Alignment := vector2{X:= 0.5, Y:= 0.5}
                    ZOrder := 1
                    SizeToContent := false
                    Widget := ExitButton
        }



Phone_device := class(creative_device):

    @editable RemoteManager : signal_remote_manager_device = signal_remote_manager_device{}

    @editable Teleporter1 : teleporter_device = teleporter_device{}
    @editable Teleporter2 : teleporter_device = teleporter_device{}
    @editable Teleporter3 : []teleporter_device = array{}





    OnBegin<override>()<suspends>:void=
        RemoteManager.PrimarySignalEvent.Subscribe(RemoteOpen)

    RemoteOpen(Agent:agent) : void=
        var NewPhone : Phone = Phone{Teleporter1 := Teleporter1, Teleporter2 := Teleporter2, Teleporter3 := Teleporter3}
        NewPhone.AddUI(Agent)