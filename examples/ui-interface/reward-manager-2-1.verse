# Reward Manager 2
# Verse code for Reward Manager 2 - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/reward-manager-2-1?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/UI }
using { /Verse.org/Colors/NamedColors }
using { /Verse.org/Colors }
using { /Verse.org/Assets }
using { /Verse.org/Random }
using { /Fortnite.com/Characters }

#THIS DEVICE GRANTS PLAYERS BETTER REWARDS THE LONGER THEY PLAY

PlayerRewards := class<unique>(Custom_Player):    #extension of custom player class

    var GameManager : Game_Manager = Game_Manager{}             #main game manager

    var RewardBoxXP : accolades_device = accolades_device{}     #Xp granted to player for claiming a reward

    var MainUI : overlay = overlay{}                            #Main UI element for reward box

    var ExitButton : button_loud = button_loud{}                #Exit Button
    var ClaimButton : button_loud = button_loud{}               #Claim Button

    #Different HUD messages to show players what rewards they were granted
    var Reward1HUD : hud_message_device = hud_message_device{}
    var Reward2HUD : hud_message_device = hud_message_device{}
    var Reward3HUD : hud_message_device = hud_message_device{}
    var Reward4HUD : hud_message_device = hud_message_device{}
    var Reward5HUD : hud_message_device = hud_message_device{}
    var Reward6HUD : hud_message_device = hud_message_device{}
    var Reward7HUD : hud_message_device = hud_message_device{}
    var Reward8HUD : hud_message_device = hud_message_device{}
    var Reward9HUD : hud_message_device = hud_message_device{}

    #Different timers all with customizable times                                 
    var Reward1Timer : TimerWidget = TimerWidget{Minutes := 5}   #<----  Change times here and in this format
    var Reward2Timer : TimerWidget = TimerWidget{Minutes := 10}
    var Reward3Timer : TimerWidget = TimerWidget{Minutes := 20}
    var Reward4Timer : TimerWidget = TimerWidget{Minutes := 30}
    var Reward5Timer : TimerWidget = TimerWidget{Minutes := 40}
    var Reward6Timer : TimerWidget = TimerWidget{Minutes := 50}
    var Reward7Timer : TimerWidget = TimerWidget{Minutes := 60}
    var Reward8Timer : TimerWidget = TimerWidget{Minutes := 90}
    var Reward9Timer : TimerWidget = TimerWidget{Minutes := 120}


    #Checkmarks to appear after the reward has been claimed                         !MUST CHANGE SETTINGS!
    var Check1 : texture_block = texture_block{DefaultImage := checkmark}#put checkmark texture here,DefaultDesiredSize := vector2{X:=80.0,Y:=80.0}}
    var Check2 : texture_block = texture_block{DefaultImage := checkmark}#put checkmark texture here,DefaultDesiredSize := vector2{X:=80.0,Y:=80.0}}
    var Check3 : texture_block = texture_block{DefaultImage := checkmark}#put checkmark texture here,DefaultDesiredSize := vector2{X:=80.0,Y:=80.0}}
    var Check4 : texture_block = texture_block{DefaultImage := checkmark}#put checkmark texture here,DefaultDesiredSize := vector2{X:=80.0,Y:=80.0}}
    var Check5 : texture_block = texture_block{DefaultImage := checkmark}#put checkmark texture here,DefaultDesiredSize := vector2{X:=80.0,Y:=80.0}}
    var Check6 : texture_block = texture_block{DefaultImage := checkmark}#put checkmark texture here,DefaultDesiredSize := vector2{X:=80.0,Y:=80.0}}
    var Check7 : texture_block = texture_block{DefaultImage := checkmark}#put checkmark texture here,DefaultDesiredSize := vector2{X:=80.0,Y:=80.0}}
    var Check8 : texture_block = texture_block{DefaultImage := checkmark}#put checkmark texture here,DefaultDesiredSize := vector2{X:=80.0,Y:=80.0}}
    var Check9 : texture_block = texture_block{DefaultImage := checkmark}#put checkmark texture here,DefaultDesiredSize := vector2{X:=80.0,Y:=80.0}}

    #Main background image for reward box (This is an image with all of the different gift boxes on it)     !MUST CHANGE SETTINGS!
    var BackgroundImage : texture_block = texture_block{DefaultImage := rewardhud, DefaultDesiredSize:= vector2{X:=1080.0, Y:=1350.0}}


    StartAllTimers() : void=    #Starts all timers
        spawn:
            Reward1Timer.StartTime(Player)
        spawn:
            Reward2Timer.StartTime(Player)
        spawn:
            Reward3Timer.StartTime(Player)
        spawn:
            Reward4Timer.StartTime(Player)
        spawn:
            Reward5Timer.StartTime(Player)
        spawn:
            Reward6Timer.StartTime(Player)
        spawn:
            Reward7Timer.StartTime(Player)
        spawn:
            Reward8Timer.StartTime(Player)
        spawn:
            Reward9Timer.StartTime(Player)
        


    InitiateRewardUI() : void=  #Initiate all buttons and hides all checkmarks
        ExitButton.SetText(StringToMessage("Exit"))
        ClaimButton.SetText(StringToMessage("Claim"))
        Check1.SetVisibility(widget_visibility.Hidden)
        Check2.SetVisibility(widget_visibility.Hidden)
        Check3.SetVisibility(widget_visibility.Hidden)
        Check4.SetVisibility(widget_visibility.Hidden)
        Check5.SetVisibility(widget_visibility.Hidden)
        Check6.SetVisibility(widget_visibility.Hidden)
        Check7.SetVisibility(widget_visibility.Hidden)
        Check8.SetVisibility(widget_visibility.Hidden)
        Check9.SetVisibility(widget_visibility.Hidden)

        set MainUI = CreateUI()         #Creates the UI
        ExitButton.OnClick().Subscribe(HandleExitButton)    #signals when exit button is clicked
        ClaimButton.OnClick().Subscribe(HandleClaimButton)      #Signals when claim button is clicked


    HandleClaimButton(Message : widget_message) : void=     #Claims rewards if timer is finished
        PR := Message.Player
            if(Reward1Timer.IsFinished?):
                set Reward1Timer.IsFinished = false
                Check1.SetVisibility(widget_visibility.Visible)
                if (PlayerUI := GetPlayerUI[Message.Player],CP := GameManager.PlayersMap[Message.Player]):
                    PlayerUI.RemoveWidget(MainUI)
                    Reward1HUD.Show(PR)
                    RewardBoxXP.Award(PR)

                    #Put reward 1 here: 
                    #Example:
                    #CP.Collect(10000.0,"Money")
            
                
            if(Reward2Timer.IsFinished?):
                set Reward2Timer.IsFinished = false
                Check2.SetVisibility(widget_visibility.Visible)
                if (PlayerUI := GetPlayerUI[Message.Player],CP := GameManager.PlayersMap[Message.Player]):
                    PlayerUI.RemoveWidget(MainUI)
                    Reward2HUD.Show(PR)
                    RewardBoxXP.Award(PR)

                    #Put reward 2 here: 
                    #Example:
                    #CP.Collect(10000.0,"Money")

        
            if(Reward3Timer.IsFinished?):
                set Reward3Timer.IsFinished = false
                Check3.SetVisibility(widget_visibility.Visible)
                if (PlayerUI := GetPlayerUI[Message.Player],CP := GameManager.PlayersMap[Message.Player]):
                    PlayerUI.RemoveWidget(MainUI)
                    Reward3HUD.Show(PR)
                    RewardBoxXP.Award(PR)

                    #Put reward 3 here: 
                    #Example:
                    #CP.Collect(10000.0,"Money")


            if(Reward4Timer.IsFinished?):
                set Reward4Timer.IsFinished = false
                Check4.SetVisibility(widget_visibility.Visible)
                if (PlayerUI := GetPlayerUI[Message.Player],CP := GameManager.PlayersMap[Message.Player]):
                    PlayerUI.RemoveWidget(MainUI)
                    Reward4HUD.Show(PR)
                    RewardBoxXP.Award(PR)

                    #Put reward 4 here: 
                    #Example:
                    #CP.Collect(10000.0,"Money")


            if(Reward5Timer.IsFinished?):
                set Reward5Timer.IsFinished = false
                Check5.SetVisibility(widget_visibility.Visible)
                if (PlayerUI := GetPlayerUI[Message.Player],CP := GameManager.PlayersMap[Message.Player]):
                    PlayerUI.RemoveWidget(MainUI)
                    Reward5HUD.Show(PR)
                    RewardBoxXP.Award(PR)

                    #Put reward 5 here: 
                    #Example:
                    #CP.Collect(10000.0,"Money")

                
            if(Reward6Timer.IsFinished?):
                set Reward6Timer.IsFinished = false
                Check6.SetVisibility(widget_visibility.Visible)
                if (PlayerUI := GetPlayerUI[Message.Player],CP := GameManager.PlayersMap[Message.Player]):
                    PlayerUI.RemoveWidget(MainUI)
                    Reward6HUD.Show(PR)
                    RewardBoxXP.Award(PR)

                    #Put reward 6 here: 
                    #Example:
                    #CP.Collect(10000.0,"Money")


            if(Reward7Timer.IsFinished?):
                set Reward7Timer.IsFinished = false
                Check7.SetVisibility(widget_visibility.Visible)
                if (PlayerUI := GetPlayerUI[Message.Player],CP := GameManager.PlayersMap[Message.Player]):
                    PlayerUI.RemoveWidget(MainUI)
                    Reward7HUD.Show(PR)
                    RewardBoxXP.Award(PR)

                    #Put reward 7 here: 
                    #Example:
                    #CP.Collect(10000.0,"Money")

            if(Reward8Timer.IsFinished?):
                set Reward8Timer.IsFinished = false
                Check8.SetVisibility(widget_visibility.Visible)
                if (PlayerUI := GetPlayerUI[Message.Player],CP := GameManager.PlayersMap[Message.Player]):
                    PlayerUI.RemoveWidget(MainUI)
                    Reward8HUD.Show(PR)
                    RewardBoxXP.Award(PR)

                    #Put reward 8 here: 
                    #Example:
                    #CP.Collect(10000.0,"Money")

                
            if(Reward9Timer.IsFinished?):
                set Reward9Timer.IsFinished = false
                Check9.SetVisibility(widget_visibility.Visible)
                if (PlayerUI := GetPlayerUI[Message.Player],CP := GameManager.PlayersMap[Message.Player]):
                    PlayerUI.RemoveWidget(MainUI)
                    Reward9HUD.Show(PR)
                    RewardBoxXP.Award(PR)
                    #Put reward 9 here: 
                    #Example:
                    #CP.Collect(10000.0,"Money")
    
    


    HandleExitButton(Message : widget_message) : void=  #Closes the UI
        if (ThePlayer := player[Message.Player],PlayerUI := GetPlayerUI[ThePlayer],CP := GameManager.PlayersMap[ThePlayer]):
            PlayerUI.RemoveWidget(MainUI)
            CP.MyUI.SetVisibility(widget_visibility.Visible)

    
    StringToMessage<localizes>(value:string) : message = "{value}"      #Convers a string to message

    CreateUI() : overlay=           #Creates the main UI
        NewUI : overlay = overlay:
            Slots := array:
                overlay_slot:    #Reward background image   
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left:=500.0,Top:=100.0,Right:=500.0,Bottom:=100.0}
                    Widget := BackgroundImage

                overlay_slot:       #Check1 Image
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left:=0.0,Top:=0.0,Right:=280.0,Bottom:=160.0}
                    Widget := Check1

                overlay_slot:       #Check2 Image
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left:=0.0,Top:=0.0,Right:=0.0,Bottom:=160.0}
                    Widget := Check2

                overlay_slot:       #Check3 Image
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left:=280.0,Top:=0.0,Right:=0.0,Bottom:=160.0}
                    Widget := Check3

                overlay_slot:       #Check4 Image
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left:=0.0,Top:=30.0,Right:=280.0,Bottom:=0.0}
                    Widget := Check4
                    
                overlay_slot:       #Check5 Image
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left:=0.0,Top:=30.0,Right:=0.0,Bottom:=0.0}
                    Widget := Check5

                overlay_slot:       #Check6 Image
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left:=280.0,Top:=30.0,Right:=0.0,Bottom:=0.0}
                    Widget := Check6

                overlay_slot:       #Check7 Image
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left:=0.0,Top:=280.0,Right:=280.0,Bottom:=0.0}
                    Widget := Check7

                overlay_slot:       #Check8 Image
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left:=0.0,Top:=280.0,Right:=0.0,Bottom:=0.0}
                    Widget := Check8

                overlay_slot:       #Check9 Image
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left:=280.0,Top:=280.0,Right:=0.0,Bottom:=0.0}
                    Widget := Check9

                overlay_slot:       #timer1
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left:=0.0,Top:=0.0,Right:=280.0,Bottom:=160.0}
                    Widget := Reward1Timer.Widget

                overlay_slot:       #timer2
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left:=0.0,Top:=0.0,Right:=0.0,Bottom:=160.0}
                    Widget := Reward2Timer.Widget

                overlay_slot:       #timer3
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left:=280.0,Top:=0.0,Right:=0.0,Bottom:=160.0}
                    Widget := Reward3Timer.Widget

                overlay_slot:       #timer4
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left:=0.0,Top:=30.0,Right:=280.0,Bottom:=0.0}
                    Widget := Reward4Timer.Widget
                    
                overlay_slot:       #timer5
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left:=0.0,Top:=30.0,Right:=0.0,Bottom:=0.0}
                    Widget := Reward5Timer.Widget

                overlay_slot:       #timer6
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left:=280.0,Top:=30.0,Right:=0.0,Bottom:=0.0}
                    Widget := Reward6Timer.Widget

                overlay_slot:       #timer7
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left:=0.0,Top:=280.0,Right:=280.0,Bottom:=0.0}
                    Widget := Reward7Timer.Widget

                overlay_slot:       #timer8
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left:=0.0,Top:=280.0,Right:=0.0,Bottom:=0.0}
                    Widget := Reward8Timer.Widget

                overlay_slot:       #timer9
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left:=280.0,Top:=280.0,Right:=0.0,Bottom:=0.0}
                    Widget := Reward9Timer.Widget
            

                overlay_slot:       #exit button
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left:=0.0,Top:=450.0,Right:=300.0,Bottom:=0.0}
                    Widget := ExitButton

                overlay_slot:       #claim button
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment := vertical_alignment.Center
                    Padding := margin{Left:=0.0,Top:=450.0,Right:=0.0,Bottom:=0.0}
                    Widget := ClaimButton
        return NewUI


