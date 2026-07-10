# Player Wallhack VFX Tracker
# Creates visual effects that track and follow other players through walls for players assigned to a specific class number. The system spawns VFX devices that continuously teleport to match other player
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/wallhacks-1?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }
WallHacks := class(creative_device):
    @editable GameStartDevice : GameStart = GameStart{}
    @editable WallHacksClassNumber : int = 100

    @editable WallHacksVFXs : []vfx_spawner_device = array{}
    var WallHackIDX : int = 0

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        Sleep(3.0)
        set WallHackIDX = 0
        for (Player : GetPlayspace().GetPlayers()):
            if(FC := Player.GetFortCharacter[], Agent := FC.GetAgent[]):
                if(GameStartDevice.EachPlayerMap[Agent].ClassNum = WallHacksClassNumber):
                    spawn:
                        WallHackPlayer(Agent)
    WallHackPlayer(Agent:agent) <suspends> : void=
        if(MainPlayer := player[Agent], MainFC:= MainPlayer.GetFortCharacter[]):
            for (Player : GetPlayspace().GetPlayers()):
                if(FC := Player.GetFortCharacter[], NewAgent := FC.GetAgent[]):
                    if(FC = MainFC):
                    else:
                        if(CurrentVFX := WallHacksVFXs[WallHackIDX]):
                            spawn:
                                TrackPlayer(FC,CurrentVFX)
                            set WallHackIDX += 1


    TrackPlayer(FC:fort_character, VFX : vfx_spawner_device)<suspends>: void=
        VFX.Enable()
        loop:
            Sleep(0.0)
            if(VFX.TeleportTo[FC.GetTransform().Translation,IdentityRotation()]){}
    
