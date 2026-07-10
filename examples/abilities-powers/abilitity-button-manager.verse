# Abilitity Button Manager
# Verse code for Abilitity Button Manager - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/abilitity-button-manager?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }


Power := class<concrete>():
    @editable SelectNumber : int = 0
    SPECIFICNUMBER : int = 0

AbilitityButtonManager := class(creative_device):
    @editable GameStartDevice : GameStart = GameStart{}
    @editable AimBotDevice : AimBot = AimBot{}
    @editable ExchangeHealthForSpeedAndStrengthDevice : ExchangeHealthForSpeedAndStrength = ExchangeHealthForSpeedAndStrength{}
    @editable ExplodeBuildsAOEDevice : ExplodeBuildsAOE = ExplodeBuildsAOE{}
    @editable FloodWithWaterDevice : FloodWithWater = FloodWithWater{}
    @editable FreezeClosestPlayerDevice : FreezeClosestPlayer = FreezeClosestPlayer{}
    @editable SeparateArenaButtonDevice : SeparateArenaButton = SeparateArenaButton{}
    @editable ShootBallDevice : ShootBall = ShootBall{}
    @editable SlowMotionDevice : SlowMotion = SlowMotion{}
    @editable SpawnClonesDevice : SpawnClones = SpawnClones{}
    @editable SwitchPositionsWithClosestDevice : SwitchPositionsWithClosest = SwitchPositionsWithClosest{}
    @editable TeleportBehindRandomDevice : TeleportBehindRandom = TeleportBehindRandom{}
    @editable TurnInvincibleDevice : TurnInvincible = TurnInvincible{}
    @editable TeleportInFrontDevice : TeleportInFront = TeleportInFront{}
    @editable TravelBackInTimeDevice : TravelBackInTime = TravelBackInTime{}
    @editable CustomVehicleDevice : CustomVehicle = CustomVehicle{}
    @editable ChangeRoomDevice : ChangeRoom = ChangeRoom{}
    @editable TempApparelOrCharacterDevice : TempApparelOrCharacter = TempApparelOrCharacter{}
    @editable PropBeamDevice : PropBeam = PropBeam{}
    @editable ExplodeAllBuildsDevice : ExplodeAllBuilds = ExplodeAllBuilds{}
    @editable SummonCageDevice : SummonCage = SummonCage{}
    @editable SpawnVFXDamageDevice : SpawnVFXDamage = SpawnVFXDamage{}
    @editable EnterHiddenAreaDevice : EnterHiddenArea = EnterHiddenArea{}
    @editable JumpScareDevice : JumpScare = JumpScare{}
    @editable SpawnNPCsDevice : SpawnNPCs = SpawnNPCs{}


    var Powers : []Power = array{}
    @editable AimBotPower : Power = Power{SPECIFICNUMBER := 1}
    @editable ExchangeHealthForSpeedAndStrengthPower : Power = Power{SPECIFICNUMBER := 2}
    @editable ExplodeBuildsAOEPower : Power = Power{SPECIFICNUMBER := 3}
    @editable FloodWithWaterPower : Power = Power{SPECIFICNUMBER := 4}
    @editable FreezeClosestPlayerPower : Power = Power{SPECIFICNUMBER := 5}
    @editable SeparateArenaButtonPower : Power = Power{SPECIFICNUMBER := 6}
    @editable ShootBallPower : Power = Power{SPECIFICNUMBER := 7}
    @editable SlowMotionPower : Power = Power{SPECIFICNUMBER := 8}
    @editable SpawnClonesPower : Power = Power{SPECIFICNUMBER := 9}
    @editable SwitchPositionsWithClosestPower : Power = Power{SPECIFICNUMBER := 10}
    @editable TeleportBehindRandomPower : Power = Power{SPECIFICNUMBER := 11}
    @editable TurnInvinciblePower : Power = Power{SPECIFICNUMBER := 12}
    @editable TeleportInFrontPower : Power = Power{SPECIFICNUMBER := 13}
    @editable TravelBackInTimePower : Power = Power{SPECIFICNUMBER := 14}
    @editable CustomVehiclePower : Power = Power{SPECIFICNUMBER := 15}
    @editable ChangeRoomPower : Power = Power{SPECIFICNUMBER := 16}
    @editable TempApparelOrCharacterPower : Power = Power{SPECIFICNUMBER := 17}
    @editable PropBeamPower : Power = Power{SPECIFICNUMBER := 18}
    @editable ExplodeAllBuildsPower : Power = Power{SPECIFICNUMBER := 19}
    @editable SummonCagePower : Power = Power{SPECIFICNUMBER := 20}
    @editable SpawnVFXDamagePower : Power  = Power{SPECIFICNUMBER := 21}
    @editable EnterHiddenAreaPower : Power  = Power{SPECIFICNUMBER := 22}
    @editable JumpScarePower : Power = Power{SPECIFICNUMBER := 23}
    @editable SpawnNPCsPower : Power = Power{SPECIFICNUMBER := 24}
    



    #A singular remote manager device with 16 triggers each set to only activate for each specific class
    @editable RemoteMan : signal_remote_manager_device = signal_remote_manager_device{}
    @editable TrigClass1 : trigger_device = trigger_device{}
    @editable TrigClass2 : trigger_device = trigger_device{}
    @editable TrigClass3 : trigger_device = trigger_device{}
    @editable TrigClass4 : trigger_device = trigger_device{}
    @editable TrigClass5 : trigger_device = trigger_device{}
    @editable TrigClass6 : trigger_device = trigger_device{}
    @editable TrigClass7 : trigger_device = trigger_device{}
    @editable TrigClass8 : trigger_device = trigger_device{}
    @editable TrigClass9 : trigger_device = trigger_device{}
    @editable TrigClass10 : trigger_device = trigger_device{}
    @editable TrigClass11 : trigger_device = trigger_device{}
    @editable TrigClass12 : trigger_device = trigger_device{}
    @editable TrigClass13 : trigger_device = trigger_device{}
    @editable TrigClass14 : trigger_device = trigger_device{}
    @editable TrigClass15 : trigger_device = trigger_device{}
    @editable TrigClass16 : trigger_device = trigger_device{}

    
    OnBegin<override>()<suspends>:void=
        AddAllPowers()
        # if(GameStartDevice.GameIsStarted = true):
            RemoteMan.PrimarySignalEvent.Subscribe(Start)
            RemoteMan.SecondarySignalEvent.Subscribe(Start)
    Start(Agent:agent) : void=
        Print("Pressed")
        TrigClass1.Trigger(Agent)
        TrigClass2.Trigger(Agent)
        TrigClass3.Trigger(Agent)
        TrigClass4.Trigger(Agent)
        TrigClass5.Trigger(Agent)
        TrigClass6.Trigger(Agent)
        TrigClass7.Trigger(Agent)
        TrigClass8.Trigger(Agent)
        TrigClass9.Trigger(Agent)
        TrigClass10.Trigger(Agent)
        TrigClass11.Trigger(Agent)
        TrigClass12.Trigger(Agent)
        TrigClass13.Trigger(Agent)
        TrigClass14.Trigger(Agent)
        TrigClass15.Trigger(Agent)
        TrigClass16.Trigger(Agent)


        TrigClass1.TriggeredEvent.Subscribe(IsClass1)
        TrigClass2.TriggeredEvent.Subscribe(IsClass2)
        TrigClass3.TriggeredEvent.Subscribe(IsClass3)
        TrigClass4.TriggeredEvent.Subscribe(IsClass4)
        TrigClass5.TriggeredEvent.Subscribe(IsClass5)
        TrigClass6.TriggeredEvent.Subscribe(IsClass6)
        TrigClass7.TriggeredEvent.Subscribe(IsClass7)
        TrigClass8.TriggeredEvent.Subscribe(IsClass8)
        TrigClass9.TriggeredEvent.Subscribe(IsClass9)
        TrigClass10.TriggeredEvent.Subscribe(IsClass10)
        TrigClass11.TriggeredEvent.Subscribe(IsClass11)
        TrigClass12.TriggeredEvent.Subscribe(IsClass12)
        TrigClass13.TriggeredEvent.Subscribe(IsClass13)
        TrigClass14.TriggeredEvent.Subscribe(IsClass14)
        TrigClass15.TriggeredEvent.Subscribe(IsClass15)
        TrigClass16.TriggeredEvent.Subscribe(IsClass16)

    IsClass1(Agent:?agent) : void=
        if(NewAgent := Agent?):
            for(POW : Powers):
                if(POW.SelectNumber = 1):
                    POWERTOPLAYER(POW.SPECIFICNUMBER , NewAgent)
    IsClass2(Agent:?agent) : void=
        if(NewAgent := Agent?):
            for(POW : Powers):
                if(POW.SelectNumber = 2):
                    POWERTOPLAYER(POW.SPECIFICNUMBER , NewAgent)
    IsClass3(Agent:?agent) : void=
        if(NewAgent := Agent?):
            for(POW : Powers):
                if(POW.SelectNumber = 3):
                    POWERTOPLAYER(POW.SPECIFICNUMBER , NewAgent)
    IsClass4(Agent:?agent) : void=
        if(NewAgent := Agent?):
            for(POW : Powers):
                if(POW.SelectNumber = 4):
                    POWERTOPLAYER(POW.SPECIFICNUMBER , NewAgent)
    IsClass5(Agent:?agent) : void=
        if(NewAgent := Agent?):
            for(POW : Powers):
                if(POW.SelectNumber = 5):
                    POWERTOPLAYER(POW.SPECIFICNUMBER , NewAgent)
    IsClass6(Agent:?agent) : void=
        if(NewAgent := Agent?):
            for(POW : Powers):
                if(POW.SelectNumber = 6):
                    POWERTOPLAYER(POW.SPECIFICNUMBER , NewAgent)
    IsClass7(Agent:?agent) : void=
        if(NewAgent := Agent?):
            for(POW : Powers):
                if(POW.SelectNumber = 7):
                    POWERTOPLAYER(POW.SPECIFICNUMBER , NewAgent)
    IsClass8(Agent:?agent) : void=
        if(NewAgent := Agent?):
            for(POW : Powers):
                if(POW.SelectNumber = 8):
                    POWERTOPLAYER(POW.SPECIFICNUMBER , NewAgent)
    IsClass9(Agent:?agent) : void=
        if(NewAgent := Agent?):
            for(POW : Powers):
                if(POW.SelectNumber = 9):
                    POWERTOPLAYER(POW.SPECIFICNUMBER , NewAgent)
    IsClass10(Agent:?agent) : void=
        if(NewAgent := Agent?):
            for(POW : Powers):
                if(POW.SelectNumber = 10):
                    POWERTOPLAYER(POW.SPECIFICNUMBER , NewAgent)
    IsClass11(Agent:?agent) : void=
        if(NewAgent := Agent?):
            for(POW : Powers):
                if(POW.SelectNumber = 11):
                    POWERTOPLAYER(POW.SPECIFICNUMBER , NewAgent)
    IsClass12(Agent:?agent) : void=
        if(NewAgent := Agent?):
            for(POW : Powers):
                if(POW.SelectNumber = 12):
                    POWERTOPLAYER(POW.SPECIFICNUMBER , NewAgent)
    IsClass13(Agent:?agent) : void=
        if(NewAgent := Agent?):
            for(POW : Powers):
                if(POW.SelectNumber = 13):
                    POWERTOPLAYER(POW.SPECIFICNUMBER , NewAgent)
    IsClass14(Agent:?agent) : void=
        if(NewAgent := Agent?):
            for(POW : Powers):
                if(POW.SelectNumber = 14):
                    POWERTOPLAYER(POW.SPECIFICNUMBER , NewAgent)
    IsClass15(Agent:?agent) : void=
        if(NewAgent := Agent?):
            for(POW : Powers):
                if(POW.SelectNumber = 15):
                    POWERTOPLAYER(POW.SPECIFICNUMBER , NewAgent)
    IsClass16(Agent:?agent) : void=
        if(NewAgent := Agent?):
            for(POW : Powers):
                if(POW.SelectNumber = 16):
                    POWERTOPLAYER(POW.SPECIFICNUMBER , NewAgent)




    AddAllPowers() : void=
        set Powers += array{AimBotPower,ExchangeHealthForSpeedAndStrengthPower,ExplodeBuildsAOEPower,FloodWithWaterPower,FreezeClosestPlayerPower,SeparateArenaButtonPower,ShootBallPower,SlowMotionPower,SpawnClonesPower,SwitchPositionsWithClosestPower,TeleportBehindRandomPower,TurnInvinciblePower,TeleportInFrontPower,TravelBackInTimePower,CustomVehiclePower,ChangeRoomPower,TempApparelOrCharacterPower,PropBeamPower,ExplodeAllBuildsPower,SummonCagePower,SpawnVFXDamagePower,EnterHiddenAreaPower,JumpScarePower,SpawnNPCsPower}


    POWERTOPLAYER(POWERSPECIFICNUM : int,NewAgent : agent) : void=
        if(POWERSPECIFICNUM = 1):
            spawn:
                AimBotDevice.BeginAimbot(NewAgent)
        if(POWERSPECIFICNUM = 2):
            spawn:
                ExchangeHealthForSpeedAndStrengthDevice.HealthtoStrength(NewAgent)
        if(POWERSPECIFICNUM = 3):
            spawn:
                ExplodeBuildsAOEDevice.AOEExplosion(NewAgent)               
        if(POWERSPECIFICNUM = 4):
            spawn:
                FloodWithWaterDevice.FloodWater(NewAgent)
        if(POWERSPECIFICNUM = 5):
            spawn:
                FreezeClosestPlayerDevice.FreezePlayer(NewAgent)
        if(POWERSPECIFICNUM = 6):
            spawn:
                SeparateArenaButtonDevice.SeparateArenaAbility(NewAgent)
        if(POWERSPECIFICNUM = 7):
            spawn:
                ShootBallDevice.ShootBallAbility(NewAgent)
        if(POWERSPECIFICNUM = 8):
            spawn:
                SlowMotionDevice.StartSlowMo(NewAgent)
        if(POWERSPECIFICNUM = 9):
            spawn:
                SpawnClonesDevice.SpawnAllClones(NewAgent)
        if(POWERSPECIFICNUM = 10):
            spawn:
                SwitchPositionsWithClosestDevice.SwitchPositions(NewAgent)
        if(POWERSPECIFICNUM = 11):
            spawn:
                TeleportBehindRandomDevice.RealTP(NewAgent)
        if(POWERSPECIFICNUM = 12):
            spawn:
                TurnInvincibleDevice.Invincibity(NewAgent)
        if(POWERSPECIFICNUM = 13):
            spawn:
                TeleportInFrontDevice.TeleportInFrontAbility(NewAgent)
        if(POWERSPECIFICNUM = 14):
            spawn:
                TravelBackInTimeDevice.TravelBack(NewAgent)
        if(POWERSPECIFICNUM = 15):
            spawn:
                CustomVehicleDevice.SpawnVehicle(NewAgent)
        if(POWERSPECIFICNUM = 16):
            spawn:
                ChangeRoomDevice.ChangeRoomAbility(NewAgent)
        if(POWERSPECIFICNUM = 17):
            spawn:
                TempApparelOrCharacterDevice.TempApparelOrCharacterAbility(NewAgent)
        if(POWERSPECIFICNUM = 18):
            spawn:
                PropBeamDevice.PropBeamAbility(NewAgent)
        if(POWERSPECIFICNUM = 19):
            spawn:
                ExplodeAllBuildsDevice.ExplodeAllBuildsAbility(NewAgent)
        if(POWERSPECIFICNUM = 20):
            spawn:
                SummonCageDevice.SummonCageAbility(NewAgent)
        if(POWERSPECIFICNUM = 21):
            spawn:
                SpawnVFXDamageDevice.SpawnVFXDamageAbility(NewAgent)
        if(POWERSPECIFICNUM = 22):
            spawn:
                EnterHiddenAreaDevice.EnterHiddenAreaAbility(NewAgent)
        if(POWERSPECIFICNUM = 23):
            spawn:
                JumpScareDevice.JumpScareAbility(NewAgent)
        if(POWERSPECIFICNUM = 24):
            spawn:
                SpawnNPCsDevice.SpawnNPCsAbility(NewAgent)

        






   





