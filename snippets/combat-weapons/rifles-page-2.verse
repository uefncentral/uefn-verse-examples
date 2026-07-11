# Rifles Page 2
# Verse code for Rifles Page 2 - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/rifles-page-2?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/SpatialMath }

RiflesMenu := class():
    Texture : []texture = array:
        Textures.RiflesPng
    MenuBg : texture_block = texture_block{DefaultImage := Textures.RiflesPng}

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
    var RfGranter1 : item_granter_device = item_granter_device{}
    var RfGranter2 : item_granter_device = item_granter_device{}
    var RfGranter3 : item_granter_device = item_granter_device{}
    var RfGranter4 : item_granter_device = item_granter_device{}
    var RfGranter5 : item_granter_device = item_granter_device{}
    var RfGranter6 : item_granter_device = item_granter_device{}
    var RfGranter7 : item_granter_device = item_granter_device{}
    var RfGranter8 : item_granter_device = item_granter_device{}
    var RfGranter9 : item_granter_device = item_granter_device{}
    var RfGranter10 : item_granter_device = item_granter_device{}
    var RfGranter11 : item_granter_device = item_granter_device{}
    var RfGranter12 : item_granter_device = item_granter_device{}
    var RfGranter13 : item_granter_device = item_granter_device{}
    var RfGranter14 : item_granter_device = item_granter_device{}
    var RfGranter15 : item_granter_device = item_granter_device{}
    var RfGranter16 : item_granter_device = item_granter_device{}

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
        RemoveUI(Player)  # Remove the RiflesPage UI
        CategoryTab.RemoteOpen(Player)  # Open the CategorySelector UI

    # GunsButtons
    GrantHammer(Message : widget_message) : void=
        Player := Message.Player
        RfGranter1.GrantItem(Player)

    GrantGateKeeper(Message : widget_message) : void=
        Player := Message.Player
        RfGranter2.GrantItem(Player)

    GrantCombatGun(Message : widget_message) : void=
        Player := Message.Player
        RfGranter3.GrantItem(Player)

    GrantOGPUMP(Message : widget_message) : void=
        Player := Message.Player
        RfGranter4.GrantItem(Player)

    GrantP90SMG(Message : widget_message) : void=
        Player := Message.Player
        RfGranter5.GrantItem(Player)

    GrantBURSTSMG(Message : widget_message) : void=
        Player := Message.Player
        RfGranter6.GrantItem(Player)

    GrantHARBINGERSMG(Message : widget_message) : void=
        Player := Message.Player
        RfGranter7.GrantItem(Player)

    GrantSUPPRESSEDSMG(Message : widget_message) : void=
        Player := Message.Player
        RfGranter8.GrantItem(Player)
        
    GrantTACTICALRIFLE(Message : widget_message) : void=
        Player := Message.Player
        RfGranter9.GrantItem(Player)

    GrantHUNTRESSDMR(Message : widget_message) : void=
        Player := Message.Player
        RfGranter10.GrantItem(Player)

    GrantMKSEVEN(Message : widget_message) : void=
        Player := Message.Player
        RfGranter11.GrantItem(Player)

    GrantASSAULTRIFLE(Message : widget_message) : void=
        Player := Message.Player
        RfGranter12.GrantItem(Player)

    GrantREAPERSNIPER(Message : widget_message) : void=
        Player := Message.Player
        RfGranter13.GrantItem(Player)

    GrantEXPLOSIVEBOW(Message : widget_message) : void=
        Player := Message.Player
        RfGranter14.GrantItem(Player)

    GrantHEAVYSNIPER(Message : widget_message) : void=
        Player := Message.Player
        RfGranter15.GrantItem(Player)

    GrantHAUNTINGRIFLE(Message : widget_message) : void=
        Player := Message.Player
        RfGranter16.GrantItem(Player)

    # Buttons Texts
    CreateUI() : canvas=
        YellowButton1.SetText(StringToMessage("TACTICAL AR"))
        YellowButton2.SetText(StringToMessage("Htrss DMR"))
        YellowButton3.SetText(StringToMessage("MK-SEVENN"))
        YellowButton4.SetText(StringToMessage("OG SCAR"))
        YellowButton5.SetText(StringToMessage("ASSAULT RIFLE"))
        YellowButton6.SetText(StringToMessage("WARFORGED AR"))
        YellowButton7.SetText(StringToMessage("NEMESIS AR"))
        YellowButton8.SetText(StringToMessage("ENFORCER AR"))
        YellowButton9.SetText(StringToMessage("AUG AR"))
        YellowButton10.SetText(StringToMessage("HEAVY AR"))
        YellowButton11.SetText(StringToMessage("COMBAT AR"))
        YellowButton12.SetText(StringToMessage("supp AR"))
        YellowButton13.SetText(StringToMessage("HAVOC AR"))
        YellowButton14.SetText(StringToMessage("INFANTRY AR"))
        YellowButton15.SetText(StringToMessage("BURST AR"))
        YellowButton16.SetText(StringToMessage("OG TACTICAL AR"))
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
                        Offsets := margin{Left:= -824.048706 , Top:= -324.971588, Right := 337.939728, Bottom := 42.0}
                        Alignment := vector2{X:= 0.0, Y:= 0.0}
                        ZOrder := 1
                        SizeToContent := false
                        Widget := YellowButton1
                canvas_slot:
                            Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                            Offsets := margin{Left:= -807.740845 , Top:= -86.774666, Right := 309.203857, Bottom := 42.0}
                            Alignment := vector2{X:= 0.0, Y:= 0.0}
                            ZOrder := 1
                            SizeToContent := false
                            Widget := YellowButton2
                canvas_slot:
                                Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                Offsets := margin{Left:= -798.660889 , Top:= 153.317139, Right := 288.464386, Bottom := 42.0}
                                Alignment := vector2{X:= 0.0, Y:= 0.0}
                                ZOrder := 1
                                SizeToContent := false
                                Widget := YellowButton3
                canvas_slot:
                                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                    Offsets := margin{Left:= -779.944885 , Top:= 390.750946, Right := 256.446533, Bottom := 42.0}
                                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                                    ZOrder := 1
                                    SizeToContent := false
                                    Widget := YellowButton4
                canvas_slot:
                                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                        Offsets := margin{Left:= -403.591492 , Top:= -324.971588, Right := 379.472137, Bottom := 42.0}
                                        Alignment := vector2{X:= 0.0, Y:= 0.0}
                                        ZOrder := 1
                                        SizeToContent := false
                                        Widget := YellowButton5
                canvas_slot:
                                            Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                            Offsets := margin{Left:= -408.292114 , Top:= -86.774666, Right := 391.67984, Bottom := 42.0}
                                            Alignment := vector2{X:= 0.0, Y:= 0.0}
                                            ZOrder := 1
                                            SizeToContent := false
                                            Widget := YellowButton6
                canvas_slot:
                                                Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                Offsets := margin{Left:= -377.492432, Top:= 153.317139, Right := 325.68634, Bottom := 42.0}
                                                Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                ZOrder := 1
                                                SizeToContent := false
                                                Widget := YellowButton7
                canvas_slot:
                                                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                    Offsets := margin{Left:= -389.67395, Top:= 390.750946, Right := 353.788696, Bottom := 42.0}
                                                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                    ZOrder := 1
                                                    SizeToContent := false
                                                    Widget := YellowButton8
                canvas_slot:
                                                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                        Offsets := margin{Left:= 100.982254 , Top:= -324.971588, Right := 237.584274, Bottom := 42.0}
                                                        Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                        ZOrder := 1
                                                        SizeToContent := false
                                                        Widget := YellowButton9
                canvas_slot:
                                                            Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                            Offsets := margin{Left:= 77.523903 , Top:= -86.774666, Right := 286.827087, Bottom := 42.0}
                                                            Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                            ZOrder := 1
                                                            SizeToContent := false
                                                            Widget := YellowButton10
                canvas_slot:
                                                                Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                                Offsets := margin{Left:= 64.970688 , Top:= 153.317139, Right := 315.155914, Bottom := 42.0}
                                                                Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                                ZOrder := 1
                                                                SizeToContent := false
                                                                Widget := YellowButton11
                canvas_slot:
                                                                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                                    Offsets := margin{Left:= 92.519386 , Top:= 390.750946, Right := 256.275848, Bottom := 42.0}
                                                                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                                    ZOrder := 1
                                                                    SizeToContent := false
                                                                    Widget := YellowButton12
                canvas_slot:
                                                                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                                        Offsets := margin{Left:= 511.360321 , Top:= -324.971588, Right := 289.298523, Bottom := 42.0}
                                                                        Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                                        ZOrder := 1
                                                                        SizeToContent := false
                                                                        Widget := YellowButton13
                canvas_slot:
                                                                            Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                                            Offsets := margin{Left:= 482.829437 , Top:= -86.774666, Right := 344.843628, Bottom := 42.0}
                                                                            Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                                            ZOrder := 1
                                                                            SizeToContent := false
                                                                            Widget := YellowButton14
                canvas_slot:
                                                                                Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                                                Offsets := margin{Left:= 514.214172 , Top:= 153.317139, Right := 277.497101, Bottom := 42.0}
                                                                                Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                                                ZOrder := 1
                                                                                SizeToContent := false
                                                                                Widget := YellowButton15
                canvas_slot:
                                                                                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                                                    Offsets := margin{Left:= 454.786469 , Top:= 390.750946, Right := 403.543518, Bottom := 42.0}                                                                   
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
     return NewUI

