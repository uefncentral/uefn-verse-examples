# Boss Health Bar System
# Creates a customizable boss health bar UI system with damage tracking and visual display. Features a named boss ('Penaldo' by default) with configurable health values and real-time health updates thro
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/boss-fight2?ref=github

using { /Fortnite.com/Game }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath}
using { /Verse.org/Colors }
using { /Verse.org/Colors/NamedColors }

health_bar2 := class():
    Player:player
    var iTotalHP<private> : float = 1000.0
    var iCurrentHP1 : float = 1000.0
    var iBossName : string = "Penaldo"

    
    BossBarColorBase : color_block = color_block{
        DefaultColor := MakeColorFromHex("000000")
        DefaultDesiredSize := vector2{X:= 1200.0, Y := 40.0}} 

    var BossBarColorTop<private> : color_block = color_block{}  
    var Overlay<private> : overlay = overlay{}
        
    HPBarTitleTextBlock<private> : text_block = text_block{DefaultTextColor := MakeColorFromHex("FFFFFF")}

    HPTitleText<private><localizes>(HPText : string) : message = "{HPText}"

    Init(BossName : string, BossTotalHP: float):void=
        set iBossName = BossName
        set iTotalHP = BossTotalHP
        set iCurrentHP1 = BossTotalHP
        HPBarTitleTextBlock.SetText(HPTitleText("{iBossName}: {iCurrentHP1}/{iTotalHP}"))

    TakeDamage(DamageAmount : float):void=
        set iCurrentHP1 -= DamageAmount
        if (iCurrentHP1 < 0.0):
            set iCurrentHP1 = 0.0
 
        HealthPercentage := iCurrentHP1 / iTotalHP
        BarSize := BossBarColorBase.GetDesiredSize()
        NewHealthBarWidth := BarSize.X * HealthPercentage
        if (Current := Int[iCurrentHP1], Total := Int[iTotalHP]):
            HPBarTitleTextBlock.SetText(HPTitleText("{iBossName}: {Current}/{Total}"))
        
        UpdateHealthBar(NewHealthBarWidth)
    
    Heal(HealAmount : float):void=
        block:

    ShowUIForPlayer():void=
        if (PlayerUI := GetPlayerUI[Player]):
            PlayerUI.AddWidget(CreateUI())
       

    ShowUIToAllPlayers():void=
        block:

    MyButton : button_device = button_device{}

    UpdateHealthBar(NewWidth : float):void=
        Overlay.RemoveWidget(HPBarTitleTextBlock)
        Overlay.RemoveWidget(BossBarColorTop)
        set BossBarColorTop = CreateTopHealthBar(NewWidth)

        Overlay.AddWidget(CreateOverlaySlot(BossBarColorTop, horizontal_alignment.Left))
        Overlay.AddWidget(CreateOverlaySlot(HPBarTitleTextBlock,horizontal_alignment.Center))
        
    CreateOverlaySlot(TheWidget : widget, HAlignment : horizontal_alignment):overlay_slot=  
        overlay_slot:
            Widget := TheWidget 
            HorizontalAlignment := HAlignment

    CreateTopHealthBar(Width: float):color_block=
        ColorBlock := color_block{
            DefaultColor := MakeColorFromHex("ff2a00")
            DefaultDesiredSize := vector2{X:= Width, Y := 40.0}} 
        
        set BossBarColorTop = ColorBlock
        

    CreateOverlay() : overlay=
        TheOverlay := overlay:
            Slots := array:
                overlay_slot:
                    Widget := BossBarColorBase
                overlay_slot:
                    Widget := CreateTopHealthBar(1200.0)
                overlay_slot:
                    Widget := HPBarTitleTextBlock
        set Overlay = TheOverlay


    CreateUI() : canvas=
        TheCanvas : canvas = canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.9}, Maximum := vector2{X := 0.5, Y := 0.9}}
                    Offsets := margin{Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 100.0}
                    Alignment := vector2{X := 0.5, Y := 1.0}
                    Widget := stack_box:
                        Orientation := orientation.Vertical
                        Slots := array:
                            stack_box_slot:
                                Widget := CreateOverlay()
                            
                                                                
        return TheCanvas        
    
    returnmevalue1():float=
        return  iCurrentHP1   
         
game_player2 := struct:
    BossUI1 : health_bar2     

