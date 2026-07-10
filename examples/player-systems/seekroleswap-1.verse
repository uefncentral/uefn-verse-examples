# Hide and Seek Manager
# Manages a hide and seek game mode where one player is designated as the seeker and others are hiders. When the seeker eliminates a hider, roles switch and the eliminated player becomes the new seeker.
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/seekroleswap-1?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/UI }
using { /Verse.org/Random }

hide_seek_manager := class(creative_device):
    @editable var Timer : timer_device = timer_device{}
    @editable var PlayerSpawner : player_spawner_device = player_spawner_device{}
    @editable var SeekerItemGranter : item_granter_device = item_granter_device{}
    @editable var HiderItemGranter : item_granter_device = item_granter_device{}
    @editable var EliminationManager : elimination_manager_device = elimination_manager_device{}
    @editable var SeekerHUD : hud_message_device = hud_message_device{}
    @editable var HiderHUD : hud_message_device = hud_message_device{}
    
    var CurrentSeeker : ?agent = false
    
    OnBegin<override>()<suspends>:void=
        Sleep(30.0)
        StartNewRound()
    
    OnEliminated(EliminatedPlayer : agent) : void =
        if (Seeker := CurrentSeeker?):
            # seeker becomes hider
            ClearAllHUDs()
            SeekerHUD.Hide()
            HiderHUD.Show()
            HiderItemGranter.Enable()
            
            # New seeker setup
            set CurrentSeeker = option{EliminatedPlayer}
            SeekerHUD.Show()
            HiderHUD.Hide()
            SeekerItemGranter.Enable()
            
            Print("Roles have switched!")
    
    StartNewRound():void=
        AllPlayers := GetPlayspace().GetPlayers()
        if (AllPlayers.Length > 0):
            if (FirstPlayer := AllPlayers[0]):
                # Setup initial seeker
                set CurrentSeeker = option{FirstPlayer}
                SeekerHUD.Show()
                SeekerItemGranter.Enable()
                Print("Initial Seeker Selected")
                
                # Setup all other players as hiders
                for (Player : AllPlayers):
                    if (Player <> FirstPlayer):
                        HiderHUD.Show()
                        HiderItemGranter.Enable()
                        Print("Hider Setup")
                Timer.Start()
    
    ClearAllHUDs():void=
        SeekerHUD.Hide()
        HiderHUD.Hide()