TimerWidget := class():     #A custom class for each timer to decrease
    var Hours : int = 0
    var Minutes : int = 0
    var Seconds : int = 0
    var Time : float = 0.0
    var Widget : text_block = text_block{DefaultTextColor := White}
    var ClaimButton : button_loud = button_loud{}
    var IsFinished : logic = false
    var CompleteEvent<public> : event() = event(){}
    StringToMessage<localizes>(value:string) : message = "{value}"

    StartTime(Player : player)<suspends> : void=        #counts down the timer
        loop:
            Sleep(1.0)
            var BonusZeroHours : string = ""
            var BonusZeroMinutes : string = ""
            var BonusZeroSeconds : string = ""
            if(Hours < 10){set BonusZeroHours = "0"}
            if(Minutes < 10){set BonusZeroMinutes = "0"}
            if(Seconds < 10){set BonusZeroSeconds = "0"}
            Widget.SetText(StringToMessage("{BonusZeroHours}{Hours}:{BonusZeroMinutes}{Minutes}:{BonusZeroSeconds}{Seconds}"))
            set Seconds -= 1
            if(Seconds <= 0):
                if(not Minutes <= 0):
                    set Minutes -= 1
                    set Seconds = 59
                else if(not Hours <= 0):
                    set Hours -= 1
                    set Minutes = 59
                    set Seconds = 59
                else:
                    set IsFinished = true
                    Widget.SetText(StringToMessage(""))
                    CompleteEvent.Signal()
                    break


