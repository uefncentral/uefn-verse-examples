# Game Manager 4
# Verse code for Game Manager 4 - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/game-manager-4?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Colors/NamedColors }

#This Code is a Game/Player Manager for a Tycoon Game Mode

Custom_Player := class<unique>(): #custom player class that holds the players values

    Player : player
    var MyUI : canvas = canvas{}
    PlayerStatManager : player_stats_manager = player_stats_manager{}

    #Bought Items Saved For Persistence
    var BoughtDoors : []int = array {}
    var BoughtPets : []int = array {}
    var BoughtApparels : []int = array {}


    #Currently Equipped Pet
    var EquippedPet : int = 999
    var EquippedApparels : []int = array{0,0,0}

    
    #Main player currencies

    var MoneyAmount : float = 0.0
    var IdleMoneyAmount : float = 0.0
    var MoneyText : text_block = text_block{DefaultTextColor := White,DefaultShadowOffset := option{vector2{X:=1.0,Y:=1.0}},DefaultShadowColor := Black}
    var IdleMoneyText : text_block = text_block{DefaultTextColor := White,DefaultShadowOffset := option{vector2{X:=1.0,Y:=1.0}},DefaultShadowColor := Black}

    var Resource2Amount : float = 0.0
    var IdleResource2Amount : float = 0.0
    var Resource2Text : text_block = text_block{DefaultTextColor := White,DefaultShadowOffset := option{vector2{X:=1.0,Y:=1.0}},DefaultShadowColor := Black}
    var IdleResource2Text : text_block = text_block{DefaultTextColor := White,DefaultShadowOffset := option{vector2{X:=1.0,Y:=1.0}},DefaultShadowColor := Black}

        
    var RebirthAmount : float = 0.0         
    var RebirthBoostAmount : float = 0.1        #CHANGE THIS TO ALTER HOW MUCH REBIRTHS BOOST THE PLAYERS MONEY BY        

    #Boost Amounts
    var CurrentMoneyBoost : float = 1.0
    var CurrentResource2Boost : float = 1.0


    
    #Toggleables
    var MusicPlaying : logic = true      #Is music playing



    InitiateUI(): void=     #Initalizes and adds the players UI
        if(PlayerObj := Player, PlayerUI := GetPlayerUI[PlayerObj]):
            set MyUI = CreateMyUI()
            PlayerUI.AddWidget(MyUI)
        MoneyText.SetShadowOpacity(1.0)
        IdleMoneyText.SetShadowOpacity(1.0)
        Resource2Text.SetShadowOpacity(1.0)
        IdleResource2Text.SetShadowOpacity(1.0)
        UpdateUI()

            
    UpdateUI(): void=        #Updates the players UI to new values
        NewIdleMoneyAmount := IdleMoneyAmount * (CurrentMoneyBoost + (RebirthAmount * RebirthBoostAmount))
        NewIdleResource2Amount := IdleResource2Amount * CurrentResource2Boost

        MoneyText.SetText(NewMessage(MoneyAmount))
        IdleMoneyText.SetText(NewMessageSec(NewIdleMoneyAmount))
        Resource2Text.SetText(NewMessage(Resource2Amount))
        IdleResource2Text.SetText(NewMessageSec(NewIdleResource2Amount))


    Collect(Amount : float, ResourceType: string): void=   #Increases a players resource amount by a specific value
        if( ResourceType = "Money"):
            set MoneyAmount += Amount
            PlayerStatManager.RecordPlayerStat(Player, StatType.Money, ?Score := Amount)        #Add/Remove this line if you want this stat to be remembered with persistence

        else if(ResourceType = "IdleMoney"):
            set IdleMoneyAmount += Amount
            PlayerStatManager.RecordPlayerStat(Player, StatType.IdleMoney, ?Score := Amount)         #Add/Remove this line if you want this stat to be remembered with persistence

        else if(ResourceType = "Resource2"):
            set Resource2Amount += Amount
            PlayerStatManager.RecordPlayerStat(Player, StatType.Resource2, ?Score := Amount)        #Add/Remove this line if you want this stat to be remembered with persistence

        else if(ResourceType = "IdleResource2"):
            set IdleResource2Amount += Amount
            PlayerStatManager.RecordPlayerStat(Player, StatType.IdleResource2, ?Score := Amount)        #Add/Remove this line if you want this stat to be remembered with persistence
            
        else if(ResourceType = "Rebirth"):
            set RebirthAmount += Amount
            PlayerStatManager.RecordPlayerStat(Player, StatType.Rebirth, ?Score := Amount)      #Add/Remove this line if you want this stat to be remembered with persistence

        else if(ResourceType = ""):
            
        else:
            Print("Invalid Resource Name:{ResourceType}")
        UpdateUI()


    Spend(Amount: float, ResourceType: string): logic=  # Sees if player has enough of a resource to spend and removes it if they do
        if(ResourceType = "Money", MoneyAmount >= Amount):
            set MoneyAmount -= Amount
            PlayerStatManager.RecordPlayerStat(Player, StatType.Money, ?Score := -Amount)       #Add/Remove this line if you want this stat to be remembered with persistence

        else if(ResourceType = "IdleMoney", IdleMoneyAmount >= Amount):
            set IdleMoneyAmount -= Amount
            PlayerStatManager.RecordPlayerStat(Player, StatType.IdleMoney, ?Score := -Amount)       #Add/Remove this line if you want this stat to be remembered with persistence

        else if(ResourceType = "Resource2", Resource2Amount >= Amount):
            set Resource2Amount -= Amount
            PlayerStatManager.RecordPlayerStat(Player, StatType.Resource2, ?Score := -Amount)       #Add/Remove this line if you want this stat to be remembered with persistence

        else if(ResourceType = "IdleResource2", IdleResource2Amount >= Amount):
            set IdleResource2Amount -= Amount
            PlayerStatManager.RecordPlayerStat(Player, StatType.IdleResource2, ?Score := -Amount)       #Add/Remove this line if you want this stat to be remembered with persistence

        else:
            Print("Not Enough Money")
            return false

        UpdateUI()
        return true



    Boost(Amount: float, ResourceType: string) : void=       #Adds boost multiplier for different resources
        if(ResourceType = "IdleMoney"):
            set CurrentMoneyBoost += Amount

        else if(ResourceType = "Resource2"):
            set CurrentResource2Boost += Amount
        
        else:
            Print("Invalid Boost Resource Type")
        UpdateUI()

    RemoveBoost(Amount: float, ResourceType: string) : void=     #Removes boost multiplier for different resources
        if(ResourceType = "Money"):
            set CurrentMoneyBoost -= Amount

        else if(ResourceType = "Resource2"):
            set CurrentResource2Boost -= Amount
    
        else:
            Print("Invalid Boost Resource Type")
        UpdateUI()


    RebirthPlayer() : void=    #Resets the character when rebirthed
        #add more things depending on how much you want to reset (ex. set BoughtPets = array{})

        Collect(-MoneyAmount,"Money")
        Collect(-IdleMoneyAmount,"IdleMoney")
        Collect(-Resource2Amount ,"Resource2")
        Collect(-IdleResource2Amount,"IdleResource2")


    CreateMyUI() : canvas =    #Creates the Main player UI
        MyCanvas: canvas = canvas:
            Slots := array:
                canvas_slot:   #Idle Money Resource Text
                    Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.5}, Maximum := vector2{X := 0.0, Y := 0.5}}
                    Offsets := margin{Left := 120.0, Top := 0.0, Right := 170.0, Bottom := 45.0}
                    Alignment := vector2{X := 0.0, Y := 0.5}
                    SizeToContent := false
                    Widget := IdleMoneyText 

                canvas_slot:    #Money Resource Text
                    Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.5}, Maximum := vector2{X := 0.0, Y := 0.5}}
                    Offsets := margin{Left := 120.0, Top := 90.0, Right := 700.0, Bottom := 45.0}
                    Alignment := vector2{X := 0.0, Y := 0.5}
                    SizeToContent := false
                    Widget := MoneyText

                canvas_slot:    #Resource2 Text
                    Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.5}, Maximum := vector2{X := 0.0, Y := 0.5}}
                    Offsets := margin{Left := 120.0, Top := 180.0, Right := 700.0, Bottom := 45.0}
                    Alignment := vector2{X := 0.0, Y := 0.5}
                    SizeToContent := false
                    Widget := Resource2Text

                canvas_slot:    #Idle Resource2 Text
                    Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.5}, Maximum := vector2{X := 0.0, Y := 0.5}}
                    Offsets := margin{Left := 120.0, Top := 270.0, Right := 700.0, Bottom := 45.0}
                    Alignment := vector2{X := 0.0, Y := 0.5}
                    SizeToContent := false
                    Widget := IdleResource2Text

               
                canvas_slot:  #Idle Money Resource Image
                     Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.5}, Maximum := vector2{X := 0.0, Y := 0.5}}
                     Offsets := margin{Left := 45.0, Top := 0.0, Right := 300.0, Bottom := 280.0}
                     Alignment := vector2{X := 0.0, Y := 0.5}
                     SizeToContent := false
                     Widget := texture_block:
                         DefaultImage := Icons.NewNewIdleMoney
                

                canvas_slot:   #Money Resource Image
                    Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.5}, Maximum := vector2{X := 0.0, Y := 0.5}}
                    Offsets := margin{Left := 45.0, Top := 90.0, Right := 300.0, Bottom := 280.0}
                    Alignment := vector2{X := 0.0, Y := 0.5}
                    SizeToContent := false
                    Widget := texture_block:
                        DefaultImage := Icons.NewMoney

                canvas_slot:  #Resource2 Image
                    Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.5}, Maximum := vector2{X := 0.0, Y := 0.5}}
                    Offsets := margin{Left := 45.0, Top := 180.0, Right := 300.0, Bottom := 280.0}
                    Alignment := vector2{X := 0.0, Y := 0.5}
                    SizeToContent := false
                    Widget := texture_block:
                        DefaultImage := Icons.NewBtc

                canvas_slot:  #IdleResource2 Image
                    Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.5}, Maximum := vector2{X := 0.0, Y := 0.5}}
                    Offsets := margin{Left := 45.0, Top := 270.0, Right := 300.0, Bottom := 280.0}
                    Alignment := vector2{X := 0.0, Y := 0.5}
                    SizeToContent := false
                    Widget := texture_block:
                        DefaultImage := Icons.NewNewIdleBTC
               
    NewMessage (value : float) : message =   #Rounds values for resources
        #Round if over 100k
        var newesstvalue : float = 0.0
        if(value > 100000.0 and value < 1000000.0):
            newvalue := ((value/1000.0) * 10.0)
            if(roundvalue := (Round[newvalue]* 0.1)):
                set newesstvalue = roundvalue
            return StringToMessageThou(newesstvalue)

        #Round if over 1M
        else if(value > 1000000.0 and value < 1000000000.0):
            newvalue := ((value/1000000.0) * 10.0)
            if(roundvalue := (Round[newvalue]* 0.1)):
                set newesstvalue = roundvalue
            return StringToMessageMil(newesstvalue)


        #Round if over 1B 
        else if(value > 1000000000.0 and value < 1000000000000.0):
            newvalue := ((value/1000000000.0) * 10.0)
            if(roundvalue := (Round[newvalue]* 0.1)):
                set newesstvalue = roundvalue
            return StringToMessageBil(newesstvalue)

        #Round if over 1T 
        else if(value > 1000000000000.0):
            newvalue := ((value/1000000000000.0) * 10.0)
            if(roundvalue := (Round[newvalue]* 0.1)):
                set newesstvalue = roundvalue
            return StringToMessageTril(newvalue)

        #Returns normal value if anything else
        else:
            return StringToMessage(value)


    NewMessageSec(value : float) : message=         #Rounds Values but for IdleMoney Instead
        var newesstvalue : float = 0.0

        #Round if over 100k
        if(value > 100000.0 and value < 1000000.0):
            newvalue := ((value/1000.0) * 10.0)
            if(roundvalue := (Round[newvalue]* 0.1)):
                set newesstvalue = roundvalue
            return StringToMessageSecThou(newesstvalue)

        #Round if over 1M
        else if(value > 1000000.0 and value < 1000000000.0):
                newvalue := ((value/1000000.0) * 10.0)
            if(roundvalue := (Round[newvalue]* 0.1)):
                set newesstvalue = roundvalue
            return StringToMessageSecMil(newesstvalue)

        #Round if over 1B 
        else if(value > 1000000000.0 and value < 1000000000000.0):
            newvalue := ((value/1000000000.0) * 10.0)
            if(roundvalue := (Round[newvalue]* 0.1)):
                set newesstvalue = roundvalue
            return StringToMessageSecBil(newesstvalue)

        #Round if over 1T 
        else if(value > 1000000000000.0):
            newvalue := ((value/1000000000000.0) * 10.0)
            if(roundvalue := (Round[newvalue]* 0.1)):
                set newesstvalue = roundvalue
            return StringToMessageSecTril(newesstvalue)

        #Returns normal value if anything else
        else:
            return StringToMessageSec(value)


    #Message Converters For Resources
    RealStringToMessage<localizes>(value:string) : message = "{value}"
    StringToMessage<localizes>(value:float) : message = "{value}"
    StringToMessageThou<localizes>(value:float) : message = "{value}K"
    StringToMessageMil<localizes>(value:float) : message = "{value}M"
    StringToMessageBil<localizes>(value:float) : message = "{value}B"
    StringToMessageTril<localizes>(value:float) : message = "{value}T"


    #Message Converters for Idle Values
    StringToMessageSec<localizes>(value:float) : message = "{value} / Sec"
    StringToMessageSecThou<localizes>(value:float) : message = "{value}K / Sec"
    StringToMessageSecMil<localizes>(value:float) : message = "{value}M / Sec"
    StringToMessageSecBil<localizes>(value:float) : message = "{value}B / Sec"
    StringToMessageSecTril<localizes>(value:float) : message = "{value}T / Sec"





