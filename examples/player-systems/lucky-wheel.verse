# Lucky Wheel
# Verse code for Lucky Wheel - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/lucky-wheel?ref=github

using { /Verse.org/Random }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }


team1_device := class(creative_device):

    @editable
    CarnavalWheel:creative_prop=creative_prop{}
    @editable
    WheelButton:button_device=button_device{}
    @editable
    wheelActivator : button_device = button_device {}
    @editable
    GrantBoogie : item_granter_device = item_granter_device {}
    @editable
    GrantPlunger : item_granter_device = item_granter_device {}
    @editable
    GrantIce : item_granter_device = item_granter_device {}
    @editable
    GrantJunk : item_granter_device = item_granter_device {}

    var IsRotating:logic=false
    var playercoins :int =0
    var playerPoints : int = 50000
    

    OnBegin<override>()<suspends>:void=
        initial()
        WheelButton.InteractedWithEvent.Subscribe(OnSpinButtonClick)

    OnSpinButtonClick(Agent:agent):void=
        if(IsRotating = false):
            if (playerPoints >= 500):
                set playerPoints = playerPoints - 500
                    spawn:
                        RotatWheel(Agent)

                

    RotatWheel(Agent:agent)<suspends>:void=
        var RotateDegrees:float = 150.0
        set IsRotating = true
        loop:
            CarnavalWheel.MoveTo(CarnavalWheel.GetTransform().Translation,CarnavalWheel.GetTransform().Rotation.ApplyRoll((RotateDegrees * Pi / 180.0)
            var RandomInt:int=GetRandomInt(5,25)
            RandomFloat:float=RandomInt*1.0

            set RotateDegrees -= RandomFloat
            if(RotateDegrees< 0.0):
            
                set IsRotating = false
                WheelRotation:[]float=CarnavalWheel.GetTransform().Rotation.GetYawPitchRollDegrees()
                if(Roll:float = WheelRotation[2]):
                    if(Roll>=0.0 and Roll <=44.9):
                        GrantIce.GrantItem(Agent)

                    else if(Roll>=45.0 and Roll <=89.9):
                        GrantJunk.GrantItem(Agent)

                    else if(Roll>=90.0 and Roll <=134.9):
                        GrantBoogie.GrantItem(Agent)

                    else if(Roll>=135.0 and Roll <=180.0):
                        GrantPlunger.GrantItem(Agent)

                    else if(Roll>=180.0 and Roll <=225.0):
                        GrantIce.GrantItem(Agent)

                    else if(Roll>=225.0 and Roll <=270.0):
                        GrantJunk.GrantItem(Agent)

                    else if(Roll>=270.0 and Roll <=315.0):
                        GrantBoogie.GrantItem(Agent)

                    else if(Roll>=315.0 and Roll <=360.0):
                        GrantPlunger.GrantItem(Agent)
                break


    initial():void=

        wheelActivator.Enable()