# SMG Weapon Menu
# Creates a custom UI menu with 16 buttons for selecting and granting different SMG weapons to players. The menu features a background texture and exit functionality, connecting UI buttons to item grant
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/smgs-page-1?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/SpatialMath }

SmgsMenu := class():
    Texture : []texture = array:
        Texturess.SmgsPng
    MenuBg : texture_block = texture_block{DefaultImage := Texturess.SmgsPng}

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
    var SmGranter1 : item_granter_device = item_granter_device{}
    var SmGranter2 : item_granter_device = item_granter_device{}
    var SmGranter3 : item_granter_device = item_granter_device{}
    var SmGranter4 : item_granter_device = item_granter_device{}
    var SmGranter5 : item_granter_device = item_granter_device{}
    var SmGranter6 : item_granter_device = item_granter_device{}
    var SmGranter7 : item_granter_device = item_granter_device{}
    var SmGranter8 : item_granter_device = item_granter_device{}
    var SmGranter9 : item_granter_device = item_granter_device{}
    var SmGranter10 : item_granter_device = item_granter_device{}
    var SmGranter11 : item_granter_device = item_granter_device{}
    var SmGranter12 : item_granter_device = item_granter_device{}
    var SmGranter13 : item_granter_device = item_granter_device{}
    var SmGranter14 : item_granter_device = item_granter_device{}
    var SmGranter15 : item_granter_device = item_granter_device{}
    var SmGranter16 : item_granter_device = item_granter_device{}

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
        RemoveUI(Player)  # Remove the Smgs_Page UI
        CategoryTab.RemoteOpen(Player)  # Open the CategorySelector UI

    # GunsButtons
    GrantHammer(Message : widget_message) : void=
        Player := Message.Player
        SmGranter1.GrantItem(Player)

    GrantGateKeeper(Message : widget_message) : void=
        Player := Message.Player
        SmGranter2.GrantItem(Player)

    GrantCombatGun(Message : widget_message) : void=
        Player := Message.Player
        SmGranter3.GrantItem(Player)

    GrantOGPUMP(Message : widget_message) : void=
        Player := Message.Player
        SmGranter4.GrantItem(Player)

    GrantP90SMG(Message : widget_message) : void=
        Player := Message.Player
        SmGranter5.GrantItem(Player)

    GrantBURSTSMG(Message : widget_message) : void=
        Player := Message.Player
        SmGranter6.GrantItem(Player)

    GrantHARBINGERSMG(Message : widget_message) : void=
        Player := Message.Player
        SmGranter7.GrantItem(Player)

    GrantSUPPRESSEDSMG(Message : widget_message) : void=
        Player := Message.Player
        SmGranter8.GrantItem(Player)
        
    GrantTACTICALRIFLE(Message : widget_message) : void=
        Player := Message.Player
        SmGranter9.GrantItem(Player)

    GrantHUNTRESSDMR(Message : widget_message) : void=
        Player := Message.Player
        SmGranter10.GrantItem(Player)

    GrantMKSEVEN(Message : widget_message) : void=
        Player := Message.Player
        SmGranter11.GrantItem(Player)

    GrantASSAULTRIFLE(Message : widget_message) : void=
        Player := Message.Player
        SmGranter12.GrantItem(Player)

    GrantREAPERSNIPER(Message : widget_message) : void=
        Player := Message.Player
        SmGranter13.GrantItem(Player)

    GrantEXPLOSIVEBOW(Message : widget_message) : void=
        Player := Message.Player
        SmGranter14.GrantItem(Player)

    GrantHEAVYSNIPER(Message : widget_message) : void=
        Player := Message.Player
        SmGranter15.GrantItem(Player)

    GrantHAUNTINGRIFLE(Message : widget_message) : void=
        Player := Message.Player
        SmGranter16.GrantItem(Player)

    # Buttons Texts
    CreateUI() : canvas=
        YellowButton1.SetText(StringToMessage("P90 SMG"))
        YellowButton2.SetText(StringToMessage("BURST SMG"))
        YellowButton3.SetText(StringToMessage("HARBINGER"))
        YellowButton4.SetText(StringToMessage("SUPP SMG"))
        YellowButton5.SetText(StringToMessage("SCOPED SMG"))
        YellowButton6.SetText(StringToMessage("OG BURST"))
        YellowButton7.SetText(StringToMessage("COMBAT SMG"))
        YellowButton8.SetText(StringToMessage("SUBMACHINE"))
        YellowButton9.SetText(StringToMessage("HYPER SMG"))
        YellowButton10.SetText(StringToMessage("TWIN MAG"))
        YellowButton11.SetText(StringToMessage("TACTICAL SMG"))
        YellowButton12.SetText(StringToMessage("MACHINE SMG"))
        YellowButton13.SetText(StringToMessage("CHARGE SMG"))
        YellowButton14.SetText(StringToMessage("RAPID FIRE"))
        YellowButton15.SetText(StringToMessage("PRIMAL SMG"))
        YellowButton16.SetText(StringToMessage("STINGER"))
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
                        Offsets := margin{Left:= -781.062317 , Top:= -324.971588, Right := 256.114716, Bottom := 42.0}
                        Alignment := vector2{X:= 0.0, Y:= 0.0}
                        ZOrder := 1
                        SizeToContent := false
                        Widget := YellowButton1
                canvas_slot:
                            Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                            Offsets := margin{Left:= -807.249207 , Top:= -86.774666, Right := 305.793762, Bottom := 42.0}
                            Alignment := vector2{X:= 0.0, Y:= 0.0}
                            ZOrder := 1
                            SizeToContent := false
                            Widget := YellowButton2
                canvas_slot:
                                Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                Offsets := margin{Left:= -810.695557 , Top:= 151.244354, Right := 310.811829, Bottom := 42.0}
                                Alignment := vector2{X:= 0.0, Y:= 0.0}
                                ZOrder := 1
                                SizeToContent := false
                                Widget := YellowButton3
                canvas_slot:
                                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                    Offsets := margin{Left:= -796.301941 , Top:= 388.254883, Right := 286.693909, Bottom := 42.0}
                                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                                    ZOrder := 1
                                    SizeToContent := false
                                    Widget := YellowButton4
                canvas_slot:
                                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                        Offsets := margin{Left:= -379.69931 , Top:= -324.971588, Right := 330.673492, Bottom := 42.0}
                                        Alignment := vector2{X:= 0.0, Y:= 0.0}
                                        ZOrder := 1
                                        SizeToContent := false
                                        Widget := YellowButton5
                canvas_slot:
                                            Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                            Offsets := margin{Left:= -352.029327 , Top:= -86.774666, Right := 276.648071, Bottom := 42.0}
                                            Alignment := vector2{X:= 0.0, Y:= 0.0}
                                            ZOrder := 1
                                            SizeToContent := false
                                            Widget := YellowButton6
                canvas_slot:
                                                Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                Offsets := margin{Left:= -387.787628 , Top:= 151.244354, Right := 347.02121, Bottom := 42.0}
                                                Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                ZOrder := 1
                                                SizeToContent := false
                                                Widget := YellowButton7
                canvas_slot:
                                                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                    Offsets := margin{Left:= -383.849854 , Top:= 388.254883, Right := 342.380157, Bottom := 42.0}
                                                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                    ZOrder := 1
                                                    SizeToContent := false
                                                    Widget := YellowButton8
                canvas_slot:
                                                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                        Offsets := margin{Left:= 69.978897 , Top:= -324.971588, Right := 308.928223, Bottom := 42.0}
                                                        Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                        ZOrder := 1
                                                        SizeToContent := false
                                                        Widget := YellowButton9
                canvas_slot:
                                                            Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                            Offsets := margin{Left:= 81.153229 , Top:= -86.774666, Right := 285.68161, Bottom := 42.0}
                                                            Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                            ZOrder := 1
                                                            SizeToContent := false
                                                            Widget := YellowButton10
                canvas_slot:
                                                                Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                                Offsets := margin{Left:= 40.665733 , Top:= 151.244354, Right := 366.818573, Bottom := 42.0}
                                                                Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                                ZOrder := 1
                                                                SizeToContent := false
                                                                Widget := YellowButton11
                canvas_slot:
                                                                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                                    Offsets := margin{Left:= 45.383621 , Top:= 388.254883, Right := 357.76828, Bottom := 42.0}
                                                                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                                    ZOrder := 1
                                                                    SizeToContent := false
                                                                    Widget := YellowButton12
                canvas_slot:
                                                                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                                        Offsets := margin{Left:= 488.889069 , Top:= -324.971588, Right := 339.815216, Bottom := 42.0}
                                                                        Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                                        ZOrder := 1
                                                                        SizeToContent := false
                                                                        Widget := YellowButton13
                canvas_slot:
                                                                            Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                                            Offsets := margin{Left:= 511.582184 , Top:= -86.774666, Right := 298.599762, Bottom := 42.0}
                                                                            Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                                            ZOrder := 1
                                                                            SizeToContent := false
                                                                            Widget := YellowButton14
                canvas_slot:
                                                                                Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                                                Offsets := margin{Left:= 494.1875 , Top:= 151.244354, Right := 326.671326, Bottom := 42.0}
                                                                                Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                                                ZOrder := 1
                                                                                SizeToContent := false
                                                                                Widget := YellowButton15
                canvas_slot:
                                                                                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                                                    Offsets := margin{Left:= 537.293457 , Top:= 388.254883, Right := 248.146118, Bottom := 42.0}                                                                   
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
    

