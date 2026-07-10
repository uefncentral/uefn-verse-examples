# Resource Converter System
# A UEFN system that allows players to convert one set of resources into another by spending required materials and gaining new ones. Players interact with a button to trigger the conversion, receiving 
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/convert-manager-1?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

#THIS DEVICE CONVERTS ONE OR MORE RESOURCES TO ANOTHER

Resource := class<concrete>():
    @editable Type : string = ""
    @editable Amount : float = 0.0

Converter := class<concrete>():
    var GameManager : Game_Manager = Game_Manager{}                             #Game manager to get player info
    
    var FailureHUD : hud_message_device = hud_message_device{}                  #Convert failure msg   

    var ConvertXP : accolades_device = accolades_device{}                       #XP granted upon conversion

    @editable SuccessHUD : hud_message_device = hud_message_device{}            #Sell success msg

    @editable ConverterButton : button_device = button_device{}                 #Button to convert

    @editable CostResources : []Resource = array{}                              #Resources that are spent

    @editable GainResources : []Resource = array{}                              #Resources that are gained

    StringToMessage<localizes>(value:string) : message = "{value}"              #Converst string to msg for crop sell msg

    #Converts resources
    TryConversion(Agent:agent) : void=
        if(CP := GameManager.PlayersMap[Agent]):

            #Makes an array of all cost resources that were spent successfully
            var SuccessfulPurchases : []int = array{}
            for(idx -> Re : CostResources):
                SpendResult := CP.Spend(Re.Amount,Re.Type)
                if(SpendResult?):
                    set SuccessfulPurchases += array{idx}

            #Checks if all cost resources were complete
            if(SuccessfulPurchases.Length = CostResources.Length):
                ConvertXP.Award(Agent)
                SuccessHUD.Show(Agent)                                              
                for(Re : GainResources):   
                    CP.Collect(Re.Amount,Re.Type) 
       

            #If they were not all complete, refunds the resources that were                        
            else:
                FailureHUD.Show(Agent)
                for(S : SuccessfulPurchases):
                    if(RefundResource := CostResources[S]):
                        CP.Collect(RefundResource.Amount,RefundResource.Type)                      
            



Convert_Manager := class(creative_device):
    @editable GameManager : Game_Manager = Game_Manager{}                       #Game Manager to get player info

    @editable Converters : []Converter = array{}                               #Array of converters

    @editable FailureHUD : hud_message_device = hud_message_device{}            #Sell failure msg

    @editable ConvertXP : accolades_device = accolades_device{}                 #XP granted upon conversion


    OnBegin<override>()<suspends>:void=
        
        #Initiliazes converters
        for(Convert : Converters):                                              
            set Convert.GameManager = GameManager
            set Convert.FailureHUD = FailureHUD
            set Convert.ConvertXP = ConvertXP
            Convert.ConverterButton.InteractedWithEvent.Subscribe(Convert.TryConversion)        #Activates when button is pressed