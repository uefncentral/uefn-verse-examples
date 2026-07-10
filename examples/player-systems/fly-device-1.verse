# Chair Flight System
# Creates a flying chair mechanic where players can sit in a chair and control its movement using input triggers. The chair moves forward in the direction the player is looking when the input is pressed
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/fly-device-1?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }

fly_device := class(creative_device):

    @editable Chair : chair_device = chair_device{}
    @editable Cam : gameplay_camera_orbit_device = gameplay_camera_orbit_device{}
    @editable InputTrigger : input_trigger_device = input_trigger_device{}

    var MovingForward : logic = false
    
    OnBegin<override>()<suspends>:void=
        Chair.SeatedEvent.Subscribe(StartFlight)
        InputTrigger.PressedEvent.Subscribe(MoveForward)
        InputTrigger.ReleasedEvent.Subscribe(StopMoving)

    MoveForward(Agent:agent) : void=
        set MovingForward = true

    StopMoving(Agent:agent , Time : float) : void=
        set MovingForward = false
        

    StartFlight(Agent : agent) : void=
        if(FortChar := Agent.GetFortCharacter[]):
            Cam.AddTo(Agent)
            InputTrigger.Register(Agent)
            spawn:
                MoveChair(FortChar)


    MoveChair(FC : fort_character)<suspends> : void=
        race:
            block:
                Chair.ExitedEvent.Await()

                if(Agent := FC.GetAgent[]):
                    InputTrigger.Unregister(Agent)
                    Cam.RemoveFrom(Agent)

            loop:
                Sleep(0.0)
                if(MovingForward?):
                    PlayerPos := FC.GetTransform().Translation
                    PlayerRot := FC.GetViewRotation()
                    PlayerForwardVector := FC.GetViewRotation().GetLocalForward() * 300.0
                    MovePos := PlayerPos + PlayerForwardVector
                    Chair.MoveTo(MovePos, PlayerRot, 0.2)
