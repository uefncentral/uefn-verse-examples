# Animated Dropper Pipe
# Creates an animated pipe system that moves dropped items from a dropper through predefined waypoints with smooth interpolation. Players earn income when items reach their destination, simulating a fac
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/dropper-device?ref=github

<#
using { /Fortnite.com/Devices }
using { /Fortnite.com/Devices/CreativeAnimation }
using { /Fortnite.com/Devices/CreativeAnimation/InterpolationTypes }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

agent_data<public> := class:
    var TotalMoney : int = 0

dropper_pipe<public> := class<concrete>:
    @editable
    DroppedProp<public> : creative_prop = creative_prop{}

    @editable
    DropperStartTargetLoc<public> :vector3 = vector3{}
    @editable
    DropperDownTargetLoc<public> :vector3 = vector3{}

    @editable
    DownMovementDuration<public> : float = 0.5
    @editable
    HorizontalMovementDuration<public> : float = 3.0

    @editable
    IncomeOnItemReach<public> : int = 100

    var AnimationKeyFrames : []keyframe_delta = array{}
    var MaybeDropper<public> : ?dropper_device = false

    InitDropperPipe<public>(Dropper : dropper_device):void=
        DroppedProp.Hide()
        set AnimationKeyFrames = array
        {
            DownMovementKeyFrame : keyframe_delta = keyframe_delta
               {
                    DeltaLocation := DropperDownTargetLoc - DropperStartTargetLoc
                    DeltaRotation := IdentityRotation()
                    DeltaScale := vector3 { X := 1.0, Y := 1.0, Z := 1.0 }
                    Time := DownMovementDuration
                    Interpolation := EaseIn
               },
               HorizontalMovementKeyFrame : keyframe_delta = keyframe_delta
               {
                    DeltaLocation := Dropper.HorizontalTargetLoc - DropperDownTargetLoc
                    DeltaRotation := IdentityRotation()
                    DeltaScale := vector3 { X := 1.0, Y := 1.0, Z := 1.0 }
                    Time := HorizontalMovementDuration
                    Interpolation := Linear
               }
        }
        set MaybeDropper = option{Dropper}

    StartDropperPipe<public>():void=
        DroppedProp.Show()
        if (Dropper := MaybeDropper?, PropAnimController := DroppedProp.GetAnimationController[]):
            if (DroppedProp.TeleportTo[DropperStartTargetLoc, IdentityRotation()]){}
            PropAnimController.SetAnimation(AnimationKeyFrames, ?Mode := animation_mode.OneShot)
            PropAnimController.MovementCompleteEvent.Subscribe(OnAnimComplete)

            PropAnimController.Play()

    OnAnimComplete():void=
        if (Dropper := MaybeDropper?, PropAnimController := DroppedProp.GetAnimationController[]):
            Dropper.UpdateTotalSavedUpMoney(IncomeOnItemReach)
            if (DroppedProp.TeleportTo[DropperStartTargetLoc, IdentityRotation()]){}
            PropAnimController.SetAnimation(AnimationKeyFrames, ?Mode := animation_mode.OneShot)

            PropAnimController.Play()

    ResetDropperPipe<public>():void=
        set MaybeDropper = false
        DroppedProp.Hide()

dropper_device<public> := class(creative_device):    

    @editable
    DropperPipes : []dropper_pipe = array{}

    @editable
    ClaimerTrigger : trigger_device = trigger_device{}
    @editable
    StartTrigger : trigger_device = trigger_device{}
    @editable
    IncomeCollectTrigger : trigger_device = trigger_device{}

    @editable
    IncomeBillboard : billboard_device = billboard_device{}

    @editable
    HorizontalTargetLoc : vector3 = vector3{}

    TextForUI<localizes>(Text : string) : message = "{Text}"

    var AgentMap : [agent]agent_data = map{}
    var MaybeOwnerAgent : ?agent = false
    var TotalSavedUpMoney : int = 0

    OnBegin<override>()<suspends>:void=
        Print("OnBegin")

        for (Player : GetPlayspace().GetPlayers()):
            OnPlayerJoined(Player)

        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerJoined)

        ClaimerTrigger.TriggeredEvent.Subscribe(OnClaimerTriggered)
        StartTrigger.TriggeredEvent.Subscribe(OnStartTriggered)
        IncomeCollectTrigger.TriggeredEvent.Subscribe(OnIncomeCollectTriggered)

    OnPlayerJoined(Agent : agent):void=
        if (set AgentMap[Agent] = agent_data{}){}

    OnClaimerTriggered(MaybeAgent : ?agent):void=
        if (Agent := MaybeAgent?):
            InitDropper(Agent)

    InitDropper(Agent : agent):void=
        set MaybeOwnerAgent = option{Agent}
        for (DropperPipe : DropperPipes):
            DropperPipe.InitDropperPipe(Self)

    OnStartTriggered(MaybeAgent : ?agent):void=
        if (Agent := MaybeAgent?, OwnerAgent := MaybeOwnerAgent?, Agent = OwnerAgent):
            for (DropperPipe : DropperPipes):
                DropperPipe.StartDropperPipe()

    OnIncomeCollectTriggered(MaybeAgent : ?agent):void=
        if (Agent := MaybeAgent?, OwnerAgent := MaybeOwnerAgent?, Agent = OwnerAgent,
        AgentData := AgentMap[OwnerAgent]):
            set AgentData.TotalMoney += TotalSavedUpMoney
            for (I := 0 .. 5):
                Print("Total Money: {AgentData.TotalMoney}")

            SetTotalSavedUpMoney(0)

    UpdateTotalSavedUpMoney<public>(Value : int):void=
        SetTotalSavedUpMoney(TotalSavedUpMoney + Value)

    SetTotalSavedUpMoney(Value : int):void=
        set TotalSavedUpMoney = Value
        IncomeBillboard.SetText(TextForUI("{TotalSavedUpMoney}"))

    ResetDropper():void=
        for (DropperPipe : DropperPipes):
            DropperPipe.ResetDropperPipe()
        set MaybeOwnerAgent = false
        SetTotalSavedUpMoney(0)
#>