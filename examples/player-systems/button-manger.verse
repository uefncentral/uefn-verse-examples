# Tycoon Button System
# A comprehensive button management system for tycoon-style game modes that handles resource spending, prop visibility, cinematics, and progression unlocks. Players can purchase upgrades that show/hide 
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/button-manger?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }

#This Code is a Button System for a Tycoon Game Mode

Props := class():
    var Prop : creative_prop = creative_prop{}
    var InitialLocation : vector3 = vector3{}
    var InitialRotation : rotation = rotation{}

SpawnerButton:= class<concrete>():  #Class for each unlockable door/button

    #Other verse devices used to activate different actions
    var PlayerStatManager : player_stats_manager = player_stats_manager{}
    var GameManager : Game_Manager = Game_Manager{}

    var Identifier : int = 0        #Identifier used to tracker persistence

    var ButtonInitialPosition : vector3 = vector3{}

    @editable Price: float = 0.0   #How much of a resource to spend
    
    @editable ResourceType: string = ""   #What resource to spend

    @editable MutatorZone: mutator_zone_device = mutator_zone_device{}  #What Mutator Activates the button

    @editable ShownMutatorZones : []mutator_zone_device = array{}    #What Other Button's Mutators will activate after this button is pressed

    var ItemsToShowy: [int]Props = map{}     #What props will show

    var ItemsToHidey: [int]Props = map{}     #What props will show

    @editable ItemsToShow: []creative_prop = array{}     #What props will show

    @editable ItemsToHide: []creative_prop = array{}        #What props will hide

    @editable ButtonCinematic : cinematic_sequence_device = cinematic_sequence_device{} #Cinematic to start playing

    @editable IncreaseResourceAmount : float = 0.0      #Amount to increase another resource by

    @editable IncreaseResourceType : string = ""        #Type of resource to collect another resource by

    @editable UniqueTrigger : trigger_device = trigger_device{}     #Trigger device to do unique events

    @editable UniqueIDX : int = 0 #List of already implemented tasks found below in CheckForUniques() Function

    @editable RiseAnimation : logic = false #whether or not the button content should play a rising animation

    #Extra unique editables
    @editable ItemPlacers : []item_placer_device = array{}    #Item placers for arsenal of weapons/heals
    @editable CarSpawner1 : vehicle_spawner_sports_car_device = vehicle_spawner_sports_car_device{}   #car spawner to despawn a vehicle
    @editable CarSpawner2 : vehicle_spawner_sports_car_device = vehicle_spawner_sports_car_device{}   #car spawner to spawn a vehicle
    @editable DamageVolume : damage_volume_device = damage_volume_device{}   #damage device to enable barrier around plot (keep other players out)
    @editable Tracker : tracker_device = tracker_device{}   #Tracker device to increment

    #Extra stuff that activates
    var BuildHouseXP : accolades_device = accolades_device{}  #XP granted to player for buying a button
    var PurchaseMSG : hud_message_device = hud_message_device{}     #Hud msg showed to player when button is bought
    var NotEnoughMoneyMSG : hud_message_device = hud_message_device{}       #Hud msg showed to player if button is pressed but fails
   
    ButtonContent(Agent:agent) : void=    #Tries to Unlock Button content
        if(CustomPlayer := GameManager.PlayersMap[Agent]):
            SpendResult := CustomPlayer.Spend(Price, ResourceType)
            if(SpendResult?): # If the player had enough money to spend
                spawn:
                    UnlockButtonContent(Agent,true) #Calls Unlock Function

                CustomPlayer.Collect(IncreaseResourceAmount, IncreaseResourceType)      #Collects any additional resources
                PurchaseMSG.Show(Agent)   #shows a purchase success hud msg
            else:
                NotEnoughMoneyMSG.Show(Agent)   #shows a purchase fail hud msg

    UnlockButtonContent(Agent:agent,AddToPersistence : logic)<suspends>: void=   #Unlocks all the button content if purchase succeeds
        CheckForUniques(Agent)  #checks for any unique actions

        ButtonCinematic.Play()    #Plays button cinematic

        UniqueTrigger.Trigger(Agent)    #Triggers to do unique action

        for(idx -> Item: ItemsToShow, B := ItemsToShowy[idx]):      #Shows all items to show
            B.Prop.Show()
            if(RiseAnimation?):     #If enabled
                if(B.Prop.TeleportTo[vector3{X:=B.InitialLocation.X,Y:=B.InitialLocation.Y,Z:=B.InitialLocation.Z - 500.0},B.InitialRotation]): #instantly moves the prop closer
                    spawn:
                        SmoothItemMove(B.Prop,B.InitialLocation,B.InitialRotation)   #plays movement animation 
            else:
                if(B.Prop.TeleportTo[vector3{X:=B.InitialLocation.X,Y:=B.InitialLocation.Y,Z:=B.InitialLocation.Z},B.InitialRotation]){}
                
        for(idx -> Item: ItemsToHide, B := ItemsToHidey[idx]):      #Shows all items to show
            B.Prop.Hide()
            if(B.Prop.TeleportTo[vector3{X:=B.InitialLocation.X,Y:=B.InitialLocation.Y,Z:=B.InitialLocation.Z - 100000.0},B.InitialRotation]){}
      
        MutatorZone.Disable()        #Disables the Buttons Own Mutator

        if(AddToPersistence = true):        #If true, adds the unlocked door to the players persistence data
            PlayerStatManager.RecordPlayerArrStat(Agent, StatType.Doors, ?Score := Identifier)
            if(CP := GameManager.PlayersMap[Agent]):
                set CP.BoughtDoors += array{Identifier}

        Sleep(1.0)  #Waits one second before activating new buttons mutators to prevent button spam

        for(On: ShownMutatorZones):   #Enables new buttons mutators
            On.Enable()

    SmoothItemMove(Prop : creative_prop,Pos : vector3, Rot : rotation)<suspends> : void=
        Prop.MoveTo(vector3{X:=Pos.X,Y:=Pos.Y,Z:=Pos.Z + 50.0},Rot,1.0)     #moves a little over the initial position
        Prop.MoveTo(vector3{X:=Pos.X,Y:=Pos.Y,Z:=Pos.Z},Rot,0.3)     #moves a to initial position

    CheckForUniques(Agent:agent)<suspends> : void=  #Checks for unique actions to take place
        #If Unique IDX = 1: item placer will be teleported 10000.0m directly upward (Placers can not be hidden so this is a workaround)
        if(UniqueIDX = 1):
            for(P : ItemPlacers):
                PreLocation := P.GetTransform().Translation
                PreRotation := P.GetTransform().Rotation
                if(P.TeleportTo[vector3{X:=PreLocation.X,Y:=PreLocation.Y,Z:=PreLocation.Z + 100000.0},PreRotation]){}
                P.Enable()

        # If Unique IDX = 2: Car Spawner 1 will be disabled and destroyed and Car Spawner 2 will be enabled and spawned
        if(UniqueIDX = 2):
            CarSpawner1.Disable()
            Sleep(1.0)
            CarSpawner2.Enable()

        #If Unique IDX = 3: Damage Volume / House barrier enables
        if(UniqueIDX = 3):
            DamageVolume.Enable()

        #If Unique IDX = 4: Increment the tracker
        if(UniqueIDX = 4):
            Tracker.Increment(Agent)

Button_Manager := class(creative_device):
    #Other Creative/Verse Devices
    PlayerStatManager : player_stats_manager = player_stats_manager{}
    @editable GameManager: Game_Manager = Game_Manager{}

    #Additional stuff that applies to every button
    @editable NotEnoughMoneyMSG : hud_message_device = hud_message_device{} #Hud msg when button fails
    @editable PurchasedMSG : hud_message_device = hud_message_device{}  #Hud msg when button succeeds
    @editable BuildHouseXP : accolades_device = accolades_device{}  #XP granted when button succeeds

    #Main array of all buttons in a plot
    @editable ButtonsArray: []SpawnerButton = array{}