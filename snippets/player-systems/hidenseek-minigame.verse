# Hidenseek Minigame
# Verse code for Hidenseek Minigame - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/hidenseek-minigame?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/Random }

hidenseek_minigame := class(creative_device):

    @editable HiderTeleporter:teleporter_device = teleporter_device{}
    @editable SeekerTeleporter:teleporter_device = teleporter_device{}
    
    @editable HiderClass:class_and_team_selector_device = class_and_team_selector_device{}
    @editable SeekerClass:class_and_team_selector_device = class_and_team_selector_device{}

    @editable Timer:timer_device = timer_device{}

    var Hider:[]agent = array{}
    var Seeker:[]agent = array{}

    @editable RoundTime:float = 150.0
    @editable RoundTimer:timer_device = timer_device{}

    RoundLoop(HiderAgent:agent)<suspends>:void=
        race:
            block:
                if(TaggedObject := GetCreativeObjectsWithTag(GameManagerTag{})[0], GameManager := game_manager[TaggedObject]):
                    GameManager.NewMinigameEvent.Await()
            block:
                RoundTimer.SetActiveDuration(RoundTime)
                RoundTimer.Start()
                Sleep(RoundTime)
                if(TaggedObject := GetCreativeObjectsWithTag(GameManagerTag{})[0]):
                    if(GameManager := game_manager[TaggedObject]):
                        GameManager.EndGame(HiderAgent)

    StartMinigame():void=
        spawn{MinigameLoop()}

    MinigameLoop()<suspends>:void=
        race:
            block:
                if(TaggedObject := GetCreativeObjectsWithTag(GameManagerTag{})[0], GameManager := game_manager[TaggedObject]):
                    GameManager.NewMinigameEvent.Await()
            block:
                Players:=GetPlayspace().GetPlayers()

                if(Player1:=Players[0], Player2:=Players[1]):
                    RandomInt := GetRandomInt(1, 2)
                    if(RandomInt = 1):
                        set Hider = array{Player1}
                        set Seeker = array{Player2}
                    else:
                        set Hider = array{Player2}
                        set Seeker = array{Player1}

                    if(HiderAgent:=Hider[0], SeekerAgent:=Seeker[0]):
                        HiderClass.ChangeClass(HiderAgent)
                        SeekerClass.ChangeClass(SeekerAgent)
                        HiderTeleporter.Teleport(HiderAgent)
                        SeekerTeleporter.Teleport(SeekerAgent)

                        Timer.Start()

                        Sleep(15.0)

                        HiderTeleporter.Teleport(SeekerAgent)
                        
                        spawn{RoundLoop(HiderAgent)}

    ResetMinigame():void=
        set Hider = array{}
        set Seeker = array{}
        RoundTimer.Reset()