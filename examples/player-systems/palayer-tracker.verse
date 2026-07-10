# Player Counter HUD Display
# Tracks and displays the number of players remaining alive in the game through a HUD message. Updates the counter in real-time when players are eliminated or join/leave the match.  **How to use:** Add 
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/palayer-tracker?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

player_counter_hud_message_device := class(creative_device):

    # Tracks the number of players alive in the game
    var PlayersInGame : int = 0

    # You can write in the string you want displayed in the hud message device
    @editable
    PlayersLeftString : string = "Players Left: "

    # This function creates the message from the string provided and the number of players in the game
    PlayerCounterMessage<localizes>(String : string, N : int) : message = "{String}{N}"

    # This is the hud message device linked to this code - it should be set to Message Recipent: ALL
    @editable
    HudDevice : hud_message_device = hud_message_device{}

    # This is be the elimination mangager tied to whenever a player is eliminated
    @editable
    EliminationManager : elimination_manager_device = elimination_manager_device{}

    @editable 
    TeamSettings : team_settings_and_inventory_device = team_settings_and_inventory_device{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=

        Sleep(1.0)

    CheckPlayers(Agent:agent):void=

        # At game start we increase the player counter by 1 for every player in game
        for(AllPlayers : GetPlayspace().GetPlayers()):
            if (TeamSettings.IsOnTeam[Agent]){
                IncreasePlayerCounter(Agent)
            }

        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerAdded)
        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerRemoved)
        EliminationManager.EliminatedEvent.Subscribe(OnPlayerEliminated)

        # Update the hud message device's text and show it
        HudDevice.SetText(PlayerCounterMessage(PlayersLeftString, PlayersInGame))
        HudDevice.Show()

    # Increase player counter and update the hud message device
    IncreasePlayerCounter(Agent:agent) : void =
        if (TeamSettings.IsOnTeam[Agent]){
            set PlayersInGame += 1
            HudDevice.SetText(PlayerCounterMessage(PlayersLeftString,PlayersInGame))
            HudDevice.Show()
        }

    # Decrease player counter and update the hud message device
    DecreasePlayerCounter(Agent:agent) : void =
        if (TeamSettings.IsOnTeam[Agent]){
            set PlayersInGame -=1
            HudDevice.SetText(PlayerCounterMessage(PlayersLeftString,PlayersInGame))
            HudDevice.Show()
        }

    OnPlayerAdded(Agent : agent) : void=
        IncreasePlayerCounter(Agent)

    OnPlayerRemoved(Agent : agent) : void=
        DecreasePlayerCounter(Agent)

    OnPlayerEliminated(Agent : agent) : void=
        DecreasePlayerCounter(Agent)