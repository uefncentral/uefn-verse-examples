# Superpower Timer HUD
# Creates a customizable countdown timer UI that displays different superpower icons and switches player classes based on active powers. The timer shows remaining time with visual indicators for powers 
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/customtimerdevice-1?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Game }
using { /Verse.org/Colors }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }



Power := enum:
    None
    SuperJump
    SuperSpeed
    SuperHP
    SuperDamage
    Invisibility



CustomTimerDevice := class(creative_device):

    @editable
    TimerPosition : type{X: float where X >= 0.0, X <= 1.0} = 0.12

    @editable
    TimerHeight : type{X: float where X >= 0.0, X <= 1.0} = 0.1

    @editable
    BackgroundSize : type{X: float where X >= 0.0, X <= 1000.0} = 200.0

    @editable
    LogoOffset : type{X: float where X >= -1.0, X <= 1.0} = -0.08

    @editable
    LogoSize : type{X: float where X >= 0.0, X <= 1000.0} = 200.0

    @editable
    TextColor : color = color{R := 1.0, G := 1.0, B:= 1.0}



    @editable
    Time : float = 120.0


    @editable
    NoPowerClass : class_and_team_selector_device = class_and_team_selector_device{}

    @editable
    SuperJumpClass : class_and_team_selector_device = class_and_team_selector_device{}

    @editable
    SuperSpeedClass : class_and_team_selector_device = class_and_team_selector_device{}

    @editable
    SuperHPClass : class_and_team_selector_device = class_and_team_selector_device{}

    @editable
    SuperDamageClass : class_and_team_selector_device = class_and_team_selector_device{}

    @editable
    InvisibilityClass : class_and_team_selector_device = class_and_team_selector_device{}



    BackgroundImage : texture = bgsuperpowertimer

    SuperJumpLogo : texture = Superjumphudtimer
    SuperSpeedLogo : texture = Superspeedhudtimer
    SuperHPLogo : texture = Superhphudtimer
    SuperDamageLogo : texture = Superdamagehudtimer
    InvisibilityLogo : texture = Invisiblehudtimer




    Text <localizes> (Txt : string) : message = "{Txt}"


    var PlayerPowers : [agent]Power = map{}
    var PlayerCanvas : [agent]canvas = map{}
    var PlayerCanvasElements : [agent]text_block = map{}



    OnBegin<override>()<suspends>:void=
        
        NoPowerClass.ClassSwitchedEvent.Subscribe(RemovePlayerHUD)
        SuperJumpClass.ClassSwitchedEvent.Subscribe(SuperJumpAcquired)
        SuperSpeedClass.ClassSwitchedEvent.Subscribe(SuperSpeedAcquired)
        SuperHPClass.ClassSwitchedEvent.Subscribe(SuperHPAcquired)
        SuperDamageClass.ClassSwitchedEvent.Subscribe(SuperDamageAcquired)
        InvisibilityClass.ClassSwitchedEvent.Subscribe(InvisibilityAcquired)



    ChangeHUD(Agent : agent, Canvas : canvas) : void =

        RemovePlayerHUD(Agent)

        if(PlayerHUD := GetPlayerUI[player[Agent]], set PlayerCanvas[Agent] = Canvas):
            PlayerHUD.AddWidget(Canvas, player_ui_slot{InputMode := ui_input_mode.None})


    RemovePlayerHUD(Agent : agent) : void =

        if(PlayerHUD := GetPlayerUI[player[Agent]], Canvas := PlayerCanvas[Agent], set PlayerCanvas[Agent] = canvas{}):
            PlayerHUD.RemoveWidget(Canvas)



    PowersRemoved(Agent : agent) : void =
        if(set PlayerPowers[Agent] = Power.None):
            RemovePlayerHUD(Agent)

    SuperJumpAcquired(Agent : agent) : void =
        if(set PlayerPowers[Agent] = Power.SuperJump):
            ChangeHUD(Agent, TimerHUD(Agent, SuperJumpLogo))
            spawn{StartTimer(Agent)}

    SuperSpeedAcquired(Agent : agent) : void =
        if(set PlayerPowers[Agent] = Power.SuperSpeed):
            ChangeHUD(Agent, TimerHUD(Agent, SuperSpeedLogo))
            spawn{StartTimer(Agent)}

    SuperHPAcquired(Agent : agent) : void =
        if(set PlayerPowers[Agent] = Power.SuperHP):
            ChangeHUD(Agent, TimerHUD(Agent, SuperHPLogo))
            spawn{StartTimer(Agent)}

    SuperDamageAcquired(Agent : agent) : void =
        if(set PlayerPowers[Agent] = Power.SuperDamage):
            ChangeHUD(Agent, TimerHUD(Agent, SuperDamageLogo))
            spawn{StartTimer(Agent)}

    InvisibilityAcquired(Agent : agent) : void =
        if(set PlayerPowers[Agent] = Power.Invisibility):
            ChangeHUD(Agent, TimerHUD(Agent, InvisibilityLogo))
            spawn{StartTimer(Agent)}



    StartTimer(Agent : agent) <suspends> : void =

        if(Element := PlayerCanvasElements[Agent], Rows := Floor[Time]):
            for(Index := 0..Rows):
                Element.SetText(Text("{Rows - Index}"))
                Sleep(1.0)



    TimerHUD(Agent : agent, Logo : texture) : canvas =

        TimerText := text_block{DefaultText := Text("?"), DefaultTextColor := TextColor}
        Background := texture_block{DefaultImage := BackgroundImage, DefaultDesiredSize := vector2{ X := BackgroundSize, Y := BackgroundSize}}
        TimerLogo := texture_block{DefaultImage := Logo, DefaultDesiredSize := vector2{ X := LogoSize, Y := LogoSize }}

        if(set PlayerCanvasElements[Agent] = TimerText):

        CanvasMenu : canvas = canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors{Minimum := vector2 {X := TimerPosition, Y := TimerHeight}, Maximum := vector2 {X := TimerPosition, Y := TimerHeight}}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := TimerText

                canvas_slot:
                    Anchors := anchors{Minimum := vector2 {X := TimerPosition, Y := TimerHeight}, Maximum := vector2 {X := TimerPosition, Y := TimerHeight}}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := Background

                canvas_slot:
                    Anchors := anchors{Minimum := vector2 {X := TimerPosition + LogoOffset, Y := TimerHeight}, Maximum := vector2 {X := TimerPosition + LogoOffset, Y := TimerHeight}}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := TimerLogo