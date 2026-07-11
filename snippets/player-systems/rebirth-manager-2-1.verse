# Rebirth Manager 2
# Verse code for Rebirth Manager 2 - UEFN/Fortnite Creative implementation
# Difficulty: intermediate  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/rebirth-manager-2-1?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

#THIS DEVICE ALLOWS THE PLAYER TO REBIRTH, RESETTING THEM BUT GAINING AN INFINITE MONEY BOOST

PurchaseBoost := class<concrete>():
    var GameManager : Game_Manager = Game_Manager{}
    @editable BoostButton : button_device = button_device{}
    @editable CostType : string = ""
    @editable CostAmount : float = 0.0
    @editable BoostType : string = ""
    @editable BoostAmount : float = 0.0
    @editable SuccessCinematic : cinematic_sequence_device = cinematic_sequence_device{}
    @editable SuccessPlayerRef : player_reference_device = player_reference_device{}
    @editable SuccessHud : hud_message_device = hud_message_device{}
    @editable FailHud : hud_message_device = hud_message_device{}
    @editable Sign : creative_prop = creative_prop{}
    @editable Accolade : accolades_device =accolades_device{}

    Purchase(Agent:agent) : void=
        if(CP := GameManager.PlayersMap[Agent]):
            SpendResult := CP.Spend(CostAmount,CostType)
            if(SpendResult?):
                CP.Boost(BoostAmount,BoostType)
                SuccessCinematic.Play(Agent)
                SuccessPlayerRef.Register(Agent)
                SuccessHud.Show(Agent)
                Sign.Hide()
                BoostButton.Disable()
                Accolade.Award(Agent)
            else:
                FailHud.Show(Agent)




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

    @editable PurchaseBoosts : []PurchaseBoost = array{}



    OnBegin<override>()<suspends>:void=
        Button.InteractedWithEvent.Subscribe(RebirthPlayer)     #Signals when button is pressed
        EnableRebirthButtonTrigger.TriggeredEvent.Subscribe(EnableButton)

        for(B : PurchaseBoosts):
            set B.GameManager = GameManager
            B.BoostButton.InteractedWithEvent.Subscribe(B.Purchase)

    EnableButton(Agent:?agent) : void=
        Button.Enable()

    RebirthPlayer(Agent:agent) : void=
        Button.Disable
        if(CP := GameManager.PlayersMap[Agent]):
            CP.RebirthPlayer()      #Resets all player resources


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
