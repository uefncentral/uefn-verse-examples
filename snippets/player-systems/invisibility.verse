# Class-Based Player Invisibility
# This system grants invisibility abilities to players of a specific class when they spawn. Players become invisible when holding a designated item/card and become visible again when not holding it.  **
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/invisibility?ref=github

using {/Fortnite.com/Devices}
using {/Fortnite.com/UI}
using {/Fortnite.com/Game}
using {/Fortnite.com/Characters}
using {/Fortnite.com/Playspaces}
using {/Verse.org/Simulation}
using {/Verse.org/Random}
using {/UnrealEngine.com/Temporary/Diagnostics}
using {/UnrealEngine.com/Temporary/UI}
using {/UnrealEngine.com/Temporary/SpatialMath}

Invisibility := class(creative_device):

    @editable var Class : int = 0
    @editable ClassTracker : tracker_device = tracker_device{}
    @editable HUDablity : hud_message_device = hud_message_device{}

    @editable CardDetector:conditional_button_device = conditional_button_device{}
    @editable ItemGranter:item_granter_device = item_granter_device{}

    OnBegin<override>()<suspends>:void=
        InitSpawners()

    InitSpawners() : void=
        Spawners := GetCreativeObjectsWithTag(spawner{})
        for (Obj : Spawners):
            if (Spawner := player_spawner_device[Obj]):
                Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)
            
    OnPlayerSpawned(Agent : agent): void=
        if (Player := player[Agent]):
            spawn{CheckClass(Agent)}

    CheckClass(Agent : agent)<suspends>:void=
        Sleep(1.0)
        if(ClassTracker.GetValue(Agent) = Class):
            HUDablity.Show(Agent)
            ItemGranter.GrantItem(Agent)
            spawn:
                CheckForCard()

    CheckForCard()<suspends>:void=
        Sleep(1.0)
        AllPlayers:=GetPlayspace().GetPlayers()
            for(Player:AllPlayers):
                if(IsAgent:agent = agent[Player]):
                    if(ClassTracker.GetValue(IsAgent) = Class):
                        loop:
                            Sleep(0.5)
                            if(CardDetector.IsHoldingItem[IsAgent]):
                                HidePlayer(IsAgent)
                            else:
                                ShowPlayer(IsAgent)
 
    ShowPlayer(Agent:agent):void=
        if(FC:=Agent.GetFortCharacter[]):
            FC.Show()
    HidePlayer(Agent:agent):void=
        if(FC:=Agent.GetFortCharacter[]):
            FC.Hide()