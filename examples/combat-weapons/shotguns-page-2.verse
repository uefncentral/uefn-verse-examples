# Shotguns Page 2
# Verse code for Shotguns Page 2 - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/shotguns-page-2?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/SpatialMath }

ShotgunsMenu := class():
    Texture : []texture = array:
        Textures.ShotgunsPng
    MenuBg : texture_block = texture_block{DefaultImage := Textures.ShotgunsPng}

    var MainCanvas : canvas = canvas{}
    var YellowButton1 : button_loud = button_loud{}
    var YellowButton2 : button_loud = button_loud{}
    var YellowButton3 : button_loud = button_loud{}
    var YellowButton4 : button_loud = button_loud{}
    var YellowButton5 : button_loud = button_loud{}
    var YellowButton6 : button_loud = button_loud{}
    var YellowButton7 : button_loud = button_loud{}
    var YellowButton8 : button_loud = button_loud{}
    var YellowButton9 : button_loud = button_loud{}
    var YellowButton10 : button_loud = button_loud{}
    var YellowButton11 : button_loud = button_loud{}
    var YellowButton12 : button_loud = button_loud{}
    var YellowButton13 : button_loud = button_loud{}
    var YellowButton14 : button_loud = button_loud{}
    var YellowButton15 : button_loud = button_loud{}
    var YellowButton16 : button_loud = button_loud{}
    var ExitButton : button_regular = button_regular{}

    var CategoryTab : CategorySelector = CategorySelector{}
    var ShGranter1 : item_granter_device = item_granter_device{}
    var ShGranter2 : item_granter_device = item_granter_device{}
    var ShGranter3 : item_granter_device = item_granter_device{}
    var ShGranter4 : item_granter_device = item_granter_device{}
    var ShGranter5 : item_granter_device = item_granter_device{}
    var ShGranter6 : item_granter_device = item_granter_device{}
    var ShGranter7 : item_granter_device = item_granter_device{}
    var ShGranter8 : item_granter_device = item_granter_device{}
    var ShGranter9 : item_granter_device = item_granter_device{}
    var ShGranter10 : item_granter_device = item_granter_device{}
    var ShGranter11 : item_granter_device = item_granter_device{}
    var ShGranter12 : item_granter_device = item_granter_device{}
    var ShGranter13 : item_granter_device = item_granter_device{}
    var ShGranter14 : item_granter_device = item_granter_device{}
    var ShGranter15 : item_granter_device = item_granter_device{}
    var ShGranter16 : item_granter_device = item_granter_device{}

    StringToMessage<localizes>(String : string) : message = "{String}"
    

    AddUI(Agent : agent) : void =
        if (Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
             set MainCanvas = CreateUI()
             PlayerUI.AddWidget(MainCanvas , player_ui_slot{InputMode := ui_input_mode.All})

    RemoveUI(Agent : agent) : void =
        if (Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
            PlayerUI.RemoveWidget(MainCanvas)

    # ExitButton
    HandleExit(Message : widget_message) : void=
        Player := Message.Player
        if(PlayerUI := GetPlayerUI[Player]):
                    PlayerUI.RemoveWidget(MainCanvas)

    OpenCategoryTab(Message : widget_message) : void=
        Player := Message.Player
        RemoveUI(Player)  # Remove the ShotgunsPage UI
        CategoryTab.RemoteOpen(Player)  # Open the CategorySelector UI

    # GunsButtons
    GrantHammer(Message : widget_message) : void=
        Player := Message.Player
        ShGranter1.GrantItem(Player)

    GrantGateKeeper(Message : widget_message) : void=
        Player := Message.Player
        ShGranter2.GrantItem(Player)

    GrantCombatGun(Message : widget_message) : void=
        Player := Message.Player
        ShGranter3.GrantItem(Player)

    GrantOGPUMP(Message : widget_message) : void=
        Player := Message.Player
        ShGranter4.GrantItem(Player)

    GrantP90SMG(Message : widget_message) : void=
        Player := Message.Player
        ShGranter5.GrantItem(Player)

    GrantBURSTSMG(Message : widget_message) : void=
        Player := Message.Player
        ShGranter6.GrantItem(Player)

    GrantHARBINGERSMG(Message : widget_message) : void=
        Player := Message.Player
        ShGranter7.GrantItem(Player)

    GrantSUPPRESSEDSMG(Message : widget_message) : void=
        Player := Message.Player
        ShGranter8.GrantItem(Player)
        
    GrantTACTICALRIFLE(Message : widget_message) : void=
        Player := Message.Player
        ShGranter9.GrantItem(Player)

    GrantHUNTRESSDMR(Message : widget_message) : void=
        Player := Message.Player
        ShGranter10.GrantItem(Player)

    GrantMKSEVEN(Message : widget_message) : void=
        Player := Message.Player
        ShGranter11.GrantItem(Player)

    GrantASSAULTRIFLE(Message : widget_message) : void=
        Player := Message.Player
        ShGranter12.GrantItem(Player)

    GrantREAPERSNIPER(Message : widget_message) : void=
        Player := Message.Player
        ShGranter13.GrantItem(Player)

    GrantEXPLOSIVEBOW(Message : widget_message) : void=
        Player := Message.Player
        ShGranter14.GrantItem(Player)

    GrantHEAVYSNIPER(Message : widget_message) : void=
        Player := Message.Player
        ShGranter15.GrantItem(Player)

    GrantHAUNTINGRIFLE(Message : widget_message) : void=
        Player := Message.Player
        ShGranter16.GrantItem(Player)

    # Buttons Texts
    CreateUI() : canvas=
        YellowButton1.SetText(StringToMessage("HAMMER"))
        YellowButton2.SetText(StringToMessage("GATEKEEPER"))
        YellowButton3.SetText(StringToMessage("COMBAT"))
        YellowButton4.SetText(StringToMessage("OG PUMP"))
        YellowButton5.SetText(StringToMessage("TACTICAL"))
        YellowButton6.SetText(StringToMessage("Charge"))
        YellowButton7.SetText(StringToMessage("Havoc"))
        YellowButton8.SetText(StringToMessage("HEAVY"))
        YellowButton9.SetText(StringToMessage("MAVEN"))
        YellowButton10.SetText(StringToMessage("BLUE PUMP"))
        YellowButton11.SetText(StringToMessage("STRIKER"))
        YellowButton12.SetText(StringToMessage("FRENZY"))
        YellowButton13.SetText(StringToMessage("LEVER"))
        YellowButton14.SetText(StringToMessage("PRIME"))
        YellowButton15.SetText(StringToMessage("THE DUB"))
        YellowButton16.SetText(StringToMessage("Thunder"))
        ExitButton.SetText(StringToMessage("EXIT"))

        ExitButton.OnClick().Subscribe(HandleExit)

        YellowButton1.OnClick().Subscribe(GrantHammer)
        YellowButton2.OnClick().Subscribe(GrantGateKeeper)
        YellowButton3.OnClick().Subscribe(GrantCombatGun)
        YellowButton4.OnClick().Subscribe(GrantOGPUMP)
        YellowButton5.OnClick().Subscribe(GrantP90SMG)
        YellowButton6.OnClick().Subscribe(GrantBURSTSMG)
        YellowButton7.OnClick().Subscribe(GrantHARBINGERSMG)
        YellowButton8.OnClick().Subscribe(GrantSUPPRESSEDSMG)
        YellowButton9.OnClick().Subscribe(GrantTACTICALRIFLE)
        YellowButton10.OnClick().Subscribe(GrantHUNTRESSDMR)
        YellowButton11.OnClick().Subscribe(GrantMKSEVEN)
        YellowButton12.OnClick().Subscribe(GrantASSAULTRIFLE)
        YellowButton13.OnClick().Subscribe(GrantREAPERSNIPER)
        YellowButton14.OnClick().Subscribe(GrantEXPLOSIVEBOW)
        YellowButton15.OnClick().Subscribe(GrantHEAVYSNIPER)
        YellowButton16.OnClick().Subscribe(GrantHAUNTINGRIFLE)

        NewUI : canvas = canvas{
            Slots := array:
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                    Offsets := margin{Left:= 0.0 , Top:= -71.682198, Right := 1920.0, Bottom := 1080.0}
                    Alignment := vector2{X:= 0.5, Y:= 0.5}
                    ZOrder := 0
                    SizeToContent := false
                    Widget := MenuBg
                canvas_slot:
                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                        Offsets := margin{Left:= -781.062317 , Top:= -324.971588, Right := 252.051086, Bottom := 42.0}
                        Alignment := vector2{X:= 0.0, Y:= 0.0}
                        ZOrder := 1
                        SizeToContent := false
                        Widget := YellowButton1
                canvas_slot:
                            Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                            Offsets := margin{Left:= -807.249207 , Top:= -86.774666, Right := 305.549713, Bottom := 42.0}
                            Alignment := vector2{X:= 0.0, Y:= 0.0}
                            ZOrder := 1
                            SizeToContent := false
                            Widget := YellowButton2
                canvas_slot:
                                Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                Offsets := margin{Left:= -781.807129 , Top:= 153.317139, Right := 251.177338, Bottom := 42.0}
                                Alignment := vector2{X:= 0.0, Y:= 0.0}
                                ZOrder := 1
                                SizeToContent := false
                                Widget := YellowButton3
                canvas_slot:
                                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                    Offsets := margin{Left:= -774.972656 , Top:= 390.750946, Right := 246.217285, Bottom := 42.0}
                                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                                    ZOrder := 1
                                    SizeToContent := false
                                    Widget := YellowButton4
                canvas_slot:
                                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                        Offsets := margin{Left:= -349.307709 , Top:= -324.971588, Right := 270.94809, Bottom := 42.0}
                                        Alignment := vector2{X:= 0.0, Y:= 0.0}
                                        ZOrder := 1
                                        SizeToContent := false
                                        Widget := YellowButton5
                canvas_slot:
                                            Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                            Offsets := margin{Left:= -341.934998 , Top:= -86.774666, Right := 244.39743, Bottom := 42.0}
                                            Alignment := vector2{X:= 0.0, Y:= 0.0}
                                            ZOrder := 1
                                            SizeToContent := false
                                            Widget := YellowButton6
                canvas_slot:
                                                Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                Offsets := margin{Left:= -332.960938 , Top:= 153.317139, Right := 223.25946, Bottom := 42.0}
                                                Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                ZOrder := 1
                                                SizeToContent := false
                                                Widget := YellowButton7
                canvas_slot:
                                                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                    Offsets := margin{Left:= -324.960938 , Top:= 390.750946, Right := 217.785767, Bottom := 42.0}
                                                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                    ZOrder := 1
                                                    SizeToContent := false
                                                    Widget := YellowButton8
                canvas_slot:
                                                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                        Offsets := margin{Left:= 104.700279 , Top:= -324.971588, Right := 223.25946, Bottom := 42.0}
                                                        Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                        ZOrder := 1
                                                        SizeToContent := false
                                                        Widget := YellowButton9
                canvas_slot:
                                                            Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                            Offsets := margin{Left:= 66.296326 , Top:= -86.774666, Right := 304.814636, Bottom := 42.0}
                                                            Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                            ZOrder := 1
                                                            SizeToContent := false
                                                            Widget := YellowButton10
                canvas_slot:
                                                                Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                                Offsets := margin{Left:= 94.828728 , Top:= 153.317139, Right := 244.369827, Bottom := 42.0}
                                                                Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                                ZOrder := 1
                                                                SizeToContent := false
                                                                Widget := YellowButton11
                canvas_slot:
                                                                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                                    Offsets := margin{Left:= 95.039062 , Top:= 390.750946, Right := 244.39743, Bottom := 42.0}
                                                                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                                    ZOrder := 1
                                                                    SizeToContent := false
                                                                    Widget := YellowButton12
                canvas_slot:
                                                                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                                        Offsets := margin{Left:= 550.056763 , Top:= -324.971588, Right := 223.25946, Bottom := 42.0}
                                                                        Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                                        ZOrder := 1
                                                                        SizeToContent := false
                                                                        Widget := YellowButton13
                canvas_slot:
                                                                            Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                                            Offsets := margin{Left:= 547.423889 , Top:= -86.774666, Right := 223.25946, Bottom := 42.0}
                                                                            Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                                            ZOrder := 1
                                                                            SizeToContent := false
                                                                            Widget := YellowButton14
                canvas_slot:
                                                                                Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                                                Offsets := margin{Left:= 538.109375 , Top:= 153.317139, Right := 249.209213, Bottom := 42.0}
                                                                                Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                                                ZOrder := 1
                                                                                SizeToContent := false
                                                                                Widget := YellowButton15
                canvas_slot:
                                                                                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                                                    Offsets := margin{Left:= 525.721069 , Top:= 390.750946, Right := 268.607025, Bottom := 42.0}                                                                   
                                                                                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                                                    ZOrder := 1
                                                                                    SizeToContent := false
                                                                                    Widget := YellowButton16
    
                canvas_slot:
                                                                                            Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                                                            Offsets := margin{Left:= -84.007301 , Top:= 476.563904, Right := 172.994003, Bottom := 50.0}
                                                                                            Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                                                            ZOrder := 1
                                                                                            SizeToContent := false
                                                                                            Widget := ExitButton
                                            
     }
    

ShotgunsPage := class(creative_device):


    @editable ShGranter1 : item_granter_device = item_granter_device{}
    @editable ShGranter2 : item_granter_device = item_granter_device{}
    @editable ShGranter3 : item_granter_device = item_granter_device{}
    @editable ShGranter4 : item_granter_device = item_granter_device{}
    @editable ShGranter5 : item_granter_device = item_granter_device{}
    @editable ShGranter6 : item_granter_device = item_granter_device{}
    @editable ShGranter7 : item_granter_device = item_granter_device{}
    @editable ShGranter8 : item_granter_device = item_granter_device{}
    @editable ShGranter9 : item_granter_device = item_granter_device{}
    @editable ShGranter10 : item_granter_device = item_granter_device{}
    @editable ShGranter11 : item_granter_device = item_granter_device{}
    @editable ShGranter12 : item_granter_device = item_granter_device{}
    @editable ShGranter13 : item_granter_device = item_granter_device{}
    @editable ShGranter14 : item_granter_device = item_granter_device{}
    @editable ShGranter15 : item_granter_device = item_granter_device{}
    @editable ShGranter16 : item_granter_device = item_granter_device{}

    RemoteOpen(Agent: agent) : void =
        var NewMenu : ShotgunsMenu = ShotgunsMenu{ShGranter1 := ShGranter1, ShGranter2 := ShGranter2, ShGranter3 := ShGranter3, ShGranter4 := ShGranter4, ShGranter5 := ShGranter5, ShGranter6 := ShGranter6, ShGranter7 := ShGranter7, ShGranter8 := ShGranter8, ShGranter9 := ShGranter9, ShGranter10 := ShGranter10, ShGranter11 := ShGranter11, ShGranter12 := ShGranter12, ShGranter13 := ShGranter13, ShGranter14 := ShGranter14, ShGranter15 := ShGranter15, ShGranter16 := ShGranter16}
        NewMenu.AddUI(Agent)