# Traptower Minigame
# Verse code for Traptower Minigame - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/traptower-minigame?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }

traptower_minigame := class(creative_device):

    var InProgress:logic = false

    @editable Teleporter1:teleporter_device = teleporter_device{}
    @editable Teleporter2:teleporter_device = teleporter_device{}

    @editable Volume:volume_device = volume_device{}
    @editable Button1:button_device = button_device{}

    @editable RoundTime:float = 150.0
    @editable RoundTimer:timer_device = timer_device{}

    RoundLoop()<suspends>:void=
        race:
            block:
                if(TaggedObject := GetCreativeObjectsWithTag(GameManagerTag{})[0], GameManager := game_manager[TaggedObject]):
                    GameManager.NewMinigameEvent.Await()
            block:
                RoundTimer.SetActiveDuration(RoundTime)
                RoundTimer.Start()
                Sleep(RoundTime)
                if(InProgress = true):
                    if(TaggedObject := GetCreativeObjectsWithTag(GameManagerTag{})[0]):
                        if(GameManager := game_manager[TaggedObject]):
                            GameManager.DrawGame()

    OnBegin<override>()<suspends>:void=
        Button1.InteractedWithEvent.Subscribe(OnButtonPressed)
        Volume.AgentEntersEvent.Subscribe(OnPlayerEntersVolume)

        Players:=GetPlayspace().GetPlayers()
        for(Player:Players):
            if(FC:=Player.GetFortCharacter[]):
                FC.DamagedEvent().Subscribe(PlayerDamaged)

    StartMinigame():void=
        set InProgress = true

        Players:=GetPlayspace().GetPlayers()
        for(Player:Players):
            if(FC:=Player.GetFortCharacter[]):
                FC.SetShield(0.0)

        if(Player1:=Players[0]):
            Teleporter1.Teleport(Player1)
        
        if(Player2:=Players[1]):
            Teleporter2.Teleport(Player2)

        spawn{RoundLoop()}

    PlayerDamaged(Result:damage_result):void=
        if(InProgress = true):
            Players:=GetPlayspace().GetPlayers()
            Amount:=Result.Amount
            Target:=Result.Target
            if(FC:=fort_character[Target], Agent:=FC.GetAgent[]):
                FC.SetHealth(100.0)
                if(Player1:=Players[0]):
                    if(Player1 = Agent):
                        Teleporter1.Teleport(Agent)
                    else:
                        Teleporter2.Teleport(Agent)
        
    OnButtonPressed(Agent:agent):void=
        if(TaggedObject := GetCreativeObjectsWithTag(GameManagerTag{})[0]):
            if(GameManager := game_manager[TaggedObject]):
                set InProgress = false
                GameManager.EndGame(Agent)

    OnPlayerEntersVolume(Agent:agent):void=
        if(InProgress = false):
            return

        Players:=GetPlayspace().GetPlayers()
        if(Player1:=Players[0]):
            if(Player1 = Agent):
                Teleporter1.Teleport(Agent)

        if(Player2:=Players[1]):
            if(Player2 = Agent):
                Teleporter2.Teleport(Agent)
        
    ResetMinigame():void=
        set InProgress = false
        RoundTimer.Reset()