RiflesPage := class(creative_device):


    @editable RfGranter1 : item_granter_device = item_granter_device{}
    @editable RfGranter2 : item_granter_device = item_granter_device{}
    @editable RfGranter3 : item_granter_device = item_granter_device{}
    @editable RfGranter4 : item_granter_device = item_granter_device{}
    @editable RfGranter5 : item_granter_device = item_granter_device{}
    @editable RfGranter6 : item_granter_device = item_granter_device{}
    @editable RfGranter7 : item_granter_device = item_granter_device{}
    @editable RfGranter8 : item_granter_device = item_granter_device{}
    @editable RfGranter9 : item_granter_device = item_granter_device{}
    @editable RfGranter10 : item_granter_device = item_granter_device{}
    @editable RfGranter11 : item_granter_device = item_granter_device{}
    @editable RfGranter12 : item_granter_device = item_granter_device{}
    @editable RfGranter13 : item_granter_device = item_granter_device{}
    @editable RfGranter14 : item_granter_device = item_granter_device{}
    @editable RfGranter15 : item_granter_device = item_granter_device{}
    @editable RfGranter16 : item_granter_device = item_granter_device{}
    
    RemoteOpen(Agent: agent) : void =
        var NewMenu : RiflesMenu = RiflesMenu{RfGranter1 := RfGranter1, RfGranter2 := RfGranter2, RfGranter3 := RfGranter3, RfGranter4 := RfGranter4, RfGranter5 := RfGranter5, RfGranter6 := RfGranter6, RfGranter7 := RfGranter7, RfGranter8 := RfGranter8, RfGranter9 := RfGranter9, RfGranter10 := RfGranter10, RfGranter11 := RfGranter11, RfGranter12 := RfGranter12, RfGranter13 := RfGranter13, RfGranter14 := RfGranter14, RfGranter15 := RfGranter15, RfGranter16 := RfGranter16}
        NewMenu.AddUI(Agent)
