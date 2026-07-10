# Cage Trap Power
# A special ability that allows players to trap nearby enemies in a cage structure. When activated, it finds the nearest enemy player and teleports them into a cage prop, then grants the user a remote d
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/cage-power?ref=github


using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Game }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

cage_power := class(power_class):

    @editable
    TrapProp: creative_prop = creative_prop{}

    @editable
    RemoteItemGranter : item_granter_device = item_granter_device{}

    @editable
    ExplosiveDevice: explosive_device = explosive_device{}

    @editable
    PowerCooldownTimer : timer_device = timer_device{}

    @editable
    StinkGranter : item_granter_device = item_granter_device{}

    @editable
    CageTP : teleporter_device = teleporter_device{}

    @editable
    CageSFX : audio_player_device = audio_player_device{}

    @editable
    ABILITY_DURATION: float = 5.0

    var MaybeOriginalTransform: ?transform = false

    var BoxCenterPointMap: [comparable]transform = map{}


    InitializePower<override>(Player: player)<suspends>: void =
        if(FortChar := Player.GetFortCharacter[]):
            CooldownTimer.InitTimer() # called for each power that needs a cooldown
            Sleep(0.25)
            StinkGranter.GrantItem(Player)
            Sleep(0.0)
            RemoteItemGranter.GrantItem(Player)
            set MaybeOriginalTransform = option{TrapProp.GetTransform()}
            BuildBoxCenterPointMap(512.0)
            FortChar.Hide()
            Sleep(0.1)
            FortChar.Show()

    ActivatedRemote<override>(Agent : agent)<suspends>:void=
        if:
            Agent = GetAbilityPlayer[]
            IsPowerAvailable() = true
            FortChar := Agent.GetFortCharacter[]
        then:
            SetPowerAvailable(false)
            MaybeNearestPlayer := FindNearestPlayer()
            if:
                NearestPlayer := MaybeNearestPlayer?
                Location := FortChar.GetTransform()
                EnemyFortChar := NearestPlayer.GetFortCharacter[]
                EnemyLocation := EnemyFortChar.GetTransform()
                EnemyAgent := agent [NearestPlayer]
            then:
                if:
                    BoxCenterPoint := GetBoxCenterPoint[EnemyFortChar]
                    ExplosiveDevice.TeleportTo[BoxCenterPoint]
                    OriginalTransform := MaybeOriginalTransform?
                then:
                    ExplodeReset(Agent)
                    Sleep(0.25)
                    if (TrapProp.TeleportTo[BoxCenterPoint]):
                        CageSFX.Play()
                        CageTP.Teleport(EnemyAgent)
                        Sleep(ABILITY_DURATION)
                        if (TrapProp.TeleportTo[OriginalTransform]) {}
                        CooldownTimer.StartTimer(10, 0)
                        SetPowerAvailable(true)
                        
                        
    BuildBoxCenterPointMap<private>(Increment: float)<suspends>: void =
        for (R := -3..3, Row := R * Increment, RowInt := Floor[Row]):
            for(C := -3..3, Column := C * Increment, ColumnInt := Floor[Column]):
                if:
                    set BoxCenterPointMap[(RowInt, ColumnInt)] = transform:
                        Translation := vector3:
                            X := Row
                            Y := Column
                            Z := 0.0
                        Rotation := rotation{}
                        Scale := vector3:
                            X := 1.0
                            Y := 1.0
                            Z := 1.0

    GetBoxCenterPoint<private>(FortCharacter: fort_character)<transacts><decides>: transform =
        ArrayOfBoundaries: []float = array{1280.0, 768.0, 256.0, -256.0, -768.0, -1280.0}
        Translation := FortCharacter.GetTransform().Translation
        var MaybeReturn: ?transform = false
        var XCenterPoint: ?float = false
        var YCenterPoint: ?float = false
        for (Boundary : ArrayOfBoundaries):
            if (Translation.X > Boundary, not XCenterPoint?):
                set XCenterPoint = option{Boundary + 256.0}
            if (Translation.Y > Boundary, not YCenterPoint?):
                set YCenterPoint = option{Boundary + 256.0}
        if (not XCenterPoint?):
            set XCenterPoint = option{-1536.0}
        if (not YCenterPoint?):
            set YCenterPoint = option{-1536.0}
        if:
            XInt: int = Floor[XCenterPoint?]
            YInt: int = Floor[YCenterPoint?]
            Return := BoxCenterPointMap[(XInt, YInt)]
        then:
            set MaybeReturn = option{Return}
        MaybeReturn?


        
    ExplodeReset(Agent : agent)<suspends>:void=
        ExplosiveDevice.Explode(Agent)
        Sleep(0.1)
        ExplosiveDevice.Reset()


    PlayerEliminated<override>(EliminationResult : elimination_result):void=
        if:
            Player := GetAbilityPlayer[]
            FortChar := Player.GetFortCharacter[]
            FortChar = EliminationResult.EliminatedCharacter
        then:
            DeathAudio.Play(Player)
            ElimVFX.Disable()
