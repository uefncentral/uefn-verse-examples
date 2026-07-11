# Upgradeable Reward Crate System
# Creates an interactive crate that players can hit to receive rewards, with the ability to upgrade the crate's level to provide better rewards. The system tracks crate levels, manages reward distributi
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/crate-managerverse?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/SpatialMath }
#THIS DEVICE GRANTS PLAYERS REWARDS WHEN HIT

CrateLevel:= class<concrete>():     #Custom class to give be able to give more resources when upgraded

    @editable LevelRewardValue1 : string = ""               #Reward Type 1
    @editable LevelRewardAmount1 : float = 0.0              #Reward Amount 1

    @editable LevelRewardValue2 : string = ""               #Reward Type 2
    @editable LevelRewardAmount2 : float = 0.0              #Reward Amount 2


    @editable HitHud : hud_message_device = hud_message_device{}    #HUD message to show what rewards the player is granted




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

    

    StringToMessage<localizes>(value:int) : message = "{value}" #Converst string to message

    OnBegin<override>()<suspends>:void=
        if(Cur := Levels[LevelIDX]):        #sets current level to the first level
            set CurrentLevel = Cur

        PropManip.DamagedEvent.Subscribe(OnHit)     #activates when the crate is hit
        UpgradeCrateTrigger.TriggeredEvent.Subscribe(UpgradeLevel)

        set CrateScale = CrateProp.GetTransform().Scale     

    OnHit(Agent:agent) : void=  #when the crate is hit

        spawn:
            HitAnimation()      #Plays a hit animation

        #collects the current levels rewards
        if(Player := player[Agent], CustomPlayer := GameManager.PlayersMap[Player],FC:= Player.GetFortCharacter[]):
            CustomPlayer.Collect(CurrentLevel.LevelRewardAmount1,CurrentLevel.LevelRewardValue1)    
            CustomPlayer.Collect(CurrentLevel.LevelRewardAmount2,CurrentLevel.LevelRewardValue2)

        CurrentLevel.HitHud.Show(Agent)             #Shows the HUD msg to represent what rewards were granted

        
    UpgradeLevel(Agent : ?agent) : void=          #function to upgrade the level
        set LevelIDX += 1
        if(Cur := Levels[LevelIDX]):
            set CurrentLevel = Cur

    ResetLevel() : void=
        set LevelIDX = 0
        if(Cur := Levels[LevelIDX]):
            set CurrentLevel = Cur

    HitAnimation()<suspends> : void=
        if(not CrateMoving?):
            set CrateMoving = true
            CratePos := CrateProp.GetTransform().Translation
            CrateRot := CrateProp.GetTransform().Rotation
            CrateProp.MoveTo(transform{Translation := CratePos,Rotation:= CrateRot, Scale:= vector3{X:= CrateSmallScale,Y:=CrateSmallScale,Z:=CrateSmallScale}} ,0.2)
            CrateProp.MoveTo(transform{Translation := CratePos,Rotation:= CrateRot, Scale:= CrateScale} ,0.2)
            set CrateMoving = false


