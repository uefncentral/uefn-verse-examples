# Infinite Sprint Changer
# Verse code for Infinite Sprint Changer - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/infinite-sprint-changer?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }

InfiniteSprintChanger := class(creative_device):

    @editable
    PlayerSpawners : []player_spawner_device = array{}

    @editable
    ToggleSwitch : switch_device = switch_device{}

    @editable
    SprintClass : class_and_team_selector_device = class_and_team_selector_device{}

    @editable
    NoClassSelector : class_and_team_selector_device = class_and_team_selector_device{}

    OnBegin<override>()<suspends>:void=
        ToggleSwitch.TurnedOnEvent.Subscribe(OnSwitchTurnedOn)
        ToggleSwitch.TurnedOffEvent.Subscribe(OnSwitchTurnedOff)
        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerJoined)
        for (Spawner : PlayerSpawners):
            Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)
        AssignClassToAllPlayers()

    OnSwitchTurnedOn(Agent : agent) : void =
        AssignClassToAllPlayers()

    OnSwitchTurnedOff(Agent : agent) : void =
        AssignNoClassToAllPlayers()

    OnPlayerJoined(Player : player) : void =
        if (ToggleSwitch.GetCurrentState[]):
            SprintClass.ChangeClass(Player)
        else:
            NoClassSelector.ChangeClass(Player)

    OnPlayerSpawned(Agent : agent) : void =
        if (ToggleSwitch.GetCurrentState[]):
            SprintClass.ChangeClass(Agent)
        else:
            NoClassSelector.ChangeClass(Agent)

    AssignClassToAllPlayers() : void =
        for (Player : GetPlayspace().GetPlayers()):
            SprintClass.ChangeClass(Player)

    AssignNoClassToAllPlayers() : void =
        for (Player : GetPlayspace().GetPlayers()):
            NoClassSelector.ChangeClass(Player)