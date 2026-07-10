# Throwable Explosive Power
# Creates a throwable explosive ability that players can activate with a remote item. When used, it plays audio effects, moves an explosive volume to the player's location, and damages other players cau
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/throwable-power?ref=github


using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Game }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }


throwable_power := class<concrete>(power_class):

    @editable
    ExplosiveDevices: []explosive_device = array{}

    @editable
    ThrowableLoop : audio_player_device = audio_player_device{}

    @editable
    ThrowableCooldownTimer : timer_device = timer_device{}

    @editable
    RemoteItemGranter : item_granter_device = item_granter_device{}

    @editable
    ThrowableProp : creative_prop = creative_prop{}

    @editable
    ThrowableVolume : volume_device = volume_device{}


    DamageAmount : float = 80.0

    var CanDamagePlayers : logic = false

    InitializePower<override>(Player: player)<suspends>: void =
        if(FortChar := Player.GetFortCharacter[]):
            CooldownTimer.InitTimer() # called for each power that needs a cooldown
            FortChar.Hide()
            Sleep(0.1)
            FortChar.Show()
            TriggerPower()
            Sleep(0.0)
            Print("ThrowablePower: Granting remote to throwable team")
            RemoteItemGranter.GrantItem(Player)


    ActivatedRemote<override>(Agent : agent)<suspends>:void=
        if:
            Agent = GetAbilityPlayer[]
            IsPowerAvailable() = true
            FortChar := Agent.GetFortCharacter[]
            Player := player[Agent]
            Direction := FortChar.GetTransform().Rotation.GetLocalForward()
        then:
            Print("ThrowablePower: Going to start power")
            SetPowerAvailable(false)
            ThrowableLoop.Play()
            # Trigger power - subscribe to volume to see who is in the volume, that is who we will damage
            ThrowableVolume.AgentEntersEvent.Subscribe(AgentEnteredVolume)
            # Move the volume to our current location
            set CanDamagePlayers = true
            Sleep(0.0)
            Print("ThrowablePower: Subscribed to volume entered, moving prop to our location")
            MovePropToSelfTurnBackwards(ThrowableProp)
            # Now move it in the direction we triggered
            Print("ThrowablePower: Now moving it in the direction we are facing")
            ThrowableProp.Show()
            #MovePropToDestination(CreativeProp : ThrowableProp, CurrentRotation : 2, MaxRotations: 15, Yaw : 0.0, MoveFactor : 500, MoveTime : .8, Direction : vector3)
            race:
                MovePropToDestination(ThrowableProp, 1, 11, 2.0, 600.0, 0.3, Direction)
                EndPowerTrigger.TriggeredEvent.Await()
                ActivateDamageAround(Agent)
            ThrowableLoop.Stop()
            # NormalClass.ChangeClass(Agent)
            Print("pre timer success")
            Print("ThrowablePower: Done moving prop, going to start cooldown")
            set CanDamagePlayers = false
            # Start cooldown timer
            CooldownTimer.StartTimer(10, 0)
            Print("ThrowablePower: Cooldown timer over")
            SetPowerAvailable(true)
            Print("ThrowablePower: Power is ready")
            Sleep(10.0)

    AgentEnteredVolume(AgentToDamage : agent):void=
        if:
            CanDamagePlayers = true
            AbilityAgent := GetAbilityPlayer[]
            AgentToDamage <> AbilityAgent
            FortChar := AbilityAgent.GetFortCharacter[]
            FortCharToDamage := AgentToDamage.GetFortCharacter[]
        then:
            Print("ThrowablePower: Got agent that entered volume")
            DamageArgs := damage_args{Instigator := option{game_action_instigator[FortChar]}, Source := false, Amount := DamageAmount}
            FortCharToDamage.Damage(DamageArgs)
            Print("ThrowablePower: Damaged player by {DamageAmount}")

    TestSound()<suspends>:void=
        Transform := ThrowableProp.GetTransform()
        Translation := Transform.Translation
        PropRotation := Transform.Rotation
        PropScale := Transform.Scale
        OutOfArenaTransform := transform{
            Translation := vector3:
                X := 0.0
                Y := 0.0
                Z := 1000.0
            Rotation := rotation{}
            Scale := PropScale
        }
        ThrowableProp.MoveTo(OutOfArenaTransform, 0.1)


    ActivateDamageAround(Agent : agent)<suspends>: void=
        var TNTIndex : int = 0
        loop:
            Sleep(0.05)
            if:
                FortChar := Agent.GetFortCharacter[]
                TNTDevice := ExplosiveDevices[TNTIndex]
            then:
                TNTDevice.Explode(Agent)
                TNTDevice.Reset()
                if (TNTIndex = ExplosiveDevices.Length -1):
                    Print("Resetting to first TNT device")
                    set TNTIndex = 0
                else:
                    Print("DamageAround: Next TNT device")
                    set TNTIndex += 1

                    
    
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
