# Vehicle Spawn Manager
# This system manages vehicle spawning for players using spawn pads with tags. It tracks multiple vehicle types (sports cars, boats, ATKs, etc.) and maintains per-player vehicle assignments with integra
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/meter-device-1?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Vehicles }
using { /Fortnite.com/UI }
using { /Fortnite.com/FortPlayerUtilities }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }
using { /Verse.org/Colors }
using { /Verse.org/Colors/NamedColors }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Random}
using { player_class }
using { helpers.MyUtils }

SpawnPadTag:= class(tag){}
meter_device := class(creative_device):

    var PlayerManager<public>:player_manager = player_manager{}
    var StatsManager<public>:stats_manager = stats_manager{}
    var LevelManager<public>:level_manager = level_manager{}

    @editable SportsVehicle : []sports_vehicle_class = array{}
    @editable ATKVehicle : []atk_vehicle_class = array{}
    @editable BoatVehicle : []boat_vehicle_class = array{}
    @editable SedanVehicle : []sedan_vehicle_class = array{}
    @editable ShoppingCartVehicle : []shopping_cart_vehicle_class = array{}
    @editable TaxiVehicle : []taxi_vehicle_class = array{}
    @editable DirtbikeVehicle : []dirtbike_vehicle_class = array{}
    @editable GetawayVehicle : []getaway_vehicle_class = array{}
    @editable BusVehicle : []bus_vehicle_class = array{}
    @editable SportsbikeVehicle : []sportsbike_vehicle_class = array{}
    @editable PickupTruckVehicle : []pickup_truck_vehicle_class = array{}
    @editable QuadcrasherVehicle : []quadcrasher_vehicle_class = array{}
    @editable NitroSedanVehicle : []nitro_sedan_vehicle_class = array{}
    @editable BigRigVehicle : []big_rig_vehicle_class = array{}
    var BigRigVehiclePerAgent : [agent]?big_rig_vehicle_class = map{}
    var NitroSedanVehiclePerAgent : [agent]?nitro_sedan_vehicle_class = map{}
    var SportsVehiclePerAgent : [agent]?sports_vehicle_class = map{}
    var ATKVehiclePerAgent : [agent]?atk_vehicle_class = map{}
    var BoatVehiclePerAgent : [agent]?boat_vehicle_class = map{}
    var SedanVehiclePerAgent : [agent]?sedan_vehicle_class = map{}
    var ShoppingCartVehiclePerAgent : [agent]?shopping_cart_vehicle_class = map{}
    var TaxiVehiclePerAgent : [agent]?taxi_vehicle_class = map{}
    var DirtbikeVehiclePerAgent : [agent]?dirtbike_vehicle_class = map{}
    var GetawayVehiclePerAgent : [agent]?getaway_vehicle_class = map{}
    var BusVehiclePerAgent : [agent]?bus_vehicle_class = map{}
    var SportsbikeVehiclePerAgent : [agent]?sportsbike_vehicle_class = map{}
    var PickupTruckVehiclePerAgent : [agent]?pickup_truck_vehicle_class = map{}
    var QuadcrasherVehiclePerAgent : [agent]?quadcrasher_vehicle_class = map{}

    @editable GoldItemGrant : item_granter_device = item_granter_device{}
    @editable GoldConditionalButton : conditional_button_device = conditional_button_device{}
    @editable GoldRemover : item_remover_device = item_remover_device{}
    @editable ElimMachine : elimination_manager_device = elimination_manager_device{}
    @editable Teleporter : teleporter_device = teleporter_device{}
    @editable FloorMutator : []mutator_zone_device = array{}
    @editable ClassSelector : class_and_team_selector_device = class_and_team_selector_device{}
    @editable NoClassClassSelector : class_and_team_selector_device = class_and_team_selector_device{}

    @editable
    DoorZone : mutator_zone_device = mutator_zone_device{} # <------ Put this at the start of the track

    @editable
    Score : score_manager_device = score_manager_device{}  # <------ Triggered when you reach a new distance

    RespawnPos: vector3=vector3{X:= -4270.381746, Y:= 10802.091436, Z:= 42708.987162}
    
    @editable
    DistanceAudio : audio_player_device = audio_player_device{} # <------ Triggered when you reach a new distance

    @editable HUDFailNotInCar : hud_message_device = hud_message_device{}
    @editable NotInCarCheck : []mutator_zone_device = array{}

    var XPBonus : int = 1
    var PlayersArray : []agent = array{}
    UIText<localizes>(Value : string) : message = "{Value}"
    RewardText<localizes>(Value : int) : message = "+${Value}"
    HighScoreText<localizes>(Value : int) : message = "{Value}"
    var RewardTextBlock : text_block = text_block{DefaultTextColor:=White,DefaultShadowOffset:=option{vector2{X:=2.5,Y:=2.5}},DefaultShadowColor:=Black}
    var HighScoreTextBlock : text_block = text_block{DefaultTextColor:=White,DefaultShadowOffset:=option{vector2{X:=2.5,Y:=2.5}},DefaultShadowColor:=Black}
    var MaybeMyUIPerPlayer : [player]?canvas = map{}

    OnBegin<override>()<suspends>:void=
        InitSpawners()

        Teleporter.TeleportedEvent.Subscribe(OnTeleported)

        DoorZone.AgentEntersEvent.Subscribe(OnEntered)

        for (NIC : NotInCarCheck):
            NIC.AgentEntersEvent.Subscribe(OnEnteredNotInCar)

        for (FM : FloorMutator):
            FM.AgentEntersEvent.Subscribe(OnEnteredCheck)
            
        for(V:SportsVehicle):
            spawn{CheckForNewSportsVehicleAgent(V)}

        for(V:ATKVehicle):
            spawn{CheckForNewATKVehicleAgent(V)}

        for(V:BoatVehicle):
            spawn{CheckForNewBoatVehicleAgent(V)}

        for(V:SedanVehicle):
            spawn{CheckForNewSedanVehicleAgent(V)}

        for(V:ShoppingCartVehicle):
            spawn{CheckForNewShoppingCartVehicleAgent(V)}

        for(V:TaxiVehicle):
            spawn{CheckForNewTaxiVehicleAgent(V)}

        for(V:DirtbikeVehicle):
            spawn{CheckForNewDirtBikeVehicleAgent(V)}

        for(V:GetawayVehicle):
            spawn{CheckForNewGetawayVehicleAgent(V)}

        for(V:BusVehicle):
            spawn{CheckForNewBusVehicleAgent(V)}

        for(V:SportsbikeVehicle):
            spawn{CheckForNewSportBikeVehicleAgent(V)}

        for(V:PickupTruckVehicle):
            spawn{CheckForNewPickupTruckVehicleAgent(V)}

        for(V:QuadcrasherVehicle):
            spawn{CheckForNewQuadcrasherVehicleAgent(V)}

        for(V:NitroSedanVehicle):
            spawn{CheckForNewNitroSedanVehicleAgent(V)}

        for(V:BigRigVehicle):
            spawn{CheckForNewBigRigVehicleAgent(V)}

        ElimMachine.EliminatedEvent.Subscribe(SelfEliminated)

    OnEnteredNotInCar(A:agent):void=
        spawn. OnEnteredNotInCarSus(A)

    OnEnteredNotInCarSus(A:agent)<suspends>:void=
        loop:
            Sleep(0.0)
            if (P := player[A]):
                if (FC := P.GetFortCharacter[]):
                    if (PlayerVehicle := FC.GetVehicle[]):
                        Print("Car")
                        AllPlayerInfos := PlayerManager.GetPlayers()
                        for (API : AllPlayerInfos):
                            if (API.AgentRef = A):
                                if (API.BeingRewarded?):
                                    break
                    else:
                        Print("No car")
                        Teleporter.Teleport(P)
                        HUDFailNotInCar.Show(A)
                        if (CurrVehicle:=SportsVehiclePerAgent[P]?):
                            CurrVehicle.Clear()
                        else if (CurrVehicle:=ATKVehiclePerAgent[P]?):
                            CurrVehicle.Clear()
                        else if (CurrVehicle:=BoatVehiclePerAgent[P]?):
                            CurrVehicle.Clear()
                        else if (CurrVehicle:=SedanVehiclePerAgent[P]?):
                            CurrVehicle.Clear()
                        else if (CurrVehicle:=ShoppingCartVehiclePerAgent[P]?):
                            CurrVehicle.Clear()
                        else if (CurrVehicle:=TaxiVehiclePerAgent[P]?):
                            CurrVehicle.Clear()
                        else if (CurrVehicle:=DirtbikeVehiclePerAgent[P]?):
                            CurrVehicle.Clear()
                        else if (CurrVehicle:=GetawayVehiclePerAgent[P]?):
                            CurrVehicle.Clear()
                        else if (CurrVehicle:=BusVehiclePerAgent[P]?):
                            CurrVehicle.Clear()
                        else if (CurrVehicle:=SportsbikeVehiclePerAgent[P]?):
                            CurrVehicle.Clear()
                        else if (CurrVehicle:=PickupTruckVehiclePerAgent[P]?):
                            CurrVehicle.Clear()
                        else if (CurrVehicle:=QuadcrasherVehiclePerAgent[P]?):
                            CurrVehicle.Clear()
                        else if (CurrVehicle:=NitroSedanVehiclePerAgent[P]?):
                            CurrVehicle.Clear()
                        else if (CurrVehicle:=BigRigVehiclePerAgent[P]?):
                            CurrVehicle.Clear()
                        break


    OnTeleported(Agent:agent):void=
        Print("Teleported")
        NoClassClassSelector.ChangeClass(Agent)
        AllPlayerInfos := PlayerManager.GetPlayers()
        PlayerCoinAmount := StatsManager.GetStat("Coins",Agent)
        PlayerLevelAmount := StatsManager.GetStat("Level",Agent)
        Print("Player Coins {PlayerCoinAmount}")
        Print("Player Level: {PlayerLevelAmount}")
        for (API : AllPlayerInfos):
            if (API.AgentRef = Agent):
                set API.Distance1 = 0
                set API.BeingChecked = false
                set API.BeingRewarded = false

    NowRespawn(Agent: agent)<suspends>:void=
        Sleep(0.1)
        Print("NowRespawn")
        AllPlayerInfos := PlayerManager.GetPlayers()
        Agent.Respawn(RespawnPos, rotation{})
        PlayerCoinAmount := StatsManager.GetStat("Coins",Agent)
        Print("Player Coins {PlayerCoinAmount}")
        for (API : AllPlayerInfos):
            if (API.AgentRef = Agent):
                set API.Distance1 = 0
        
    SelfEliminated(Agent:agent):void=
        spawn{NowRespawn(Agent)}

    InitSpawners():void=
        Spawners := GetCreativeObjectsWithTag(SpawnPadTag{})
        for (Obj : Spawners):
            if (Spawner := player_spawner_device[Obj]):
                Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

    OnPlayerSpawned(Agent:agent):void=
        if:
            PlayerObj := player[Agent]
        then:
            if(PlayerExists:=PlayersArray.Find[Agent]):
                return
            else:
                set PlayersArray = PlayersArray + array{Agent}
                spawn. TimePlayer(Agent)
                spawn. GivePersistanceMoney(Agent)

    GivePersistanceMoney(Agent:agent)<suspends>:void=
        PlayerCoinAmount := StatsManager.GetStat("Coins",Agent)
        GoldItemGrant.GrantItem(Agent)
        NewAmount := 999999-PlayerCoinAmount
        GoldConditionalButton.SetItemCountRequired(0,NewAmount)
        Sleep(1.5)
        GoldConditionalButton.Activate(Agent)

    TimePlayer(Agent:agent)<suspends>:void=
        loop:
            Sleep(60.0)
            StatsManager.AddStat(Agent, "Playtime", 1)

    OnEntered(PAgent : agent) : void =
        if (FC := PAgent.GetFortCharacter[]):
            LastLOC := FC.GetTransform().Translation.Y
            spawn:
                LocationLoop(FC, PAgent)
    
    OnEnteredCheck(Agent:agent):void=
        spawn. OnEnteredCheckSus(Agent)

    OnEnteredCheckSus(Agent:agent)<suspends>:void=
        loop:
            Sleep(0.0)
            if (P := player[Agent]):
                if (FC := P.GetFortCharacter[]):
                    if (PlayerVehicle := FC.GetVehicle[]):
                        if (PlayerVehicle.GetHealth() > 1.0):
                            # Print("Car")
                        else:
                            Print("No car")
                            # Sleep(1.0)
                            FC.ReleaseFromStasis()
                            ChangePlayerClasss(P)
                            break
                    else:
                        Print("No car")
                        # Sleep(1.0)
                        FC.ReleaseFromStasis()
                        ChangePlayerClasss(P)
                        if (CurrVehicle:=SportsVehiclePerAgent[P]?):
                            CurrVehicle.Clear()
                        else if (CurrVehicle:=ATKVehiclePerAgent[P]?):
                            CurrVehicle.Clear()
                        else if (CurrVehicle:=BoatVehiclePerAgent[P]?):
                            CurrVehicle.Clear()
                        else if (CurrVehicle:=SedanVehiclePerAgent[P]?):
                            CurrVehicle.Clear()
                        else if (CurrVehicle:=ShoppingCartVehiclePerAgent[P]?):
                            CurrVehicle.Clear()
                        else if (CurrVehicle:=TaxiVehiclePerAgent[P]?):
                            CurrVehicle.Clear()
                        else if (CurrVehicle:=DirtbikeVehiclePerAgent[P]?):
                            CurrVehicle.Clear()
                        else if (CurrVehicle:=GetawayVehiclePerAgent[P]?):
                            CurrVehicle.Clear()
                        else if (CurrVehicle:=BusVehiclePerAgent[P]?):
                            CurrVehicle.Clear()
                        else if (CurrVehicle:=SportsbikeVehiclePerAgent[P]?):
                            CurrVehicle.Clear()
                        else if (CurrVehicle:=PickupTruckVehiclePerAgent[P]?):
                            CurrVehicle.Clear()
                        else if (CurrVehicle:=QuadcrasherVehiclePerAgent[P]?):
                            CurrVehicle.Clear()
                        else if (CurrVehicle:=NitroSedanVehiclePerAgent[P]?):
                            CurrVehicle.Clear()
                        else if (CurrVehicle:=BigRigVehiclePerAgent[P]?):
                            CurrVehicle.Clear()
                        break

    ChangePlayerClasss(P:player)<suspends>:void=
        Print("Create new classss")
        Sleep(1.0)
        Print("After the sleep")
        ClassSelector.ChangeClass(P)
        Teleporter.Teleport(P)

    LocationLoop(FC : fort_character, PAgent : agent) <suspends> : void =
        var LastLOC : float = FC.GetTransform().Translation.Y
        loop:
            Sleep(0.0)
            CurrentLOC := FC.GetTransform().Translation.Y
            CurrentLOCHeight := FC.GetTransform().Translation.Z / 100.0
            if(CurrentLOC - LastLOC <= -1420.0 ): #-1420 <------ Treshold you want ( 1000 = 2 Fortnite floor)
                set LastLOC = FC.GetTransform().Translation.Y


                Print("New distance reach")
                Score.Activate(PAgent)
                DistanceAudio.Play(PAgent)
                AllPlayerInfos := PlayerManager.GetPlayers()
                for (API : AllPlayerInfos):
                    if (API.AgentRef = PAgent):
                        set API.Distance1 += 1
                        if (API.BeingRewarded?):
                            break
                            
                if (RoundedCurrentLOCHeight := Floor[CurrentLOCHeight] - 3):
                    if(RoundedCurrentLOCHeight <= 325):
                        if (PlayerVehicle := FC.GetVehicle[]):
                            if (PlayerVehicle.IsOnGround[]):
                                # Print("PutInStasis")
                                FC.PutInStasis(stasis_args{AllowTurning := true, AllowFalling := true, AllowEmotes := true})
                                if (Agent := FC.GetAgent[]):
                                    if (Player := player[Agent]):
                                        AllPlayerInfoss := PlayerManager.GetPlayers()
                                        for (API : AllPlayerInfoss):
                                            if (API.PlayerRef = Player):
                                                BeingCheckedLogic := API.BeingChecked
                                                spawn. PlayerCarOnFloor(Player,BeingCheckedLogic)

                                            

    PlayerCarOnFloor(P:player,BeingChecked:logic)<suspends>:void=
        if (BeingChecked = false):
            AllPlayerInfoss := PlayerManager.GetPlayers()
            if (FC := P.GetFortCharacter[]):
                for (API : AllPlayerInfoss):
                    if (API.PlayerRef = P): 
                        set API.BeingChecked = true
                        Sleep(5.0)
                        DistanceReward := API.Distance1*25
                        spawn. RewardForPlayer(P,DistanceReward)
        else:
            # Print("Player is already being checked")
            return
            
    RewardForPlayer(Agent:agent,DistanceTraveled:int)<suspends>:void=
        AllPlayerInfoss := PlayerManager.GetPlayers()
        if (P := player[Agent]):
            if (FC := P.GetFortCharacter[]):
                if (Vehicle := FC.GetVehicle[]):
                    MaxHealth := Vehicle.GetHealth()
                    Vehicle.Damage(MaxHealth)

                    if (CurrVehicle:=SportsVehiclePerAgent[P]?):
                        CurrVehicle.SportsVehicle.RespawnVehicle()
                        CurrVehicle.Reset()
                        
                    else if (CurrVehicle:=ATKVehiclePerAgent[P]?):
                        
                        CurrVehicle.ATKVehicle.RespawnVehicle()
                        CurrVehicle.Reset()
                        
                    else if (CurrVehicle:=BoatVehiclePerAgent[P]?):
                        
                        CurrVehicle.BoatVehicle.RespawnVehicle()
                        CurrVehicle.Reset()
                        
                    else if (CurrVehicle:=SedanVehiclePerAgent[P]?):
                        
                        CurrVehicle.SedanVehicle.RespawnVehicle()
                        CurrVehicle.Reset()
                        
                    else if (CurrVehicle:=ShoppingCartVehiclePerAgent[P]?):
                        
                        CurrVehicle.ShoppingCartVehicle.RespawnVehicle()
                        CurrVehicle.Reset()
                        
                    else if (CurrVehicle:=TaxiVehiclePerAgent[P]?):
                        
                        CurrVehicle.TaxiVehicle.RespawnVehicle()
                        CurrVehicle.Reset()
                    else if (CurrVehicle:=DirtbikeVehiclePerAgent[P]?):
                        
                        CurrVehicle.DirtBikeVehicle.RespawnVehicle()
                        CurrVehicle.Reset()
                        
                    else if (CurrVehicle:=GetawayVehiclePerAgent[P]?):
                        
                        CurrVehicle.GetAwayVehicle.RespawnVehicle()
                        CurrVehicle.Reset()
                        
                    else if (CurrVehicle:=BusVehiclePerAgent[P]?):
                        
                        CurrVehicle.BusVehicle.RespawnVehicle()
                        CurrVehicle.Reset()
                        
                    else if (CurrVehicle:=SportsbikeVehiclePerAgent[P]?):
                        
                        CurrVehicle.SportsBikeVehicle.RespawnVehicle()
                        CurrVehicle.Reset()
                        
                    else if (CurrVehicle:=PickupTruckVehiclePerAgent[P]?):
                        
                        CurrVehicle.PickUpTruckVehicle.RespawnVehicle()
                        CurrVehicle.Reset()
                        
                    else if (CurrVehicle:=QuadcrasherVehiclePerAgent[P]?):
                        
                        CurrVehicle.QuadcrasherVehicle.RespawnVehicle()
                        CurrVehicle.Reset()
                        
                    else if (CurrVehicle:=NitroSedanVehiclePerAgent[P]?):
                        
                        CurrVehicle.NitroSedanVehicle.RespawnVehicle()
                        CurrVehicle.Reset()
                        
                    else if (CurrVehicle:=BigRigVehiclePerAgent[P]?):
                        Print("Big rig")
                        CurrVehicle.Reset()

                for (API : AllPlayerInfoss):
                    if (API.AgentRef = Agent):
                        set XPBonus = API.XPBonus
                        set API.BeingRewarded = true


                        StatsManager.AddStat(Agent,"AllTimeScore",API.Distance1*25)
                        
                        RewardTextBlock.SetText(RewardText(API.Distance1*25))
                        StatsManager.AddStat(Agent,"Coins",API.Distance1*25)
                        
                        HighScoreAmount := StatsManager.GetStat("HighScore",Agent)
                        PlayerCoinAmount := StatsManager.GetStat("Coins",Agent)

                        if (API.Distance1*25 > HighScoreAmount):
                            StatsManager.SetStat(Agent, "HighScore", API.Distance1*25)
                            HighScoreTextBlock.SetText(HighScoreText(API.Distance1*25))
                            P.HighScoreUI()
                        else:
                            P.RewardUI()

                        RandomXP := GetRandomInt(15,25) * XPBonus
                        LevelManager.AddScore(Agent,RandomXP,true)
                        LevelManager.GetRankTexture(Agent,LevelManager.GetRank(Agent))
                        # StatsManager.AddStat(Agent,"Coins",DistanceTraveled)
                        GoldRemover.Remove(Agent)
                        GoldItemGrant.GrantItem(Agent)
                        NewAmount := 999999-PlayerCoinAmount
                        GoldConditionalButton.SetItemCountRequired(0,NewAmount)
                        Sleep(1.5)
                        GoldConditionalButton.Activate(Agent)
                        P.RemoveUI()
            
    CheckForNewSportsVehicleAgent(V:sports_vehicle_class)<suspends>:void=
        loop:
            Agent:= V.SportsVehicle.AgentEntersVehicleEvent.Await()
            if(CurrVehicle:=SportsVehiclePerAgent[Agent]?):
                CurrVehicle.Clear()
            if(set SportsVehiclePerAgent[Agent] = option{V}){}
            V.RegisterPlayer(Agent)

    CheckForNewATKVehicleAgent(V:atk_vehicle_class)<suspends>:void=
        loop:
            Agent:= V.ATKVehicle.AgentEntersVehicleEvent.Await()
            if(CurrVehicle:=ATKVehiclePerAgent[Agent]?):
                CurrVehicle.Clear()
            if(set ATKVehiclePerAgent[Agent] = option{V}){}
            V.RegisterPlayer(Agent)

    CheckForNewBoatVehicleAgent(V:boat_vehicle_class)<suspends>:void=
        loop:
            Agent:= V.BoatVehicle.AgentEntersVehicleEvent.Await()
            if(CurrVehicle:=BoatVehiclePerAgent[Agent]?):
                CurrVehicle.Clear()
            if(set BoatVehiclePerAgent[Agent] = option{V}){}
            V.RegisterPlayer(Agent)

    CheckForNewSedanVehicleAgent(V:sedan_vehicle_class)<suspends>:void=
        loop:
            Agent:= V.SedanVehicle.AgentEntersVehicleEvent.Await()
            if(CurrVehicle:=SedanVehiclePerAgent[Agent]?):
                CurrVehicle.Clear()
            if(set SedanVehiclePerAgent[Agent] = option{V}){}
            V.RegisterPlayer(Agent)

    CheckForNewShoppingCartVehicleAgent(V:shopping_cart_vehicle_class)<suspends>:void=
        loop:
            Agent:= V.ShoppingCartVehicle.AgentEntersVehicleEvent.Await()
            if(CurrVehicle:=ShoppingCartVehiclePerAgent[Agent]?):
                CurrVehicle.Clear()
            if(set ShoppingCartVehiclePerAgent[Agent] = option{V}){}
            V.RegisterPlayer(Agent)

    CheckForNewTaxiVehicleAgent(V:taxi_vehicle_class)<suspends>:void=
        loop:
            Agent:= V.TaxiVehicle.AgentEntersVehicleEvent.Await()
            if(CurrVehicle:=TaxiVehiclePerAgent[Agent]?):
                CurrVehicle.Clear()
            if(set TaxiVehiclePerAgent[Agent] = option{V}){}
            V.RegisterPlayer(Agent)

    CheckForNewDirtBikeVehicleAgent(V:dirtbike_vehicle_class)<suspends>:void=
        loop:
            Agent:= V.DirtBikeVehicle.AgentEntersVehicleEvent.Await()
            if(CurrVehicle:=DirtbikeVehiclePerAgent[Agent]?):
                CurrVehicle.Clear()
            if(set DirtbikeVehiclePerAgent[Agent] = option{V}){}
            V.RegisterPlayer(Agent)

    CheckForNewGetawayVehicleAgent(V:getaway_vehicle_class)<suspends>:void=
        loop:
            Agent:= V.GetAwayVehicle.AgentEntersVehicleEvent.Await()
            if(CurrVehicle:=GetawayVehiclePerAgent[Agent]?):
                CurrVehicle.Clear()
            if(set GetawayVehiclePerAgent[Agent] = option{V}){}
            V.RegisterPlayer(Agent)

    CheckForNewBusVehicleAgent(V:bus_vehicle_class)<suspends>:void=
        loop:
            Agent:= V.BusVehicle.AgentEntersVehicleEvent.Await()
            if(CurrVehicle:=BusVehiclePerAgent[Agent]?):
                CurrVehicle.Clear()
            if(set BusVehiclePerAgent[Agent] = option{V}){}
            V.RegisterPlayer(Agent)

    CheckForNewSportBikeVehicleAgent(V:sportsbike_vehicle_class)<suspends>:void=
        loop:
            Agent:= V.SportsBikeVehicle.AgentEntersVehicleEvent.Await()
            if(CurrVehicle:=SportsbikeVehiclePerAgent[Agent]?):
                CurrVehicle.Clear()
            if(set SportsbikeVehiclePerAgent[Agent] = option{V}){}
            V.RegisterPlayer(Agent)

    CheckForNewPickupTruckVehicleAgent(V:pickup_truck_vehicle_class)<suspends>:void=
        loop:
            Agent:= V.PickUpTruckVehicle.AgentEntersVehicleEvent.Await()
            if(CurrVehicle:=PickupTruckVehiclePerAgent[Agent]?):
                CurrVehicle.Clear()
            if(set PickupTruckVehiclePerAgent[Agent] = option{V}){}
            V.RegisterPlayer(Agent)

    CheckForNewQuadcrasherVehicleAgent(V:quadcrasher_vehicle_class)<suspends>:void=
        loop:
            Agent:= V.QuadcrasherVehicle.AgentEntersVehicleEvent.Await()
            if(CurrVehicle:=QuadcrasherVehiclePerAgent[Agent]?):
                CurrVehicle.Clear()
            if(set QuadcrasherVehiclePerAgent[Agent] = option{V}){}
            V.RegisterPlayer(Agent)

    CheckForNewNitroSedanVehicleAgent(V:nitro_sedan_vehicle_class)<suspends>:void=
        loop:
            Agent:= V.NitroSedanVehicle.AgentEntersVehicleEvent.Await()
            if(CurrVehicle:=NitroSedanVehiclePerAgent[Agent]?):
                CurrVehicle.Clear()
            if(set NitroSedanVehiclePerAgent[Agent] = option{V}){}
            V.RegisterPlayer(Agent)

    CheckForNewBigRigVehicleAgent(V:big_rig_vehicle_class)<suspends>:void=
        loop:
            Agent:= V.BigRigVehicle.AgentEntersVehicleEvent.Await()
            if(CurrVehicle:=BigRigVehiclePerAgent[Agent]?):
                CurrVehicle.Clear()
            if(set BigRigVehiclePerAgent[Agent] = option{V}){}
            V.RegisterPlayer(Agent)

    (Player : player).RewardUI()<suspends>: void =
        PresentOverlay:=overlay:
            Slots:=array:
                overlay_slot:
                    Widget:=texture_block{DefaultImage:=_Textures.CoinAmount,DefaultDesiredSize:=vector2{X:=295.0,Y:=105.0}}
                    HorizontalAlignment:=horizontal_alignment.Fill
                    VerticalAlignment:=vertical_alignment.Fill
                overlay_slot:
                    Widget:=RewardTextBlock
                    HorizontalAlignment:=horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Center
                    Padding:=margin{Top:=0.0,Left:=30.0,Right:=0.0,Bottom:=0.0}

        PresentStackBox:=stack_box:
            Orientation:=orientation.Horizontal
            Slots:=array:
                stack_box_slot:
                    Widget:=PresentOverlay
                    HorizontalAlignment:=horizontal_alignment.Fill
                    VerticalAlignment:=vertical_alignment.Fill

        NewCanvas : canvas = canvas:
            Slots := array:
                canvas_slot:
                    Widget := PresentStackBox
                    Anchors := anchors{ Minimum := vector2{ X := 0.497743, Y := 0.502984}, Maximum := vector2{ X := 0.497743, Y := 0.502984}}
                    Alignment:=vector2{X:=0.5,Y:=0.5}
                    SizeToContent := true

        if(PlayerUI := GetPlayerUI[Player], FortCharacter := Player.GetFortCharacter[]):
            PlayerUI.AddWidget(NewCanvas,player_ui_slot{InputMode:=ui_input_mode.None})
            if (set MaybeMyUIPerPlayer[Player] = option{NewCanvas}) {}

    (Player:player).RemoveUI() :void=
        if:
            PlayerUI := GetPlayerUI[Player]
            Canvas := MaybeMyUIPerPlayer[Player]?
        then:
            PlayerUI.RemoveWidget(Canvas)

    (Player : player).HighScoreUI()<suspends>: void =
        PresentOverlay:=overlay:
            Slots:=array:
                overlay_slot:
                    Widget:=texture_block{DefaultImage:=_Textures.CoinAmount,DefaultDesiredSize:=vector2{X:=295.0,Y:=105.0}}
                    HorizontalAlignment:=horizontal_alignment.Fill
                    VerticalAlignment:=vertical_alignment.Fill
                overlay_slot:
                    Widget:=RewardTextBlock
                    HorizontalAlignment:=horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Center
                    Padding:=margin{Top:=0.0,Left:=30.0,Right:=0.0,Bottom:=0.0}

        PresentStackBox:=stack_box:
            Orientation:=orientation.Horizontal
            Slots:=array:
                stack_box_slot:
                    Widget:=PresentOverlay
                    HorizontalAlignment:=horizontal_alignment.Fill
                    VerticalAlignment:=vertical_alignment.Fill

        HighScoreOverlay:=overlay:
            Slots:=array:
                overlay_slot:
                    Widget:=texture_block{DefaultImage:=_Textures.NewHighScore,DefaultDesiredSize:=vector2{X:=489.6,Y:=184.0}}
                    HorizontalAlignment:=horizontal_alignment.Fill
                    VerticalAlignment:=vertical_alignment.Fill
                overlay_slot:
                    Widget:=HighScoreTextBlock
                    HorizontalAlignment:=horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Center
                    Padding:=margin{Top:=15.0,Left:=-0.0,Right:=0.0,Bottom:=0.0}

        HighScoreStackBox:=stack_box:
            Orientation:=orientation.Horizontal
            Slots:=array:
                stack_box_slot:
                    Widget:=HighScoreOverlay
                    HorizontalAlignment:=horizontal_alignment.Fill
                    VerticalAlignment:=vertical_alignment.Fill

        NewCanvas : canvas = canvas:
            Slots := array:
                canvas_slot:
                    Widget := HighScoreStackBox
                    Anchors := anchors{ Minimum := vector2{ X := 0.497685, Y := 0.345679}, Maximum := vector2{ X := 0.497685, Y := 0.345679}}
                    Alignment:=vector2{X:=0.5,Y:=0.5}
                    SizeToContent := true
                canvas_slot:
                    Widget := PresentStackBox
                    Anchors := anchors{ Minimum := vector2{ X := 0.497743, Y := 0.502984}, Maximum := vector2{ X := 0.497743, Y := 0.502984}}
                    Alignment:=vector2{X:=0.5,Y:=0.5}
                    SizeToContent := true

        if(PlayerUI := GetPlayerUI[Player], FortCharacter := Player.GetFortCharacter[]):
            PlayerUI.AddWidget(NewCanvas,player_ui_slot{InputMode:=ui_input_mode.None})
            if (set MaybeMyUIPerPlayer[Player] = option{NewCanvas}) {}


