# EZUI Helper Library
# A utility module providing simplified UI functions for Fortnite Creative. It includes helper functions for converting data types to UI messages, validating players, and custom data structures for UI o
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/ezuiapimodule-1?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

#imports
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /Verse.org/Colors }
using { /Fortnite.com/Playspaces }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Assets }
using { /Fortnite.com/Characters }


EZUI<public> := module:

    # Custom data types  ---------------------------------------------------------------------------------------

    ezui_opacity_range<public> := struct<concrete>{ @editable Value:type{_X:float where 0.000000 <= _X, _X <= 1.000000} = 0.0}
    ezui_anchor_range<public> := struct<concrete>{ @editable Value:type{_X:float where 0.000000 <= _X, _X <= 1.000000} = 0.0}

    # Toolkit ---------------------------------------------------------------------------------------

    <# 
        EZUI.TextToMsg
        comverts a text string to a UI message
    #>
    TextToMsg<public><localizes> (t : string) : message = "{t}" 

    <# 
        EZUI.IntToMsg
        comverts an int to a UI message
    #>
    IntToMsg<public><localizes>(i : int) : message = "{i}"

    <# 
        EZUI.FloatToMsg
        comverts a float to a UI message
    #>
    FloatToMsg<public><localizes>(i : float) : message = "{i}"

    <#
        EZUI.IsAPlayer
        used to determine if a TriggerEvent is from a player, or to check if the 
        input is a player, to allow for a UI to be safely referenced
    #>
    IsAPlayer<public>(MaybeAgent : ?agent, VerseDevice : creative_device) : logic =

        if(not MaybeAgent?):
            #Print("EZUI: Not an Agent")
            return false

        if(MaybePlayer := MaybeAgent?):
            for (k -> v : VerseDevice.GetPlayspace().GetPlayers()):
                if (v = player[MaybePlayer]):
                    #Print("EZUI: Is a Player")
                    return true
        
        #Print("EZUI: Not a Player")
        return false
      
    <# 
        EZUI.InsertWidget
        add a specific widget to a specific player's UI
    #>
    InsertWidget<public>(Player : player, NewWidget : widget) : void =
        if (PlayerUI := GetPlayerUI[Player]):
            PlayerUI.AddWidget(NewWidget)

    InsertZOrderWidget<public>(Player : player, NewWidget : widget, MyZOrder : type {_X:int where 0 <= _X, _X <= 2147483647}) : void =
        if (PlayerUI := GetPlayerUI[Player]):
            PlayerUI.AddWidget(NewWidget,player_ui_slot{ZOrder := MyZOrder})

    InsertActiveWidget <public> (Player : player, NewWidget : widget) : void =
        if (PlayerUI := GetPlayerUI[Player]):
            PlayerUI.AddWidget(NewWidget,player_ui_slot{InputMode := ui_input_mode.All})

    InsertActiveZOrderWidget <public> (Player : player, NewWidget : widget, MyZOrder : type {_X:int where 0 <= _X, _X <= 2147483647}) : void =
                if (PlayerUI := GetPlayerUI[Player]):
                    PlayerUI.AddWidget(NewWidget,player_ui_slot{InputMode := ui_input_mode.All,ZOrder := MyZOrder})
    
    <# 
        EZUI.DeleteWidget
        removes a specific widget from a specific player's UI
    #>
    DeleteWidget<public>(Player : player, Widget : widget) : void =
        if (PlayerUI := GetPlayerUI[Player]):
            PlayerUI.RemoveWidget(Widget)

    <# 
        EZUI.GetMyHUDController
        returns the HUD controller for the requesting verse device's playspace
        and is used to show or hide all or parts of the default Fortnite UI
    #>
    GetMyHUDController <public> (VerseDevice : creative_device) : fort_hud_controller =
        Playspace := VerseDevice.GetPlayspace()
        HUDController := Playspace.GetHUDController()
        return HUDController

    
    <# 
        EZUI.DisablePlayerControls
        EZUI.RestorePlayerControls
        lock player movement while a UI is open and
        restore it when needed
    #>
    DisablePlayerControls <public> (Player : player) : void =
            if(PlayerAgent := agent[Player]):
                PlayerCharacter := PlayerAgent.GetFortCharacter[] or Err("[EZUI] : DisablePlayerControls()  - Should be unfailable")
                PlayerCharacter.PutInStasis(stasis_args{})
    
    RestorePlayerControls <public> (Player : player) : void =
            if(PlayerAgent := agent[Player]):
                PlayerCharacter := PlayerAgent.GetFortCharacter[] or Err("[EZUI] : RestorePlayerControls()  - Should be unfailable")
                PlayerCharacter.ReleaseFromStasis()

    <#
	    EZUI.GetPlayerName
	    returns a message containing the name of a player or agent
	    for use in the UI or Prints. May thanks to japan on
	    the UEFN Discord!
	#>
	GetPlayerName<localizes>(Agent : agent) : message := "{Agent}"



    # Extended UI class functions ----------------------------------------------------------------------
        
    <# 
       Forces a full refresh of the UI when used on ANY widget within
       the player_ui. Best used on a widget like an empty canvas so
       that the flickering isn't noticed. 

        Use in loops where you want to create a widget that updates
        every frame. Thx Mayapple and SprinterMax!
    #>
    (Widget:widget).EZRefresh<public>():void = 
        {
            Widget.SetEnabled(false)
            Widget.SetEnabled(true)
        }





    # VFX library ---------------------------------------------------------------------------------

    <#
        EZUI.FlickerVFX
        Used to create a flickering effect on UI elements for a defined
        duration and then ending with one of four ways:
            1 - visible
            2 = invisible
            3 = invisible and collapsed
            4 = removed
    
    #>
    FlickerVFX <public> (ThisWidget : widget, Duration : float, VFXEnd : int, LinkedPlayer : player)<suspends> : void =
        var Countdown : float = (Duration * 10)
        
        loop:
                ThisWidget.SetVisibility(widget_visibility.Hidden)
                Sleep(0.05)
                ThisWidget.SetVisibility(widget_visibility.Visible)
                Sleep(0.05)
                set Countdown = Countdown - 1.0
        
                if(Countdown = 0.0):

                    if (VFXEnd = 1):
                        ThisWidget.SetVisibility(widget_visibility.Visible)
                        
                    if (VFXEnd = 2):
                        ThisWidget.SetVisibility(widget_visibility.Hidden)
                    
                    if (VFXEnd = 3):
                        ThisWidget.SetVisibility(widget_visibility.Collapsed) 

                    if (VFXEnd = 4):
                        if (PlayerUI := GetPlayerUI[LinkedPlayer]):
                            PlayerUI.RemoveWidget(ThisWidget)           
                       
                    break

    <#
        EZUI.FadeVFX
        EZUI.FadeTextVFX
        smoothly modifies the opacity of a color_block over a period
        (in seconds) between two values or does the same with a text_block
    #>
    FadeVFX <public> (TargetWidget : color_block, FadeColor : color, InitialOpacity : float, FinalOpacity : float, FadeDuration : float) <suspends>: void =
        #Print("[EZUI] : FadeInVFX")

        var ElapsedTime : float = 0.0
        var StartTime : float = 0.0

        TargetWidget.SetColor(FadeColor)

        loop:
            CurrentTime := GetSimulationElapsedTime()

            if (StartTime = 0.0):
                set StartTime = CurrentTime

            set ElapsedTime = Min(FadeDuration , CurrentTime - StartTime)
            
            Value := Lerp(InitialOpacity, FinalOpacity, ElapsedTime / FadeDuration )
            OpacityValue: type{_X:float where 0.000000 <= _X, _X <= 1.000000 } = type{_X:float where 0.000000 <= _X, _X <= 1.000000 }[Clamp(Value, 0.0, 1.0)] or Err("Should be unfailable")
            TargetWidget.SetOpacity(OpacityValue)
            #Print("[EZUI] : Widget Opacity is {Value}")

            if (ElapsedTime = FadeDuration):
                break

            Sleep(0.0)

    FadeTextVFX <public> (TargetWidget : text_block, FadeColor : color, InitialOpacity : float, FinalOpacity : float, FadeDuration : float) <suspends>: void =
        #Print("[EZUI] : FadeInVFX")
        
        var ElapsedTime : float = 0.0
        var StartTime : float = 0.0
        
        TargetWidget.SetTextColor(FadeColor)
        
            loop:
                CurrentTime := GetSimulationElapsedTime()
        
                if (StartTime = 0.0):
                    set StartTime = CurrentTime
        
                set ElapsedTime = Min(FadeDuration , CurrentTime - StartTime)
                    
                Value := Lerp(InitialOpacity, FinalOpacity, ElapsedTime / FadeDuration )
                OpacityValue: type{_X:float where 0.000000 <= _X, _X <= 1.000000 } = type{_X:float where 0.000000 <= _X, _X <= 1.000000 }[Clamp(Value, 0.0, 1.0)] or Err("Should be unfailable")
                TargetWidget.SetTextOpacity(OpacityValue)
                #Print("[EZUI] : Widget Opacity is {Value}")
        
                if (ElapsedTime = FadeDuration):
                    break
        
                Sleep(0.0)

    <#
        EZUI.AnimatedCounterVFX
        smoothly increments the text_block from the start
        value to the final value over a defined period

        Note: Requires the text_block to be nested in 
        an overlay widget
    #>
    AnimatedCounterVFX <public> (MyPlayer : player, TargetWidget : text_block, InitialValue : float, FinalValue: float, Duration : float ) <suspends>: void =
        #Print("[EZUI] IncrementCounter() start")
        var ElapsedTime : float = 0.0
        var StartTime : float = 0.0
        var RoundedNewValue : int = 0
                        
        loop:
            CurrentTime := GetSimulationElapsedTime()
            MyParentWidget := overlay[TargetWidget.GetParentWidget[]] or Err("IncrementCounter() . Shouldn't Error")
                        
            if (StartTime = 0.0):
                set StartTime = CurrentTime
                
            
            set ElapsedTime = Min(Duration , CurrentTime - StartTime)
                                        
            NewValue := Lerp(InitialValue, FinalValue, ElapsedTime / Duration )
            set RoundedNewValue = Floor[NewValue] or Err("IncrementCounter() . Shouldn't Error")
            
            DeleteWidget(MyPlayer,TargetWidget)
            TargetWidget.SetText(IntToMsg(RoundedNewValue))     
            NewCounterSlot := overlay_slot {Widget := TargetWidget}
            MyParentWidget.AddWidget(NewCounterSlot)
                            
            if (ElapsedTime = Duration):
                #Print("[EZUI]:AnimatedCounterVFX() stop")
                break      
                            
            Sleep(0.0)

