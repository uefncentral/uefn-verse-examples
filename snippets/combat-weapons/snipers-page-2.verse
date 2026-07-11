# Snipers Page 2
# Verse code for Snipers Page 2 - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/snipers-page-2?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/SpatialMath }

SnipersMenu := class():
    Texture : []texture = array:
        Textures.SnipersPng
    MenuBg : texture_block = texture_block{DefaultImage := Textures.SnipersPng}

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
    var SnGranter1 : item_granter_device = item_granter_device{}
    var SnGranter2 : item_granter_device = item_granter_device{}
    var SnGranter3 : item_granter_device = item_granter_device{}
    var SnGranter4 : item_granter_device = item_granter_device{}
    var SnGranter5 : item_granter_device = item_granter_device{}
    var SnGranter6 : item_granter_device = item_granter_device{}
    var SnGranter7 : item_granter_device = item_granter_device{}
    var SnGranter8 : item_granter_device = item_granter_device{}
    var SnGranter9 : item_granter_device = item_granter_device{}
    var SnGranter10 : item_granter_device = item_granter_device{}
    var SnGranter11 : item_granter_device = item_granter_device{}
    var SnGranter12 : item_granter_device = item_granter_device{}
    var SnGranter13 : item_granter_device = item_granter_device{}
    var SnGranter14 : item_granter_device = item_granter_device{}
    var SnGranter15 : item_granter_device = item_granter_device{}
    var SnGranter16 : item_granter_device = item_granter_device{}

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
        RemoveUI(Player)  # Remove the SnipersPage UI
        CategoryTab.RemoteOpen(Player)  # Open the CategorySelector UI

    # GunsButtons
    GrantHammer(Message : widget_message) : void=
        Player := Message.Player
        SnGranter1.GrantItem(Player)

    GrantGateKeeper(Message : widget_message) : void=
        Player := Message.Player
        SnGranter2.GrantItem(Player)

    GrantCombatGun(Message : widget_message) : void=
        Player := Message.Player
        SnGranter3.GrantItem(Player)

    GrantOGPUMP(Message : widget_message) : void=
        Player := Message.Player
        SnGranter4.GrantItem(Player)

    GrantP90SMG(Message : widget_message) : void=
        Player := Message.Player
        SnGranter5.GrantItem(Player)

    GrantBURSTSMG(Message : widget_message) : void=
        Player := Message.Player
        SnGranter6.GrantItem(Player)

    GrantHARBINGERSMG(Message : widget_message) : void=
        Player := Message.Player
        SnGranter7.GrantItem(Player)

    GrantSUPPRESSEDSMG(Message : widget_message) : void=
        Player := Message.Player
        SnGranter8.GrantItem(Player)
        
    GrantTACTICALRIFLE(Message : widget_message) : void=
        Player := Message.Player
        SnGranter9.GrantItem(Player)

    GrantHUNTRESSDMR(Message : widget_message) : void=
        Player := Message.Player
        SnGranter10.GrantItem(Player)

    GrantMKSEVEN(Message : widget_message) : void=
        Player := Message.Player
        SnGranter11.GrantItem(Player)

    GrantASSAULTRIFLE(Message : widget_message) : void=
        Player := Message.Player
        SnGranter12.GrantItem(Player)

    GrantREAPERSNIPER(Message : widget_message) : void=
        Player := Message.Player
        SnGranter13.GrantItem(Player)

    GrantEXPLOSIVEBOW(Message : widget_message) : void=
        Player := Message.Player
        SnGranter14.GrantItem(Player)

    GrantHEAVYSNIPER(Message : widget_message) : void=
        Player := Message.Player
        SnGranter15.GrantItem(Player)

    GrantHAUNTINGRIFLE(Message : widget_message) : void=
        Player := Message.Player
        SnGranter16.GrantItem(Player)

    # Buttons Texts
    CreateUI() : canvas=
        YellowButton1.SetText(StringToMessage("REAPER SNIPER"))
        YellowButton2.SetText(StringToMessage("OG HUNTING"))
        YellowButton3.SetText(StringToMessage("HEAVY IMPACT"))
        YellowButton4.SetText(StringToMessage("HEAVY SNIPER"))
        YellowButton5.SetText(StringToMessage("RAIL GUN"))
        YellowButton6.SetText(StringToMessage("BOLT ACTION"))
        YellowButton7.SetText(StringToMessage("STORM SCOUT"))
        YellowButton8.SetText(StringToMessage("SEMI AUTO SNP"))
        YellowButton9.SetText(StringToMessage("HUNTER BOLT"))
        YellowButton10.SetText(StringToMessage("OG BOLT ACTION"))
        YellowButton11.SetText(StringToMessage("AUTOMATIC SNP"))
        YellowButton12.SetText(StringToMessage("LEVER ACTION"))
        YellowButton13.SetText(StringToMessage("HUNTING RIFLE"))
        YellowButton14.SetText(StringToMessage("EXPLOSIVE SNP"))
        YellowButton15.SetText(StringToMessage("DRAGON SNP"))
        YellowButton16.SetText(StringToMessage("BOOM SNIPER"))
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
                        Offsets := margin{Left:= -844.143799 , Top:= -324.971619, Right := 383.966064, Bottom := 42.0}
                        Alignment := vector2{X:= 0.0, Y:= 0.0}
                        ZOrder := 1
                        SizeToContent := false
                        Widget := YellowButton1
                canvas_slot:
                            Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                            Offsets := margin{Left:= -816.957703 , Top:= -86.774689, Right := 326.589447, Bottom := 42.0}
                            Alignment := vector2{X:= 0.0, Y:= 0.0}
                            ZOrder := 1
                            SizeToContent := false
                            Widget := YellowButton2
                canvas_slot:
                                Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                Offsets := margin{Left:= -841.831543 , Top:= 153.3172, Right := 380.172363, Bottom := 42.0}
                                Alignment := vector2{X:= 0.0, Y:= 0.0}
                                ZOrder := 1
                                SizeToContent := false
                                Widget := YellowButton3
                canvas_slot:
                                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                    Offsets := margin{Left:= -835.468506 , Top:= 390.750946, Right := 367.386658, Bottom := 42.0}
                                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                                    ZOrder := 1
                                    SizeToContent := false
                                    Widget := YellowButton4
                canvas_slot:
                                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                        Offsets := margin{Left:= -351.270111 , Top:= -324.971619, Right := 267.929199, Bottom := 42.0}
                                        Alignment := vector2{X:= 0.0, Y:= 0.0}
                                        ZOrder := 1
                                        SizeToContent := false
                                        Widget := YellowButton5
                canvas_slot:
                                            Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                            Offsets := margin{Left:= -381.770996 , Top:= -86.774689, Right := 339.882263, Bottom := 42.0}
                                            Alignment := vector2{X:= 0.0, Y:= 0.0}
                                            ZOrder := 1
                                            SizeToContent := false
                                            Widget := YellowButton6
                canvas_slot:
                                                Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                Offsets := margin{Left:= -395.850128 , Top:= 153.3172, Right := 359.65506, Bottom := 42.0}
                                                Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                ZOrder := 1
                                                SizeToContent := false
                                                Widget := YellowButton7
                canvas_slot:
                                                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                    Offsets := margin{Left:= -403.616547 , Top:= 390.750977, Right := 379.83551, Bottom := 42.0}
                                                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                    ZOrder := 1
                                                    SizeToContent := false
                                                    Widget := YellowButton8
                canvas_slot:
                                                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                        Offsets := margin{Left:= 47.656528 , Top:= -324.971619, Right := 352.20813, Bottom := 42.0}
                                                        Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                        ZOrder := 1
                                                        SizeToContent := false
                                                        Widget := YellowButton9
                canvas_slot:
                                                            Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                            Offsets := margin{Left:= 19.962511 , Top:= -86.774689, Right := 408.323517, Bottom := 42.0}
                                                            Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                            ZOrder := 1
                                                            SizeToContent := false
                                                            Widget := YellowButton10
                canvas_slot:
                                                                Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                                Offsets := margin{Left:= 17.929821 , Top:= 153.3172, Right := 409.829224, Bottom := 42.0}
                                                                Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                                ZOrder := 1
                                                                SizeToContent := false
                                                                Widget := YellowButton11
                canvas_slot:
                                                                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                                    Offsets := margin{Left:= 43.604801 , Top:= 390.750977, Right := 361.70575, Bottom := 42.0}
                                                                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                                    ZOrder := 1
                                                                    SizeToContent := false
                                                                    Widget := YellowButton12
                canvas_slot:
                                                                        Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                                        Offsets := margin{Left:= 474.091644 , Top:= -324.971619, Right := 370.207184, Bottom := 42.0}
                                                                        Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                                        ZOrder := 1
                                                                        SizeToContent := false
                                                                        Widget := YellowButton13
                canvas_slot:
                                                                            Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                                            Offsets := margin{Left:= 466.018127 , Top:= -86.774689, Right := 384.860535, Bottom := 42.0}
                                                                            Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                                            ZOrder := 1
                                                                            SizeToContent := false
                                                                            Widget := YellowButton14
                canvas_slot:
                                                                                Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                                                Offsets := margin{Left:= 487.757538 , Top:= 153.3172, Right := 339.095825, Bottom := 42.0}
                                                                                Alignment := vector2{X:= 0.0, Y:= 0.0}
                                                                                ZOrder := 1
                                                                                SizeToContent := false
                                                                                Widget := YellowButton15
                canvas_slot:
                                                                                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                                                                                    Offsets := margin{Left:= 484.255646 , Top:= 390.750977, Right := 349.602966, Bottom := 42.0}                                                                   
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
    

