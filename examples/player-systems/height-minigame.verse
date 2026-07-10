# Height Minigame
# Verse code for Height Minigame - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/height-minigame?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /Verse.org/Colors }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/Game }

height_minigame := class(creative_device):

    @editable Timer:timer_device = timer_device{}
    @editable var Time:float = 60.0

    var InProgress:logic = false

    OnBegin<override>()<suspends>:void=
        Players:=GetPlayspace().GetPlayers()
        for(Player:Players):
            if(FC:=Player.GetFortCharacter[]):
                FC.DamagedEvent().Subscribe(PlayerDamaged)

    PlayerDamaged(Result:damage_result):void=
        if(InProgress = true):
            Target:=Result.Target
            if(FC:=fort_character[Target]):
                FC.SetHealth(100.0)
                FC.SetShield(84.0)               

    StartMinigame():void=
        set InProgress = true
        spawn{UpdateDistances()}

    UpdateDistances()<suspends>:void =
        race:
            block:
                if(TaggedObject := GetCreativeObjectsWithTag(GameManagerTag{})[0], GameManager := game_manager[TaggedObject]):
                    GameManager.NewMinigameEvent.Await()
            block:
                var TimePassed:float = 0.0
                var Player1Height:float = 0.0
                var Player2Height:float = 0.0

                Players:=GetPlayspace().GetPlayers()

                Timer.SetMaxDuration(Time)
                Timer.Start()

                if(TaggedObject := GetCreativeObjectsWithTag(UtilsTag{})[0], UtilsSystem := utils_system[TaggedObject]):
                    UtilsSystem.GrantStandardItems()

                loop:
                    if(InProgress = false):
                        break

                    Sleep(0.4)

                    if(Player1:=Players[0], Player1FC:=Player1.GetFortCharacter[]):
                        DistanceVerticalMeters := Player1FC.GetTransform().Translation.Z / 100.0
                        Print("Player 1 Distance: {DistanceVerticalMeters}m")
                        set Player1Height = DistanceVerticalMeters
                    
                    if(Player2:=Players[1], Player2FC:=Player2.GetFortCharacter[]):
                        DistanceVerticalMeters := Player2FC.GetTransform().Translation.Z / 100.0
                        Print("Player 2 Distance: {DistanceVerticalMeters}m")
                        set Player2Height = DistanceVerticalMeters

                    set TimePassed = TimePassed + 0.4
                    if(TimePassed >= Time):
                        break

                if(InProgress = false):
                    return

                set InProgress = false

                if(Player1Height > Player2Height):
                    Print("Player 1 wins!")
                    if(TaggedObject := GetCreativeObjectsWithTag(GameManagerTag{})[0], Player1:=Players[0]):
                        if(GameManager := game_manager[TaggedObject]):
                            GameManager.EndGame(Player1)    
                else:
                    Print("Player 2 wins!")
                    if(TaggedObject := GetCreativeObjectsWithTag(GameManagerTag{})[0], Player2:=Players[1]):
                        if(GameManager := game_manager[TaggedObject]):
                            GameManager.EndGame(Player2)

    ResetMinigame():void=
        set InProgress = false
        Timer.Reset()