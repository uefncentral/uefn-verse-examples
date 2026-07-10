# Game Start
# Verse code for Game Start - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/game-start?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath}
using { /Verse.org/Assets }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/FortPlayerUtilities }

EachPlayer := class():
    var ClassNum : int = 0

EachSelector := class<concrete>():
    @editable SelectorClassNum : int = 0
    @editable ClassSelector : class_and_team_selector_device = class_and_team_selector_device{}
    @editable ClassHud : hud_message_device = hud_message_device{}
    



GameStart := class(creative_device):
    @editable FullClassSelectorList : []EachSelector = array{}
    var ClassSelectors : []EachSelector = array{}


    
    @editable SpawnBarriers : []barrier_device = array{}
    @editable PlayerSpawners : []player_spawner_device = array{}

    @editable CodeHUD : hud_message_device = hud_message_device{}

    var EachPlayerMap : [agent]EachPlayer = map{}
    var GameIsStarted : logic = false
  

    OnBegin<override>()<suspends>:void=
        set ClassSelectors = FullClassSelectorList
        for (SpawnPad : PlayerSpawners):
            SpawnPad.SpawnedEvent.Subscribe(AssignClass)
        spawn: 
            StartGame()
        spawn:
            SpectatorUIChange()

        
    StartGame()<suspends> : void=
        Sleep(5.0)
        Print("Start")
        for (Barrier : SpawnBarriers):
            Barrier.Disable()
        set GameIsStarted = true

    AssignClass(Agent:agent) : void=
        spawn:
            AssignClassReal(Agent)
        spawn:
            AssignCodeHud(Agent)
    AssignClassReal(Agent:agent)<suspends>: void=
        Sleep(1.0)
        if(set EachPlayerMap[Agent] = EachPlayer{}){}   
        RandomGen := GetRandomInt(0,ClassSelectors.Length-1)
        if(RandomClass:= ClassSelectors[RandomGen]):
            RandomClass.ClassSelector.ChangeTeamAndClass(Agent)
            RandomClass.ClassHud.Show(Agent)
            if(set EachPlayerMap[Agent].ClassNum = RandomClass.SelectorClassNum){}
            if(SelectorToRemove  := ClassSelectors.RemoveElement[RandomGen]):
                set ClassSelectors = SelectorToRemove

    
    SpectatorUIChange()<suspends> : void=
        loop:
            Sleep(1.0)
            for(Player : GetPlayspace().GetPlayers(),FC:=Player.GetFortCharacter[],Agent := FC.GetAgent[]): #Gets Every Player
                if(FC.IsActive[]):    #If the Player is Alive
                    if(PlayersClass := EachPlayerMap[Agent].ClassNum):  #Gets the class number forr the player
                        SpectatingPlayers := Player.GetPlayersSpectating() #Gets all the players spectating that player
                        for(Spectator : SpectatingPlayers,SpectatorFC := Spectator.GetFortCharacter[],SpectatorAgent := SpectatorFC.GetAgent[]): #For every spectator
                            if(SpectatorClass := EachPlayerMap[SpectatorAgent].ClassNum):
                                for(Selec : FullClassSelectorList): #Gets Every Set of class info
                                    if(Selec.SelectorClassNum = PlayersClass): #Gets the class info equal to the player who is being spectated's class
                                        Selec.ClassHud.Show(SpectatorAgent) #shows the hud for the spectator




    AssignCodeHud(Agent:agent)<suspends> : void=
        CodeHUD.Show(Agent)
         
                                  
                    


    # TellClassNum() <suspends> : void=
    #     loop:
    #         Sleep(1.0)
    #         for (Player : GetPlayspace().GetPlayers(), FortCharacter := Player.GetFortCharacter[], Agent:= FortCharacter.GetAgent[]):
    #             if(ClassNumIs := GameStartDevice.EachPlayerMap[Agent].ClassNum):
    #                 Print("{ClassNumIs}")
    
                                

    
  

    
