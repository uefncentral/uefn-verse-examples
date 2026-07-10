# Slap Fight Game
# Creates a slap fighting game where players can equip gloves and slap each other with cooldowns and radius detection. Players interact with buttons to wear gloves, then use input triggers to perform sl
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/slap-fight-main-device-1?ref=github


using { /Fortnite.com/Game }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Devices/CreativeAnimation }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }

SlapFightModule := module:

    glove_data := class<concrete>:
        @editable
        WearButton : button_device = button_device{}

        @editable
        GlovePropAsset : creative_prop_asset = DefaultCreativePropAsset

        @editable
        MovementModulator : movement_modulator_device = movement_modulator_device{}

        @editable
        SlapCooldownSeconds : float = 1.0

        @editable
        SlapRadius : float = 500.0

        var MaybeMainDevice : ?slap_fight_main_device = false

        Init<public>(MainDevice : slap_fight_main_device):void=
            set MaybeMainDevice = option{ MainDevice }
            WearButton.InteractedWithEvent.Subscribe(OnWearInteractedWith)

        OnWearInteractedWith(Agent : agent):void=
            if (MainDevice := MaybeMainDevice?):
                MainDevice.OnWearGlove(Agent, Self)                

    glove_instance_data := class:
        GlovePropInstance : creative_prop
        GloveData : glove_data
        var bMoving : logic
        var LastSlapTime : float

    slap_fight_main_device := class(creative_device):

        @editable
        PlayerSpawners : []player_spawner_device = array{}

        @editable
        SlapInputTrigger : input_trigger_device = input_trigger_device{}

        @editable
        GlovesData : []glove_data = array{}

        @editable
        SlapHitRadius : float = 150.0

        var MaybeGlovePerAgent : [agent]?glove_instance_data = map{}

        OnBegin<override>()<suspends>:void=
            Print("OnBegin")

            SlapInputTrigger.PressedEvent.Subscribe(OnSlap)
            GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerLeft)

            for (GloveData : GlovesData):
                GloveData.Init(Self)

            for (PlayerSpawner : PlayerSpawners):
                PlayerSpawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

            spawn{ AsyncGloveFollow() }

        OnPlayerSpawned(Agent : agent):void=
            if (GloveInstanceData := MaybeGlovePerAgent[Agent]?):
                GloveInstanceData.GlovePropInstance.Show()

        OnPlayerEliminated(EliminationResult : elimination_result):void=
            if (EliminatedAgent := EliminationResult.EliminatedCharacter.GetAgent[],
            GloveInstanceData := MaybeGlovePerAgent[EliminatedAgent]?):
                GloveInstanceData.GlovePropInstance.Hide()

        OnPlayerLeft(Player : player):void=
            if (GloveInstanceData := MaybeGlovePerAgent[Player]?):
                GloveInstanceData.# GlovePropInstance.Dispose()  # TODO: Verse has no manual disposal
                if (set MaybeGlovePerAgent[Player] = false){}

        OnWearGlove(Agent : agent, GloveData : glove_data):void=
            if (GloveInstance := MaybeGlovePerAgent[Agent]?):
                GloveInstance.# GlovePropInstance.Dispose()  # TODO: Verse has no manual disposal
                if (set MaybeGlovePerAgent[Agent] = false){}

            else:
                SlapInputTrigger.Register(Agent)

            if (FortCharacter := Agent.GetFortCharacter[]):

                FortCharacter.EliminatedEvent().Subscribe(OnPlayerEliminated)

                FCTransform := FortCharacter.GetTransform()
                LocalRight := FCTransform.Rotation.GetLocalRight()
                SomeLocationAtRight := FCTransform.Translation + (LocalRight * 250.0)

                SpawnResult : tuple(?creative_prop, spawn_prop_result) = SpawnProp(GloveData.GlovePropAsset,
                SomeLocationAtRight, MakeRotationFromYawPitchRollDegrees(0.0, 0.0, -45.0))

                if (SpawnedProp := SpawnResult(0)?):
                    if (set MaybeGlovePerAgent[Agent] = option{ glove_instance_data{
                        GlovePropInstance := SpawnedProp, GloveData := GloveData,
                        bMoving := false, LastSlapTime := 0.0 }}){}

        OnSlap(Agent : agent):void=
            CurrentTime := GetSimulationElapsedTime()

            if (GloveInstanceData := MaybeGlovePerAgent[Agent]?,
            (GloveInstanceData.LastSlapTime + GloveInstanceData.GloveData.SlapCooldownSeconds) < CurrentTime,
            ThisPlayer := player[Agent], FortCharacter := Agent.GetFortCharacter[]):

                GloveData := GloveInstanceData.GloveData

                FCTransform := FortCharacter.GetTransform()
                FCRightVector := FCTransform.Rotation.GetLocalRight()
                SphereLocation := FCTransform.Translation + (FCTransform.Rotation.GetLocalForward() * GloveData.SlapRadius)
                SphereRadius := GloveData.SlapRadius

                var MaybeSlapAgent : ?agent = false
                var CurrentSlapAgentDistance : float = SphereRadius*2.0

                Players := GetPlayspace().GetPlayers()
                for (Player : Players, Player <> ThisPlayer, PlayerFortCharacter := Player.GetFortCharacter[]):
                    PlayerLocation := PlayerFortCharacter.GetTransform().Translation

                    CurrentDistance := Distance(PlayerLocation, SphereLocation)
                    if (CurrentDistance <= SphereRadius and CurrentDistance <= CurrentSlapAgentDistance):
                        set CurrentSlapAgentDistance = CurrentDistance
                        set MaybeSlapAgent = option{ Player }

                GlovePropInstance := GloveInstanceData.GlovePropInstance
                GPTransform := GlovePropInstance.GetTransform()
                var DeltaLocation : vector3 = FCTransform.Rotation.GetLocalForward() * 100.0
                FirstKeyFrameDuration := 0.35

                if (SlappedAgent := MaybeSlapAgent?, SlappedFortCharacter := SlappedAgent.GetFortCharacter[]):
                    MovementModulator := GloveData.MovementModulator

                    spawn{ LateActivate(MovementModulator, SlappedAgent, Agent, GlovePropInstance, FirstKeyFrameDuration) }

                    set DeltaLocation = SlappedFortCharacter.GetTransform().Translation - GPTransform.Translation

                set GloveInstanceData.LastSlapTime = CurrentTime

                ZAngle := 105.0
                TargetRotation := GPTransform.Rotation.ApplyWorldRotationZ((ZAngle * Pi / 180.0))

                DeltaRotation := MakeShortestRotationBetween(GPTransform.Rotation, TargetRotation)
                AnimationKeyFrames : []keyframe_delta = array
                {
                    keyframe_delta
                    {
                        DeltaLocation := DeltaLocation,
                        DeltaRotation := DeltaRotation,
                        Time := FirstKeyFrameDuration,
                        Interpolation := InterpolationTypes.EaseInOut
                    },
                    keyframe_delta
                    {
                        DeltaLocation := vector3{},
                        DeltaRotation := IdentityRotation(),
                        Time := 0.15,
                        Interpolation := InterpolationTypes.Linear
                    }
                }

                if (AnimController := GlovePropInstance.GetAnimationController[]):
                    AnimController.SetAnimation(AnimationKeyFrames, ?Mode := animation_mode.OneShot)
                    AnimController.Play()

        LateActivate(MovementModulator : movement_modulator_device, SlappedAgent : agent,
        SlappingAgent : agent, GloveProp : creative_prop, SleepDuration : float)<suspends>:void=
           Sleep(SleepDuration)

            if (SlappedFortCharacter := SlappedAgent.GetFortCharacter[]):

                DistanceToGlove := Distance(SlappedFortCharacter.GetTransform().Translation, GloveProp.GetTransform().Translation)
                if (DistanceToGlove <= SlapHitRadius, SlappingFortCharacter := SlappingAgent.GetFortCharacter[]):

                    FCRightVector := SlappingFortCharacter.GetTransform().Rotation.GetLocalRight()

                    MMTransform := MovementModulator.GetTransform()
                    MMForwardVector := MMTransform.Rotation.GetLocalForward()

                    ShortestRotation := MakeShortestRotationBetween(MMForwardVector, FCRightVector)
                    MMNewRotation := MMTransform.Rotation.RotateBy(ShortestRotation)

                    if (MovementModulator.TeleportTo[MMTransform.Translation, MMNewRotation]):
                        Print("Teleport Success.")

                    MovementModulator.Activate(SlappedAgent)

        AsyncGloveFollow()<suspends>:void=
            loop:
                Sleep(0.0)

                Players := GetPlayspace().GetPlayers()
                for (Player : Players, GloveInstanceData := MaybeGlovePerAgent[Player]?, GloveInstanceData.bMoving = false,
                AnimController := GloveInstanceData.GlovePropInstance.GetAnimationController[],
                AnimController.GetState() <> animation_controller_state.Playing,
                FortCharacter := Player.GetFortCharacter[], FortCharacter.IsActive[]):

                    GlovePropInstance := GloveInstanceData.GlovePropInstance
                    Radius := 150.0

                    FCTransform := FortCharacter.GetTransform()
                    FCForwardVector := FCTransform.Rotation.GetLocalForward()
                    FCRightVector := FCTransform.Rotation.GetLocalRight()
                    FCLeftVector := vector3{ X := -FCRightVector.X, Y := -FCRightVector.Y, Z := FCRightVector.Z }

                    FCLocation := FCTransform.Translation
                    LeftPoint := FCLocation + (FCLeftVector * Radius)

                    var TargetPoint : vector3 = LeftPoint + (FCForwardVector * 75.0)
                    set TargetPoint.Z += 75.0

                    GPTransform := GlovePropInstance.GetTransform()

                    PropDistance := Distance(GPTransform.Translation, TargetPoint)
                    LimitDistance := 50.0
                    if (PropDistance >= LimitDistance):
                        T := 0.1
                        V := LimitDistance / T

                        NewT := if (PropDistance > (LimitDistance*20.0))
                        then T
                        else PropDistance / V

                        GPForwardVector := GPTransform.Rotation.GetLocalForward()
                        ShortestRotation := MakeShortestRotationBetween(GPForwardVector, FCForwardVector)
                        TargetRotation := GPTransform.Rotation.RotateBy(ShortestRotation)

                        set GloveInstanceData.bMoving = true
                        spawn{ MoveGlove(GloveInstanceData, TargetPoint, TargetRotation, NewT) }

        MoveGlove(GloveInstanceData : glove_instance_data, TargetLocation : vector3,
        TargetRotation : rotation, MoveTime : float)<suspends>:void=
            GloveInstanceData.GlovePropInstance.MoveTo(TargetLocation, TargetRotation, MoveTime)
            set GloveInstanceData.bMoving = false