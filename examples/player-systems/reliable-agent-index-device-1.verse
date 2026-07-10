# Player Taxi Assignment System
# This device assigns each player a persistent index that corresponds to a specific taxi spawner. When players join or leave the game, the system dynamically manages taxi assignments to ensure each play
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/reliable-agent-index-device-1?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

reliable_agent_index_device := class(creative_device):

    @editable
    TaxiSpawnersPerPlayer : []vehicle_spawner_taxi_device = array{}

    @editable
    MaxPlayers : int = 10

    var ReliableAgentIndex : [agent]int = map{}
    var UnusedAgentIndexes : []int = array{}

    OnBegin<override>()<suspends>:void=
        Print("OnBegin")

        for (I := 0 .. MaxPlayers-1):
            set UnusedAgentIndexes += array{I}

        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerJoined)
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerLeft)

    PutAgentBackInTheirTaxi(Agent : agent):void=
        if (ReliableIndex := ReliableAgentIndex[Agent],
        TaxiOfAgent := TaxiSpawnersPerPlayer[ReliableIndex]):

    OnPlayerJoined(Player : player):void=
        if (AvailableAgentIndex := UnusedAgentIndexes[0]):
            if (NewUnusedAgentIndexes := UnusedAgentIndexes.RemoveElement[0]):
                set UnusedAgentIndexes = NewUnusedAgentIndexes
            if (set ReliableAgentIndex[Player] = AvailableAgentIndex){}

    OnPlayerLeft(Player : player):void=
        if (Index := ReliableAgentIndex[Player]):
            set UnusedAgentIndexes += array{Index}