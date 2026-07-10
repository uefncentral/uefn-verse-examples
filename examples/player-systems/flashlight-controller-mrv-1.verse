# Player Flashlight System
# Creates an assignable flashlight system where each player gets their own light device when they join. Players can toggle their personal flashlight on/off using an input trigger, and lights are automat
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/flashlight-controller-mrv-1?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }

CustomLight := class<concrete>():
    @editable LightDevice : customizable_light_device = customizable_light_device{}

    var IsAvailable : logic = true



Flashlight_Controller := class(creative_device):

    @editable CustomLights : []CustomLight = array{}

    @editable InputTrigger : input_trigger_device = input_trigger_device{}

    OnBegin<override>()<suspends>:void=
        for(Player : GetPlayspace().GetPlayers()):
            TrackPlayer(Player)
        
        GetPlayspace().PlayerAddedEvent().Subscribe(TrackPlayer)


    TrackPlayer(Agent:agent) : void=
        spawn:
            TrackPlayer2(Agent)


    GetAvailableLight() : CustomLight=
        var NewLight : CustomLight = CustomLight{}
        var IsFound : logic = false
        for(L : CustomLights , not IsFound?):
            if(L.IsAvailable?):
                set NewLight = L
                set IsFound = true
                set L.IsAvailable = false
        return NewLight

    TrackPlayer2(Agent:agent)<suspends> : void=
        NewLight := GetAvailableLight()
        var IsOff : logic = true

        if(FC := Agent.GetFortCharacter[]):
            race:
                block:
                    loop:
                        PlayerLeft := GetPlayspace().PlayerRemovedEvent().Await()
                        if(PlayerLeft = Agent):
                            set NewLight.IsAvailable = true
                            NewLight.LightDevice.TurnOff()
                            break
                block:
                    loop:
                        TogglingPlayer := InputTrigger.PressedEvent.Await()
                        if(TogglingPlayer = Agent):
                            if(IsOff?):
                                NewLight.LightDevice.TurnOn()
                                set IsOff = false
                            else:
                                NewLight.LightDevice.TurnOff()
                                set IsOff = true
                loop:       
                    Sleep(0.0)
                    PlayerPos := FC.GetTransform().Translation
                    PlayerRot := FC.GetViewRotation()
                    PlayerForwardVector := PlayerRot.GetLocalForward() * 100.0
                    SpawnPos := PlayerPos + PlayerForwardVector
                    if(NewLight.LightDevice.TeleportTo[SpawnPos + vector3{Z:= 30.0},PlayerRot]){}



        