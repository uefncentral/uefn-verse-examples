# Interactive HUD Manager
# Creates and manages custom HUD canvases for players through button interactions and triggers. Players can toggle their HUD on/off via button presses, while triggers allow batch assignment or removal o
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/buttons-1?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
 
HUD_Tutorial := class(creative_device):
    @editable var MyButton : button_device = button_device{}
    @editable var AssignAllHUDSTrigger : trigger_device = trigger_device{}
    @editable var RemoveAllHUDSTrigger : trigger_device = trigger_device{}
 
 
    var MaybeMyUIPerPlayer : [player]?canvas = map{}
 
    OnBegin<override>()<suspends>:void=
        Print("HUD_Tutorial has begun")
        MyButton.InteractedWithEvent.Subscribe(HandleMyButton)
        AssignAllHUDSTrigger.TriggeredEvent.Subscribe(AssignAllHUDS)
        RemoveAllHUDSTrigger.TriggeredEvent.Subscribe(RemoveAllHUDS)
 
    AssignAllHUDS(Agent:?agent):void=
        Print("Assigning all huds")
        CurrentPlayers := GetPlayspace().GetPlayers()
        for(Player:CurrentPlayers):
            if(MyAgent := agent[Player]):
                HandleMyButton(MyAgent)
 
    HandleMyButton(Agent:agent):void=
        Print("MyButton was pressed")
        if(Player:=player[Agent], PlayerUI:=GetPlayerUI[Player]):
            #If the player has a canvas:
            if(MyUI:=MaybeMyUIPerPlayer[Player]?):
                Print("Player already has a HUD")
                PlayerUI.RemoveWidget(MyUI)
                if(set MaybeMyUIPerPlayer[Player] = false){}
                var MyCanvas : canvas = MakeCanvas()
                PlayerUI.AddWidget(MyCanvas,player_ui_slot{InputMode:=ui_input_mode.All})
                if(set MaybeMyUIPerPlayer[Player] = option{MyCanvas}){}
            #If the player does not have a canvas:
            else:
                Print("Player does not have a HUD")
                var MyCanvas : canvas = MakeCanvas()
                PlayerUI.AddWidget(MyCanvas,player_ui_slot{InputMode:=ui_input_mode.All})
                if(set MaybeMyUIPerPlayer[Player] = option{MyCanvas}){}
 
    @editable Button1_Text : string = ""
    @editable Button1_Position : vector2 = vector2{}
    @editable Button1_Size : vector2 = vector2{}
 
    @editable Button2_Text : string = ""
    @editable Button2_Position : vector2 = vector2{}
    @editable Button2_Size : vector2 = vector2{}
 
    @editable Button3_Text : string = ""
    @editable Button3_Position : vector2 = vector2{}
    @editable Button3_Size : vector2 = vector2{}

    @editable Button4_Text : string = ""
    @editable Button4_Position : vector2 = vector2{}
    @editable Button4_Size : vector2 = vector2{}

    @editable Button5_Text : string = ""
    @editable Button5_Position : vector2 = vector2{}
    @editable Button5_Size : vector2 = vector2{}

    @editable Button6_Text : string = ""
    @editable Button6_Position : vector2 = vector2{}
    @editable Button6_Size : vector2 = vector2{}

    @editable Button7_Text : string = ""
    @editable Button7_Position : vector2 = vector2{}
    @editable Button7_Size : vector2 = vector2{}

    @editable Button8_Text : string = ""
    @editable Button8_Position : vector2 = vector2{}
    @editable Button8_Size : vector2 = vector2{}

    @editable Button9_Text : string = ""
    @editable Button9_Position : vector2 = vector2{}
    @editable Button9_Size : vector2 = vector2{}
 
    StringToMessage<localizes>(S:string):message="{S}"
 
    MakeCanvas():canvas=
 
        Button1 : button_regular = button_regular{}
        Button1.SetText(StringToMessage(Button1_Text))
        Button1.OnClick().Subscribe(HandleButton1)
 
        Button2 : button_regular = button_regular{}
        Button2.SetText(StringToMessage(Button2_Text))
        Button2.OnClick().Subscribe(HandleButton2)

        Button3 : button_regular = button_regular{}
        Button3.SetText(StringToMessage(Button3_Text))
        Button3.OnClick().Subscribe(HandleButton3)

        Button4 : button_regular = button_regular{}
        Button4.SetText(StringToMessage(Button4_Text))
        Button4.OnClick().Subscribe(HandleButton4)

        Button5 : button_regular = button_regular{}
        Button5.SetText(StringToMessage(Button5_Text))
        Button5.OnClick().Subscribe(HandleButton5)

        Button6 : button_regular = button_regular{}
        Button6.SetText(StringToMessage(Button6_Text))
        Button6.OnClick().Subscribe(HandleButton6)

        Button7 : button_regular = button_regular{}
        Button7.SetText(StringToMessage(Button7_Text))
        Button7.OnClick().Subscribe(HandleButton7)

        Button8 : button_regular = button_regular{}
        Button8.SetText(StringToMessage(Button8_Text))
        Button8.OnClick().Subscribe(HandleButton8)

        Button9 : button_regular = button_regular{}
        Button9.SetText(StringToMessage(Button9_Text))
        Button9.OnClick().Subscribe(HandleButton9)
 
        var MyCanvas : canvas = canvas:
            #add contents of canvas
            Slots := array:
                canvas_slot:
                    Widget:=Button1
                    ZOrder:=0
                    SizeToContent:=false
                    Offsets:=margin{Top:=Button1_Position.Y,Left:=Button1_Position.X,Bottom:=Button1_Size.Y,Right:=Button1_Size.X}
 
                canvas_slot:
                    Widget:=Button2
                    ZOrder:=1
                    SizeToContent:=false
                    Offsets:=margin{Top:=Button2_Position.Y,Left:=Button2_Position.X,Bottom:=Button2_Size.Y,Right:=Button2_Size.X}

                canvas_slot:
                    Widget:=Button3
                    ZOrder:=2
                    SizeToContent:=false
                    Offsets:=margin{Top:=Button3_Position.Y,Left:=Button3_Position.X,Bottom:=Button3_Size.Y,Right:=Button3_Size.X}
 
                canvas_slot:
                    Widget:=Button4
                    ZOrder:=3
                    SizeToContent:=false
                    Offsets:=margin{Top:=Button4_Position.Y,Left:=Button4_Position.X,Bottom:=Button4_Size.Y,Right:=Button4_Size.X}

                canvas_slot:
                    Widget:=Button5
                    ZOrder:=4
                    SizeToContent:=false
                    Offsets:=margin{Top:=Button5_Position.Y,Left:=Button5_Position.X,Bottom:=Button5_Size.Y,Right:=Button5_Size.X}

                canvas_slot:
                    Widget:=Button6
                    ZOrder:=5
                    SizeToContent:=false
                    Offsets:=margin{Top:=Button6_Position.Y,Left:=Button6_Position.X,Bottom:=Button6_Size.Y,Right:=Button6_Size.X}

                canvas_slot:
                    Widget:=Button7
                    ZOrder:=6
                    SizeToContent:=false
                    Offsets:=margin{Top:=Button7_Position.Y,Left:=Button7_Position.X,Bottom:=Button7_Size.Y,Right:=Button7_Size.X}

                canvas_slot:
                    Widget:=Button8
                    ZOrder:=7
                    SizeToContent:=false
                    Offsets:=margin{Top:=Button8_Position.Y,Left:=Button8_Position.X,Bottom:=Button8_Size.Y,Right:=Button8_Size.X}

                canvas_slot:
                    Widget:=Button9
                    ZOrder:=8
                    SizeToContent:=false
                    Offsets:=margin{Top:=Button9_Position.Y,Left:=Button9_Position.X,Bottom:=Button9_Size.Y,Right:=Button9_Size.X}

        return MyCanvas
 
    @editable Button1_Outcome_Trigger : trigger_device = trigger_device{}
    HandleButton1(Wdata:widget_message):void=
        Print("Button1 Pressed")
        RemoveHUD(Wdata)
        if(Agent := agent[Wdata.Player]):
            Button1_Outcome_Trigger.Trigger(Agent)
 
    @editable Button2_Outcome_Trigger : trigger_device = trigger_device{}
    HandleButton2(Wdata:widget_message):void=
        Print("Button2 Pressed")
        RemoveHUD(Wdata)
        if(Agent := agent[Wdata.Player]):
            Button2_Outcome_Trigger.Trigger(Agent)
 
    @editable Button3_Outcome_Trigger : trigger_device = trigger_device{}
    HandleButton3(Wdata:widget_message):void=
        Print("Button3 Pressed")
        RemoveHUD(Wdata)
        if(Agent := agent[Wdata.Player]):
            Button3_Outcome_Trigger.Trigger(Agent)

    @editable Button4_Outcome_Trigger : trigger_device = trigger_device{}
    HandleButton4(Wdata:widget_message):void=
        Print("Button4 Pressed")
        RemoveHUD(Wdata)
        if(Agent := agent[Wdata.Player]):
            Button4_Outcome_Trigger.Trigger(Agent)


    @editable Button5_Outcome_Trigger : trigger_device = trigger_device{}
    HandleButton5(Wdata:widget_message):void=
        Print("Button5 Pressed")
        RemoveHUD(Wdata)
        if(Agent := agent[Wdata.Player]):
            Button5_Outcome_Trigger.Trigger(Agent)

    @editable Button6_Outcome_Trigger : trigger_device = trigger_device{}
    HandleButton6(Wdata:widget_message):void=
        Print("Button6 Pressed")
        RemoveHUD(Wdata)
        if(Agent := agent[Wdata.Player]):
            Button6_Outcome_Trigger.Trigger(Agent)

    @editable Button7_Outcome_Trigger : trigger_device = trigger_device{}
    HandleButton7(Wdata:widget_message):void=
        Print("Button7 Pressed")
        RemoveHUD(Wdata)
        if(Agent := agent[Wdata.Player]):
            Button7_Outcome_Trigger.Trigger(Agent)

    @editable Button8_Outcome_Trigger : trigger_device = trigger_device{}
    HandleButton8(Wdata:widget_message):void=
        Print("Button8 Pressed")
        RemoveHUD(Wdata)
        if(Agent := agent[Wdata.Player]):
            Button8_Outcome_Trigger.Trigger(Agent)

    @editable Button9_Outcome_Trigger : trigger_device = trigger_device{}
    HandleButton9(Wdata:widget_message):void=
        Print("Button9 Pressed")
        RemoveHUD(Wdata)
        if(Agent := agent[Wdata.Player]):
            Button9_Outcome_Trigger.Trigger(Agent)
 
    RemoveAllHUDS(Agent:?agent):void=
        Print("Removing All HUDS")
        CurrentPlayers := GetPlayspace().GetPlayers()
        for(Player:CurrentPlayers):
            if(MyAgent:=agent[Player]):
                if(PlayerUI:=GetPlayerUI[Player], MyUI:=MaybeMyUIPerPlayer[Player]?):
                    PlayerUI.RemoveWidget(MyUI)
                    if(set MaybeMyUIPerPlayer[Player] = false){}
 
    RemoveHUD(Wdata:widget_message):void=
        Print("Removing HUD")
        if(Player:=Wdata.Player, PlayerUI:=GetPlayerUI[Player], SelectedButton:=Wdata.Source):
            if(MyUI:=MaybeMyUIPerPlayer[Player]?):
                PlayerUI.RemoveWidget(MyUI)
                if(set MaybeMyUIPerPlayer[Player] = false){}
