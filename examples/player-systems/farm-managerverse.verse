# Crop Farming System
# A farming system that manages collectible crops with growth timers, visual scaling, and player interaction tracking. Players can harvest crops by walking over them, earning XP and incrementing resourc
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/farm-managerverse?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }
#THIS DEVICE WILL WORK AS A FARM TO COLLECT A SPECIFIC RESOURCE ON A TIMER WHEN A PLAYER RUNS OVER IT

Crop:= class<concrete>():
    var GameManager : Game_Manager = Game_Manager{}                                     #Main game manager

    var PickUpAudio : audio_player_device = audio_player_device{}                       #Pickup Sound

    var CropXP : accolades_device = accolades_device{}                                  #XP Granted on pickup

    var CropTracker : tracker_device = tracker_device{}                                 #Tracker to incremenet on pickup

    var CropResource : string = ""                                                      #What resource is your crop

    @editable CropMaxGrowScale : float = 0.0                                            #What scale the prop should be when it is at max growth

    @editable CropMinGrowScale : float = 0.0                                            #what scale the prop should be when it is at min growth

    @editable CropGrowTime : float = 0.0                                                #How long for the crop to grow

    @editable CropMutator : mutator_zone_device = mutator_zone_device{}               #Mutator to track when player picks up crop

    @editable CropReadyProp : creative_prop = creative_prop{}                         #Prop that shows when the crop is fully grown

    @editable CropProp : creative_prop = creative_prop{}                               #The actual crop prop

    var IsGrown : logic = false                                                         #Whether or not the crop is fully grown yet




    EnableCrop()<suspends> : void=    #Enables the crop
        CropProp.Show()     #shows the crop prop
        CropMutator.Enable()    #Enables the crops mutator
        CropScale := CropProp.GetTransform().Scale
        CropPos := CropProp.GetTransform().Translation
        CropRot := CropProp.GetTransform().Rotation
        if(CropProp.TeleportTo[transform{Translation := CropPos,Rotation:= CropRot, Scale:= vector3{X:=CropMinGrowScale,Y:=CropMinGrowScale,Z:=CropMinGrowScale}}]){}
        CropProp.MoveTo(transform{Translation := CropPos,Rotation:= CropRot, Scale:= vector3{X:=CropMaxGrowScale,Y:=CropMaxGrowScale,Z:=CropMaxGrowScale}} , CropGrowTime)
        CropReadyProp.Show()    #Shows the ready prop to signify to players that it is grown
        set IsGrown = true          #Sets logic to true
        CropMutator.AgentEntersEvent.Subscribe(CollectCrop)     #When player enters the crop mutator, tries to collect the crop

    CollectCrop(Agent:agent) : void=    #Tries to collect the crop
        if(IsGrown = true):     #If grown:
            if(CustomPlayer := GameManager.PlayersMap[Agent]):  
                PickUpAudio.Play(Agent)     #Play pickup sound
                CropReadyProp.Hide()        #Hide the ready prop
               
                CustomPlayer.Collect(1.0,CropResource)

                CropXP.Award(Agent)         #Gives player xp for collecting crop
                CropTracker.Increment(Agent)       #Increments a crop collection tracker
                
                set IsGrown = false     #Sets logic to false

                spawn:
                    EnableCrop()        #Resets the crop
        else:
            Print("NoPickup")   #Prints if not fully grown yet
    
    

Farm_Manager := class(creative_device):
    #Three collections of crops to be able to be enabled at different times
    @editable FirstCrops : []Crop = array{}
    @editable SecondCrops : []Crop = array{}
    @editable ThirdCrops : []Crop = array{}

    @editable GameManager : Game_Manager = Game_Manager{}                       #Main game manager

    @editable PickupAudio : audio_player_device = audio_player_device{}         #Pickup sound

    @editable CropXP : accolades_device = accolades_device{}                    #Crop pickup XP

    @editable CropTracker : tracker_device = tracker_device{}                   #Crop tracker

    @editable CropResource : string = ""                                        #What resource is your crop

    #Triggers to begin farms
    @editable FirstFarmTrigger : trigger_device = trigger_device{}
    @editable SecondFarmTrigger : trigger_device = trigger_device{}
    @editable ThirdFarmTrigger : trigger_device = trigger_device{}


    StringToMessage<localizes>(value:string) : message = "{value}"         #Converst string to msg for crop sell msg

    OnBegin<override>()<suspends>:void=
        Sleep(1.0)


        #When triggers are triggered, enable correct crops
        FirstFarmTrigger.TriggeredEvent.Subscribe(EnableFirstCrops)
        SecondFarmTrigger.TriggeredEvent.Subscribe(EnableSecondCrops)
        ThirdFarmTrigger.TriggeredEvent.Subscribe(EnableThirdCrops)

        #For all crops, initialize variables and hide initial props
        for(C : FirstCrops):
            set C.GameManager = GameManager  
            set C.PickUpAudio = PickupAudio
            set C.CropXP = CropXP
            set C.CropTracker = CropTracker
            set C.CropResource = CropResource
            C.CropReadyProp.Hide()
            C.CropProp.Hide()

        for(C : SecondCrops):
            set C.GameManager = GameManager
            set C.PickUpAudio = PickupAudio
            set C.CropXP = CropXP
            set C.CropTracker = CropTracker
            set C.CropResource = CropResource
            C.CropReadyProp.Hide()
            C.CropProp.Hide()

        for(C : ThirdCrops):
            set C.GameManager = GameManager
            set C.PickUpAudio = PickupAudio
            set C.CropXP = CropXP
            set C.CropTracker = CropTracker
            set C.CropResource = CropResource
            C.CropReadyProp.Hide()
            C.CropProp.Hide()


  

    #Enable respective crops
    EnableFirstCrops(Agent: ?agent) : void=    
        for(C : FirstCrops):
            spawn:
                C.EnableCrop()
    EnableSecondCrops(Agent: ?agent) : void=
        for(C : SecondCrops):
            spawn:
                C.EnableCrop()
    EnableThirdCrops(Agent: ?agent) : void=
        for(C : ThirdCrops):
            spawn:
                C.EnableCrop()

    #Resets All Crops
    ResetAllCrops() : void=
        for(C : FirstCrops):
            C.CropReadyProp.Hide()
            C.CropProp.Hide()
            C.CropMutator.Disable()
        for(C : SecondCrops):
            C.CropReadyProp.Hide()
            C.CropProp.Hide()
            C.CropMutator.Disable()
        for(C : ThirdCrops):
            C.CropReadyProp.Hide()
            C.CropProp.Hide()
            C.CropMutator.Disable()



