# Mobility Item Menu System
# Creates a custom UI menu with 16 buttons that grant different mobility items to players through item_granter_devices. Features a categorized interface with yellow buttons for item selection and an exi
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/mobilitiespage-1?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/SpatialMath }

MobilitiesMenu := class():
    Texture : []texture = array:
        Texturess.SnipersPng
    MenuBg : texture_block = texture_block{DefaultImage := Texturess.MobilitiesPng}

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
    var MbGranter1 : item_granter_device = item_granter_device{}
    var MbGranter2 : item_granter_device = item_granter_device{}
    var MbGranter3 : item_granter_device = item_granter_device{}
    var MbGranter4 : item_granter_device = item_granter_device{}
    var MbGranter5 : item_granter_device = item_granter_device{}
    var MbGranter6 : item_granter_device = item_granter_device{}
    var MbGranter7 : item_granter_device = item_granter_device{}
    var MbGranter8 : item_granter_device = item_granter_device{}
    var MbGranter9 : item_granter_device = item_granter_device{}
    var MbGranter10 : item_granter_device = item_granter_device{}
    var MbGranter11 : item_granter_device = item_granter_device{}
    var MbGranter12 : item_granter_device = item_granter_device{}
    var MbGranter13 : item_granter_device = item_granter_device{}
    var MbGranter14 : item_granter_device = item_granter_device{}
    var MbGranter15 : item_granter_device = item_granter_device{}
    var MbGranter16 : item_granter_device = item_granter_device{}

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
        RemoveUI(Player)  # Remove the MobilitiesPage UI
        CategoryTab.RemoteOpen(Player)  # Open the CategorySelector UI

    # GunsButtons
    GrantHammer(Message : widget_message) : void=
        Player := Message.Player
        MbGranter1.GrantItem(Player)

    GrantGateKeeper(Message : widget_message) : void=
        Player := Message.Player
        MbGranter2.GrantItem(Player)

    GrantCombatGun(Message : widget_message) : void=
        Player := Message.Player
        MbGranter3.GrantItem(Player)

    GrantOGPUMP(Message : widget_message) : void=
        Player := Message.Player
        MbGranter4.GrantItem(Player)

    GrantP90SMG(Message : widget_message) : void=
        Player := Message.Player
        MbGranter5.GrantItem(Player)

    GrantBURSTSMG(Message : widget_message) : void=
        Player := Message.Player
        MbGranter6.GrantItem(Player)

    GrantHARBINGERSMG(Message : widget_message) : void=
        Player := Message.Player
        MbGranter7.GrantItem(Player)

    GrantSUPPRESSEDSMG(Message : widget_message) : void=
        Player := Message.Player
        MbGranter8.GrantItem(Player)
        
    GrantTACTICALRIFLE(Message : widget_message) : void=
        Player := Message.Player
        MbGranter9.GrantItem(Player)

    GrantHUNTRESSDMR(Message : widget_message) : void=
        Player := Message.Player
        MbGranter10.GrantItem(Player)

    GrantMKSEVEN(Message : widget_message) : void=
        Player := Message.Player
        MbGranter11.GrantItem(Player)

    GrantASSAULTRIFLE(Message : widget_message) : void=
        Player := Message.Player
        MbGranter12.GrantItem(Player)

    GrantREAPERSNIPER(Message : widget_message) : void=
        Player := Message.Player
        MbGranter13.GrantItem(Player)

    GrantEXPLOSIVEBOW(Message : widget_message) : void=
        Player := Message.Player
        MbGranter14.GrantItem(Player)

    GrantHEAVYSNIPER(Message : widget_message) : void=
        Player := Message.Player
        MbGranter15.GrantItem(Player)

    GrantHAUNTINGRIFLE(Message : widget_message) : void=
        Player := Message.Player
        MbGranter16.GrantItem(Player)

    # Buttons Texts
    CreateUI() : canvas=
        YellowButton1.SetText(StringToMessage("Witch Broom"))
        YellowButton2.SetText(StringToMessage("Grappler"))
        YellowButton3.SetText(StringToMessage("Bull Toy"))
        YellowButton4.SetText(StringToMessage("Blades"))
        YellowButton5.SetText(StringToMessage("Rocket Ram"))
        YellowButton6.SetText(StringToMessage("Hammer"))
        YellowButton7.SetText(StringToMessage("Crash Pad Jr"))
        YellowButton8.SetText(StringToMessage("Fizz"))
        YellowButton9.SetText(StringToMessage("Grapple Glove"))
        YellowButton10.SetText(StringToMessage("FLOWBERRY"))
        YellowButton11.SetText(StringToMessage("DASH FISH"))
        YellowButton12.SetText(StringToMessage("Nitro Fists"))
        YellowButton13.SetText(StringToMessage("Nitro Splash"))
        YellowButton14.SetText(StringToMessage("Crash Pad"))
        YellowButton15.SetText(StringToMessage("SHOCKWAVE"))
        YellowButton16.SetText(StringToMessage("SLAP SPLASH"))
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
                        Offsets := margin{Left:= -829.334229 , Top:= -324.191437, Right := 351.250092, Bottom := 42.0}
                        Alignment := vector2{X:= 0.0, Y:= 0.0}
                        ZOrder := 1
                        SizeToContent := false
                        Widget := YellowButton1
                canvas_slot:
                            Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                            Offsets := margin{Left:= -797.61377 , Top:= -86.774666, Right := 289.36554, Bottom := 42.0}
                            Alignment := vector2{X:= 0.0, Y:= 0.0}
                            ZOrder := 1
                            SizeToContent := false
                            Widget := YellowButton2
                canvas_slot:
                                Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                Offsets := margin{Left:= -789.345581 , Top:= 150.882141, Right := 267.771393, Bottom := 42.0}
                                Alignment := vector2{X:= 0.0, Y:= 0.0}
                                ZOrder := 1
                                SizeToContent := false
                                Widget := YellowButton3
                canvas_slot:
                                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                    Offsets := margin{Left:= -771.254333 , Top:= 388.565247, Right := 236.963852, Bottom := 42.0}
                                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                                    ZOrder := 1
                                    SizeToContent := false
                                    Widget := YellowButton4
                canvas_slot:
                                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                        Offsets := margin{Left:= -381.832642 , Top:= -324.191437, Right := 331.174805, Bottom := 42.0}
                                        Alignment := vector2{X:= 0.0, Y:= 0.0}
                                        ZOrder := 1
                                        SizeToContent := false
                                        Widget := YellowButton5
                canvas_slot:
                                            Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                            Offsets := margin{Left:= -341.49585 , Top:= -86.774666, Right := 256.409698, Bottom := 42.0}
                                            Alignment := vector2{X:= 0.0, Y:= 0.0}
                                            ZOrder := 1
                                            SizeToContent := false
                                            Widget := YellowButton6
                canvas_slot:
                                                Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                Offsets := margin{Left:= -391.033966 , Top:= 150.882141, Right := 354.083649, Bottom := 42.0}
                                                Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                ZOrder := 1
                                                SizeToContent := false
                                                Widget := YellowButton7
                canvas_slot:
                                                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                    Offsets := margin{Left:= -297.851959 , Top:= 388.565247, Right := 166.434906, Bottom := 42.0}
                                                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                    ZOrder := 1
                                                    SizeToContent := false
                                                    Widget := YellowButton8
                canvas_slot:
                                                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                        Offsets := margin{Left:= 27.362274, Top:= -324.191437, Right := 391.046997, Bottom := 42.0}
                                                        Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                        ZOrder := 1
                                                        SizeToContent := false
                                                        Widget := YellowButton9
                canvas_slot:
                                                            Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                            Offsets := margin{Left:= 62.375046 , Top:= -86.774666, Right := 320.558807, Bottom := 42.0}
                                                            Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                            ZOrder := 1
                                                            SizeToContent := false
                                                            Widget := YellowButton10
                canvas_slot:
                                                                Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                                Offsets := margin{Left:= 81.363243 , Top:= 150.882141, Right := 289.73703, Bottom := 42.0}
                                                                Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                                ZOrder := 1
                                                                SizeToContent := false
                                                                Widget := YellowButton11
                canvas_slot:
                                                                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                                    Offsets := margin{Left:= 63.601936 , Top:= 388.565247, Right := 315.947784, Bottom := 42.0}
                                                                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                                    ZOrder := 1
                                                                    SizeToContent := false
                                                                    Widget := YellowButton12
                canvas_slot:
                                                                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                                        Offsets := margin{Left:= 489.500153 , Top:= -324.191437, Right := 341.056519, Bottom := 42.0}
                                                                        Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                                        ZOrder := 1
                                                                        SizeToContent := false
                                                                        Widget := YellowButton13
                canvas_slot:
                                                                            Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                                            Offsets := margin{Left:= 500.760223 , Top:= -86.774666, Right := 311.798676, Bottom := 42.0}
                                                                            Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                                            ZOrder := 1
                                                                            SizeToContent := false
                                                                            Widget := YellowButton14
                canvas_slot:
                                                                                Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                                                Offsets := margin{Left:= 490.691376, Top:= 150.882141, Right := 339.992432, Bottom := 42.0}
                                                                                Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                                                ZOrder := 1
                                                                                SizeToContent := false
                                                                                Widget := YellowButton15
                canvas_slot:
                                                                                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                                                    Offsets := margin{Left:= 486.555756 , Top:= 388.565247, Right := 344.152313, Bottom := 42.0}                                                                   
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
    

