# Interactive Light Control System
# A system that manages 8 customizable lights with audio effects through button interactions. Players can turn lights on/off using buttons, which also trigger teleportation effects and audio playback fo
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/lightsmanager-1?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

LightsManager := class(creative_device):

    @editable
    L1:customizable_light_device = customizable_light_device{}
    @editable
    L2:customizable_light_device = customizable_light_device{}
    @editable
    L3:customizable_light_device = customizable_light_device{}
    @editable
    L4:customizable_light_device = customizable_light_device{}
    @editable
    L5:customizable_light_device = customizable_light_device{}
    @editable
    L6:customizable_light_device = customizable_light_device{}
    @editable
    L7:customizable_light_device = customizable_light_device{}
    @editable
    L8:customizable_light_device = customizable_light_device{}

    @editable
    A1:audio_player_device = audio_player_device{}
    @editable
    A2:audio_player_device = audio_player_device{}
    @editable
    A3:audio_player_device = audio_player_device{}
    @editable
    A4:audio_player_device = audio_player_device{}

    @editable
    Button_On:button_device = button_device{}
    @editable
    Button_Off:button_device = button_device{}
    
    var LightsAreOn:logic = false

    var ChangingLightsState:logic = false

    OFF_STATE:int = 0
    ON_STATE:int = 1

    OnBegin<override>()<suspends>:void=
        Button_On.InteractedWithEvent.Subscribe(OnLightButtonClick)
        Button_Off.InteractedWithEvent.Subscribe(OnLightButtonClick)


    #
    TurnLightsOn(LightsState:int)<suspends>:void=
        set ChangingLightsState = true
        if(LightsState = OFF_STATE):
            if(Button_Off.TeleportTo[vector3{X:=16378.0, Y:=-17920.0, Z:=800.0}, Button_Off.GetTransform().Rotation]):

            if(Button_On.TeleportTo[vector3{X:=16378.0, Y:=-17920.0, Z:=-2000.0}, Button_On.GetTransform().Rotation]):

            
            L7.TurnOff()
            L8.TurnOff()
            A4.Play()

            Sleep(0.5)
            L5.TurnOff()
            L6.TurnOff()
            A3.Play()

            Sleep(0.5)
            L3.TurnOff()
            L4.TurnOff()
            A2.Play()

            Sleep(0.5)
            L1.TurnOff()
            L2.TurnOff()
            A1.Play()

            set LightsAreOn = false

        else:
            if(Button_On.TeleportTo[vector3{X:=16376.0, Y:=-17920.0, Z:=800.0}, Button_On.GetTransform().Rotation]):

            if(Button_Off.TeleportTo[vector3{X:=16376.0, Y:=-17920.0, Z:=-2000.0}, Button_Off.GetTransform().Rotation]):
            L1.TurnOn()
            L2.TurnOn()
            A1.Play()

            Sleep(0.5)
            L3.TurnOn()
            L4.TurnOn()
            A2.Play()

            Sleep(0.5)
            L5.TurnOn()
            L6.TurnOn()
            A3.Play()

            Sleep(0.5)
            L7.TurnOn()
            L8.TurnOn()
            A4.Play()

            set LightsAreOn = true

        set ChangingLightsState = false


    OnLightButtonClick(Agent:agent):void=
        if(ChangingLightsState = false):
            if(LightsAreOn = false):
                
                spawn:
                    TurnLightsOn(ON_STATE)
            else:
                
                spawn:
                    TurnLightsOn(OFF_STATE)
        