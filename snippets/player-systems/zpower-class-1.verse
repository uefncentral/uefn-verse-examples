# Player Power System
# This code creates a power/ability system that manages player special abilities with cooldowns, audio feedback, and HUD notifications. It tracks power availability states, handles ability activation th
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/zpower-class-1?ref=github


using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/Playspaces}
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

power_class := class<concrete>:

    # @editable
    # MyCarProp : creative_prop = creative_prop{}

    # @editable
    # CarRevButton : button_device = button_device{}

    # @editable
    # CarRevAudio : audio_player_device = audio_player_device{}

    @editable
    DeathAudio : audio_player_device = audio_player_device{}

    @editable
    ClassAndTeamSelector: class_and_team_selector_device = class_and_team_selector_device{}

    @editable
    HudMessageDevice: hud_message_device = hud_message_device{}

    @editable
    EndPowerTrigger : trigger_device = trigger_device{}

    @editable
    RunPowerTrigger : trigger_device = trigger_device{}

    @editable
    CooldownTimer : countdown_device = countdown_device{}

    @editable
    ElimVFX : vfx_spawner_device = vfx_spawner_device{}

    var AbilityPlayer: ?player = false

    var AllPlayers: []player = array{}

    var PowerAvailable : logic = false

    var PowerAvailable2 : logic = false

    var MaybeArenaSize : ?arena_size = false

    var PowerName : string = "Unknown"

    var DidRevEngine : logic = false

    GetAbilityPlayer()<transacts><decides>: player = AbilityPlayer?

    SetAbilityPlayer(InPlayer: player): void = set AbilityPlayer = option{InPlayer}

    IsPowerAvailable()<transacts>: logic = PowerAvailable

    IsPowerAvailable2()<transacts>: logic = PowerAvailable2

    SetPowerAvailable(Bool : logic): void = set PowerAvailable = Bool

    SetPowerAvailable2(Bool : logic): void = set PowerAvailable2 = Bool

    GetHudMessageDevice(): hud_message_device = Self.HudMessageDevice

    GetAllPlayers(): []player = AllPlayers

    SetAllPlayers(AllPlayersInput: []player): void = set AllPlayers = AllPlayersInput

    GetArena()<transacts><decides>: arena_size = MaybeArenaSize?

    #Init(Player: player, PlayerArray: []player, EmoteMutatorZone : mutator_zone_device, SignalRemoteManager : signal_remote_manager_device, RoundStartTimer : timer_device, InArenaSize : arena_size): hud_message_device =
    Init(Player: player, PlayerArray: []player, Playspace : fort_playspace, PowerOptions : power_options, InPowerName : string): hud_message_device =
        if:
            FortChar := Player.GetFortCharacter[]
        then:
            set PowerName = InPowerName
            Print("{PowerName}: Subscribing to events")
            FortChar.EliminatedEvent().Subscribe(PlayerEliminated)
            PowerOptions.EmoteMutatorZone.AgentBeginsEmotingEvent.Subscribe(AgentStartedEmoting)
            #EmoteMutatorZone.AgentEndsEmotingEvent.Subscribe(AgentStoppedEmoting)
            FortChar.DamagedShieldEvent().Subscribe(PlayerDamaged)
            FortChar.DamagedEvent().Subscribe(PlayerDamaged)
            #FortChar.CrouchedEvent().Subscribe(PlayerCrouched)
            #FortChar.SprintedEvent().Subscribe(PlayerSprinted)
            #FortChar.JumpedEvent().Subscribe(PlayerJumped)
            PowerOptions.SignalRemoteManager.PrimarySignalEvent.Subscribe(OnRemoteUsed)
            Playspace.PlayerRemovedEvent().Subscribe(PlayerLeftServer)
            #Playspace.PlayerAddedEvent().Subscribe(PlayerJoinedServer)
            Print("{PowerName}: Finished subscribing")
            for (EnemyPlayer : PlayerArray):
                if (EnemyFortChar := EnemyPlayer.GetFortCharacter[]):
                    EnemyFortChar.DamagedShieldEvent().Subscribe(PlayerDamaged)
                    EnemyFortChar.DamagedEvent().Subscribe(PlayerDamaged)
        set MaybeArenaSize = option{PowerOptions.ArenaSize}
        Print("{PowerName}: Setting ability player")
        SetAbilityPlayer(Player)
        Print("{PowerName}: Setting all players")
        SetAllPlayers(PlayerArray)
        Print("{PowerName}: Changing team")
        ClassAndTeamSelector.ChangeTeam(Player)
        Print("{PowerName}: Granting items")
        # spawn:
        #     RevCars(PowerOptions.RoundStartTimer)
        spawn:
            InitRound(Player, PowerOptions.RoundStartTimer)
        HudMessageDevice

    InitRound(Player : player, RoundStartTimer : timer_device)<suspends>:void=
        spawn:
            InitializePower(Player)
        RoundStartTimer.SuccessEvent.Await()
        SetPowerAvailable(true)
        Print("{PowerName}: Set Power Available")


    FindNearestPlayer(): ?player=
        var MaybeNearestPlayer : ?player = false
        var MaybeNearestDistance : ?float = false
        if:
            SelfAgent := AbilityPlayer?
            SelfFortChar := SelfAgent.GetFortCharacter[]
            SelfLocation := SelfFortChar.GetTransform()
            SelfPlayer := player[SelfAgent]
        then:
            for (Player : AllPlayers, FortChar := Player.GetFortCharacter[], FortChar.IsActive[]):
                Print("{PowerName}: Searching for nearest player")
                if (MaybeNearestPlayer = false, MaybeNearestDistance = false, Player <> SelfPlayer):
                    Print("{PowerName}: This is the first player")
                    MaybeNearestPlayerLocation := FortChar.GetTransform()
                    Print("{PowerName}: First player checked")
                    set MaybeNearestPlayer = option{Player}
                    set MaybeNearestDistance = option{Distance(SelfLocation.Translation, MaybeNearestPlayerLocation.Translation)}
                    Print("{PowerName}: Set nearest player")
                else if:
                    Player <> SelfPlayer
                    MaybeNearestPlayer?
                    MaybeNearestDistance?
                    CharacterTransform := FortChar.GetTransform()
                    DistanceBetweenNewChar := Distance(SelfLocation.Translation, CharacterTransform.Translation)
                    DistanceBetweenNewChar < MaybeNearestDistance?
                then:
                    Print("{PowerName}: Updating next player")
                    set MaybeNearestPlayer = option{Player}
                    set MaybeNearestDistance = option{DistanceBetweenNewChar}

        MaybeNearestPlayer

    # Don't override these functions:

    PlayerDamaged(DamageResult : damage_result):void=
        #Print("{PowerName}: Player damaged?")
        if:
            Instigator := DamageResult.Instigator?
            AgentDoingDamage := Instigator.GetInstigatorAgent[]
            FortCharReceivingDamage := fort_character[DamageResult.Target]
            AgentReceivingDamage := FortCharReceivingDamage.GetAgent[]
            Amount := DamageResult.Amount
            Source := DamageResult.Source
        then:
            #Print("{PowerName}: Player damaged another player by {Amount}")
            if (AgentDoingDamage = GetAbilityPlayer[] and AgentDoingDamage <> AgentReceivingDamage):
                spawn:
                    DamagedPlayer(AgentDoingDamage, AgentReceivingDamage, Amount, Source)
            else if(AgentReceivingDamage = GetAbilityPlayer[] and AgentDoingDamage <> AgentReceivingDamage):
                spawn:
                    ReceivedDamage(AgentDoingDamage, AgentReceivingDamage, Amount, Source)

    OnRemoteUsed(Agent : agent):void=
        spawn:
            ActivatedRemote(Agent)

    PlayerLeftServer(Player : player):void=
        if (Player = GetAbilityPlayer[]):
            EndPowerTrigger.Trigger(Player)

    PlayerEliminated(EliminationResult : elimination_result):void=
        if:
            Player := GetAbilityPlayer[]
            FortChar := Player.GetFortCharacter[]
            FortChar = EliminationResult.EliminatedCharacter
        then:
            Print("Player Eliminated")
            EndPowerTrigger.Trigger(Player)

    AgentStartedEmoting(Agent : agent):void=
        Print("{PowerName}: Player started emoting")
        block:

    AgentStoppedEmoting(Agent : agent):void=
        block:

    GetPlayerViewRotation():?rotation=
        var Rotation : ?rotation = false
        if:
            Player := AbilityPlayer?
            FortCharacter := Player.GetFortCharacter[]
        then:
            set Rotation = option{FortCharacter.GetViewRotation()}
        Rotation

    GetPlayerViewLocation():?vector3=
        var Vector : ?vector3 = false
        if:
            Player := AbilityPlayer?
            FortCharacter := Player.GetFortCharacter[]
        then:
            set Vector = option{FortCharacter.GetViewLocation()}
        Vector

    MovePropToSelf(CreativeProp : creative_prop):void=
        if:
            Agent := AbilityPlayer?
            FortChar := Agent.GetFortCharacter[]
            CurrentTransform := FortChar.GetTransform()
            CreativeProp.TeleportTo[CurrentTransform]
            
    MoveAudioToPlayer(EliminatedAudio : audio_player_device, Agent : agent):void=
        if:
            FortChar := Agent.GetFortCharacter[]
            CurrentTransform := FortChar.GetTransform()
            EliminatedAudio.TeleportTo[CurrentTransform]

    MovePropToSelfTurnBackwards(CreativeProp : creative_prop):void=
        if:
            Agent := AbilityPlayer?
            FortChar := Agent.GetFortCharacter[]
            CurrentTransform := FortChar.GetTransform()
            NewRotation := CurrentTransform.Rotation.ApplyYaw(3.14)
            NewTransform := transform{
                Translation := CurrentTransform.Translation,
                Rotation := NewRotation,
                Scale := CurrentTransform.Scale
            }
            CreativeProp.TeleportTo[NewTransform]

    MovePropToDestination(CreativeProp : creative_prop, CurrentRotation : int, MaxRotations: int, Yaw : float, MoveFactor : float, MoveTime : float, Direction : vector3)<suspends>:void=
        Transform := CreativeProp.GetTransform()
        Translation := Transform.Translation
        PropRotation := Transform.Rotation
        PropScale := Transform.Scale
        NewRotation := PropRotation.ApplyYaw(Yaw)

        if:
            Agent := AbilityPlayer?
            FortChar := Agent.GetFortCharacter[]
            #Direction := FortChar.GetTransform().Rotation.GetLocalForward()
            NewTransform := transform{
                Translation := vector3{
                    X := Translation.X + (Direction.X * MoveFactor),
                    Y := Translation.Y + (Direction.Y * MoveFactor),
                    Z := Translation.Z + (Direction.Z * MoveFactor)
                },
                Rotation := NewRotation,
                Scale := PropScale
            }
        then:
            MoveResult := CreativeProp.MoveTo(NewTransform, MoveTime)
            if (MoveResult = move_to_result.DestinationReached and CurrentRotation < MaxRotations):
                MovePropToDestination(CreativeProp, CurrentRotation+1, MaxRotations, Yaw, MoveFactor, MoveTime, Direction)
            else if (CurrentRotation >= MaxRotations):
                OutOfArenaTransform := transform{
                    Translation := vector3{X := 0.0, Y := 0.0, Z := 1000.0},
                    Rotation := NewRotation,
                    Scale := PropScale
                }
                CreativeProp.MoveTo(OutOfArenaTransform, 0.1)
    

    # Override these functions:

    InitializePower(Player: player)<suspends>: void = Sleep(0.0)


    DamagedPlayer(AgentDoingDamage : agent, AgentReceivingDamage : agent, Amount : float, Source : ?game_action_causer)<suspends>:void=
        block:

    ReceivedDamage(AgentDoingDamage : agent, AgentReceivingDamage : agent, Amount : float, Source : ?game_action_causer)<suspends>:void=
        block:

    ActivatedRemote(Agent : agent)<suspends>:void=
        block:

    PlayerCrouched(Tuple : tuple(fort_character, logic)):void=
        block:

    PlayerSprinted(Tuple : tuple(fort_character, logic)):void=
        block:

    PlayerJumped(FortCharacter : fort_character):void=
        block:

    SpawnFX(PropAsset : creative_prop_asset, Transform : transform)<suspends>:void=
        Print("{PowerName}: SpawnFX")
        if (SpawnedProp := SpawnProp(PropAsset, Transform)(0)?):
            EndPowerTrigger.TriggeredEvent.Await()
            # SpawnedProp.Dispose()  # TODO: Verse has no manual disposal

    FollowFX(VFXSpawner : vfx_spawner_device, Agent : agent, TimeBetweenUpdates : float)<suspends>:void=
        Print("{PowerName}: FollowFX")
        race:
            block:
                var first_run : logic = true
                loop:
                    if:
                        FortChar := Agent.GetFortCharacter[]
                        Transform := FortChar.GetTransform()
                        VFXSpawner.TeleportTo[Transform]
                    then:
                        if (first_run = true):
                            VFXSpawner.Enable()
                            set first_run = false
                    Sleep(TimeBetweenUpdates)
            EndPowerTrigger.TriggeredEvent.Await()
        VFXSpawner.Disable()

    FollowFX1(VFXSpawner : vfx_spawner_device, Agent : agent, TimeBetweenUpdates : float)<suspends>:void=
        Print("{PowerName}: FollowFX")
        race:
            block:
                var first_run : logic = true
                loop:
                    if:
                        FortChar := Agent.GetFortCharacter[]
                        Transform := FortChar.GetTransform()
                        VFXSpawner.TeleportTo[Transform]
                    then:
                        if (first_run = true):
                            # VFXSpawner.Enable()
                            set first_run = false
                    Sleep(TimeBetweenUpdates)
            EndPowerTrigger.TriggeredEvent.Await()
        # VFXSpawner.Disable()

    FollowProp(Prop : creative_prop, Agent : agent, TimeBetweenUpdates : float)<suspends>:void=
        Print("{PowerName}: FollowFX")
        race:
            block:
                var first_run : logic = true
                loop:
                    if:
                        FortChar := Agent.GetFortCharacter[]
                        Transform := FortChar.GetTransform()
                        Prop.TeleportTo[Transform]
                    then:
                        if (first_run = true):
                            set first_run = false
                    Sleep(TimeBetweenUpdates)
            EndPowerTrigger.TriggeredEvent.Await()

    TriggerPower():void=
        Print("{PowerName}: Triggering power trigger")
        if (Player := AbilityPlayer?):
            RunPowerTrigger.Trigger(Player)
        Print("{PowerName}: Triggered power trigger")

    





