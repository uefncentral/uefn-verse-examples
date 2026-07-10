# Double Pump System
# Implements a double pump shotgun mechanic by automatically removing and re-granting items when players switch weapons. This allows for faster firing rates by bypassing normal pump shotgun reload delay
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/dablapumuuuuuuuuuuuuuuuu?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }

DoublePump := class(creative_device):
    
   


    @editable DoublePumpConditional : conditional_button_device = conditional_button_device{}
    @editable DoublePumpPlayerMarker:player_marker_device = player_marker_device{}                  
    @editable DoublePumpItemGranter:item_granter_device = item_granter_device{}                     
    @editable DoublePumpItemRemover:item_remover_device = item_remover_device{}                    

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        Sleep(3.0)
        DoublePumpPlayerMarker.DetachFromAll()
        for (Player : GetPlayspace().GetPlayers()):
            if(FC := Player.GetFortCharacter[], Agent := FC.GetAgent[]):
                
                
                    spawn:
                        DoublePumpPlayer(Agent)
    DoublePumpPlayer(Agent:agent)<suspends> : void =
        DoublePumpPlayerMarker.Attach(Agent) 
         
        DoublePumpPlayerMarker.FirstItemValueChangedEvent.Subscribe(OnItemChanged)  
            
    OnItemChanged(Agent : agent):void=
        # if(DoublePumpConditional.IsHoldingItem[Agent]):
            RemoveAndGive(Agent)
    RemoveAndGive(Agent:agent) : void=
        # DoublePumpPlayerMarker.Attach(Agent)
        DoublePumpItemRemover.Remove(Agent)                                               
        DoublePumpItemGranter.GrantItem(Agent)                                            
    