Smgs_Page := class(creative_device):

    @editable SmGranter1 : item_granter_device = item_granter_device{}
    @editable SmGranter2 : item_granter_device = item_granter_device{}
    @editable SmGranter3 : item_granter_device = item_granter_device{}
    @editable SmGranter4 : item_granter_device = item_granter_device{}
    @editable SmGranter5 : item_granter_device = item_granter_device{}
    @editable SmGranter6 : item_granter_device = item_granter_device{}
    @editable SmGranter7 : item_granter_device = item_granter_device{}
    @editable SmGranter8 : item_granter_device = item_granter_device{}
    @editable SmGranter9 : item_granter_device = item_granter_device{}
    @editable SmGranter10 : item_granter_device = item_granter_device{}
    @editable SmGranter11 : item_granter_device = item_granter_device{}
    @editable SmGranter12 : item_granter_device = item_granter_device{}
    @editable SmGranter13 : item_granter_device = item_granter_device{}
    @editable SmGranter14 : item_granter_device = item_granter_device{}
    @editable SmGranter15 : item_granter_device = item_granter_device{}
    @editable SmGranter16 : item_granter_device = item_granter_device{}


    RemoteOpen(Agent: agent) : void =
        var NewMenu : SmgsMenu = SmgsMenu{SmGranter1 := SmGranter1, SmGranter2 := SmGranter2, SmGranter3 := SmGranter3, SmGranter4 := SmGranter4, SmGranter5 := SmGranter5, SmGranter6 := SmGranter6, SmGranter7 := SmGranter7, SmGranter8 := SmGranter8, SmGranter9 := SmGranter9, SmGranter10 := SmGranter10, SmGranter11 := SmGranter11, SmGranter12 := SmGranter12, SmGranter13 := SmGranter13, SmGranter14 := SmGranter14, SmGranter15 := SmGranter15, SmGranter16 := SmGranter16}
        NewMenu.AddUI(Agent)