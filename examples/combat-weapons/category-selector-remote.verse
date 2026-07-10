# Category Selector Remote
# Verse code for Category Selector Remote - UEFN/Fortnite Creative implementation
# Difficulty: intermediate  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/category-selector-remote?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/SpatialMath }

Category := class():
    Texture : []texture = array:
        Textures.CategoriesPng
    CatBG : texture_block = texture_block{DefaultImage := Textures.CategoriesPng}

    var MainCanvas : canvas = canvas{}
    var ShotgunsButton : button_regular = button_regular{}
    var SmgsButton : button_regular = button_regular{}
    var RiflesButton : button_regular = button_regular{}
    var SnipersButton : button_regular = button_regular{}
    var MobilitiesButton : button_regular = button_regular{}
    var HealsButton : button_regular = button_regular{}
    var ExitButton : button_regular = button_regular{}

    var ShotgunsTab : ShotgunsPage = ShotgunsPage{}
    var SmgsTab : Smgs_Page = Smgs_Page{}
    var RiflesTab : RiflesPage = RiflesPage{}
    var SnipersTab : SnipersPage = SnipersPage{}
    var MobilitiesTab : MobilitiesPage = MobilitiesPage{}
    var HealsTab : HealsPage = HealsPage{}

    AddUI(Agent : agent) : void =
        if (Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
            set MainCanvas = CreateUI()
            PlayerUI.AddWidget(MainCanvas , player_ui_slot{InputMode := ui_input_mode.All})

    RemoveUI(Agent : agent) : void =
        if (Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
            PlayerUI.RemoveWidget(MainCanvas)

    HandleExit(Message : widget_message) : void=
        Player := Message.Player
        if(PlayerUI := GetPlayerUI[Player]):
            PlayerUI.RemoveWidget(MainCanvas)

    StringToMessage<localizes>(String : string) : message = "{String}"

    OpenShotgunsTab(Message : widget_message) : void=
        Player := Message.Player
        RemoveUI(Player)  # Remove the Category UI
        ShotgunsTab.RemoteOpen(Player)  # Open the Shotguns UI

    OpenSmgsTab(Message : widget_message) : void=
        Player := Message.Player
        RemoveUI(Player)  # Remove the Category UI
        SmgsTab.RemoteOpen(Player)  # Open the SMGs UI

    OpenRiflesTab(Message : widget_message) : void=
        Player := Message.Player
        RemoveUI(Player)  # Remove the Category UI
        RiflesTab.RemoteOpen(Player)  # Open the Rifless UI

    OpenSnipersTab(Message : widget_message) : void=
        Player := Message.Player
        RemoveUI(Player)  # Remove the Category UI
        SnipersTab.RemoteOpen(Player)  # Open the Snipers UI

    OpenMobilitiesTab(Message : widget_message) : void=
        Player := Message.Player
        RemoveUI(Player)  # Remove the Category UI
        MobilitiesTab.RemoteOpen(Player)  # Open the Mobilities UI

    OpenHealsTab(Message : widget_message) : void=
        Player := Message.Player
        RemoveUI(Player)  # Remove the Category UI
        HealsTab.RemoteOpen(Player)  # Open the Heals UI

    CreateUI() : canvas=
        ShotgunsButton.SetText(StringToMessage("Shotguns"))
        SmgsButton.SetText(StringToMessage("Smgs"))
        RiflesButton.SetText(StringToMessage("Rifles"))
        SnipersButton.SetText(StringToMessage("Snipers"))
        MobilitiesButton.SetText(StringToMessage("Mobilities"))
        HealsButton.SetText(StringToMessage("Heals"))
        ExitButton.SetText(StringToMessage("Exit"))

        ExitButton.OnClick().Subscribe(HandleExit)
        ShotgunsButton.OnClick().Subscribe(OpenShotgunsTab)
        SmgsButton.OnClick().Subscribe(OpenSmgsTab)
        RiflesButton.OnClick().Subscribe(OpenRiflesTab)
        SnipersButton.OnClick().Subscribe(OpenSnipersTab)
        MobilitiesButton.OnClick().Subscribe(OpenMobilitiesTab)
        HealsButton.OnClick().Subscribe(OpenHealsTab)

        NewUI : canvas = canvas{
            Slots := array:
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                    Offsets := margin{Left:= 0.0 , Top:= -56.618191, Right := 1920.0, Bottom := 1080.0}
                    Alignment := vector2{X:= 0.5, Y:= 0.5}
                    ZOrder := 0
                    SizeToContent := false
                    Widget := CatBG

                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                    Offsets := margin{Left:= -516.960938 , Top:= -133.946884, Right := 278.178192, Bottom := 52.012012}
                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                    ZOrder := 1
                    SizeToContent := false
                    Widget := ShotgunsButton

                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                    Offsets := margin{Left:= -76.960938 , Top:= -133.946884, Right := 200.100113, Bottom := 52.012012}
                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                    ZOrder := 1
                    SizeToContent := false
                    Widget := SmgsButton

                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                    Offsets := margin{Left:= 311.039062 , Top:= -133.946884, Right := 223.900391, Bottom := 52.012012}
                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                    ZOrder := 1
                    SizeToContent := false
                    Widget := RiflesButton

                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                    Offsets := margin{Left:= -498.797394 , Top:= 279.38385, Right := 246.843704, Bottom := 52.012012}
                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                    ZOrder := 1
                    SizeToContent := false
                    Widget := SnipersButton

                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                    Offsets := margin{Left:= -118.834885 , Top:= 279.38385, Right := 284.803192, Bottom := 52.012012}
                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                    ZOrder := 1
                    SizeToContent := false
                    Widget := MobilitiesButton

                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                    Offsets := margin{Left:= 315.98114 , Top:= 279.38385, Right := 219.816681, Bottom := 52.012012}
                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                    ZOrder := 1
                    SizeToContent := false
                    Widget := HealsButton

                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:=0.5, Y:= 0.5}, Maximum := vector2{X:=0.5, Y:= 0.5}}
                    Offsets := margin{Left:= -60.482727 , Top:= 395.459473, Right := 168.603302, Bottom := 52.012012}
                    Alignment := vector2{X:= 0.0, Y:= 0.0}
                    ZOrder := 1
                    SizeToContent := false
                    Widget := ExitButton
        }
        return NewUI

CategorySelector := class(creative_device):
    @editable RemoteManager : signal_remote_manager_device = signal_remote_manager_device{}
    @editable ShotgunsTab : ShotgunsPage = ShotgunsPage{}
    @editable SmgsTab : Smgs_Page = Smgs_Page{}
    @editable RiflesTab : RiflesPage = RiflesPage{}
    @editable SnipersTab : SnipersPage = SnipersPage{}
    @editable MobilitiesTab : MobilitiesPage = MobilitiesPage{}
    @editable HealsTab : HealsPage = HealsPage{}

    OnBegin<override>()<suspends>:void=    
        RemoteManager.PrimarySignalEvent.Subscribe(RemoteOpen)

    RemoteOpen(Agent: agent) : void =
        var NewCategory : Category = Category{ShotgunsTab := ShotgunsTab, SmgsTab := SmgsTab, RiflesTab := RiflesTab, SnipersTab := SnipersTab, HealsTab := HealsTab, MobilitiesTab := MobilitiesTab}
        NewCategory.AddUI(Agent)