sports_vehicle_class:=class<concrete>:
    var MaybeAgent : ?agent = false
    @editable SportsVehicle : vehicle_spawner_sports_car_device = vehicle_spawner_sports_car_device{}

    RegisterPlayer(A:agent):void=
        set MaybeAgent = option{A}
        SportsVehicle.AgentExitsVehicleEvent.Subscribe(OnExitCar)

    OnExitCar(Agent:agent):void=
        Reset()

    Clear():void=
        set MaybeAgent = false

    Reset():void=
        SportsVehicle.RespawnVehicle()
        set MaybeAgent = false

atk_vehicle_class:=class<concrete>:
    var MaybeAgent : ?agent = false
    @editable ATKVehicle : vehicle_spawner_atk_device = vehicle_spawner_atk_device{}

    RegisterPlayer(A:agent):void=
        set MaybeAgent = option{A}
        ATKVehicle.AgentExitsVehicleEvent.Subscribe(OnExitCar)

    OnExitCar(Agent:agent):void=
        Reset()

    Clear():void=
        set MaybeAgent = false

    Reset():void=
        ATKVehicle.RespawnVehicle()
        set MaybeAgent = false

boat_vehicle_class:=class<concrete>:
    var MaybeAgent : ?agent = false
    @editable BoatVehicle : vehicle_spawner_boat_device = vehicle_spawner_boat_device{}

    RegisterPlayer(A:agent):void=
        set MaybeAgent = option{A}
        BoatVehicle.AgentExitsVehicleEvent.Subscribe(OnExitCar)

    OnExitCar(Agent:agent):void=
        Reset()

    Clear():void=
        set MaybeAgent = false

    Reset():void=
        BoatVehicle.RespawnVehicle()
        set MaybeAgent = false

