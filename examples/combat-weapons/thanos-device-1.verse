# Thanos Snap Device
# Creates a purchasable button that simulates Thanos's snap by removing all items from hostile enemy team members when activated. The device identifies the activating player's team and targets only host
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/thanos-device-1?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/Teams }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

thanos_device := class(creative_device):
    @editable
    purchase_button: conditional_button_device = conditional_button_device {}

    @editable
    remover: item_remover_device = item_remover_device {}

    @editable
    killfeed: elimination_feed_device = elimination_feed_device {}

    OnBegin<override>()<suspends>: void =
        purchase_button.ActivatedEvent.Subscribe(OnPurchase);

    OnPurchase(Agent: agent): void =
        Print("Agent THANOS SNAPPED!");
        killfeed.Activate(Agent);

        TeamColl := GetPlayspace().GetTeamCollection();
        if:
            OurTeam := TeamColl.GetTeam[Agent]
            AllTeams := TeamColl.GetTeams()
        then:
            for (Team: AllTeams):
                if (Team = OurTeam) { Print("Found our team"); }
                else:
                    Print("Found a team that isnt ours");

                    if:
                        Agents := TeamColl.GetAgents[Team]
                        Attitude := TeamColl.GetTeamAttitude[Team, OurTeam]
                        Attitude = team_attitude.Hostile
                    then:
                        for (AgentInTeam: Agents):
                            Print("Agent in team!!");
                            remover.Remove(AgentInTeam);
                    else:
                        Print("attitude isnt hostile or agents check failed");
        else:
            Print("failed to get own team or all teams");