# Tycoon Plot Manager
# Manages plot ownership and ATM money systems for a tycoon game mode. Handles plot claiming, team assignment, money tracking, and player progress with visual feedback through HUD messages and billboard
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/plot-managerverse?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

#This Code is a Plot/ATM Manager for a Tycoon Game Mode

Plot_Manager := class(creative_device):
    #Other Creative/Verse devices
    @editable ButtonManager : Button_Manager = Button_Manager{}
    @editable GameManager : Game_Manager = Game_Manager{}
    @editable CrateManager : Crate_Manager = Crate_Manager{}
    PlayerStatManager : player_stats_manager = player_stats_manager{}

    @editable ClaimPlotMutator : mutator_zone_device = mutator_zone_device{}   #Mutator to claim a plot

    @editable ClaimPlotSelector : class_and_team_selector_device = class_and_team_selector_device{}   #Selector to change class/team to plot team

    @editable ClaimMoneyHUD : hud_message_device = hud_message_device{}   #HUD message device that shows when claiming ATM Money

    @editable ClaimMoneyMutator : mutator_zone_device = mutator_zone_device{}      #Mutator device for claiming ATM Money

    @editable ClaimMoneyBillboard : billboard_device = billboard_device{}      #Bilboard device for displaying ATM Money

    @editable ClaimPlotPlayerRef : player_reference_device = player_reference_device{}      #Player reference to show player skin/name above/infront of plot

    @editable ClaimPlotCinematic : cinematic_sequence_device = cinematic_sequence_device{}      #Cinematic to play when player claims a plot

    @editable ClaimPlotHud : hud_message_device = hud_message_device{}      #Hud msg to show to player when they claim a plot

    @editable ClaimPlotTracker : tracker_device = tracker_device{}      #Tracker device to increment when a player claims a plot
 
    @editable ScoreManager : score_manager_device = score_manager_device{}      #Score Manager to track a players score for in-game scoreboard

    var ATMAmount : float = 0.0   #Amount in ATM

    var PlotsPlayer : []agent = array{} #Holds the agent who owns plot

    ResetPlotEvent<public> : event() = event(){}    #Event used to disable the atm loop whenever the plot is reset

    StringToMessage<localizes>(value:float) : message = "{value}"  #Convert a float to message for billboard

    OnBegin<override>()<suspends>:void=
        ClaimPlotMutator.AgentEntersEvent.Subscribe(ClaimPlotSetup)       #Claims plot when in mutator
        ClaimMoneyMutator.AgentEntersEvent.Subscribe(ClaimMoney)            #Claims Money when in mutator
        GetPlayspace().PlayerRemovedEvent().Subscribe(PlayerLeft)

    ClaimPlotSetup(Agent:agent) : void=
        spawn:
            ATMStart(Agent)        #Starts producing money in the ATM for the player
        spawn:
            ClaimPlot(Agent)        #Does various things for the plot claim
 
    ClaimPlot(Agent:agent)<suspends> : void=
        if(Player := player[Agent], CustomPlayer := GameManager.PlayersMap[Player]):
            ClaimPlotSelector.ChangeTeam(Agent)     #Changes the players team to the plot team
            ClaimPlotPlayerRef.Register(Agent)      #Adds a player to the player reference
            ClaimPlotCinematic.Play(Agent)          #Plays plot cinematic
            ClaimPlotHud.Show(Agent)                #Shows plot HUD msg
            ClaimPlotTracker.Increment(Agent)       #Increments Claim Plot Tracker
            set PlotsPlayer = array{}
            set PlotsPlayer += array {Agent}        #Assigns plot's player to player who claimed

    PlayerLeft(Agent:agent ) : void=            #Resets the plot
        if(OwnedPlayer := PlotsPlayer[0], CP := GameManager.PlayersMap[Agent]):
            if(OwnedPlayer = Agent):

                for(B : ButtonManager.ButtonsArray):       
                    for(idx -> Item: B.ItemsToShow, D := B.ItemsToShowy[idx]):                           #Hides props
                        D.Prop.Hide()
                        if(D.Prop.TeleportTo[vector3{X:=D.InitialLocation.X,Y:=D.InitialLocation.Y,Z:=D.InitialLocation.Z - 100000.0},D.InitialRotation]){}

                        
                    for(P : B.ItemPlacers):                            #Hides item placers
                        ItemPlacerPos := P.GetTransform().Translation
                        ItemPlacerRot := P.GetTransform().Rotation
                        if(P.TeleportTo[vector3{X:=ItemPlacerPos.X,Y:=ItemPlacerPos.Y,Z:=ItemPlacerPos.Z - 100000.0},ItemPlacerRot]):

                    #Disables unique stuff
                    B.CarSpawner1.Disable()
                    B.CarSpawner2.Disable()
                    B.DamageVolume.Disable()
            
                    for(One : B.ShownMutatorZones):                #disables mutator
                        One.Disable()

                    B.ButtonCinematic.Stop()                              #Updated: changed Cinematic to ButtonCinematic
    
                #Resets ATM
                ResetPlotEvent.Signal()
                set ATMAmount = 0.0
                ClaimMoneyBillboard.SetText(StringToMessage(ATMAmount))     
                         
               
                #Shows the first button again
                if(FirstButton := ButtonManager.ButtonsArray[0]):
                    FirstButton.MutatorZone.Enable()
                    for(idx -> Item : FirstButton.ItemsToHide, B := FirstButton.ItemsToHidey[idx]):
                        B.Prop.Show()
                        if(B.Prop.TeleportTo[vector3{X:=B.InitialLocation.X,Y:=B.InitialLocation.Y,Z:=B.InitialLocation.Z},B.InitialRotation]){}

                set CP.BoughtDoors = array{}

                CrateManager.ResetLevel()       #Resets Crate Level

    ATMStart(Agent:agent)<suspends> : void=
        if(Player := player[Agent], CustomPlayer := GameManager.PlayersMap[Player]):
            race:
                block:  
                    ResetPlotEvent.Await()      #Ends loop when plot is reset

                loop:      #loops every second and claims resources for player
                    Sleep(1.0)

                    #Adds current boosts to the amount to increase
                    IncAmount := CustomPlayer.IdleMoneyAmount * (CustomPlayer.CurrentMoneyBoost + (CustomPlayer.RebirthAmount * CustomPlayer.RebirthBoostAmount))      
                    
                    set ATMAmount += IncAmount                                  #Adds increase amount to ATM

                    ClaimMoneyBillboard.SetText(StringToMessage(ATMAmount))     #Sets ATM billboard to new ATM amount

    ClaimMoney(Agent:agent) : void=      #Activates when player enters ATM Mutator
        if(Player := player[Agent], CustomPlayer := GameManager.PlayersMap[Player]):
            ClaimMoneyHUD.Show(Agent)   #Shows HUD msg when money is claimed 
            CustomPlayer.Collect(ATMAmount,"Money")    #Collects the money in ATM
            set ATMAmount = 0.0         #Resets the ATM amount back to 0