sedan_vehicle_class:=class<concrete>:
    var MaybeAgent : ?agent = false
    @editable SedanVehicle : vehicle_spawner_sedan_device = vehicle_spawner_sedan_device{}

    RegisterPlayer(A:agent):void=
        set MaybeAgent = option{A}
        SedanVehicle.AgentExitsVehicleEvent.Subscribe(OnExitCar)

    OnExitCar(Agent:agent):void=
        Reset()

    Clear():void=
        set MaybeAgent = false

    Reset():void=
        SedanVehicle.RespawnVehicle()
        set MaybeAgent = false

shopping_cart_vehicle_class:=class<concrete>:
    var MaybeAgent : ?agent = false
    @editable ShoppingCartVehicle : vehicle_spawner_shopping_cart_device = vehicle_spawner_shopping_cart_device{}

    RegisterPlayer(A:agent):void=
        set MaybeAgent = option{A}
        ShoppingCartVehicle.AgentExitsVehicleEvent.Subscribe(OnExitCar)

    OnExitCar(Agent:agent):void=
        Reset()

    Clear():void=
        set MaybeAgent = false

    Reset():void=
        ShoppingCartVehicle.RespawnVehicle()
        set MaybeAgent = false

taxi_vehicle_class:=class<concrete>:
    var MaybeAgent : ?agent = false
    @editable TaxiVehicle : vehicle_spawner_taxi_device = vehicle_spawner_taxi_device{}

    RegisterPlayer(A:agent):void=
        set MaybeAgent = option{A}
        TaxiVehicle.AgentExitsVehicleEvent.Subscribe(OnExitCar)

    OnExitCar(Agent:agent):void=
        Reset()

    Clear():void=
        set MaybeAgent = false

    Reset():void=
        TaxiVehicle.RespawnVehicle()
        set MaybeAgent = false

