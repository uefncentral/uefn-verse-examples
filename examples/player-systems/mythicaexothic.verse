# Weapon Spin Wheels
# Creates two interactive spinning wheels that players can pay to spin for random weapon rewards. Each wheel has configurable prices, rotation animations, and grants different weapon types (Exotic and M
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/mythicaexothic?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/SpatialMath }


Overall:=struct<concrete>{
    @editable Spin_Audio : audio_player_device = audio_player_device{}
    @editable Grant_Audio : audio_player_device = audio_player_device{}
    @editable Gold_Checker : conditional_button_device = conditional_button_device{}
    @editable Not_Enough_Currency_Message : hud_message_device = hud_message_device{}
    @editable XP_Granter : accolades_device = accolades_device{}
}

Wheel_1:=struct<concrete>{
    @editable Weapon_Granters1 : []item_granter_device = array{}
    @editable Spinner1 : creative_prop = creative_prop{}
    @editable Button1 : button_device = button_device{}
    @editable Levers_Cinematic1 : cinematic_sequence_device = cinematic_sequence_device{}
    @editable Price1 : int = 50
    @editable Rotation_Degrees1 : float = 30.0

}

Wheel_2:=struct<concrete>{
    @editable Weapon_Granters2 : []item_granter_device = array{}
    @editable Spinner2 : creative_prop = creative_prop{}
    @editable Button2 : button_device = button_device{}
    @editable Levers_Cinematic2 : cinematic_sequence_device = cinematic_sequence_device{}
    @editable Price2 : int = 50
    @editable Rotation_Degrees2 : float = 30.0

}

ui := class(creative_device):
#Overall
   @editable Overall_Devices : Overall = Overall{}

#Wheel 1
   @editable Exotic_Wheel : Wheel_1 = Wheel_1{}

#Wheel 2
   @editable Mythic_Wheel : Wheel_2 = Wheel_2{}
    
    
    var IsRotating : logic = false
    var IsRotating2 : logic = false
    var Degrees : []float = array{0.0, 30.0, 60.0, 90.0, 120.0, 150.0, 180.0, -150.0, -120.0, -90.0, -60.0, -30.0}
    var Degrees2 : []float = array{0.0, 30.0, 60.0, 90.0, 120.0, 150.0, 180.0, -150.0, -120.0, -90.0, -60.0, -30.0}
    var RandomInt : int = 0
    var RandomInt2 : int = 0
    var InitialSpeed : float = 0.2
    var InitialSpeed2 : float = 0.2
    var InitialDelay : int = 8
    var InitialDelay2 : int = 8
    

   
    OnBegin<override>()<suspends>:void=
        
        Exotic_Wheel.Button1.InteractedWithEvent.Subscribe(Wheel1)
        Mythic_Wheel.Button2.InteractedWithEvent.Subscribe(Wheel2)
     
    
    Wheel1(Agent:agent):void=
       OnButtonClicked(Agent,Exotic_Wheel.Price1,"Wheel1")
    Wheel2(Agent:agent):void=
       OnButtonClicked(Agent,Mythic_Wheel.Price2,"Wheel2")
     
    OnButtonClicked(Agent : agent,Price:int,WheelE:string):void=
     if (WheelE = "Wheel1" and IsRotating = false or WheelE ="Wheel2" and IsRotating2 = false ):
        CurrentGoldCount := Overall_Devices.Gold_Checker.GetItemCount (Agent, 0) # Grabs how much gold the player has then stores it in a variable
        if (CurrentGoldCount >= Price ):
            Overall_Devices.Gold_Checker.SetItemCountRequired(0, Price)
            Overall_Devices.Gold_Checker.Activate(Agent)
            if(WheelE = "Wheel1"):
                Exotic_Wheel.Levers_Cinematic1.Play(Agent)
                set RandomInt = GetRandomInt(0, Degrees.Length -1)
                if (Angle := Degrees[RandomInt]):
                    spawn {MakePropsSpin1(Agent, Angle)}
                    
            else:
                Mythic_Wheel.Levers_Cinematic2.Play(Agent)
                set RandomInt2 = GetRandomInt(0, Degrees2.Length -1)
                if (Angle := Degrees2[RandomInt2]):
                    spawn {MakePropsSpin2(Agent, Angle)}
        else:
            Overall_Devices.Not_Enough_Currency_Message.Show(Agent)
            
                
              
     #GoldChecker.SetItemCountRequired(0, 100)
    MakePropsSpin1(Agent : agent, Angle : float)<suspends>:void=

        set IsRotating = true
        var CurrentSpeed : float = InitialSpeed
        var CurrentDelay : int = InitialDelay
        loop:
            Overall_Devices.Spin_Audio.Play(Agent)
            
            Transform := Exotic_Wheel.Spinner1.GetTransform()
            Position2 := Transform.Translation
            Rotation := Transform.Rotation
            NewRotation := Rotation.ApplyRoll((Exotic_Wheel.Rotation_Degrees1 * Pi / 180.0)
            Exotic_Wheel.Spinner1.MoveTo(Position2, NewRotation, CurrentSpeed)
            if (CurrentDelay <= 0):
                if(CurrentSpeed < 0.35):
                   set CurrentSpeed += 0.10
              
                PropCurrentRotation : []float = Exotic_Wheel.Spinner1.GetTransform().Rotation.GetYawPitchRollDegrees()
                if (CurrentAngle := PropCurrentRotation[2]):
                   
                    if (RoundedCurrentAngle := Round[CurrentAngle] * 1.0):
                        if (RoundedCurrentAngle < Angle + 10.0 and RoundedCurrentAngle > Angle - 10.0):
                            set IsRotating = false
                            GrantItem1(Agent)
                            Overall_Devices.XP_Granter.Award(Agent)
                            break
                            
            else:
                set CurrentDelay -= 1
            Sleep(0.0)
    MakePropsSpin2(Agent : agent, Angle : float)<suspends>:void=

        set IsRotating2 = true
        var CurrentSpeed : float = InitialSpeed2
        var CurrentDelay : int = InitialDelay2
        loop:
            Overall_Devices.Spin_Audio.Play(Agent)
          
            Transform := Mythic_Wheel.Spinner2.GetTransform()
            Position3 := Transform.Translation
            Rotation := Transform.Rotation
            NewRotation := Rotation.ApplyRoll((Mythic_Wheel.Rotation_Degrees2 * Pi / 180.0)
            Mythic_Wheel.Spinner2.MoveTo(Position3, NewRotation, CurrentSpeed)
            if (CurrentDelay <= 0):
                if(CurrentSpeed < 0.35):
                    set CurrentSpeed += 0.10
          
                PropCurrentRotation : []float = Mythic_Wheel.Spinner2.GetTransform().Rotation.GetYawPitchRollDegrees()
                if (CurrentAngle := PropCurrentRotation[2]):
                 
                    if (RoundedCurrentAngle := Round[CurrentAngle] * 1.0):
                        if (RoundedCurrentAngle < Angle + 10.0 and RoundedCurrentAngle > Angle - 10.0):
                            set IsRotating2 = false
                            GrantItem2(Agent)
                            Overall_Devices.XP_Granter.Award(Agent)
                            break
                            
            else:
                set CurrentDelay -= 1
            Sleep(0.0)
    GrantItem1(Agent : agent):void=
        if (Item := Exotic_Wheel.Weapon_Granters1[RandomInt]):
            Item.GrantItem(Agent)

    GrantItem2(Agent : agent):void=
        if (Item := Mythic_Wheel.Weapon_Granters2[RandomInt2]):
            Item.GrantItem(Agent)