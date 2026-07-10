# Agent Participant Repository
# A bidirectional mapping system that manages relationships between game agents and participant IDs. It provides methods to update, clear, and retrieve associations between agents and their correspondin
# Difficulty: beginner  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/agent-repository-1?ref=github

using { /Verse.org/Simulation }

# TODO: Address things Knight Breaker noticed:
#  * shouldn't ClearAgent also clear the the agent to participent map?
#  * GetAgent and GetParticipent are both decides even though they cannot fail, the failure is expressed through the optional type in this case
agent_repository<public> := class<concrete>():
    var AgentToParticipant:[agent]?int = map{}
    var ParticipantToAgent:[int]?agent = map{}

    UpdateAgent<public>(Agent:agent, ParticipantID:int):void=
        if (set AgentToParticipant[Agent] = option. ParticipantID) {}
        if (set ParticipantToAgent[ParticipantID] = option. Agent) {}

    ClearAgent<public>(ParticipantID:int):void=
        if (set ParticipantToAgent[ParticipantID] = false) {}

    GetAgent<public>(ID:int)<decides><transacts>:?agent=
        if(Agent := ParticipantToAgent[ID]?). option. Agent else. false

    GetParticipant<public>(Agent:agent)<decides><transacts>:?int=
        if(ParticipantID := AgentToParticipant[Agent]?). option. ParticipantID else. false
