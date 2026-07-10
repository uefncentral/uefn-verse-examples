# Blade Ball Game System
# A custom game mode that implements a blade ball mechanic where players can fire, shield, and perform special jumps while interacting with a ball prop. The system manages player spawning, team selectio
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/blade-ball-device?ref=github


using { /Fortnite.com/UI }
using { /Fortnite.com/Game }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Colors }
using { /Verse.org/Assets }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { /Verse.org/Concurrency }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }

BladeBallModule := module:

    agent_data := class:    
        var bShieldOn : logic = false
        var LastFireTime : float = 0.0
        var LastShieldTime : float = 0.0
        var LastJumpHighTime : float = 0.0
        var LastJumpForwardTime : float = 0.0

        var MaybeCanvas : ?canvas = false

    blade_ball_device := class(creative_device):

        @editable
        PlayerSpawners : []player_spawner_device = array{}

        @editable
        GameAreaTeleporters : []teleporter_device = array{}
        @editable
        LobbyTeleporters : []teleporter_device = array{}

        @editable
        BallProp : creative_prop = creative_prop{}

        @editable
        ClassSelectorGreen : class_and_team_selector_device = class_and_team_selector_device{}
        @editable
        ClassSelectorRed : class_and_team_selector_device = class_and_team_selector_device{}

        @editable
        FireInputTrigger : input_trigger_device = input_trigger_device{}
        @editable
        ShieldInputTrigger : input_trigger_device = input_trigger_device{}
        @editable
        JumpHighInputTrigger : input_trigger_device = input_trigger_device{}
        @editable
        JumpForwardInputTrigger : input_trigger_device = input_trigger_device{}

        @editable
        UpwardModulator : movement_modulator_device = movement_modulator_device{}
        @editable
        ForwardModulator : movement_modulator_device = movement_modulator_device{}

        @editable
        GameStartButton : button_device = button_device{}

        @editable
        ShieldVFXPowerup : visual_effect_powerup_device = visual_effect_powerup_device{}

        @editable
        ScoreManager : score_manager_device = score_manager_device{}

        @editable
        RoundCountdownHudMessager : hud_message_device = hud_message_device{}

        @editable
        BallBaseSpeedUnitsPerSecond : float = 512.0
        @editable
        BallSpeedIncreaseUnitsPerSecond : float = 256.0

        @editable
        BallHitRadius : float = 192.0

        @editable
        ShieldDurationSeconds : float = 2.0

        @editable
        ShieldCooldownSeconds : float = 4.0
        @editable
        JumpHighCooldownSeconds : float = 2.5
        @editable
        JumpForwardCooldownSeconds : float = 2.5

        @editable
        RoundCountdownSeconds : type {_X:int where 1 <= _X, _X <= 59} = 10

        TextForUI<localizes>(InText : string) : message = "{InText}"

        SkillIconSize : vector2 = vector2{ X := 102.0, Y := 174.0 }

        var AgentMap : [agent]agent_data = map{}
        var InGamePlayers : []player = array{}

        var BallTargetIndex : int = -1
        var MaybeBallTargets : []?agent = array{ false, false }
        var MaybeWaitingTask : ?task(void) = false

        var BallStartLocation : vector3 = vector3{}

        var CurrentBallSpeed : float = 0.0

        var bGameActive : logic = false
        var bGameRoundActive : logic = false

        OnBegin<override>()<suspends>:void=
            Print("OnBegin")

            set BallStartLocation = BallProp.GetTransform().Translation            

            GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerLeft)

            for (PlayerSpawner : PlayerSpawners):
                PlayerSpawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

            FireInputTrigger.PressedEvent.Subscribe(OnFireInputPressed)
            ShieldInputTrigger.PressedEvent.Subscribe(OnShieldInputPressed)
            JumpHighInputTrigger.PressedEvent.Subscribe(OnJumpHighInputPressed)
            JumpForwardInputTrigger.PressedEvent.Subscribe(OnJumpForwardInputPressed)

            GameStartButton.InteractedWithEvent.Subscribe(OnGameStartButtonPressed)

            ShieldVFXPowerup.SetDuration(ShieldDurationSeconds)

            spawn{ AsyncBallTick() }
            spawn{ AsyncUITick() }

