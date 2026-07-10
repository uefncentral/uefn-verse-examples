# Button Manager 2
# Verse code for Button Manager 2 - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/button-manager-2-1?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }

#This Code is a Button System for a Tycoon Game Mode

Props := class():
    var Prop : creative_prop = creative_prop{}
    var InitialZLocation : float = 0.0
    var HiddenZLocation : float = 0.0

    Initialize(): void=
        set InitialZLocation = Prop.GetTransform().Translation.Z
        set HiddenZLocation = Prop.GetTransform().Translation.Z - 10000.0



SpawnerButton:= class<concrete>():  #Class for each unlockable door/button

    #Other verse devices used to activate different actions
    var PlayerStatManager : player_stats_manager = player_stats_manager{}
    var GameManager : Game_Manager = Game_Manager{}

    var Identifier : int = 0        #Identifier used to tracker persistence

    var PropsHiddenAtATime : int = 0

    @editable Price: float = 0.0   #How much of a resource to spend
    
    @editable ResourceType: string = ""   #What resource to spend

    @editable MutatorZone: mutator_zone_device = mutator_zone_device{}  #What Mutator Activates the button

    @editable PurchaseTrigger : trigger_device = trigger_device{}

    @editable ShownMutatorZones : []mutator_zone_device = array{}    #What Other Button's Mutators will activate after this button is pressed

    var ItemsToShowMap: [int]Props = map{}     #What props will show

    @editable ItemsToShow: []creative_prop = array{}     #What props will show

    @editable ItemsToHide: []creative_prop = array{}        #What props will hide

    @editable Cinematic : cinematic_sequence_device = cinematic_sequence_device{} #Cinematic to start playing

    @editable IncreaseResourceAmount : float = 0.0      #Amount to increase another resource by

    @editable IncreaseResourceType : string = ""        #Type of resource to collect another resource by

    @editable UniqueTrigger : trigger_device = trigger_device{}     #Trigger device to do unique events

    @editable UniqueIDX : int = 0 #List of already implemented tasks found below in CheckForUniques() Function

    @editable RiseAnimation : logic = false #whether or not the button content should play a rising animation

    @editable VFX : vfx_spawner_device = vfx_spawner_device{}

    @editable Switch : switch_device = switch_device{}



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

    ResetButton(Agent:agent)<suspends> : void=
        var CurrentResetAmount : int = 0
        for(idx -> Item: ItemsToShow, D := ItemsToShowMap[idx]):                           #Hides props
            if(CurrentValueInt := Int[D.Prop.GetTransform().Translation.Z],InitialValueInt := Int[D.InitialZLocation]):
                if(CurrentValueInt = InitialValueInt):
                    PropPos := D.Prop.GetTransform().Translation
                    if(D.Prop.TeleportTo[vector3{X:=PropPos.X,Y:=PropPos.Y,Z:=D.HiddenZLocation},D.Prop.GetTransform().Rotation]){}
                    if(CurrentResetAmount <= PropsHiddenAtATime):
                        set CurrentResetAmount += 1
                    else:
                        Sleep(0.01)
                        set CurrentResetAmount = 0
               
        
        for(P : ItemPlacers):                            #Hides item placers
            ItemPlacerPos := P.GetTransform().Translation
            ItemPlacerRot := P.GetTransform().Rotation
            if(P.TeleportTo[vector3{X:=ItemPlacerPos.X,Y:=ItemPlacerPos.Y,Z:=ItemPlacerPos.Z - 10000.0},ItemPlacerRot]):

        SwitchPos := Switch.GetTransform().Translation
        SwitchRot := Switch.GetTransform().Rotation
        if(Switch.TeleportTo[vector3{X:=SwitchPos.X,Y:=SwitchPos.Y,Z:=SwitchPos.Z - 10000.0},SwitchRot]):

        
        #Disables unique stuff
        CarSpawner1.Disable()
        CarSpawner2.Disable()
        DamageVolume.Disable()

        for(Zone : ShownMutatorZones):                #disables mutator
            Zone.Disable()

        Cinematic.Stop()                              #stops cinematic

    
    ButtonContentTrigger(Agent:?agent) : void=    #Tries to Unlock Button content
        if(NewAgent := Agent?){ButtonContent(NewAgent)}
        
    ButtonContent(Agent:agent) : void=    #Tries to Unlock Button content
        if(CustomPlayer := GameManager.PlayersMap[Agent]):
            if(Identifier = 0):
                if(CustomPlayer.BoughtDoors.Length < 1): #If they've already bought doors before    
                    SpendResult := CustomPlayer.Spend(Price, ResourceType)
                    if(SpendResult?): # If the player had enough money to spend
                        spawn:
                            UnlockButtonContent(Agent,true) #Calls Unlock Function

                        CustomPlayer.Collect(IncreaseResourceAmount, IncreaseResourceType)      #Collects any additional resources
                        PurchaseMSG.Show(Agent)   #shows a purchase success hud msg
                    else:
                        NotEnoughMoneyMSG.Show(Agent)   #shows a purchase fail hud msg

            else:      
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

        Cinematic.Play()    #Plays button cinematic

        UniqueTrigger.Trigger(Agent)    #Triggers to do unique action

        BuildHouseXP.Award(Agent)

        for(idx -> Item: ItemsToShow, B := ItemsToShowMap[idx]):      #Shows all items to show
            if(CurrentValueInt := Int[B.Prop.GetTransform().Translation.Z],HiddenValueInt := Int[B.HiddenZLocation]):
                if(CurrentValueInt = HiddenValueInt):
                    PropPos := B.Prop.GetTransform().Translation
                    PropRot := B.Prop.GetTransform().Rotation
                    if(RiseAnimation?):     #If enabled
                        if(B.Prop.TeleportTo[vector3{X:=PropPos.X,Y:=PropPos.Y,Z:=B.InitialZLocation - 500.0},PropRot]): #instantly moves the prop closer
                            spawn:
                                SmoothItemMove(B.Prop , B.InitialZLocation)   #plays movement animation 
                    else:
                        if(B.Prop.TeleportTo[vector3{X:=PropPos.X,Y:=PropPos.Y,Z:=B.InitialZLocation},PropRot]){}

                
        for(idx -> Item: ItemsToHide):      #Shows all items to show
            PropPos := Item.GetTransform().Translation
            PropRot := Item.GetTransform().Rotation
            if(Item.TeleportTo[vector3{X:=PropPos.X,Y:=PropPos.Y,Z:=PropPos.Z -10000.0}, PropRot]):
      
        MutatorZone.Disable()        #Disables the Buttons Own Mutator
            
        if(AddToPersistence = true,CP := GameManager.PlayersMap[Agent]):        #If true, adds the unlocked door to the players persistence data
            if(not CP.BoughtDoors.Find[Identifier]):
                PlayerStatManager.RecordPlayerArrStat(Agent, StatType.Doors, ?Score := Identifier)
                set CP.BoughtDoors += array{Identifier}

        Sleep(1.0)  #Waits one second before activating new buttons mutators to prevent button spam

        VFX.Enable()

        for(Zone: ShownMutatorZones):   #Enables new buttons mutators
            Zone.Enable()

    SmoothItemMove(Prop : creative_prop,InitialZ : float)<suspends> : void=
        PropPos := Prop.GetTransform().Translation
        PropRot := Prop.GetTransform().Rotation
        Prop.MoveTo(vector3{X:=PropPos.X,Y:=PropPos.Y,Z:=InitialZ + 50.0},PropRot,1.0)     #moves a little over the initial position
        Prop.MoveTo(vector3{X:=PropPos.X,Y:=PropPos.Y,Z:=InitialZ},PropRot,0.3)     #moves a to initial position

    CheckForUniques(Agent:agent)<suspends> : void=  #Checks for unique actions to take place
        if(UniqueIDX = 1):
            for(P : ItemPlacers):
                PreLocation := P.GetTransform().Translation
                PreRotation := P.GetTransform().Rotation
                if(P.TeleportTo[vector3{X:=PreLocation.X,Y:=PreLocation.Y,Z:=PreLocation.Z + 10000.0},PreRotation]){}
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

        if (UniqueIDX = 5):
            NewSwitchPos := Switch.GetTransform().Translation
            NewSwitchRot := Switch.GetTransform().Rotation
            if(Switch.TeleportTo[vector3{X:=NewSwitchPos.X,Y:=NewSwitchPos.Y,Z:=NewSwitchPos.Z + 10000.0},NewSwitchRot]):



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

    @editable PropsHiddenAtATime : int = 0


    OnBegin<override>()<suspends>:void=
        Sleep(1.0)
        for(idx -> Button : ButtonsArray):   #For every single button
            #Assign values after game has started (This is to avoid a glitch)
            set Button.GameManager = GameManager
            set Button.PlayerStatManager = PlayerStatManager
            set Button.PurchaseMSG = PurchasedMSG
            set Button.NotEnoughMoneyMSG = NotEnoughMoneyMSG
            set Button.BuildHouseXP = BuildHouseXP
            set Button.Identifier = idx
            set Button.PropsHiddenAtATime = PropsHiddenAtATime

            for(P : Button.ItemPlacers):                            #Hides item placers
                ItemPlacerPos := P.GetTransform().Translation
                ItemPlacerRot := P.GetTransform().Rotation
                if(P.TeleportTo[vector3{X:=ItemPlacerPos.X,Y:=ItemPlacerPos.Y,Z:=ItemPlacerPos.Z - 10000.0},ItemPlacerRot]):

            SwitchPos := Button.Switch.GetTransform().Translation
            SwitchRot := Button.Switch.GetTransform().Rotation
            if(Button.Switch.TeleportTo[vector3{X:=SwitchPos.X,Y:=SwitchPos.Y,Z:=SwitchPos.Z - 10000.0},SwitchRot]):


            for(index -> Item: Button.ItemsToShow):   #Initalizes show props 
                if(set Button.ItemsToShowMap[index] = Props{Prop := Item}):
                    if(CurrentProp := Button.ItemsToShowMap[index]):
                        CurrentProp.Initialize()

            var CurrentResetAmount : int = 0
            for(B : Button.ItemsToShowMap):               #Hides all props 
                if(CurrentValueInt := Int[B.Prop.GetTransform().Translation.Z],InitialValueInt := Int[B.InitialZLocation]):
                    if(CurrentValueInt =InitialValueInt):
                        PropPos := B.Prop.GetTransform().Translation
                        if(B.Prop.TeleportTo[vector3{X:=PropPos.X,Y:=PropPos.Y,Z:=B.HiddenZLocation},B.Prop.GetTransform().Rotation]):
                            if(CurrentResetAmount <= PropsHiddenAtATime):
                                set CurrentResetAmount += 1
                            else:
                                Sleep(0.01)
                                set CurrentResetAmount = 0
        Sleep(1.0)
        for(Button : ButtonsArray):
            Button.MutatorZone.AgentEntersEvent.Subscribe(Button.ButtonContent) #Activates button when entered
            Button.PurchaseTrigger.TriggeredEvent.Subscribe(Button.ButtonContentTrigger)