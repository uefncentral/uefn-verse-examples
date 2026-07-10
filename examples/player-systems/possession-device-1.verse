# Player Possession System
# Manages dynamic player possession and spawning using participant IDs. Allows players to interact with buttons or spawn points to possess different entities, with automatic state management and player 
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/possession-device-1?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Simulation/Tags }

using { Tableau }
using { TableauParticipant }

possession_tag := class(tag){}
possession_device<public> := class(creative_device, updatable):

    # Entity State Management
    @editable ParticipantID:int = 0
    var CurrentAgent:?agent = false
    var AgentRepository:?agent_repository = false

    # Device Properties
    @editable PlayerRef:player_reference_device = player_reference_device{}
    @editable Button:button_device = button_device{}
    @editable PlayerSpawner:?player_spawner_device = false

    # Commands
    PossessCommand<public>:event(tuple(agent, int)) = event(tuple(agent, int)){}

    Subscriptions<override>()<transacts>:[]event_subscription = array:
        event_subscription:
            Entity := entity_participant{}
            EntityID := option. ParticipantID
    ClearState<override>():void= {}
    Update<override>()<suspends>:void=
        # Animate between current and new state
        if:
            NewAgent := AgentRepository?.GetAgent[ParticipantID]?
        then:
            PlayerRef.Register(NewAgent)
            set CurrentAgent = option. NewAgent
        else:
            PlayerRef.Clear()
            set CurrentAgent = false

    OnBegin<override>()<suspends>:void=
        if (Spawner := PlayerSpawner?):
            Agent := Spawner.SpawnedEvent.Await()
            PossessCommand.Signal(Agent, ParticipantID)

    Command_Possess()<suspends>:void=
        Agent := Button.InteractedWithEvent.Await()
        PossessCommand.Signal(Agent, ParticipantID)

    Initialize<public>(
        Repository:agent_repository
    )<suspends>:void=
        set AgentRepository = option. Repository
        spawn. FreshUpdate()

        # Events to Commands
        loop:
            # sync:
                Command_Possess()

LoadPossessionDevices<public>():[]possession_device=
    TaggedDevices := GetCreativeObjectsWithTag(possession_tag{})
    for(Index -> Tagged : TaggedDevices, Device := possession_device[Tagged]). Device
