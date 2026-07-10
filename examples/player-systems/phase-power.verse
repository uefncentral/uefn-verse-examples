# Phase Teleport Power
# A player ability system that allows teleporting forward a fixed distance (256 units) in the direction the player is facing. The power includes cooldown management, item requirements, boundary validati
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/phase-power?ref=github

using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Game }


phase_power := class<concrete>(power_class):

    @editable
    ArrowVFX : vfx_spawner_device = vfx_spawner_device{}

    @editable
    HoldingItemCheck : conditional_button_device = conditional_button_device{}

    @editable
    PhaseCooldownTimer : timer_device = timer_device{}

    @editable
    RemoteItemGranter : item_granter_device = item_granter_device{}

    @editable
    Teleporter : teleporter_device = teleporter_device{}

    AMOUNT_TO_PHASE : float = 256.0

    InitializePower<override>(Player: player)<suspends>: void =
        if(FortChar := Player.GetFortCharacter[]):
            CooldownTimer.InitTimer() # called for each power that needs a cooldown
            RemoteItemGranter.GrantItem(Player)
            FortChar.Hide()
            Sleep(0.1)
            FortChar.Show()


    ActivatedRemote<override>(Agent : agent)<suspends>:void=
        if:
            Agent = GetAbilityPlayer[]
            IsPowerAvailable() = true
            FortChar := Agent.GetFortCharacter[]
            Transform := FortChar.GetTransform()
            Yaw := Transform.Rotation.GetYawPitchRollDegrees()[0]
            Translation := Transform.Translation
            Arena := GetArena[]
        then:
            Print("Phase: Going to make player phase")
            SetPowerAvailable(false)
            NewTranslation := GetNewTranslationNew(Transform, Yaw, AMOUNT_TO_PHASE)
            ValidLocation :=Arena.WithinArenaBounds(NewTranslation)
            if (ValidLocation = true):
                Print("Phase: Valid location, going to move player")
                if (Teleporter.TeleportTo[NewTranslation, Transform.Rotation]):
                    Print("Phase: Teleported rift")
                    Teleporter.Teleport(Agent)
                    Print("Phase: Moved user successfully, starting cooldown")
                    # Start cooldown timer
                    CooldownTimer.StartTimer(10, 0)
                    Print("Phase: Cooldown timer over")
                    SetPowerAvailable(true)
                    Print("Phase: Power is ready")
                else:
                    Print("Phase: Failed to move user")
            else:
                Print("New location isn't valid, try again")
                SetPowerAvailable(true)
        else:
            if (Agent = GetAbilityPlayer[]):
                Print("Phase: 1")
            if (IsPowerAvailable() = true):
                Print("Phase: 2")
            if (FortChar := Agent.GetFortCharacter[]):
                Print("Phase: 3")
            if (Arena := GetArena[]):
                Print("Phase: 7")


    FollowPhaseFX(TimeBetweenUpdates : float)<suspends>:void=
        Print("{PowerName}: FollowFX")
        race:
            block:
                loop:
                    if:
                        Agent := GetAbilityPlayer[]
                        IsPowerAvailable() = true
                        HoldingItemCheck.IsHoldingItem[Agent]
                    then:
                        if:
                            FortChar := Agent.GetFortCharacter[]
                            Transform := FortChar.GetTransform()
                            Yaw := Transform.Rotation.GetYawPitchRollDegrees()[0]
                        then:
                            NewTranslation := GetNewTranslationNew(Transform, Yaw, AMOUNT_TO_PHASE)
                            if (ArrowVFX.TeleportTo[NewTranslation, Transform.Rotation]) {
                                ArrowVFX.Enable()
                            }
                            else {Print("Failed to teleport arrow")}
                    else:
                        ArrowVFX.Disable()
                    Sleep(TimeBetweenUpdates)
            EndPowerTrigger.TriggeredEvent.Await()
        ArrowVFX.Disable()



    GetNewTranslationNew(Transform : transform, Yaw : float, MovementDistance : float):vector3=
        # Quadrant 1 
        if (Yaw >=0.0 and Yaw < 45.0):
            Print("Quadrant 1")
            RotationAngle := (Yaw * Pi / 180.0)
            NewXLocation := Transform.Translation.X + (MovementDistance * Cos(RotationAngle))
            NewYLocation := Transform.Translation.Y + (MovementDistance * Sin(RotationAngle))
            Print("Changing X from {Transform.Translation.X} to {NewXLocation}")
            Print("Changing Y from {Transform.Translation.Y} to {NewYLocation}")
            vector3{X := NewXLocation, Y := NewYLocation, Z := Transform.Translation.Z}
        # Quadrant 2 
        else if (Yaw >=45.0 and Yaw < 90.0):
            Print("Quadrant 2")
            RotationAngle := (90.0 - Yaw * Pi / 180.0)
            NewXLocation := Transform.Translation.X + (MovementDistance * Sin(RotationAngle))
            NewYLocation := Transform.Translation.Y + (MovementDistance * Cos(RotationAngle))
            Print("Changing X from {Transform.Translation.X} to {NewXLocation}")
            Print("Changing Y from {Transform.Translation.Y} to {NewYLocation}")
            vector3{X := NewXLocation, Y := NewYLocation, Z := Transform.Translation.Z}
        # Quadrant 3 
        else if (Yaw >=90.0 and Yaw < 135.0):
            Print("Quadrant 3")
            RotationAngle := (Yaw - 90.0 * Pi / 180.0)
            NewXLocation := Transform.Translation.X - (MovementDistance * Sin(RotationAngle))
            NewYLocation := Transform.Translation.Y + (MovementDistance * Cos(RotationAngle))
            Print("Changing X from {Transform.Translation.X} to {NewXLocation}")
            Print("Changing Y from {Transform.Translation.Y} to {NewYLocation}")
            vector3{X := NewXLocation, Y := NewYLocation, Z := Transform.Translation.Z}
        # Quadrant 4 
        else if (Yaw >=135.0):
            Print("Quadrant 4")
            RotationAngle := (180.0 - Yaw * Pi / 180.0)
            NewXLocation := Transform.Translation.X - (MovementDistance * Cos(RotationAngle))
            NewYLocation := Transform.Translation.Y + (MovementDistance * Sin(RotationAngle))
            Print("Changing X from {Transform.Translation.X} to {NewXLocation}")
            Print("Changing Y from {Transform.Translation.Y} to {NewYLocation}")
            vector3{X := NewXLocation, Y := NewYLocation, Z := Transform.Translation.Z}
        # Quadrant 5 
        else if (Yaw <= -135.0):
            Print("Quadrant 5")
            RotationAngle := (Yaw - 180.0 * Pi / 180.0)
            NewXLocation := Transform.Translation.X - (MovementDistance * Cos(RotationAngle))
            NewYLocation := Transform.Translation.Y - (MovementDistance * Sin(RotationAngle))
            Print("Changing X from {Transform.Translation.X} to {NewXLocation}")
            Print("Changing Y from {Transform.Translation.Y} to {NewYLocation}")
            vector3{X := NewXLocation, Y := NewYLocation, Z := Transform.Translation.Z}
        # Quadrant 6 
        else if (Yaw <= -90.0):
            Print("Quadrant 6")
            RotationAngle := (-90.0 - Yaw * Pi / 180.0)
            NewXLocation := Transform.Translation.X - (MovementDistance * Sin(RotationAngle))
            NewYLocation := Transform.Translation.Y - (MovementDistance * Cos(RotationAngle))
            Print("Rotation angle: {RotationAngle}")
            Print("Changing X from {Transform.Translation.X} to {NewXLocation}")
            Print("Changing Y from {Transform.Translation.Y} to {NewYLocation}")
            vector3{X := NewXLocation, Y := NewYLocation, Z := Transform.Translation.Z}
        # Quadrant 7 
        else if (Yaw <= -45.0):
            Print("Quadrant 7")
            RotationAngle := (Yaw - -90.0 * Pi / 180.0)
            NewXLocation := Transform.Translation.X + (MovementDistance * Sin(RotationAngle))
            NewYLocation := Transform.Translation.Y - (MovementDistance * Cos(RotationAngle))
            Print("RotationAngle: {RotationAngle}")
            Print("Changing X from {Transform.Translation.X} to {NewXLocation}")
            Print("Changing Y from {Transform.Translation.Y} to {NewYLocation}")
            vector3{X := NewXLocation, Y := NewYLocation, Z := Transform.Translation.Z}
        else:
            Print("Quadrant 8")
            RotationAngle := (0.0 - Yaw * Pi / 180.0)
            NewXLocation := Transform.Translation.X + (MovementDistance * Cos(RotationAngle))
            NewYLocation := Transform.Translation.Y - (MovementDistance * Sin(RotationAngle))
            Print("Changing X from {Transform.Translation.X} to {NewXLocation}")
            Print("Changing Y from {Transform.Translation.Y} to {NewYLocation}")
            vector3{X := NewXLocation, Y := NewYLocation, Z := Transform.Translation.Z}


    
    PlayerEliminated<override>(EliminationResult : elimination_result):void=
        if:
            Player := GetAbilityPlayer[]
            FortChar := Player.GetFortCharacter[]
            FortChar = EliminationResult.EliminatedCharacter
        then:
            DeathAudio.Play(Player)
            spawn:
                EliminationVFX()



    EliminationVFX()<suspends>:void=
        ElimVFX.Enable()
        Sleep(2.0)
        ElimVFX.Disable()

