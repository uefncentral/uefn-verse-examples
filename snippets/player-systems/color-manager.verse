# Prop Color Change Shop
# A comprehensive system that allows players to purchase and change the materials/colors of tagged props in the game. Players can browse different color options through a UI interface and spend resource
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/color-manager?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /Verse.org/Assets }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation/Tags }

#THIS DEVICE IS USED TO ALLOW THE PLAYER TO PURCHASE AND CHANGE THE MATERIALS OF DIFFERENT PROPS

#Tag to apply to props for changing
ColorChange := class(tag){}

#Class for each color
ColorOption := class<concrete>():
    #Add Images & Materials Here 
    #*************************************************************************************************************************************************
    var PrePurchaseImages : []texture = array{}
    var PostPurchaseImages : []texture = array{}
    var Mats : []material = array{}
    #*************************************************************************************************************************************************

    #Verse Devices and Settings
    PersistanceManager : Persistance_Manager = Persistance_Manager{}
    var GameManager : Game_Manager = Game_Manager{}
    var ButtonManager : Button_Manager = Button_Manager{}
    var ColorChangeSettings : ColorChangeSetting = ColorChangeSetting{}

    #UI Stuff
    var ColorCanvas : canvas = canvas{}
    var ColorImage : texture_block = texture_block{DefaultImage := TycoonAssets.blank}
    var ColorButtons : UIButtons = UIButtons{}

    #Extra Stuff
    CheckEvent : event() = event(){}
    var IDX : int = 0

    #Editables
    @editable ImageIDX : int = 0
    @editable MaterialIDX : int = 0
    @editable SuccessSound : audio_player_device = audio_player_device{}
    @editable FailureSound : audio_player_device = audio_player_device{}
    @editable PurchaseXP : accolades_device = accolades_device{}

    @editable CostResources : []SpendableResource = array{}

    #Sets up the canvas for each Color option on the UI, based off of the "Combined Position Settings"
    SetUpCanvas() : void=
        ColorButton := ColorButtons.GetButton(ColorChangeSettings.CombinedPositionSettings.ButtonType)

        ColorButton.OnClick().Subscribe(HandlePress)
        if(NewImage := PrePurchaseImages[ImageIDX]){ColorImage.SetImage(NewImage)}
        set ColorCanvas = NewCanvas : canvas = canvas{
            Slots := array:
                ColorChangeSettings.CombinedPositionSettings.ImagePosition.MakeCanvasSlot(ColorImage,false)
                ColorChangeSettings.CombinedPositionSettings.ButtonPosition.MakeCanvasSlot(ColorButton,false)
        }

    #When a color button is pressed, checks if it is owned and if it is equipped and handles accordingly
    HandlePress(Message : widget_message) : void=
        if(Agent := Message.Player, CP := GameManager.PlayersMap[Agent]):
            if(not CP.BoughtColors.Find[IDX]):              
                HasEnough := CP.Check(CostResources)
                if(HasEnough?):
                    CP.Spend(CostResources)
                    set CP.BoughtColors += array{IDX}
                    PersistanceManager.RecordPlayerArrStat(Agent, StatType.Colors, ?Score := IDX)
                    SuccessSound.Play(Agent)
                    PurchaseXP.Award(Agent)
                else:
                    FailureSound.Play(Agent)
            else:
                if(not CP.EquippedColor = IDX):
                    set CP.EquippedColor = IDX
                    Equip(Agent)
        CheckEvent.Signal()

    #Equips the color and changes all props tagged to the colors material
    Equip(Agent:agent) : void=
        TaggedActors := GetCreativeObjectsWithTag(ColorChange{})
        for(Button : ButtonManager.ButtonsArray):
            for(B : Button.ItemsToShow , ButtonTrans := B.GetTransform().Translation):
                for(P : TaggedActors,Prop := creative_prop[P] , PropTrans := Prop.GetTransform().Translation):
                    if:
                        ButtonTrans.X = PropTrans.X
                        ButtonTrans.Y = PropTrans.Y
                        ButtonTrans.Z = PropTrans.Z
                    then:
                        if(Mat := Mats[MaterialIDX]){Prop.SetMaterial(Mat)}
                
    #Changes the text and images based on whether the color is owned or equipped
    CheckText(Agent:agent) : void=
        ColorButton := ColorButtons.GetButton(ColorChangeSettings.CombinedPositionSettings.ButtonType)
        if(CP := GameManager.PlayersMap[Agent]):
            if(CP.BoughtColors.Find[IDX]):
                if(NewImage := PostPurchaseImages[ImageIDX]){ColorImage.SetImage(NewImage)}
                if(CP.EquippedColor = IDX):
                    ColorButton.SetText(StringToMessage("Equipped"))
                else:
                    ColorButton.SetText(StringToMessage("Equip"))
            else:
                if(NewImage := PrePurchaseImages[ImageIDX]){ColorImage.SetImage(NewImage)}
                ColorButton.SetText(StringToMessage("Purchase"))
    