Game_Manager := class(creative_device): #Verse Device visible in editor
    PlayerStatManager : player_stats_manager = player_stats_manager{}     #Persistence Device
    @editable PlayerSpawners : []player_spawner_device = array{}     #All player spawners
    @editable BaseClassSelector : class_and_team_selector_device = class_and_team_selector_device{}   #Base team selector to switch to
    var PlayersMap : [player]Custom_Player = map{}      #Map of all players info


    #Music Stuff
    @editable ToggleMusicButtons : []switch_device = array{}
    @editable MusicPlayer : audio_player_device = audio_player_device{}


    OnBegin<override>()<suspends>:void=
        for(Spawner : PlayerSpawners):
            Spawner.SpawnedEvent.Subscribe(InitiatePlayer)      #Activates when a player is spawned on a spawn pad

        for(Switches : ToggleMusicButtons):
            Switches.TurnedOnEvent.Subscribe(ToggleMusic)
            Switches.TurnedOffEvent.Subscribe(ToggleMusic)    #When button is pressed toggles music for player
            Switches.TurnedOnEvent.Subscribe(printfunc)
        GetPlayspace().PlayerAddedEvent().Subscribe(PlayerJoined)

    printfunc(Agent : agent) : void=
        Print("Switch turned on")

    PlayerJoined(Agent:agent ) : void=              #When player joins
        if(CustomPlayer := PlayersMap[Agent]):          #If player is already in the map
            BaseClassSelector.ChangeTeam(Agent)         #Changes team to base team
            MusicPlayer.Play(Agent)                 #Plays game music to player

    InitiatePlayer(Agent:agent): void=
        if(Player := player[Agent]):    
            PlayerStatManager.InitializePlayer(Player)
            if(PlayerExists := PlayersMap[Player]):      #If player already has been initialized

            else:
                BaseClassSelector.ChangeTeam(Agent)         #Changes team to base team
                MusicPlayer.Play(Agent)                     #Plays game music to player
                if:         #If the player has persistence data
                    PlayerStats := PlayerStatManager.GetPlayerStats[Player]
                then:        
                    if(set PlayersMap[Player] = Custom_Player{          #Assigns all persistence data to the current player
                        Player := Player
                        # MoneyAmount := PlayerStats.MoneyAmount
                        # IdleMoneyAmount := PlayerStats.IdleMoneyAmount
                        # Resource2Amount := PlayerStats.Resource2Amount
                        # IdleResource2Amount := PlayerStats.IdleResource2Amount
                        # RebirthAmount := PlayerStats.RebirthAmount
                        # BoughtPets := PlayerStats.BoughtPets
                        BoughtDoors := PlayerStats.BoughtDoors
                        # BoughtApparels := PlayerStats.BoughtApparels

                        #Add more/less depending on what you want to persist

                        }){}
                    if(CustomPlayer := PlayersMap[Player]):     #Adds the UI
                        CustomPlayer.InitiateUI()

                else:       #Registers play if it does not have persistence data
                    PlayerStatManager.InitializePlayer(Player)
                    if(set PlayersMap[Player] = Custom_Player{Player := Player}){}
                    if(CustomPlayer := PlayersMap[Player]):
                        CustomPlayer.InitiateUI()       #Adds the UI


    ToggleMusic(Agent:agent) : void=  #function used to toggle music
        Print("Trying to toggle music")
        if(CP := PlayersMap[Agent]):
            if(CP.MusicPlaying?):
                MusicPlayer.Stop(Agent)
                set CP.MusicPlaying = false
            else:
                MusicPlayer.Play(Agent)
                set CP.MusicPlaying = true