dirtbike_vehicle_class:=class<concrete>:
    var MaybeAgent : ?agent = false
    @editable DirtBikeVehicle : vehicle_spawner_dirtbike_device = vehicle_spawner_dirtbike_device{}

    RegisterPlayer(A:agent):void=
        set MaybeAgent = option{A}
        DirtBikeVehicle.AgentExitsVehicleEvent.Subscribe(OnExitCar)

    OnExitCar(Agent:agent):void=
        Reset()

    Clear():void=
        set MaybeAgent = false

    Reset():void=
        DirtBikeVehicle.RespawnVehicle()
        set MaybeAgent = false

getaway_vehicle_class:=class<concrete>:
    var MaybeAgent : ?agent = false
    @editable GetAwayVehicle : vehicle_spawner_getaway_device = vehicle_spawner_getaway_device{}

    RegisterPlayer(A:agent):void=
        set MaybeAgent = option{A}
        GetAwayVehicle.AgentExitsVehicleEvent.Subscribe(OnExitCar)

    OnExitCar(Agent:agent):void=
        Reset()

    Clear():void=
        set MaybeAgent = false

    Reset():void=
        GetAwayVehicle.RespawnVehicle()
        set MaybeAgent = false

bus_vehicle_class:=class<concrete>:
    var MaybeAgent : ?agent = false
    @editable BusVehicle : vehicle_spawner_armored_battle_bus_device = vehicle_spawner_armored_battle_bus_device{}

    RegisterPlayer(A:agent):void=
        set MaybeAgent = option{A}
        BusVehicle.AgentExitsVehicleEvent.Subscribe(OnExitCar)

    OnExitCar(Agent:agent):void=
        Reset()

    Clear():void=
        set MaybeAgent = false

    Reset():void=
        BusVehicle.RespawnVehicle()
        set MaybeAgent = false