# EVENTS:
        OnPlayerLeft(Player : player):void=

            bFindNewBallTarget : logic = TryRemovingBallTarget(Player)

            if (NewInGamePlayers := InGamePlayers.RemoveFirstElement[Player]):
                set InGamePlayers = NewInGamePlayers

            spawn{ LatePlayerLeft(bFindNewBallTarget) }

        LatePlayerLeft(bFindNewBallTarget : logic)<suspends>:void=
            Sleep(3.0)

            Players := GetPlayspace().GetPlayers()
            if (Players.Length < 2 or InGamePlayers.Length < 2):
                set bGameActive = false
                set bGameRoundActive = false

                ShuffledTeleporters := Shuffle(LobbyTeleporters)

                for (I := 0 .. Players.Length-1, Player := Players[I]):
                    if (Teleporter := ShuffledTeleporters[I]):
                        Teleporter.Teleport(Player)
                    else:
                        RandomTeleporterIndex := GetRandomInt(0, ShuffledTeleporters.Length-1)
                        if (Teleporter := ShuffledTeleporters[RandomTeleporterIndex]):
                            Teleporter.Teleport(Player)
            else:
                if (bFindNewBallTarget = true):
                    FindBallTarget()

        OnPlayerSpawned(Agent : agent):void=
            if (AgentData := AgentMap[Agent]):
                RandomTeleporterIndex := GetRandomInt(0, LobbyTeleporters.Length-1)
                if (Teleporter := LobbyTeleporters[RandomTeleporterIndex]):
                    Teleporter.Teleport(Agent)

            else:
                AgentData := agent_data{}
                if (Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
                    Canvas := CreateCanvas()
                    PlayerUI.AddWidget(Canvas)

                    set AgentData.MaybeCanvas = option{ Canvas }

                if (set AgentMap[Agent] = AgentData){}

                FireInputTrigger.Register(Agent)
                ShieldInputTrigger.Register(Agent)
                JumpHighInputTrigger.Register(Agent)
                JumpForwardInputTrigger.Register(Agent)
                
                if (FC := Agent.GetFortCharacter[]):
                    FC.EliminatedEvent().Subscribe(OnPlayerEliminated)

        OnPlayerEliminated(EliminationResult : elimination_result):void=
            if (EliminatedAgent := EliminationResult.EliminatedCharacter.GetAgent[],
            EliminatedPlayer := player[EliminatedAgent]):                

                ClassSelectorGreen.ChangeClass(EliminatedAgent)

                if (LobbyTeleporter := LobbyTeleporters[GetRandomInt(0, LobbyTeleporters.Length-1)]):
                    LobbyTeleporter.Teleport(EliminatedPlayer)

        OnFireInputPressed(Agent : agent):void=            
            if (AgentData := AgentMap[Agent]):
                set AgentData.LastFireTime = GetSimulationElapsedTime()

        OnShieldInputPressed(Agent : agent):void=
            CurrentTime := GetSimulationElapsedTime()
            if (AgentData := AgentMap[Agent], AgentData, AgentData.bShieldOn = false,
            (AgentData.LastShieldTime + ShieldCooldownSeconds < CurrentTime)):

                ShieldVFXPowerup.Pickup(Agent)
                set AgentData.LastShieldTime = CurrentTime
                set AgentData.bShieldOn = true

                spawn{ LateShieldDeactivate(AgentData) }

                if (Canvas := AgentData.MaybeCanvas?):
                    SetShieldBoxFill(Canvas, 1.0)

        LateShieldDeactivate(AgentData : agent_data)<suspends>:void=
            Sleep(ShieldDurationSeconds)

            set AgentData.bShieldOn = false

        OnJumpHighInputPressed(Agent : agent):void=
            CurrentTime := GetSimulationElapsedTime()
            if (AgentData := AgentMap[Agent], AgentData,
            (AgentData.LastJumpHighTime + JumpHighCooldownSeconds < CurrentTime)):
                set AgentData.LastJumpHighTime = CurrentTime
                UpwardModulator.Activate(Agent)

                if (Canvas := AgentData.MaybeCanvas?):
                    SetJumpUpBoxFill(Canvas, 1.0)

        OnJumpForwardInputPressed(Agent : agent):void=
            CurrentTime := GetSimulationElapsedTime()
            if (AgentData := AgentMap[Agent], AgentData,
            (AgentData.LastJumpForwardTime + JumpForwardCooldownSeconds < CurrentTime),
            FC := Agent.GetFortCharacter[]):
                set AgentData.LastJumpForwardTime = CurrentTime
                FCRotation := FC.GetTransform().Rotation

                if (ForwardModulator.TeleportTo[ForwardModulator.GetTransform().Translation, FCRotation]){}

                ForwardModulator.Activate(Agent)

                if (Canvas := AgentData.MaybeCanvas?):
                    SetJumpForwardBoxFill(Canvas, 1.0)

        OnGameStartButtonPressed(Agent : agent):void=
            Players := GetPlayspace().GetPlayers()
            if (bGameActive = true or Players.Length < 2):
                return

            set bGameActive = true
            spawn{ AsyncRoundStarter() }

# VARIOUS FUNCTIONS:

        TryRemovingBallTarget(Agent : agent):logic=
            var bRemoved : logic = false

            if (MaybeBallTarget0 := MaybeBallTargets[0], MaybeBallTarget1 := MaybeBallTargets[1]):

                var FoundIndex : int = -1
                if (BallTarget0 := MaybeBallTarget0?, Agent = BallTarget0):
                    set FoundIndex = 0

                if (BallTarget1 := MaybeBallTarget1?, Agent = BallTarget1):
                    set FoundIndex = 1

                if (FoundIndex <> -1):
                    if (MaybeBallTargets[FoundIndex] = false){}
                    set MaybeWaitingTask = false

                    set bRemoved = true

            return bRemoved

        ChangeBallTarget():logic=
            if (BallTarget0 := MaybeBallTargets[0]?, BallTarget1 := MaybeBallTargets[1]?):
                set BallTargetIndex = if (BallTargetIndex = 0)
                then 1
                else 0

                set CurrentBallSpeed += BallSpeedIncreaseUnitsPerSecond

                UpdatePlayerClasses()
                return true

            else:
                FindBallTarget()
                return false

        FindBallTarget():void=
            if (BallTarget0 := MaybeBallTargets[0]?, BallTarget1 := MaybeBallTargets[1]?):
                return

            set CurrentBallSpeed = BallBaseSpeedUnitsPerSecond
            if (BallTarget0 := MaybeBallTargets[0]?):
                set BallTargetIndex = 1
            else if (BallTarget1 := MaybeBallTargets[1]?):
                set BallTargetIndex = 0
            else:
                set BallTargetIndex = GetRandomInt(0, 1)

            var ShuffledInGamePlayers : []player = Shuffle(InGamePlayers)

            for (I := 0 .. 1):
                if (set MaybeBallTargets[I] = option{ShuffledInGamePlayers[I]}){}

            UpdatePlayerClasses()

        UpdatePlayerClasses():void=
            OtherTargetIndex := if (BallTargetIndex = 0)
            then 1
            else 0

            if (RedTarget := MaybeBallTargets[BallTargetIndex]?, RedTargetPlayer := player[RedTarget]):
                ClassSelectorRed.ChangeClass(RedTarget)

                for (InGamePlayer : InGamePlayers, InGamePlayer <> RedTargetPlayer):
                    ClassSelectorGreen.ChangeClass(InGamePlayer)

        AsyncBusyWait()<suspends>:void=
            loop:
                Sleep(0.0)
                if (WaitingTask := MaybeWaitingTask?):
                    break

        AsyncRoundStarter()<suspends>:void=

            set bGameRoundActive = false
            set CurrentBallSpeed = BallBaseSpeedUnitsPerSecond

            if (BallProp.TeleportTo[BallStartLocation, IdentityRotation()]){}

            Players := GetPlayspace().GetPlayers()
            ShuffledTeleporters := Shuffle(GameAreaTeleporters)

            RoundCountdownHudMessager.Show()

            var SecondsPassed : int = 0
            loop:
                if (SecondsPassed >= RoundCountdownSeconds or bGameActive = false):
                    break

                RoundCountdownHudMessager.SetText(TextForUI("{RoundCountdownSeconds-SecondsPassed}"))
                set SecondsPassed += 1
                Sleep(1.0)

            RoundCountdownHudMessager.Hide()

            if (bGameActive = false):
                return

            set bGameRoundActive = true
            set InGamePlayers = Players

            for (I := 0 .. Players.Length-1, Player := Players[I]):
                if (Teleporter := ShuffledTeleporters[I]):
                    Teleporter.Teleport(Player)
                else:
                    RandomTeleporterIndex := GetRandomInt(0, ShuffledTeleporters.Length-1)
                    if (Teleporter := ShuffledTeleporters[RandomTeleporterIndex]):
                        Teleporter.Teleport(Player)

        AsyncBallTick()<suspends>:void=
            var MainLoopSleepSeconds : float = 0.1
            loop:
                Sleep(MainLoopSleepSeconds)

                if (bGameActive = true, bGameRoundActive = true):
                    if (BallTarget0 := MaybeBallTargets[0]?,
                    BallTarget1 := MaybeBallTargets[1]?, ActualBallTarget := MaybeBallTargets[BallTargetIndex]?,
                    ActualBallTargetFC := ActualBallTarget.GetFortCharacter[]):

                        WaitingTask : task(void) = spawn{ AsyncBusyWait() }
                        set MaybeWaitingTask = option{ WaitingTask }
    
                        loop:
                            StartLocation : vector3 = BallProp.GetTransform().Translation
                            EndLocation : vector3 = ActualBallTargetFC.GetTransform().Translation
                            EntireDistance : float = Distance(EndLocation, StartLocation)
                            Direction : vector3 = if (Dir := (EndLocation - StartLocation).MakeUnitVector[])
                            then Dir
                            else vector3{}
    
                            var MoveTime : float = 0.25
                            var DistanceToCover : float = MoveTime * CurrentBallSpeed
                            if (DistanceToCover > EntireDistance):
                                set DistanceToCover = EntireDistance
                                set MoveTime = DistanceToCover / CurrentBallSpeed
    
                            var TargetLocation : vector3 = StartLocation + Direction*DistanceToCover
                            if (TargetLocation.Z < BallStartLocation.Z):
                                set TargetLocation.Z = BallStartLocation.Z
                            MovementStartTime := GetSimulationElapsedTime()
    
                            race:
                                WaitingTask.Await()
                                BallProp.MoveTo(TargetLocation, IdentityRotation(), MoveTime)
    
                            MovementEndTime := GetSimulationElapsedTime()
    
                            if (ActualBallTargetAgain := MaybeBallTargets[BallTargetIndex]?){}
                            else:
                                set MainLoopSleepSeconds = 0.1
                                break
    
                            if (Distance(ActualBallTargetFC.GetTransform().Translation, BallProp.GetTransform().Translation) <= BallHitRadius):
                                
                                if (TargetAgentData := AgentMap[ActualBallTarget]):
                                    if (TargetAgentData.bShieldOn = true or
                                    (TargetAgentData.LastFireTime >= (MovementStartTime-0.2) and TargetAgentData.LastFireTime <= MovementEndTime)):
                                        bSuccessfullChange := ChangeBallTarget()
                                        set MainLoopSleepSeconds = 0.0
                                    else:
                                        if (ActualBallTargetPlayer := player[ActualBallTarget],
                                        NewInGamePlayers := InGamePlayers.RemoveFirstElement[ActualBallTargetPlayer]):
                                            set InGamePlayers = NewInGamePlayers

                                        OtherTargetIndex : int = if (BallTargetIndex = 0)
                                        then 1
                                        else 0
                                        if (OtherTarget := MaybeBallTargets[OtherTargetIndex]?):
                                            ScoreManager.Activate(OtherTarget)
    
                                        if (set MaybeBallTargets[BallTargetIndex] = false){}

                                        ActualBallTargetFC.Damage(ActualBallTargetFC.GetMaxHealth()*2.0)
                                        set MainLoopSleepSeconds = 0.0

                                        if (InGamePlayers.Length = 1, InGamePlayer := InGamePlayers[0],
                                        LobbyTeleporter := LobbyTeleporters[0]):
                                            LobbyTeleporter.Teleport(InGamePlayer)

                                            set bGameRoundActive = false
                                            spawn{ AsyncRoundStarter() }

                                            break

                                        FindBallTarget()
                                break
    
                            if (PulledWaitingTask := MaybeWaitingTask? or bGameRoundActive = false or bGameActive = false):
                                set MainLoopSleepSeconds = 0.1
                                break
    
                        set MaybeWaitingTask = false

                    else:

                        FindBallTarget()
                        set MainLoopSleepSeconds = 3.0

# UI.
        AsyncUITick()<suspends>:void=

            loop:
                Sleep(0.0)
                CurrentTime := GetSimulationElapsedTime()

                Players := GetPlayspace().GetPlayers()
                for (Player : Players, AgentData := AgentMap[Player]):
                    
                    if (AgentData.LastShieldTime + ShieldCooldownSeconds > (CurrentTime-0.25)):
                        if (Canvas := AgentData.MaybeCanvas?):

                            FillRatio := 1.0 - ((CurrentTime - AgentData.LastShieldTime) / ShieldCooldownSeconds)
                            SetShieldBoxFill(Canvas, FillRatio)

                    if (AgentData.LastJumpHighTime + JumpHighCooldownSeconds > (CurrentTime-0.25)):
                        if (Canvas := AgentData.MaybeCanvas?):

                            FillRatio := 1.0 - ((CurrentTime - AgentData.LastJumpHighTime) / JumpHighCooldownSeconds)
                            SetJumpUpBoxFill(Canvas, FillRatio)

                    if (AgentData.LastJumpForwardTime + JumpForwardCooldownSeconds > (CurrentTime-0.25)):
                        if (Canvas := AgentData.MaybeCanvas?):

                            FillRatio := 1.0 - ((CurrentTime - AgentData.LastJumpForwardTime) / JumpForwardCooldownSeconds)
                            SetJumpForwardBoxFill(Canvas, FillRatio)

        SetShieldBoxFill(Canvas : canvas, Fill : float):void=
            SetSkillBoxFill(Canvas, Fill, 0)

        SetJumpUpBoxFill(Canvas : canvas, Fill : float):void=
            SetSkillBoxFill(Canvas, Fill, 1)

        SetJumpForwardBoxFill(Canvas : canvas, Fill : float):void=
            SetSkillBoxFill(Canvas, Fill, 2)

        SetSkillBoxFill(Canvas : canvas, Fill : float, SkillBoxIndex : int):void=

            ClampedFill := Clamp(Fill, 0.0, 1.0)
            if (SkillBoxCanvas := canvas[Canvas.Slots[SkillBoxIndex].Widget],
            SkillBoxTransparentFill := color_block[SkillBoxCanvas.Slots[1].Widget]):
                SkillBoxTransparentFill.SetDesiredSize(vector2{ X := SkillIconSize.X, Y := SkillIconSize.Y*ClampedFill })

        CreateCanvas():canvas=
            var CanvasSlots : []canvas_slot = array{}

            TopOffset := -32.0
            SideOffset := 128.0

            set CanvasSlots += array
            {
                CanvasSlot0 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.5, Y := 1.0 }, Maximum := vector2{ X := 0.5, Y := 1.0 } }
                    Offsets := margin{ Top := TopOffset, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.5, Y := 1.0 }
                    SizeToContent := true
                    ZOrder := 0
                    Widget := CreateSkillBoxCanvas(Textures.T_Shield)
            }

            set CanvasSlots += array
            {
                CanvasSlot1 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.5, Y := 1.0 }, Maximum := vector2{ X := 0.5, Y := 1.0 } }
                    Offsets := margin{ Top := TopOffset, Left := -SideOffset, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.5, Y := 1.0 }
                    SizeToContent := true
                    ZOrder := 0
                    Widget := CreateSkillBoxCanvas(Textures.T_JumpUp)
            }

            set CanvasSlots += array
            {
                CanvasSlot2 := canvas_slot:
                    Anchors := anchors{ Minimum := vector2{ X := 0.5, Y := 1.0 }, Maximum := vector2{ X := 0.5, Y := 1.0 } }
                    Offsets := margin{ Top := TopOffset, Left := SideOffset, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.5, Y := 1.0 }
                    SizeToContent := true
                    ZOrder := 0
                    Widget := CreateSkillBoxCanvas(Textures.T_JumpForward)
            }

            Canvas := canvas:
                Slots := CanvasSlots

            return Canvas

        CreateSkillBoxCanvas(SkillTexture : texture):canvas=
            var CanvasSlots : []canvas_slot = array{}

            Vector2One := vector2{ X := 0.5, Y := 1.0 }

            set CanvasSlots += array
            {
                CanvasSlot0 := canvas_slot:
                    Anchors := anchors{ Minimum := Vector2One, Maximum := Vector2One }
                    Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.5, Y := 1.0 }
                    SizeToContent := true
                    ZOrder := 0
                    Widget := texture_block{ DefaultImage := SkillTexture, DefaultDesiredSize := SkillIconSize }
            }

            set CanvasSlots += array
            {
                CanvasSlot1 := canvas_slot:
                    Anchors := anchors{ Minimum := Vector2One, Maximum := Vector2One }
                    Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                    Alignment := vector2{ X := 0.5, Y := 1.0 }
                    SizeToContent := true
                    ZOrder := 1
                    Widget := color_block{ DefaultColor := NamedColors.White, DefaultOpacity := 0.5,
                    DefaultDesiredSize := vector2{ X := SkillIconSize.X, Y := 0.0 } }
            }

            Canvas := canvas:
                Slots := CanvasSlots

            return Canvas