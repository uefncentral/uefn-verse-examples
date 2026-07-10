# Team-Based Nuke Purchase
# Creates a purchasable nuke system where players can buy and activate explosive attacks against hostile teams. When activated, it triggers team-specific explosives and displays elimination feed notific
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/nuke-device-1?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/Teams }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

nuke_device := class(creative_device):
    @editable
    purchase_button: conditional_button_device = conditional_button_device {}

    @editable
    killfeed: elimination_feed_device = elimination_feed_device {}

    @editable
    explosive_kills_red: explosive_device = explosive_device {}

    @editable
    explosive_kills_blue: explosive_device = explosive_device {}

    OnBegin<override>()<suspends>: void =
        purchase_button.ActivatedEvent.Subscribe(OnPurchase);

    OnPurchase(Agent: agent): void =
        Print("Agent NUKED!");
        killfeed.Activate(Agent);

        TeamColl := GetPlayspace().GetTeamCollection();
        if:
            OurTeam := TeamColl.GetTeam[Agent]
            AllTeams := TeamColl.GetTeams()
        then:
            for (TeamNum->Team: AllTeams):
                if (Team = OurTeam) { Print("Found our team ({TeamNum})") }
                else:
                    Print("Found a team that isnt ours");
                    Print("Team: {TeamNum}");

                    if:
                        Agents := TeamColl.GetAgents[Team]
                        Attitude := TeamColl.GetTeamAttitude[Team, OurTeam]
                        Attitude = team_attitude.Hostile
                    then:
                        Print("Team {TeamNum} is hostile");
                        if (TeamNum = 0):
                            explosive_kills_blue.Explode(Agent);
                        else:
                            explosive_kills_red.Explode(Agent);
                    else:
                        Print("attitude isnt hostile or agents check failed");
        else:
            Print("failed to get own team or all teams");