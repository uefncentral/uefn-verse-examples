# Monster Reward System
# Manages custom creatures that grant players resources, XP, and display HUD messages when eliminated. The system uses creature spawners with customizable props for different monster states (walking, at
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/monster-managerverse?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Colors/NamedColors }
using { /Fortnite.com/Characters}

#THIS DEVICE CONTROLS CUSTOM CREATURES THAT WILL AWARD PLAYERS A RESOURCE WHEN ELIMINATED

Monster_Manager := class(creative_device):
    @editable GameManager : Game_Manager = Game_Manager{}                   #Game manager to get player info

    @editable MonsterSpawners : []creature_spawner_device = array{}         #Array of creature spawners that spawn the monsters

    @editable MonsterHUD : hud_message_device = hud_message_device{}        #Hud displayed wehn a creature is killed

    @editable MonsterXP : accolades_device = accolades_device{}             #XP granted when a monster is killed

    @editable MonsterResourceType : string = ""                             #Type of resource granted when a monster is killed

    @editable MonsterResourceAmount : float = 0.0                           #Amount of resource granted when a monster is killed


    #Props used to customize monster
    @editable MonsterWalkingProp : creative_prop_asset = DefaultCreativePropAsset
    @editable MonsterAttackingProp : creative_prop_asset = DefaultCreativePropAsset
    @editable MonsterIdleProp : creative_prop_asset = DefaultCreativePropAsset
    @editable MonsterDeathProp : creative_prop_asset = DefaultCreativePropAsset


    OnBegin<override>()<suspends>:void=
        for(Spawner :MonsterSpawners):                          #For all monster spawners
            Spawner.SpawnedEvent.Subscribe(SpawnedR)        #Activates on spawned
            Spawner.EliminatedEvent.Subscribe(Eliminated)   #Activates on eliminated
    

    Eliminated(Result : device_ai_interaction_result) : void=
        if(Agent := Result.Source?):
            if(CP :=GameManager.PlayersMap[Agent]):
                CP.Collect(MonsterResourceAmount,MonsterResourceType)           #Grants the resources to player who eliminated
                MonsterXP.Award(Agent)                                          #Grants XP
                MonsterHUD.Show(Agent)                                          #Shows HUD



    StringToMessage<localizes>(value:string) : message = "{value}"

    SpawnedR(Agent:agent) : void=
        spawn:
            Spawned(Agent)

    Spawned(Agent:agent)<suspends> : void=                                          #Activates when a creature is spawned
        if(FC := Agent.GetFortCharacter[]):
            FC.Hide()                                                               #Hides the creature
            ZombPos := FC.GetTransform().Translation - vector3{Z:=80.0}             #Gets position of creature

            #Spawns Props at creatures location
            MaybeWalkProp := SpawnProp(MonsterWalkingProp,ZombPos,IdentityRotation())         
            MaybeAttackProp := SpawnProp(MonsterAttackingProp,ZombPos,IdentityRotation())
            MaybeIdleProp := SpawnProp(MonsterIdleProp,ZombPos,IdentityRotation())
            MaybeDeathPropProp := SpawnProp(MonsterDeathProp,ZombPos,IdentityRotation())

            #Gets the props spawned
            if:
                WalkProp := MaybeWalkProp(0)?
                AttackProp := MaybeAttackProp(0)?
                IdleProp := MaybeIdleProp(0)?
                DeathProp := MaybeDeathPropProp(0)?
            then:
                var CurrentState : int = 0                                      #Used to check animation state of monster
                DeathProp.Hide()                                                #Hides prop for death animation
                race:
                    block:                              #Waits for creature to die
                        loop:
                            Sleep(0.1)
                            if(not FC.IsActive[]):              
                                # WalkProp.Dispose()  # TODO: Verse has no manual disposal
                                # AttackProp.Dispose()  # TODO: Verse has no manual disposal
                                # IdleProp.Dispose()  # TODO: Verse has no manual disposal
                                DeathProp.Show()                
                                Sleep(1.0)
                                # DeathProp.Dispose()  # TODO: Verse has no manual disposal             
                                return

                    block:                                      #Checks if creature is close enough to any players to begin attack animation
                        loop:
                            Sleep(0.1)
                            ZombP := FC.GetTransform().Translation - vector3{Z:=80.0}
                            for(Player : GetPlayspace().GetPlayers(), PC:=Player.GetFortCharacter[]):
                                PlayerP := PC.GetTransform().Translation
                                if(Distance(PlayerP,ZombP) < 150.0):
                                    WalkProp.Hide()
                                    IdleProp.Hide()
                                    AttackProp.Show()
                                    set CurrentState = 3
           

                    block:                                      #If attack animation is not playing, checks if the creature is idle or moving and shows props accordingly
                        loop:
                            Sleep(0.1)
                            ZombP := FC.GetTransform().Translation - vector3{Z:=80.0}
                            var TempLocation : vector3 = vector3{}
                            set TempLocation = ZombPos
                            Sleep(0.1)
                            NewZombP := FC.GetTransform().Translation - vector3{Z:=80.0}
                            if(Distance(NewZombP,ZombP) > 0.0,CurrentState<>3):
                                WalkProp.Show()
                                IdleProp.Hide()
                                AttackProp.Hide()
                                set CurrentState = 2
                            else:
                                WalkProp.Hide()
                                IdleProp.Show()
                                AttackProp.Hide()
                                set CurrentState = 1


                    loop:                                        #Main loop to move all props to the zombies location
                        Sleep(0.1)
                        ZombP := FC.GetTransform().Translation - vector3{Z:=80.0}
                        ZombR := FC.GetTransform().Rotation
                        spawn:
                            WalkProp.MoveTo(ZombP,ZombR,0.1)
                        spawn:
                            AttackProp.MoveTo(ZombP,ZombR,0.1)
                        spawn:
                            IdleProp.MoveTo(ZombP,ZombR,0.1)
                        spawn:
                            DeathProp.MoveTo(ZombP,ZombR,0.1)
