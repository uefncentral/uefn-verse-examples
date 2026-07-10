# Double Pump 2
# Verse code for Double Pump 2 - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/double-pump-2-1?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

Double_Pump := class(creative_device):

    @editable
    PlayerMarker:player_marker_device = player_marker_device{}                  #Tracks the selected weapon when you shoot

    @editable
    ItemGranter:item_granter_device = item_granter_device{}                     #Grants the item you have selected in the device

    @editable
    ItemRemover:item_remover_device = item_remover_device{}                     #Removes the weapon you have selected in the device

    @editable
    PlayerSpawners:[]player_spawner_device = array{}                            #An array of PlayerSpawners for attaching PlayerMarker to multiple people

    OnBegin<override>()<suspends>:void=
        for(PlayerSpawner:PlayerSpawners):
            PlayerSpawner.SpawnedEvent.Subscribe(OnPlayerSpawned)               #Subscribe to the SpawnedEvent on the PlayerSpawners
            PlayerMarker.FirstItemValueChangedEvent.Subscribe(OnItemChanged)    #Subsctibe to the FirstItemValueChangedEvent on the PlayerMarker
        
    OnItemChanged(Agent : agent):void=
        ItemRemover.Remove(Agent)                                               #Remove the weapon from inventory of the Agent
        ItemGranter.GrantItem(Agent)                                            #Grant the weapon to inventory of the Agent

    OnPlayerSpawned(Agent : agent):void=
        PlayerMarker.Attach(Agent)                                              #Attach the PlayerMarker on OnPlayerSpawned