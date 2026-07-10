# Carnival Wheel Spinner
# Creates an interactive carnival/prize wheel that players can spin by pressing a button. The wheel rotates with decreasing speed and awards random items from a selection of weapons and consumables when
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/prize-wheel-1?ref=github

using { /Fortnite.com/Devices }

using { /Fortnite.com/Devices/CreativeAnimation }

using { /Fortnite.com/Devices/CreativeAnimation/InterpolationTypes}

using { /Verse.org/Simulation }

using { /Verse.org/Random }

using { /UnrealEngine.com/Temporary/Diagnostics }

using { /UnrealEngine.com/Temporary/SpatialMath }



GameManager := class(creative_device):



    @editable

    CarnivalWheel:creative_prop = creative_prop{}



    @editable

    SpinButton:conditional_button_device = conditional_button_device{}



    @editable

    Banana:item_granter_device = item_granter_device{}

    @editable

    DrumGun:item_granter_device = item_granter_device{}

    @editable

    Pistol:item_granter_device = item_granter_device{}

    @editable

    Pump:item_granter_device = item_granter_device{}

    @editable

    Rocket:item_granter_device = item_granter_device{}

    @editable

    Ballistic:item_granter_device = item_granter_device{}

    @editable

    Grappler:item_granter_device = item_granter_device{}

    @editable

    Wings:item_granter_device = item_granter_device{}



    @editable

    ConfettiVFX:vfx_spawner_device = vfx_spawner_device{}



    var IsRotating:logic = false



    OnBegin<override>()<suspends>:void=

        SpinButton.ActivatedEvent.Subscribe(OnSpinButtonClick)





    OnSpinButtonClick(Agent:agent):void=

        if(IsRotating = false):

            spawn:

                MakeWheelSpin(Agent)

        



    MakeWheelSpin(Agent:agent)<suspends>:void=

        var RotateDegrees:float = 150.0

        set IsRotating = true

        loop:

            CarnivalWheel.MoveTo(CarnivalWheel.GetTransform().Translation, CarnivalWheel.GetTransform().Rotation.ApplyRoll((RotateDegrees * Pi / 180.0)

            var RandomInt:int = GetRandomInt(5, 25)

            RandomFloat:float = RandomInt * 1.0

            



            set RotateDegrees -= RandomFloat

            if(RotateDegrees < 0.0):

                

                spawn:

                    StartConfetti()

                set IsRotating = false

                WheelRotation:[]float = CarnivalWheel.GetTransform().Rotation.GetYawPitchRollDegrees()

                if(Roll:float = WheelRotation[2]):

                    Print("Current roll rotation {Roll}")

                    if(Roll >= 0.0 and Roll <= 34.9):

                        Banana.GrantItem(Agent)

                    else if(Roll >= 35.0 and Roll <= 79.9):

                        DrumGun.GrantItem(Agent)

                    else if(Roll >= 80.0 and Roll <= 124.9):

                        Pistol.GrantItem(Agent)

                    else if(Roll >= 125.0 and Roll <= 180.0):

                        Pump.GrantItem(Agent)

                    else if(Roll <= 0.0 and Roll >= -34.9):

                        Rocket.GrantItem(Agent)

                    else if(Roll <= -35.0 and Roll >= -79.9):

                        Ballistic.GrantItem(Agent)

                    else if(Roll <= -80.0 and Roll >= -124.9):

                        Grappler.GrantItem(Agent)

                    else if(Roll <= -125.0 and Roll >= -180.0):

                        Wings.GrantItem(Agent)



                break

            



    StartConfetti()<suspends>:void=

        ConfettiVFX.Enable()

        Sleep(5.0)

        ConfettiVFX.Disable()