# Teleport Behind Power
# Creates a special ability that allows players to teleport directly behind the nearest enemy player. When activated, the power finds the closest opponent and teleports the user to that enemy's location
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/tp-behind-power?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/Teams }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices/CreativeAnimation }
using { /Fortnite.com/Devices/CreativeAnimation/InterpolationTypes }
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Game }


tp_behind_power := class<concrete>(power_class):

    @editable
    RemoteItemGranter : item_granter_device = item_granter_device{}

    @editable
    MyTeleporter : teleporter_device = teleporter_device{}


    @editable
    AudioPlayer : audio_player_device = audio_player_device{}


    InitializePower<override>(Player: player)<suspends>: void =
        if(FortChar := Player.GetFortCharacter[]):
            CooldownTimer.InitTimer() # called for each power that needs a cooldown
            Sleep(0.1)
            FortChar.Hide()
            Sleep(0.1)
            FortChar.Show()
        RemoteItemGranter.GrantItem(Player)

    ActivatedRemote<override>(Agent : agent)<suspends>:void=
        if:
            Agent = GetAbilityPlayer[]
            IsPowerAvailable() = true
            FortChar := Agent.GetFortCharacter[]
        then:
            SetPowerAvailable(false)
            # Trigger power
            MaybeNearestPlayer := FindNearestPlayer()
            Print("SwapPower : after FindNearestPlayer")
            if:
                NearestPlayer := MaybeNearestPlayer?
                Location := FortChar.GetTransform()
                EnemyFortChar := NearestPlayer.GetFortCharacter[]
                EnemyLocation := EnemyFortChar.GetTransform().Translation
                EnemyAgent := agent [NearestPlayer]
                MyTeleporter.TeleportTo[EnemyFortChar.GetTransform()]
            then:
                AudioPlayer.Play()
                MyTeleporter.Teleport(Agent)
                Print("TESTING1")
                CooldownTimer.StartTimer(10, 0)
                Print("SwapPower: Cooldown timer over")
                SetPowerAvailable(true)
                Print("SwapPower: Power is ready")


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



            
    LookAt(LookPos : vector3, Origin : vector3)<decides><transacts> : rotation=
        var NewRotation : rotation = rotation{}

        if (LookDirection := (LookPos - Origin).MakeUnitVector[]):
            Yaw := (ArcTan(LookDirection.Y, LookDirection.X * 180.0 / Pi))
            Pitch := 0.0
            Roll := 0.0
            
            set NewRotation = MakeRotationFromYawPitchRollDegrees(Yaw, Pitch, Roll)
        
        NewRotation


        