boss_fight2 := class(creative_device):

    @editable DeathAnimation : cinematic_sequence_device = cinematic_sequence_device{}
         
    @editable SmashAtackCinema : cinematic_sequence_device = cinematic_sequence_device{}
            
    @editable WalkCinema : cinematic_sequence_device = cinematic_sequence_device{}
        
    @editable leftturn : cinematic_sequence_device = cinematic_sequence_device{}
    @editable rightturn : cinematic_sequence_device = cinematic_sequence_device{}
        
    @editable BossManip : prop_manipulator_device = prop_manipulator_device{}
        
    @editable Boss : creative_prop = creative_prop{}
        
    @editable mutator1 : mutator_zone_device = mutator_zone_device{}
        
    @editable MoveSpeed : float = 25.0

    @editable timer1 : timer_device = timer_device{}

    @editable timer : timer_device = timer_device{}

    @editable mutator2 : mutator_zone_device = mutator_zone_device{}

    @editable DeathAudio : audio_player_device = audio_player_device{}



    @editable damage1 : damage_volume_device = damage_volume_device{}

    @editable damage2 : damage_volume_device = damage_volume_device{}

    @editable damage3 : damage_volume_device = damage_volume_device{}
        
    @editable item2 : item_spawner_device = item_spawner_device{}
    

    
    var heath12 : float = 1000.0    

    var breakvalue1 : float = 0.0

    var showvalue1 : float = 0.0



    #------------------------------------------------------------------------------------------

    var GlobalData : weak_map(session, [player]game_player2) = map{}

    # GamePlayers()<transacts>:[player]game_player2=
    #     var Players : [player]game_player2 = map{}
    #     if (P:= GlobalData[GetSession()]):
    #        set Players = P
    #     Players

    GamePlayers()<transacts>:[player]game_player2=
        var Players : [player]game_player2 = map{}
        if (set Players = GlobalData[GetSession()]) {}
        Players
    
    InitPlayer(Player : player):void=
        BossUI1 := health_bar2{Player := Player}
        GamePlayer := game_player2{BossUI1 := BossUI1}
        if (set GlobalData[GetSession()][Player] = GamePlayer) {}

    #------------------------------------------------------------------------------------------
    
            
    OnBegin<override>()<suspends>:void=

        if (set GlobalData[GetSession()] = map{}){}            
        
        Sleep(0.0)    
        AllPlayers := GetPlayspace().GetPlayers()
        Self.GetPlayspace().PlayerAddedEvent().Subscribe(ForNewPlayer1)
        # Self.GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerJoinedServer)


        for (Player : GetPlayspace().GetPlayers()):
            InitPlayer(Player)

        damage3.Disable()
        damage2.Disable()
        mutator1.Disable()

        
        BossManip.DamagedEvent.Subscribe(OnBossDamaged)
        
        
        mutator1.AgentEntersEvent.Subscribe(Kick)
        
        timer1.SuccessEvent.Subscribe(Startronaldo)

    # OnPlayerJoinedServer(PlayerEntering : player):void=
    #     InitPlayer(PlayerEntering)


    ChangeName():void=
        for (Player : GamePlayers()):
            Player.BossUI1.Init("Penaldo", 1000.0)

    ForNewPlayer1(Player : player):void=

        BossUI1 := health_bar2{Player := Player}
        GamePlayer2 := game_player2{BossUI1 := BossUI1}
        if (set GlobalData[GetSession()][Player] = GamePlayer2) {} 
        spawn:
            ShowUiToNew(Player) 
    
    ShowUiToNew(Player : player)<suspends>:void=
        if(showvalue1 > 0.0):
           Sleep(1.0)
           BossUI1 := health_bar2{Player := Player}
           GamePlayer2 := game_player2{BossUI1 := BossUI1}
           Sleep(1.0)
            for (Player1 : GamePlayers()):
                Player1.BossUI1.ShowUIForPlayer()    
            
            Sleep(1.0)  
            takedamage0()  
            
    OnBossDamaged(Agent : agent):void=
        set heath12 -= 10.0
        if (heath12 < 0.0):
            set heath12 = 0.0
        for (Player : GamePlayers()):
            Player.BossUI1.TakeDamage(10.0) 

    BossKilled(Agent:agent):void=
        BossManip.Disable()
        
    Kick(Agent : agent):void=
        spawn:
         SmashAnimation()
            
    SmashAnimation()<suspends>:void=
            SmashAtackCinema.Play()
            Sleep(1.36)
        
    Startronaldo1()<suspends>:void=
        loop:
        
            Sleep(0.3)
            StartMeleeAttack1()
            omparehealthhide()
            Sleep(1.5)

            if (breakvalue1 > 0.0):
                break

    Startronaldo(Agent : ?agent):void=
        ChangeName()
        spawn:
            Startronaldo1()

        BossManip.ShowProps()
        takedamage0()  
        mutator1.Enable()  
        damage2.Enable()
        damage3.Enable()
        set breakvalue1 = 0.0
        set showvalue1 = 1.0
        # set BossHPBar.iCurrentHP1 = 1000.0    
        for (Player : GamePlayers()):
            Player.BossUI1.ShowUIForPlayer()


    takedamage0():void=
     for (Player : GamePlayers()):
         Player.BossUI1.TakeDamage(0.0)            

    omparehealthhide():void=
      if (heath12 < 1.0):
       
        mutator1.Disable()
        spawn: 
           deathhogayabhai()
        
        DeathAudio.Play()   
        timer.Start()
        mutator2.Enable()
        damage1.Enable()
        spawn:
            kyanamdu()
       

    kyanamdu()<suspends>:void =
        set breakvalue1 = 1.0
        Sleep(9.0)
        set heath12 = 1000.0
        set showvalue1 = 0.0
        # ChangeName()
        # for (Player : GamePlayers()): 
        #     set Player.BossUI.iCurrentHP = 500.0 


    
    deathhogayabhai()<suspends>:void=
        DeathAnimation.Play()
        
        item2.SpawnItem()
        Sleep(5.0)
        BossManip.HideProps()
        
        
        
        
    (Base : transform).GetClosestPositional(Targets : []positional)<transacts>:?positional=
        var ClosestIDX : int = 0
        var ClosestDistance : float = 10000000000.0
    
        for (IDX -> Target : Targets):
            TDistance := Distance(Target.GetTransform().Translation, Base.Translation)
            if (TDistance < ClosestDistance):
                set ClosestDistance = TDistance
                set ClosestIDX = IDX
    
        if (Target := Targets[ClosestIDX]):
            option{Target}
        else:
            false
    
    # Casts players into positionals for easier math work
    (Players : []player).ToPositionals()<transacts>:[]positional=
        var Positionals : []positional = array{}
    
        for (Player : Players, Agent := agent[Player], Fort := Agent.GetFortCharacter[], Pos := positional[Fort]):
            set Positionals += array{Pos}
    
        Positionals
            
    # What rotation a transform needs to make to look at a target
    (Location : transform).GetLookAtRotation(Target : vector3):rotation=
        BaseTran := Location.Translation
        TargetTran := Target
            
        if (LookDirection := (TargetTran - BaseTran).MakeUnitVector[]):
            Yaw := (ArcTan(LookDirection.Y, LookDirection.X * 180.0 / Pi)) - 90.0
            Pitch := 0.0 
            Roll := 0.0
            
            MakeRotationFromYawPitchRollDegrees(Yaw, Pitch, Roll)
        else:
            IdentityRotation()  
        
        
    StartMeleeAttack1()<suspends>:void=
        StartLocation := Boss.GetTransform().Translation
        # Find the nearest player
        Players := GetPlayspace().GetPlayers().ToPositionals()
        if (Target := Boss.GetTransform().GetClosestPositional(Players)?):
            var TargetLocation : vector3 = Target.GetTransform().Translation
            # Rotate toward player before moving
            var NewRotation : rotation = Boss.GetTransform().GetLookAtRotation(TargetLocation)
            Boss.MoveTo(Boss.GetTransform().Translation, NewRotation, 0.3)
            
            MoveDistance := DistanceXY(StartLocation, TargetLocation)
            DistanceCoveredPerSecond := 45.0 * MoveSpeed
            var MoveTime: float = MoveDistance / DistanceCoveredPerSecond

            if (MoveTime <= 0.0):
                set MoveTime = 1.0

            #Play the dash animation

            Boss.MoveTo(TargetLocation, NewRotation, MoveTime)

            set TargetLocation = Target.GetTransform().Translation
            
            # One more quick rotation to face the player
            set NewRotation = Boss.GetTransform().GetLookAtRotation(TargetLocation)
            Boss.MoveTo(Boss.GetTransform().Translation, NewRotation, 0.3)