#Main class to create the UI
ColorChangeUI := class():
    #Devices and settings
    var GameManager : Game_Manager = Game_Manager{}
    var ColorChangeSettings : ColorChangeSetting = ColorChangeSetting{}
    var ColorCancelSettings : ColorCancelSetting = ColorCancelSetting{}
    var Cinematic : cinematic_sequence_device = cinematic_sequence_device{}

    #All of the colors available
    var AllColors : []ColorOption = array{}

    #UI stuff
    var MainUI : canvas = canvas{}
    var ExitButton : button_loud = button_loud{}
    
    #Initializes the UI and adds it to the player
    OpenUI(Agent:agent) : void=
        for(C : AllColors){spawn{TextUpdate(Agent,C)}}
        ExitButton.SetText(StringToMessage("Exit"))
        ExitButton.OnClick().Subscribe(HandleExitUI)
        spawn{HandleCancel(Agent)}
        if(Player := player[Agent],PlayerUI := GetPlayerUI[Player]):
            set MainUI = CreateUI()
            PlayerUI.AddWidget(MainUI, player_ui_slot{InputMode := ui_input_mode.All})

    #Adds all of the colors UIs to the main UI
    CreateUI() : canvas =
        var NewUI : canvas = canvas{}
        for(idx -> UISlot : ColorChangeSettings.AllColorPositions , CurColor := AllColors[idx]):
            NewCanvas := CurColor.ColorCanvas
            set UISlot.Canvas = NewCanvas

            NewSlot := UISlot.Position.MakeCanvasSlot(UISlot.Canvas,false)
            NewUI.AddWidget(NewSlot)

        if(ColorCancelSettings.CancelType = colorcanceltype.UI):
            ExitButton.SetVisibility(widget_visibility.Visible)
            NewUI.AddWidget(ColorCancelSettings.UIExitPosition.MakeCanvasSlot(ExitButton, false))
        return NewUI

    #Used to call the exit function, except from the UI button
    HandleExitUI(Message : widget_message) : void=
        Player := Message.Player
        HandleExit(Player)

    #Exits the UI and removes the cinematic
    HandleExit(Agent:agent) : void=
        if (Player := player[Agent],PlayerUI := GetPlayerUI[Player],FC:=Agent.GetFortCharacter[],CP := GameManager.PlayersMap[Agent]):
            MainUI.SetVisibility(widget_visibility.Hidden)
            PlayerUI.RemoveWidget(MainUI)
            Cinematic.Stop(Agent)
            
    #Waits for a color button to be pressed and updates the text for all buttons when it is
    TextUpdate(Agent:agent , Col : ColorOption)<suspends> : void=
        Col.CheckText(Agent)
        loop:
            Sleep(0.0)
            Col.CheckEvent.Await()
            for(C : AllColors){C.CheckText(Agent)}
              
    #Tracks for when a player cancels based on the cancel setting
    HandleCancel(Agent:agent)<suspends> : void=
        if(ColorCancelSettings.CancelType = colorcanceltype.UI):
            ExitButton.OnClick().Subscribe(HandleExitUI)

        else if(ColorCancelSettings.CancelType = colorcanceltype.Duration):
            Sleep(ColorCancelSettings.CancelDuration)
            HandleExit(Agent)

#Creative device class
Color_Manager := class(creative_device):
    #Devices
    @editable GameManager : Game_Manager = Game_Manager{}
    @editable ButtonManager : Button_Manager = Button_Manager{}
    @editable Button : button_device = button_device{}
    @editable Cinematic : cinematic_sequence_device = cinematic_sequence_device{}

    #Settings
    @editable ColorChangeSettings : ColorChangeSetting = ColorChangeSetting{}
    @editable ColorCancelSettings : ColorCancelSetting = ColorCancelSetting{}
    @editable AllColors : []ColorOption = array{}

    #Initializes at the start of the game and waits for button to be pressed
    OnBegin<override>()<suspends>:void=
        Initialize()
        Button.InteractedWithEvent.Subscribe(OpenUI)

    #Initializes all of the colors
    Initialize() : void=
        for(idx -> C : AllColors):
            set C.GameManager = GameManager
            set C.ButtonManager = ButtonManager
            set C.IDX = idx
            set C.ColorChangeSettings = ColorChangeSettings
            C.SetUpCanvas()

    #Makes a new UI And adds it to the player when button is pressed, also plays cinematic
    OpenUI(Agent:agent) : void=
        NewColorUI := ColorChangeUI:
            GameManager := GameManager
            ColorChangeSettings := ColorChangeSettings 
            ColorCancelSettings := ColorCancelSettings
            Cinematic := Cinematic
            AllColors := AllColors
        NewColorUI.OpenUI(Agent)
        Cinematic.Play(Agent)

#Different cancel types
colorcanceltype := enum:
    UI
    Duration

#Settings to control how UI is canceled / closed
ColorCancelSetting := class<concrete>():
    @editable CancelType : colorcanceltype = colorcanceltype.UI
    @editable UIExitPosition : CanvasPosition = CanvasPosition{}
    @editable CancelDuration : float = 0.0

#Position of each color
ColorPosition := class<concrete>():
    @editable Position : CanvasPosition = CanvasPosition{}
    var Canvas : canvas = canvas{}

#Combination of other color settings to be concise
ColorChangeSetting := class<concrete>():
    @editable CombinedPositionSettings : CombinedSetting = CombinedSetting{}
    @editable AllColorPositions : []ColorPosition = array{}