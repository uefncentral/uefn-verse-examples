# Loot Crate Manager
# A reward system that grants players resources when they hit interactive crates. Features upgradeable crate levels with customizable rewards, visual effects, audio feedback, and HUD messages to display
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/crate-manager-1?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /Verse.org/Colors/NamedColors }
#THIS DEVICE GRANTS PLAYERS REWARDS WHEN HIT

CrateLevel:= class<concrete>():     #Custom class to give be able to give more resources when upgraded

    @editable LevelRewardValue1 : string = ""               #Reward Type 1
    @editable LevelRewardAmount1 : float = 0.0              #Reward Amount 1

    @editable LevelRewardValue2 : string = ""               #Reward Type 2
    @editable LevelRewardAmount2 : float = 0.0              #Reward Amount 2


    @editable HitHud : hud_message_device = hud_message_device{}    #HUD message to show what rewards the player is granted

    @editable CrateVFX : vfx_spawner_device = vfx_spawner_device{}  #VFX spawner that appears when crate is hit

    @editable CrateSound : audio_player_device = audio_player_device{} #Audio that plays when crate is hit



Crate_Manager := class(creative_device):

    @editable GameManager : Game_Manager = Game_Manager{}                                   #Main game manager

    @editable PropManip : prop_manipulator_device = prop_manipulator_device{}               #Manipulator to track when box is hit

    @editable CrateProp : creative_prop = creative_prop{}                                   #Prop for the crate

    @editable Levels : []CrateLevel = array{}                                               #All potential levels for the crate

    var CurrentLevel : CrateLevel = CrateLevel{}                                            #The crate's current level

    var LevelIDX : int = 0                                                                  #The Level Index

    @editable UpgradeCrateTrigger : trigger_device = trigger_device{}                       #Trigger that upgrades level

    @editable CrateSmallScale : float = 0.0
    
    var CrateScale : vector3 = vector3{} 

    var CrateMoving : logic = false

    ResetTimerEvent<public> : event(agent) = event(agent){}

    var MaybeUIPerPlayer : [player]?canvas = map{}

    StringToMessage<localizes>(Value : string) : message = "{Value}"

    @editable TimeUntilUIDissapears : float = 3.0

    @editable ImageIDX : int = 0

    var PopUpImages : []texture = array{}

    var CurrentImage : texture = MOUI
    StringToMessage<localizes>(value:int) : message = "{value}" #Converst string to message

    OnBegin<override>()<suspends>:void=
        if(Cur := Levels[LevelIDX]):        #sets current level to the first level
            set CurrentLevel = Cur

        PropManip.DamagedEvent.Subscribe(OnHit)     #activates when the crate is hit
        UpgradeCrateTrigger.TriggeredEvent.Subscribe(UpgradeLevel)

        set CrateScale = CrateProp.GetTransform().Scale     

    OnHit(Agent:agent) : void=  #when the crate is hit
        spawn:
            DisplayGatherHUD(Agent)

        spawn:
            HitAnimation()      #Plays a hit animation

        #collects the current levels rewards
        if(Player := player[Agent], CustomPlayer := GameManager.PlayersMap[Player],FC:= Player.GetFortCharacter[]):
            CustomPlayer.Collect(CurrentLevel.LevelRewardAmount1,CurrentLevel.LevelRewardValue1)    
            CustomPlayer.Collect(CurrentLevel.LevelRewardAmount2,CurrentLevel.LevelRewardValue2)

        # CurrentLevel.HitHud.Show(Agent)             #Shows the HUD msg to represent what rewards were granted
        CurrentLevel.CrateSound.Play()              #Plays sound at crates location
        spawn:
            PlayVFX()

    PlayVFX()<suspends> : void=                 #Plays Visual effect at crates location
        CurrentLevel.CrateVFX.Enable()
        Sleep(0.2)
        CurrentLevel.CrateVFX.Disable()

    UpgradeLevel(Agent : ?agent) : void=          #function to upgrade the level
        set LevelIDX += 1
        if(Cur := Levels[LevelIDX]):
            set CurrentLevel = Cur

    ResetLevel() : void=
        set LevelIDX = 0
        if(Cur := Levels[LevelIDX]):
            set CurrentLevel = Cur

    HitAnimation()<suspends> : void=            #Plays an animation for the crate
        if(not CrateMoving?):
            set CrateMoving = true
            CratePos := CrateProp.GetTransform().Translation
            CrateRot := CrateProp.GetTransform().Rotation
            CrateProp.MoveTo(transform{Translation := CratePos,Rotation:= CrateRot, Scale:= vector3{X:= CrateSmallScale,Y:=CrateSmallScale,Z:=CrateSmallScale}} ,0.2)
            CrateProp.MoveTo(transform{Translation := CratePos,Rotation:= CrateRot, Scale:= CrateScale} ,0.2)
            set CrateMoving = false




    DisplayGatherHUD(Agent:agent)<suspends> : void=
        if(Player := player[Agent],PlayerUI := GetPlayerUI[Player],CP := GameManager.PlayersMap[Agent]):
            NewHitUI := CreateHitUI(CurrentLevel.LevelRewardAmount1)
            PlayerUI.AddWidget(NewHitUI)
            
            if(MaybeUIPerPlayer[Player]?):
                ResetTimerEvent.Signal(Agent)
            else:
                NewStableUI := CreateStableUI(CurrentLevel.LevelRewardAmount1,Agent)
                PlayerUI.AddWidget(NewStableUI)
                if(set MaybeUIPerPlayer[Player] = option{NewStableUI}){}
                
        
    CreateStableUI(ReceiveCollect : float,Agent:agent) : canvas=

        if(NewImage := PopUpImages[ImageIDX]):
            set CurrentImage = NewImage
        ResourceCollectAmount := TruncateFloatString(ReceiveCollect,0)
        var PositionSquare : color_block = color_block{DefaultColor := Black,DefaultOpacity := 1.0}
        var CollectAmount : text_block = text_block{DefaultTextColor := White,DefaultTextOpacity := 1.0,DefaultText := StringToMessage("x {ResourceCollectAmount}"),DefaultShadowOffset := option{vector2{X:=1.0,Y:=1.0}},DefaultShadowColor := Gray}
        var PositionBrick : texture_block = texture_block{DefaultImage := CurrentImage}
        CollectAmount.SetShadowOpacity(1.0)
        PositionSquare.SetOpacity(0.2)
        MainCanvas : canvas = canvas{
            Slots := array{
                canvas_slot{
                    Anchors := anchors{Minimum := vector2{X := 0.5,Y := 0.5},Maximum := vector2{X := 0.5,Y := 0.5}}
                    Offsets := margin{Left := 260.0 , Top := 60.0 , Right := 180.0 , Bottom := 60.0}
                    SizeToContent := false
                    Alignment := vector2{X := 0.5,Y := 0.5}
                    ZOrder := 0
                    Widget := PositionSquare
                    }

                canvas_slot{
                    Anchors := anchors{Minimum := vector2{X := 0.5,Y := 0.5},Maximum := vector2{X := 0.5,Y := 0.5}}
                    Offsets := margin{Left := 315.0 , Top := 60.0 , Right := 165.0 , Bottom := 40.0}
                    SizeToContent := false
                    Alignment := vector2{X := 0.5,Y := 0.5}
                    ZOrder := 1
                    Widget := CollectAmount
                    }

                canvas_slot{
                    Anchors := anchors{Minimum := vector2{X := 0.5,Y := 0.5},Maximum := vector2{X := 0.5,Y := 0.5}}
                    Offsets := margin{Left := 200.0 , Top := 60.0 , Right := 50.0 , Bottom := 50.0}
                    SizeToContent := false
                    Alignment := vector2{X := 0.5,Y := 0.5}
                    ZOrder := 1
                    Widget := PositionBrick
                }
                }    
            }
        spawn:
            StableLoop(Agent,MainCanvas,PositionSquare,CollectAmount,PositionBrick,ReceiveCollect)
        return MainCanvas

    StableLoop(Agent : agent, MainWidget : canvas , Square : color_block,CollectAmount:text_block,PositionBrick : texture_block,ReceiveCollect:float)<suspends> : void=
        if(Player := player[Agent]):
            var CollectVal : float = ReceiveCollect
            var ResetTime : float = TimeUntilUIDissapears
            race:
                block:
                    loop:
                        Sleep(1.0)
                        set ResetTime -= 1.0
                        if(ResetTime <=  0.0):
                            PositionBrick.SetVisibility(widget_visibility.Hidden)
                            CollectAmount.SetVisibility(widget_visibility.Hidden)
                            Square.SetVisibility(widget_visibility.Hidden)
                            MainWidget.RemoveWidget(Square)
                            MainWidget.RemoveWidget(CollectAmount)
                            MainWidget.RemoveWidget(PositionBrick)
                            if(set MaybeUIPerPlayer[Player] = false){}
                            return
                block:
                    loop:
                        Sleep(0.0)
                        ResettingAgent := ResetTimerEvent.Await()
                        if(ResetAgent := agent[ResettingAgent]):
                            if(ResetAgent = Agent):
                                set ResetTime = TimeUntilUIDissapears

                loop:
                    PropManip.DamagedEvent.Await()
                    set CollectVal += ReceiveCollect
                    ResourceCollectAmount := TruncateFloatString(CollectVal,0)
                    CollectAmount.SetText(StringToMessage("x {ResourceCollectAmount}"))

        


    CreateHitUI<public>(ReceiveCollect : float) : canvas = 
        
        ResourceCollectAmount := TruncateFloatString(ReceiveCollect,0)
            
        var PositionBrick : texture_block = texture_block{DefaultImage := CurrentImage}
        var CollectAmount : text_block = text_block{DefaultTextColor := White,DefaultTextOpacity := 1.0,DefaultText := StringToMessage("+ {ResourceCollectAmount}"),DefaultShadowOffset := option{vector2{X:=1.0,Y:=1.0}},DefaultShadowColor := Gray}
        CollectAmount.SetShadowOpacity(1.0)
        MainCanvas : canvas = canvas{
            Slots := array{
                canvas_slot{
                    Anchors := anchors{Minimum := vector2{X := 0.5,Y := 0.5},Maximum := vector2{X := 0.5,Y := 0.5}}
                    Offsets := margin{Left := 200.0 , Top := 0.0 , Right := 50.0 , Bottom := 50.0}
                    SizeToContent := false
                    Alignment := vector2{X := 0.5,Y := 0.5}
                    Widget := PositionBrick
                    }

                canvas_slot{
                    Anchors := anchors{Minimum := vector2{X := 0.5,Y := 0.5},Maximum := vector2{X := 0.5,Y := 0.5}}
                    Offsets := margin{Left := 315.0 , Top := 0.0 , Right := 160.0 , Bottom := 40.0}
                    SizeToContent := false
                    Alignment := vector2{X := 0.5,Y := 0.5}
                    Widget := CollectAmount
                    }
                }    
            }
        spawn:
            MoveUI(MainCanvas,PositionBrick,CollectAmount)

        return MainCanvas


    MoveUI(MovingWidget : canvas , PositionBrick : texture_block,CollectAmount:text_block)<suspends> : void=
        Sleep(0.05)
        var Opacity : float = 1.0
        var Height : float = 0.0
        var ConstrainOpacity : type{_X : float where _X >= 0.0, _X <= 1.0} = 1.0
        race:
            block:
                Sleep(TimeUntilUIDissapears)
                PositionBrick.SetVisibility(widget_visibility.Hidden)
                CollectAmount.SetVisibility(widget_visibility.Hidden)
                MovingWidget.RemoveWidget(PositionBrick)
                MovingWidget.RemoveWidget(CollectAmount)
                return

            loop:
                Sleep(0.01)
                set Opacity -= 0.01
                if(NEWOPACITY := type{_X : float where _X >= 0.0, _X <= 1.0}[Opacity]):
                    set ConstrainOpacity = NEWOPACITY
                CollectAmount.SetTextOpacity(ConstrainOpacity)
                set Height -= 3.0
                
                UpdateSquare(MovingWidget,PositionBrick,CollectAmount,Height)
            

    UpdateSquare<private>(MovingWidget : canvas , PositionSquare : texture_block,CollectAmount : text_block, Height : float)<suspends> : void = 
        PositionSquare.SetVisibility(widget_visibility.Hidden)
        CollectAmount.SetVisibility(widget_visibility.Hidden)
        MovingWidget.RemoveWidget(PositionSquare)
        MovingWidget.RemoveWidget(CollectAmount)
        PositionSquare.SetVisibility(widget_visibility.Visible)
        CollectAmount.SetVisibility(widget_visibility.Visible)

        MovingWidget.AddWidget(
            canvas_slot:
                Anchors := anchors{Minimum := vector2{X := 0.5,Y := 0.5},Maximum := vector2{X := 0.5,Y := 0.5}}
                Offsets := margin{Left := 200.0 , Top := Height , Right := 50.0 , Bottom := 50.0}
                SizeToContent := false
                Alignment := vector2{X := 0.5,Y := 0.5}
                Widget := PositionSquare
        )
        MovingWidget.AddWidget(
            canvas_slot:
                Anchors := anchors{Minimum := vector2{X := 0.5,Y := 0.5},Maximum := vector2{X := 0.5,Y := 0.5}}
                Offsets := margin{Left := 315.0 , Top := Height , Right := 160.0 , Bottom := 40.0}
                SizeToContent := false
                Alignment := vector2{X := 0.5,Y := 0.5}
                Widget := CollectAmount
        )



    TruncateFloatString(Input:float, Decimals:int) : []char = {
        var String : []char = ToString(Input)
    
        if (DotIndex := String.Find['.']) {
            StopIndex := if (Decimals > 0) { Min(DotIndex+Decimals+1,String.Length) } else { DotIndex }
            if (FinalString := String.Slice[0, StopIndex]) {
                return FinalString
            }
        }
    
        return "NaN"
        }
        