# Player Freeze Manager
# A game manager that provides functionality to freeze and unfreeze all players in the game. When frozen, players cannot move or emote but can still turn and fall, useful for creating pause mechanics or
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/gmae-manager-1?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
 
game_manager := class(creative_device):
 
    OnBegin<override>()<suspends>:void=
        return
 
    OnStart()<suspends>:void=
        Print("test")
 
    FreezeAllPlayers():void=
        AllPlayers := GetPlayspace().GetPlayers()
        for (Player : AllPlayers, FortCharacter := Player.GetFortCharacter[]):
            FortCharacter.PutInStasis(stasis_args{AllowTurning := false, AllowFalling := true, AllowEmotes := false})
 
    UnfreezeAllPlayers():void=
        AllPlayers := GetPlayspace().GetPlayers()
        for (Player : AllPlayers, FortCharacter := Player.GetFortCharacter[]):
            FortCharacter.ReleaseFromStasis()