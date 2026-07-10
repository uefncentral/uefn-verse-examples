# Interactive Lucky Wheel
# Creates a customizable spinning wheel game that randomly selects from configurable slots and grants items to players. Players interact with a conditional button to spin the wheel, which displays visua
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/lucky-wheel-device-1?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /Verse.org/Assets }
using { /Verse.org/Colors }


lucky_wheel_device := class(creative_device):

    @editable WheelID : type{_X : int where _X >= 0, _X <= 3} = 0
    @editable LuckyWheelProp : creative_prop = creative_prop{}
    @editable ItemGranter : item_granter_device = item_granter_device{}
    @editable ConditionalButton : conditional_button_device = conditional_button_device{}
    @editable SlotsNumber : int = 16
    @editable ScreenBackgroundColor : color = color{}
    
        
    OnBegin<override>()<suspends>:void=
        LuckyWheelMat1 : Materials.MI_LuckyWheelScreen_1_material = Materials.MI_LuckyWheelScreen_1_material{}
        LuckyWheelMat2 : Materials.MI_LuckyWheelScreen_2_material = Materials.MI_LuckyWheelScreen_2_material{}
        LuckyWheelMat3 : Materials.MI_LuckyWheelScreen_3_material = Materials.MI_LuckyWheelScreen_3_material{}
        LuckyWheelMat4 : Materials.MI_LuckyWheelScreen_4_material = Materials.MI_LuckyWheelScreen_4_material{}
        if (WheelID = 0):            
            LuckyWheelProp.SetMaterial(LuckyWheelMat1)
            set LuckyWheelMat1.BackgroundColor = ScreenBackgroundColor
            AwaitButtonInteraction(LuckyWheelMat1, LuckyWheelMat2, LuckyWheelMat3, LuckyWheelMat4)
        else if (WheelID = 1):            
            LuckyWheelProp.SetMaterial(LuckyWheelMat2)
            set LuckyWheelMat2.BackgroundColor = ScreenBackgroundColor
            AwaitButtonInteraction(LuckyWheelMat1, LuckyWheelMat2, LuckyWheelMat3, LuckyWheelMat4)
        else if (WheelID = 2):            
            LuckyWheelProp.SetMaterial(LuckyWheelMat3)
            set LuckyWheelMat3.BackgroundColor = ScreenBackgroundColor
            AwaitButtonInteraction(LuckyWheelMat1, LuckyWheelMat2, LuckyWheelMat3, LuckyWheelMat4)
        if (WheelID = 3):            
            LuckyWheelProp.SetMaterial(LuckyWheelMat4)
            set LuckyWheelMat4.BackgroundColor = ScreenBackgroundColor
            AwaitButtonInteraction(LuckyWheelMat1, LuckyWheelMat2, LuckyWheelMat3, LuckyWheelMat4)
        
        
    AwaitButtonInteraction(LuckyWheelMat1 : Materials.MI_LuckyWheelScreen_1_material, LuckyWheelMat2 : Materials.MI_LuckyWheelScreen_2_material, LuckyWheelMat3 : Materials.MI_LuckyWheelScreen_3_material, LuckyWheelMat4 : Materials.MI_LuckyWheelScreen_4_material)<suspends>:void=
        loop:
            Agent := ConditionalButton.ActivatedEvent.Await()
            OnButtonPressed(Agent, LuckyWheelMat1, LuckyWheelMat2, LuckyWheelMat3, LuckyWheelMat4)
            Sleep(0.1)


    OnButtonPressed(Agent : agent, LuckyWheelMat1 : Materials.MI_LuckyWheelScreen_1_material, LuckyWheelMat2 : Materials.MI_LuckyWheelScreen_2_material, LuckyWheelMat3 : Materials.MI_LuckyWheelScreen_3_material, LuckyWheelMat4 : Materials.MI_LuckyWheelScreen_4_material):void=
        ConditionalButton.Disable()
        spawn {OnLuckyWheelActivated(Agent, LuckyWheelMat1, LuckyWheelMat2, LuckyWheelMat3, LuckyWheelMat4)}


    OnLuckyWheelActivated(Agent : agent, LuckyWheelMat1 : Materials.MI_LuckyWheelScreen_1_material, LuckyWheelMat2 : Materials.MI_LuckyWheelScreen_2_material, LuckyWheelMat3 : Materials.MI_LuckyWheelScreen_3_material, LuckyWheelMat4 : Materials.MI_LuckyWheelScreen_4_material)<suspends>:void=
        var SpinSpeed : float = GetRandomFloat(0.5, 2.0)
        loop:
            if (WheelID = 0):
                set LuckyWheelMat1.WinSlot = 0.0
                set LuckyWheelMat1.Rotation += SpinSpeed
                if (LuckyWheelMat1.Rotation >= (SlotsNumber - 1) * 1.0):
                    set LuckyWheelMat1.Rotation = 0.0
                if (SpinSpeed > 0.0):
                    set SpinSpeed -= 0.01
                else:
                    if:
                        WinSlotIDX := Round[LuckyWheelMat1.Rotation]
                    then:
                        spawn {FinishRotation(WinSlotIDX, Agent, LuckyWheelMat1, LuckyWheelMat2, LuckyWheelMat3, LuckyWheelMat4)}
                        break
            else if (WheelID = 1):
                set LuckyWheelMat2.WinSlot = 0.0
                set LuckyWheelMat2.Rotation += SpinSpeed
                if (LuckyWheelMat2.Rotation >= (SlotsNumber - 1) * 1.0):
                    set LuckyWheelMat2.Rotation = 0.0
                if (SpinSpeed > 0.0):
                    set SpinSpeed -= 0.01
                else:
                    if:
                        WinSlotIDX := Round[LuckyWheelMat2.Rotation]
                    then:
                        spawn {FinishRotation(WinSlotIDX, Agent, LuckyWheelMat1, LuckyWheelMat2, LuckyWheelMat3, LuckyWheelMat4)}
                        break

            else if (WheelID = 2):
                set LuckyWheelMat3.WinSlot = 0.0
                set LuckyWheelMat3.Rotation += SpinSpeed
                if (LuckyWheelMat3.Rotation >= (SlotsNumber - 1) * 1.0):
                    set LuckyWheelMat3.Rotation = 0.0
                if (SpinSpeed > 0.0):
                    set SpinSpeed -= 0.01
                else:
                    if:
                        WinSlotIDX := Round[LuckyWheelMat3.Rotation]
                    then:
                        spawn {FinishRotation(WinSlotIDX, Agent, LuckyWheelMat1, LuckyWheelMat2, LuckyWheelMat3, LuckyWheelMat4)}
                        break
            else if (WheelID = 3):
                set LuckyWheelMat4.WinSlot = 0.0
                set LuckyWheelMat4.Rotation += SpinSpeed
                if (LuckyWheelMat4.Rotation >= (SlotsNumber - 1) * 1.0):
                    set LuckyWheelMat4.Rotation = 0.0
                if (SpinSpeed > 0.0):
                    set SpinSpeed -= 0.01
                else:
                    if:
                        WinSlotIDX := Round[LuckyWheelMat4.Rotation]
                    then:
                        spawn {FinishRotation(WinSlotIDX, Agent, LuckyWheelMat1, LuckyWheelMat2, LuckyWheelMat3, LuckyWheelMat4)}
                        break
            Sleep(0.01)


    FinishRotation(WinSlotIDX : int, Agent : agent, LuckyWheelMat1 : Materials.MI_LuckyWheelScreen_1_material, LuckyWheelMat2 : Materials.MI_LuckyWheelScreen_2_material, LuckyWheelMat3 : Materials.MI_LuckyWheelScreen_3_material, LuckyWheelMat4 : Materials.MI_LuckyWheelScreen_4_material)<suspends>:void=
        loop:
            if (WheelID = 0):
                if (LuckyWheelMat1.Rotation > WinSlotIDX * 1.0):
                    set LuckyWheelMat1.Rotation -= 0.01
                else:
                    set LuckyWheelMat1.Rotation += 0.01
                if (WinSlotIDX * 1.0 >= LuckyWheelMat1.Rotation - 0.1 and WinSlotIDX * 1.0 <= LuckyWheelMat1.Rotation + 0.1):
                    set LuckyWheelMat1.WinSlot = (WinSlotIDX + 1) * 1.0
                    OnRewardGranted(WinSlotIDX, Agent)
                    Sleep(5.0)
                    set LuckyWheelMat1.WinSlot = 0.0
                    break
            else if (WheelID = 1):
                if (LuckyWheelMat2.Rotation > WinSlotIDX * 1.0):
                    set LuckyWheelMat2.Rotation -= 0.01
                else:
                    set LuckyWheelMat2.Rotation += 0.01
                if (WinSlotIDX * 1.0 >= LuckyWheelMat2.Rotation - 0.1 and WinSlotIDX * 1.0 <= LuckyWheelMat2.Rotation + 0.1):
                    set LuckyWheelMat2.WinSlot = (WinSlotIDX + 1) * 1.0
                    OnRewardGranted(WinSlotIDX, Agent)
                    Sleep(5.0)
                    set LuckyWheelMat2.WinSlot = 0.0
                    break
            else if (WheelID = 2):
                if (LuckyWheelMat3.Rotation > WinSlotIDX * 1.0):
                    set LuckyWheelMat3.Rotation -= 0.01
                else:
                    set LuckyWheelMat3.Rotation += 0.01
                if (WinSlotIDX * 1.0 >= LuckyWheelMat3.Rotation - 0.1 and WinSlotIDX * 1.0 <= LuckyWheelMat3.Rotation + 0.1):
                    set LuckyWheelMat3.WinSlot = (WinSlotIDX + 1) * 1.0
                    OnRewardGranted(WinSlotIDX, Agent)
                    Sleep(5.0)
                    set LuckyWheelMat3.WinSlot = 0.0
                    break
            else if (WheelID = 3):
                if (LuckyWheelMat4.Rotation > WinSlotIDX * 1.0):
                    set LuckyWheelMat4.Rotation -= 0.01
                else:
                    set LuckyWheelMat4.Rotation += 0.01
                if (WinSlotIDX * 1.0 >= LuckyWheelMat4.Rotation - 0.1 and WinSlotIDX * 1.0 <= LuckyWheelMat4.Rotation + 0.1):
                    set LuckyWheelMat4.WinSlot = (WinSlotIDX + 1) * 1.0
                    OnRewardGranted(WinSlotIDX, Agent)
                    Sleep(5.0)
                    set LuckyWheelMat4.WinSlot = 0.0
                    break
            Sleep(0.01)


    OnRewardGranted(WinSlotIDX : int, Agent : agent):void=        
        ItemGranter.GrantItemIndex(Agent, WinSlotIDX)
        ConditionalButton.Enable()