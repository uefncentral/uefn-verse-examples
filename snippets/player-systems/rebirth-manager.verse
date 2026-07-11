# Player Rebirth System
# This code creates a rebirth/prestige system that allows players to reset their progress in exchange for permanent bonuses. When activated via a button, it resets all player resources, buttons, and plo
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/rebirth-manager?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

#THIS DEVICE ALLOWS THE PLAYER TO REBIRTH, RESETTING THEM BUT GAINING AN INFINITE MONEY BOOST

Rebirth_Manager := class(creative_device):

    PlayerStatManager : player_stats_manager = player_stats_manager{}   #Tracks persistence

    @editable GameManager : Game_Manager = Game_Manager{}       #Main game manager

    @editable CrateManager : Crate_Manager = Crate_Manager{}    #Crate manager

    @editable FarmManager : Farm_Manager = Farm_Manager{}

    @editable Button : button_device = button_device{}          #Button to activate rebirth

    @editable ButtonManager : Button_Manager = Button_Manager{} #Button Manager device 

    @editable PlotManager : Plot_Manager = Plot_Manager{}       #Plot Manager device

    @editable BaseClassSelector : class_and_team_selector_device = class_and_team_selector_device{}     #Switches player back to base team

    @editable EnableRebirthButtonTrigger : trigger_device = trigger_device{}



    OnBegin<override>()<suspends>:void=
        Button.InteractedWithEvent.Subscribe(RebirthPlayer)     #Signals when button is pressed
        EnableRebirthButtonTrigger.TriggeredEvent.Subscribe(EnableButton)

    EnableButton(Agent:?agent) : void=
        Button.Enable()
    
    RebirthPlayer(Agent:agent) : void=
        Button.Disable
        if(CP := GameManager.PlayersMap[Agent]):
            CP.RebirthPlayer()      #Resets all player resources

            #Resets all buttons
            for(B : ButtonManager.ButtonsArray): 
                spawn:      
                    B.ResetButton(Agent)

            #Resets ATM
            PlotManager.ResetPlotEvent.Signal()
            set PlotManager.ATMAmount = 0.0
            PlotManager.ClaimMoneyBillboard.SetText(PlotManager.StringToMessage(PlotManager.ATMAmount))     

            CP.Collect(1.0,"Rebirth")     #Collects rebirth   
            BaseClassSelector.ChangeTeam(Agent)     #Reverts Team
            set CP.BoughtDoors = array{}
            PlayerStatManager.ResetPlayerArrStat(Agent, StatType.Doors)

            #Shows the first button again
            if(FirstButton := ButtonManager.ButtonsArray[0]):
                FirstButton.MutatorZone.Enable()
                for(idx -> Item : FirstButton.ItemsToHide):
                    PropPos := Item.GetTransform().Translation
                    PropRot := Item.GetTransform().Rotation
                    if(Item.TeleportTo[vector3{X:=PropPos.X,Y:=PropPos.Y,Z:=PropPos.Z + 100000.0},PropRot]){}

            CrateManager.ResetLevel()       #Resets Crate Level
            FarmManager.ResetAllCrops()

