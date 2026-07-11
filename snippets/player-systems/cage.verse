# Player Cage Trap System
# Creates a class-based cage trapping system where players of a specific class can use remote devices to cage the closest enemy player. When triggered, it spawns a cage prop at the target player's locat
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/cage?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

Cage := class(creative_device):


    @editable var Class : int = 0
    @editable ClassTracker : tracker_device = tracker_device{}
    @editable HUDablity : hud_message_device = hud_message_device{}

    @editable SignalRemoteManager:signal_remote_manager_device = signal_remote_manager_device{}

    @editable 
    ItemGranter: item_granter_device = item_granter_device{}

    @editable
    CageBlue:creative_prop = creative_prop{}

    @editable
    HUD:hud_message_device = hud_message_device{}

    @editable
    BeginPlace : vector3 = vector3{ X :=1000.0, Y := 1000.0, Z := 1000.0}

    @editable
    CageScale : vector3 = vector3{ X := 1.0, Y := 1.0, Z := 1.33333 }

    StringToMessage<localizes>(value:string)<computes> : message = "{value}"

    var DoTeleportInsteadOfVFX:logic = true

    OnBegin<override>()<suspends>:void=
        SignalRemoteManager.PrimarySignalEvent.Subscribe(OnRemoteClicked)
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


    OnRemoteClicked(Agent:agent):void=
        if(ClassTracker.GetValue(Agent) = Class):
            Print("remote clicked")
            FindClosestPlayer(Agent)

    FindClosestPlayer(Agent:agent):void=
        #go through all the players and find the closest
        AllPlayers:[]player = GetPlayspace().GetPlayers()

        PlayerCount:int = AllPlayers.Length

        if(PlayerCount = 1):
            Print("There is {PlayerCount} player in the game")
        else:
            Print("There are {PlayerCount} players in the game")

        var ClosestPlayer:?agent = false
        var DistanceToMe:float = 100000000.0
        var FoundPlayer:logic = false
        for(Player:AllPlayers):
            if(Player <> Agent):    
                #find the distance of this player to me
                if(MyFC:fort_character = Agent.GetFortCharacter[]):
                    if(OtherFC:fort_character = Player.GetFortCharacter[]):
                        MyPos:vector3 = MyFC.GetTransform().Translation
                        OtherPos:vector3 = OtherFC.GetTransform().Translation
                        TotalDistance:float = Distance(MyPos, OtherPos) / 100.0
                        if(TotalDistance < DistanceToMe):
                            set FoundPlayer = true
                            set DistanceToMe = TotalDistance
                            set ClosestPlayer = option{Player}

        if(FoundPlayer = true):
            HUD.SetText(StringToMessage("You found the closest player!"))
            HUD.Show(Agent)
            #grab the player's current position
            if(PlayerAgent:agent = agent[ClosestPlayer?]):
                if(FC:fort_character = PlayerAgent.GetFortCharacter[]):
                    Pos:transform = FC.GetTransform()
                    if(DoTeleportInsteadOfVFX = true):
                        if(CageBlue.TeleportTo[Pos.Translation + vector3{Z:=-60.0}, Pos.Rotation]):
                            spawn:
                                ResetCage()

    ResetCage()<suspends>:void=
        Sleep(3.0)
        if (CageBlue.TeleportTo[BeginPlace, MakeRotation(CageScale, 0.0)]):

    WaitingTime(Agent:agent)<suspends>:void=
        Print("ff rusten")
        Sleep(4.0)

        if (CageBlue.TeleportTo[BeginPlace, MakeRotation(CageScale, 0.0)]):