MobilitiesPage := class(creative_device):

    @editable MbGranter1 : item_granter_device = item_granter_device{}
    @editable MbGranter2 : item_granter_device = item_granter_device{}
    @editable MbGranter3 : item_granter_device = item_granter_device{}
    @editable MbGranter4 : item_granter_device = item_granter_device{}
    @editable MbGranter5 : item_granter_device = item_granter_device{}
    @editable MbGranter6 : item_granter_device = item_granter_device{}
    @editable MbGranter7 : item_granter_device = item_granter_device{}
    @editable MbGranter8 : item_granter_device = item_granter_device{}
    @editable MbGranter9 : item_granter_device = item_granter_device{}
    @editable MbGranter10 : item_granter_device = item_granter_device{}
    @editable MbGranter11 : item_granter_device = item_granter_device{}
    @editable MbGranter12 : item_granter_device = item_granter_device{}
    @editable MbGranter13 : item_granter_device = item_granter_device{}
    @editable MbGranter14 : item_granter_device = item_granter_device{}
    @editable MbGranter15 : item_granter_device = item_granter_device{}
    @editable MbGranter16 : item_granter_device = item_granter_device{}

    

    RemoteOpen(Agent: agent) : void =
        var NewMenu : MobilitiesMenu  = MobilitiesMenu {MbGranter1 := MbGranter1, MbGranter2 := MbGranter2, MbGranter3 := MbGranter3, MbGranter4 := MbGranter4, MbGranter5 := MbGranter5, MbGranter6 := MbGranter6, MbGranter7 := MbGranter7, MbGranter8 := MbGranter8, MbGranter9 := MbGranter9, MbGranter10 := MbGranter10, MbGranter11 := MbGranter11, MbGranter12 := MbGranter12, MbGranter13 := MbGranter13, MbGranter14 := MbGranter14, MbGranter15 := MbGranter15, MbGranter16 := MbGranter16}
        NewMenu.AddUI(Agent)