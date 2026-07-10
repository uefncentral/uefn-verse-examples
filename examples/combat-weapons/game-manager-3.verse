# Game Manager 3
# Verse code for Game Manager 3 - UEFN/Fortnite Creative implementation
# Difficulty: intermediate  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/game-manager-3?ref=github

using { /Fortnite.com/Devices }          
using { /Fortnite.com/Characters }       
using { /Fortnite.com/Game }             
using { /Verse.org/Simulation }         
using { /Verse.org/Colors/NamedColors }  

Guns : int = 40 # <- Change this to the number of guns!

(Granter:item_granter_device).GetLength():int=
    return Guns

gun_game_device := class(creative_device):

    @editable
    AllWeapons : item_granter_device = item_granter_device{}                                   

    @editable
    EndGame : end_game_device = end_game_device{}                                                                                       

    var ElimsToWin : int = 0                                                                    

    var PlayerProgress : [player]int = map{}
    
    OnPlayerAdded(Player:player):void=

        if(FC:= Player.GetFortCharacter[]):
            if:
                set PlayerProgress[Player] = 0

                WeaponIndex := PlayerProgress[Player]
            then:
                FC.EliminatedEvent().Subscribe(HandlePlayerEliminated)
                AllWeapons.SetNextItem(WeaponIndex)
                AllWeapons.GrantItem(Player)
                                                            
                                                                                                    
    OnBegin<override>()<suspends>:void=
        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerAdded)
    
        set ElimsToWin = AllWeapons.GetLength()                                                 

        AllPlayers := GetPlayspace().GetPlayers()                                               

        for(Player:AllPlayers, FortCharacter:= Player.GetFortCharacter[]):

            if:
                set PlayerProgress[Player] = 0

                WeaponIndex := PlayerProgress[Player]
            then:                                                                                            
                FortCharacter.EliminatedEvent().Subscribe(HandlePlayerEliminated)     
                AllWeapons.SetNextItem(WeaponIndex)              
                AllWeapons.GrantItem(Player)


    HandlePlayerEliminated(Result:elimination_result):void=
        
        KilledCharacter := Result.EliminatedCharacter

        if:                                                                    
            KilledAgent := KilledCharacter.GetAgent[]

            KillerChar := Result.EliminatingCharacter?

            KillerAgent := KillerChar.GetAgent[]

            KillerPlayer := player[KillerAgent]   

            WeaponIndex := PlayerProgress[KillerAgent]                                         
        then:

            if(KillerAgent <> KilledAgent):                                                     
                NextWeaponIndex := WeaponIndex + 1                                                                               
                if(NextWeaponIndex >= ElimsToWin):                       
                    EndGame.Activate(KillerAgent)                                               
                if:
                    set PlayerProgress[KillerPlayer] = NextWeaponIndex                          
                then:
                    AllWeapons.SetNextItem(NextWeaponIndex)                                         
                    AllWeapons.GrantItem(KillerPlayer)
                                                                                                                                    