sportsbike_vehicle_class:=class<concrete>:
    var MaybeAgent : ?agent = false
    @editable SportsBikeVehicle : vehicle_spawner_sportbike_device = vehicle_spawner_sportbike_device{}

    RegisterPlayer(A:agent):void=
        set MaybeAgent = option{A}
        SportsBikeVehicle.AgentExitsVehicleEvent.Subscribe(OnExitCar)

    OnExitCar(Agent:agent):void=
        Reset()

    Clear():void=
        set MaybeAgent = false

    Reset():void=
        SportsBikeVehicle.RespawnVehicle()
        set MaybeAgent = false

pickup_truck_vehicle_class:=class<concrete>:
    var MaybeAgent : ?agent = false
    @editable PickUpTruckVehicle : vehicle_spawner_pickup_truck_device = vehicle_spawner_pickup_truck_device{}

    RegisterPlayer(A:agent):void=
        set MaybeAgent = option{A}
        PickUpTruckVehicle.AgentExitsVehicleEvent.Subscribe(OnExitCar)

    OnExitCar(Agent:agent):void=
        Reset()

    Clear():void=
        set MaybeAgent = false

    Reset():void=
        PickUpTruckVehicle.RespawnVehicle()
        set MaybeAgent = false

quadcrasher_vehicle_class:=class<concrete>:
    var MaybeAgent : ?agent = false
    @editable QuadcrasherVehicle : vehicle_spawner_quadcrasher_device = vehicle_spawner_quadcrasher_device{}

    RegisterPlayer(A:agent):void=
        set MaybeAgent = option{A}
        QuadcrasherVehicle.AgentExitsVehicleEvent.Subscribe(OnExitCar)

    OnExitCar(Agent:agent):void=
        Reset()

    Clear():void=
        set MaybeAgent = false

    Reset():void=
        QuadcrasherVehicle.RespawnVehicle()
        set MaybeAgent = false

nitro_sedan_vehicle_class:=class<concrete>:
    var MaybeAgent : ?agent = false
    @editable NitroSedanVehicle : vehicle_spawner_nitro_drifter_sedan_device = vehicle_spawner_nitro_drifter_sedan_device{}

    RegisterPlayer(A:agent):void=
        set MaybeAgent = option{A}
        NitroSedanVehicle.AgentExitsVehicleEvent.Subscribe(OnExitCar)

    OnExitCar(Agent:agent):void=
        Reset()

    Clear():void=
        set MaybeAgent = false

    Reset():void=
        NitroSedanVehicle.RespawnVehicle()
        set MaybeAgent = false

big_rig_vehicle_class:=class<concrete>:
    var MaybeAgent : ?agent = false
    @editable BigRigVehicle : vehicle_spawner_big_rig_device = vehicle_spawner_big_rig_device{}

    RegisterPlayer(A:agent):void=
        set MaybeAgent = option{A}
        BigRigVehicle.AgentExitsVehicleEvent.Subscribe(OnExitCar)

    OnExitCar(Agent:agent):void=
        Reset()

    Clear():void=
        set MaybeAgent = false

    Reset():void=
        BigRigVehicle.RespawnVehicle()
        set MaybeAgent = false