Reward_Manager := class(creative_device):

    @editable GameManager : Game_Manager = Game_Manager{}               #Main game manager

    @editable RewardButton : button_device = button_device{}            #Reward box button

    @editable RewardAlertHUD : hud_message_device = hud_message_device{}        #HUD message that displays when a reward is available for a player

    @editable RewardActivateTrigger : trigger_device = trigger_device{}

     #Different HUD messages to show players what rewards they were granted
    @editable Reward1HUD : hud_message_device = hud_message_device{}
    @editable Reward2HUD : hud_message_device = hud_message_device{}
    @editable Reward3HUD : hud_message_device = hud_message_device{}
    @editable Reward4HUD : hud_message_device = hud_message_device{}
    @editable Reward5HUD : hud_message_device = hud_message_device{}
    @editable Reward6HUD : hud_message_device = hud_message_device{}
    @editable Reward7HUD : hud_message_device = hud_message_device{}
    @editable Reward8HUD : hud_message_device = hud_message_device{}
    @editable Reward9HUD : hud_message_device = hud_message_device{}

    @editable RewardBoxXP : accolades_device = accolades_device{}       #XP granted when a player claims a reward

    var MaybeMyUIRewPerPlayer : [player]?overlay = map{}                #Map to store players UI

    var ExitButton : button_loud = button_loud{}                        #Exit button

    var ClaimButton : button_loud = button_loud{}                       #Claim button

    var PlayerRewardMap : [player]PlayerRewards = map{}                 #Map for all players rewards/timers


    StringToMessage<localizes>(value:string) : message = "{value}"      #Converts string to message

    OnBegin<override>()<suspends>:void=
        RewardButton.InteractedWithEvent.Subscribe(OpenRewardBox)       #Activates when reward box button is pressed
        RewardActivateTrigger.TriggeredEvent.Subscribe(InitiateRewards)
    
        
    OpenRewardBox(Agent:agent): void=           #Adds the ui to player
        if(Player := player[Agent], PlayerUI := GetPlayerUI[Player],PR := PlayerRewardMap[Player],CP := GameManager.PlayersMap[Agent]):
            CP.MyUI.SetVisibility(widget_visibility.Hidden)
            PlayerUI.AddWidget(PR.MainUI, player_ui_slot{InputMode := ui_input_mode.All})
            if (set MaybeMyUIRewPerPlayer[Player] = option{PR.MainUI}) {}




    InitiateRewards(MAgent:?agent) : void=      #Initiates rewards for the player (Have this activate as your first plot button)
        if(Agent:= MAgent?):
            RewardButton.Enable()                           #Enables the reward box button

            #Sets up rewards for player
            if(Player := player[Agent]):                    
                if(PlayerExists := PlayerRewardMap[Player]):
                else:
                    if:
                        FC := Player.GetFortCharacter[]
                    then:
                        if(set PlayerRewardMap[Player] = PlayerRewards{Player := Player}){}
                        if(CustomPlayer := PlayerRewardMap[Player]):    
                            CustomPlayer.StartAllTimers()
                            CustomPlayer.InitiateRewardUI()
                            set CustomPlayer.GameManager = GameManager
                            set CustomPlayer.Reward1HUD = Reward1HUD
                            set CustomPlayer.Reward2HUD = Reward2HUD
                            set CustomPlayer.Reward3HUD = Reward3HUD
                            set CustomPlayer.Reward4HUD = Reward4HUD
                            set CustomPlayer.Reward5HUD = Reward5HUD
                            set CustomPlayer.Reward6HUD = Reward6HUD
                            set CustomPlayer.Reward7HUD = Reward7HUD
                            set CustomPlayer.Reward8HUD = Reward8HUD
                            set CustomPlayer.Reward9HUD = Reward9HUD
                            set CustomPlayer.RewardBoxXP = RewardBoxXP
                        spawn:
                            RewardNotify(Player)    #notify player when rewards are available
    


    RewardNotify(Player:player)<suspends> : void=       #Notifies players when rewards are available for them
        if(CP := PlayerRewardMap[Player]):
            CP.Reward1Timer.CompleteEvent.Await()
            RewardAlertHUD.Show(Player)
            CP.Reward2Timer.CompleteEvent.Await()
            RewardAlertHUD.Show(Player)
            CP.Reward3Timer.CompleteEvent.Await()
            RewardAlertHUD.Show(Player)
            CP.Reward4Timer.CompleteEvent.Await()
            RewardAlertHUD.Show(Player)
            CP.Reward5Timer.CompleteEvent.Await()
            RewardAlertHUD.Show(Player)
            CP.Reward6Timer.CompleteEvent.Await()
            RewardAlertHUD.Show(Player)
            CP.Reward7Timer.CompleteEvent.Await()
            RewardAlertHUD.Show(Player)
            CP.Reward8Timer.CompleteEvent.Await()
            RewardAlertHUD.Show(Player)
            CP.Reward9Timer.CompleteEvent.Await()
            RewardAlertHUD.Show(Player)