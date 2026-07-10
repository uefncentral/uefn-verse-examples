# AFK Resource Collection Zone
# Creates a designated AFK zone where players automatically collect resources while idle. When players enter the zone, a cinematic plays and HUD message appears, then resources are continuously gathered
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/afk-manager?ref=github




using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

#THIS SCRIPT COLLECTS RESOURCES FOR A PLAYER WHEN IN A SPECIFIED ZONE

AFK_Manager := class(creative_device):
    #Base Stuff
    @editable GameManager : Game_Manager = Game_Manager{}  
    var LeftEvent : event(agent) = event(agent){}
    
    
    #Devices
    @editable AFKCin : cinematic_sequence_device = cinematic_sequence_device{}
    @editable AFKMutator : mutator_zone_device = mutator_zone_device{}            
    @editable AFKHUD : hud_message_device = hud_message_device{}     

    #Settings
    @editable AFKCollectionSettings : AFKCollectionSetting = AFKCollectionSetting{}
    @editable AFKPopUpSettings : PopUpAnimationSetting = PopUpAnimationSetting{}

    
    
    OnBegin<override>()<suspends>:void=
        #Activates different actions based on mutator events
        AFKMutator.AgentEntersEvent.Subscribe(OnEntered)     
        AFKMutator.AgentExitsEvent.Subscribe(OnExit)     
        AFKMutator.AgentBeginsEmotingEvent.Subscribe(StartDance)     
        AFKMutator.AgentEndsEmotingEvent.Subscribe(StopDance)        

    #Handles when a player enters zone
    OnEntered(Agent:agent) : void=      
        AFKCin.Play(Agent)       
        AFKHUD.Show(Agent)       
        spawn{Activate(Agent)}

    #Handles when a player exits zone
    OnExit(Agent:agent ) : void=     
        AFKCin.Stop(Agent)      
        AFKHUD.Hide()            
        LeftEvent.Signal(Agent)

    #Loop that collects resources for the player while in zone
    Activate(Agent:agent)<suspends> : void=
        if(CP := GameManager.PlayersMap[Agent]):
            race:
                #Waits for the player to leave the mutator and ends loop
                block:
                    loop:
                        LeavingPlayer := LeftEvent.Await()
                        if(LeavingPlayer = Agent):
                            for(Re : AFKCollectionSettings.CollectionResources):
                                if(Re.CollectionType = AFKCollectionType.ResourceBoost):
                                    CP.RemoveBoost(array{Re})
                            set CP.IsBoosted = false
                            break

                #Main loop for collection resources
                loop:
                    #Collects resources / boosts resources when player is dancing
                    if(AFKCollectionSettings.RequiresDance?):
                        if(CP.IsDancing?):
                            for(Re : AFKCollectionSettings.CollectionResources):
                                if(Re.CollectionType = AFKCollectionType.ResourceBoost , not CP.IsBoosted?):
                                    CP.Boost(array{Re})
                                    set CP.IsBoosted=true

                                else if(Re.CollectionType = AFKCollectionType.ResourceCollect):
                                    if(Re.CollectIdleAmountInstead?):
                                        CP.Collect(array{ATMResource{ResourceName := Re.ResourceName, AutoCollect := true}})
                                        if(AFKPopUpSettings.Enabled?):
                                            if(DisplayResource := AFKCollectionSettings.CollectionResources[AFKPopUpSettings.ResourceIDX]):
                                                for(Res : CP.Resources):
                                                    if(DisplayResource.ResourceName = Res.ResourceName):
                                                        NewAmount := Res.ResourceIdleAmount
                                                        set CP.PopUp.PopUpAnimationSettings = AFKPopUpSettings
                                                        set CP.PopUp.Amount = NewAmount
                                                        spawn{CP.PopUp.DisplayPopUp(Agent)}
                                    else:
                                        CP.Collect(array{GainableResource{ResourceName := Re.ResourceName , Amount := Re.Amount, EffectIdleAmount := false }})
                                        if(AFKPopUpSettings.Enabled?):
                                            if(DisplayResource := AFKCollectionSettings.CollectionResources[AFKPopUpSettings.ResourceIDX], NewAmount := DisplayResource.Amount ):
                                                set CP.PopUp.PopUpAnimationSettings = AFKPopUpSettings
                                                set CP.PopUp.Amount = NewAmount
                                                spawn{CP.PopUp.DisplayPopUp(Agent)}
            
                    #Collects resources / boosts resources when player is in zone
                    else:
                        for(Re : AFKCollectionSettings.CollectionResources):
                            if(Re.CollectionType = AFKCollectionType.ResourceBoost , not CP.IsBoosted?):
                                CP.Boost(array{Re})
                                set CP.IsBoosted=true

                            else if(Re.CollectionType = AFKCollectionType.ResourceCollect):
                                if(Re.CollectIdleAmountInstead?):
                                    CP.Collect(array{ATMResource{ResourceName := Re.ResourceName, AutoCollect := true}})
                                    if(AFKPopUpSettings.Enabled?):
                                        if(DisplayResource := AFKCollectionSettings.CollectionResources[AFKPopUpSettings.ResourceIDX]):
                                            for(Res : CP.Resources):
                                                if(DisplayResource.ResourceName = Res.ResourceName):
                                                    NewAmount := Res.ResourceIdleAmount
                                                    set CP.PopUp.PopUpAnimationSettings = AFKPopUpSettings
                                                    set CP.PopUp.Amount = NewAmount
                                                    spawn{CP.PopUp.DisplayPopUp(Agent)}
                                else:
                                    CP.Collect(array{GainableResource{ResourceName := Re.ResourceName , Amount := Re.Amount, EffectIdleAmount := false }})
                                    if(AFKPopUpSettings.Enabled?):
                                        if(DisplayResource := AFKCollectionSettings.CollectionResources[AFKPopUpSettings.ResourceIDX], NewAmount := DisplayResource.Amount):
                                            set CP.PopUp.PopUpAnimationSettings = AFKPopUpSettings
                                            set CP.PopUp.Amount = NewAmount
                                            spawn{CP.PopUp.DisplayPopUp(Agent)}

                    #waits specified amount between resource awards
                    Sleep(AFKCollectionSettings.CollectionTime)

    #Activates when the player begins dancing
    StartDance(Agent:agent) : void=     
        if(CP := GameManager.PlayersMap[Agent]):
            if(CP.IsDancing = false){set CP.IsDancing = true}      
            
    #Activates when the player stops dancing
    StopDance(Agent:agent) : void=      
        if(CP := GameManager.PlayersMap[Agent]):
            if(CP.IsDancing = true){set CP.IsDancing = false}         
            
#Settings that control what/how resources are collected
AFKCollectionSetting:= class<concrete>():
    @editable RequiresDance : logic = false
    @editable CollectionResources : []AFKResource = array{}
    @editable CollectionTime : float = 0.0

#Resource that is collected
AFKResource := class<concrete>(BaseResource):
    @editable CollectionType : AFKCollectionType = AFKCollectionType.ResourceBoost
    @editable Amount : float = 0.0
    @editable CollectIdleAmountInstead : logic = false
    
#Different collection types
AFKCollectionType := enum:
    ResourceBoost
    ResourceCollect