SnipersPage := class(creative_device):

    @editable SnGranter1 : item_granter_device = item_granter_device{}
    @editable SnGranter2 : item_granter_device = item_granter_device{}
    @editable SnGranter3 : item_granter_device = item_granter_device{}
    @editable SnGranter4 : item_granter_device = item_granter_device{}
    @editable SnGranter5 : item_granter_device = item_granter_device{}
    @editable SnGranter6 : item_granter_device = item_granter_device{}
    @editable SnGranter7 : item_granter_device = item_granter_device{}
    @editable SnGranter8 : item_granter_device = item_granter_device{}
    @editable SnGranter9 : item_granter_device = item_granter_device{}
    @editable SnGranter10 : item_granter_device = item_granter_device{}
    @editable SnGranter11 : item_granter_device = item_granter_device{}
    @editable SnGranter12 : item_granter_device = item_granter_device{}
    @editable SnGranter13 : item_granter_device = item_granter_device{}
    @editable SnGranter14 : item_granter_device = item_granter_device{}
    @editable SnGranter15 : item_granter_device = item_granter_device{}
    @editable SnGranter16 : item_granter_device = item_granter_device{}

    

    RemoteOpen(Agent: agent) : void =
        var NewMenu : SnipersMenu  = SnipersMenu {SnGranter1 := SnGranter1, SnGranter2 := SnGranter2, SnGranter3 := SnGranter3, SnGranter4 := SnGranter4, SnGranter5 := SnGranter5, SnGranter6 := SnGranter6, SnGranter7 := SnGranter7, SnGranter8 := SnGranter8, SnGranter9 := SnGranter9, SnGranter10 := SnGranter10, SnGranter11 := SnGranter11, SnGranter12 := SnGranter12, SnGranter13 := SnGranter13, SnGranter14 := SnGranter14, SnGranter15 := SnGranter15, SnGranter16 := SnGranter16}
        NewMenu.AddUI(Agent)