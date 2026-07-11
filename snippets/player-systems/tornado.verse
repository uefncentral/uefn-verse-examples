# Tornado Effect System
# Creates a tornado-like effect using multiple explosive devices triggered in sequence when activated. The system tracks player classes and displays HUD messages while spawning visual effects and explos
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/tornado?ref=github


<# 
|
|    ███████╗ ██╗   ██╗ ██████╗  ██╗  ██╗  █████╗  ██████╗  ██╗  █████╗  ██╗  ██╗
|    ██╔════╝ ██║   ██║ ██╔══██╗ ██║  ██║ ██╔══██╗ ██╔══██╗ ██║ ██╔══██╗ ╚██╗██╔╝
|    █████╗   ██║   ██║ ██████╔╝ ███████║ ██║  ██║ ██████╔╝ ██║ ███████║  ╚███╔╝
|    ██╔══╝   ██║   ██║ ██╔═══╝  ██╔══██║ ██║  ██║ ██╔══██╗ ██║ ██╔══██║  ██╔██╗
|    ███████╗ ╚██████╔╝ ██║      ██║  ██║ ╚█████╔╝ ██║  ██║ ██║ ██║  ██║ ██╔╝╚██╗
|    ╚══════╝  ╚═════╝  ╚═╝      ╚═╝  ╚═╝  ╚════╝  ╚═╝  ╚═╝ ╚═╝ ╚═╝  ╚═╝ ╚═╝  ╚═╝
|
#>

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/Verse }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters }
using { /Fortnite.com/FortPlayerUtilities }
#VERSE SCRIPT
#A device that spawns a Blueprint Prop (in the example shown, inside is a Niagra Particle System Component) upon player death

#TO-DO: 
# - Drag your Blueprint with a Niagra System inside, from your content browser, into the details panel into "DeathNiagraFX"
# - Select your Elimination Manager Device in the details panel

TornadoEffect := class(creative_device):

    @editable var Class : int = 0
    @editable ClassTracker : tracker_device = tracker_device{}
    @editable HUDablity : hud_message_device = hud_message_device{}

    @editable 
    TheLog : creative_prop= creative_prop{}
    @editable
    explosive_device1 : explosive_device = explosive_device {}
    @editable
    explosive_device2 : explosive_device = explosive_device {}
    @editable
    explosive_device3 : explosive_device = explosive_device {}
    @editable
    explosive_device4 : explosive_device = explosive_device {}
    @editable
    explosive_device5 : explosive_device = explosive_device {}
    @editable
    explosive_device6 : explosive_device = explosive_device {}
    @editable 
    EffectDuration : float = 15.0
    @editable
    MyRemote : signal_remote_manager_device = signal_remote_manager_device{}
    @editable
    ItemGranter: item_granter_device = item_granter_device{}
    @editable # Detector button to check if signal remote is being held (not fully functional)
    HeldDetector : conditional_button_device = conditional_button_device{}
    @editable
    BeginPlace : vector3 = vector3{ X :=1000.0, Y := 1000.0, Z := 1000.0}
    @editable
    BeginScale : vector3 = vector3{ X := 1.0, Y := 1.0, Z := 1.33333 }
    @editable
    ExplosionLine:creative_prop = creative_prop{}
    var AgentMap : [agent]transform = map{}


    OnBegin<override>()<suspends>:void=
        MyRemote.PrimarySignalEvent.Subscribe(SetLocation)
        MyRemote.SecondarySignalEvent.Subscribe(SetLocation)
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

    SetLocation(Agent : agent):void=
        if(ClassTracker.GetValue(Agent) = Class):
            if:
                FortCharacter := Agent.GetFortCharacter[]
                set AgentMap[Agent] = FortCharacter.GetTransform()
            then:
                Print("Location Set:  {FortCharacter.GetTransform().Translation} {FortCharacter.GetTransform().Rotation}")
                if(Fort := Agent.GetFortCharacter[]): ### getting fort_character from the Agent

                    FortTransform := Fort.GetTransform() ### getting transform
                    Position := FortTransform.Translation ### getting Position
                    Rotation := FortTransform.Rotation ### Rotation
                    if(TheLog.TeleportTo[Position + vector3{Z:=-40.0}, Rotation]):
                        if(ExplosionLine.TeleportTo[Position + vector3{Z:=-40.0}, Rotation]):
                            spawn:
                                Explosion(Agent)
                    
    Explosion(Agent: agent)<suspends>:void=
        if(ClassTracker.GetValue(Agent) = Class):
            explosive_device1.Explode(Agent)
            Sleep(0.4)
            explosive_device2.Explode(Agent)
            Sleep(0.9)
            explosive_device3.Explode(Agent)
            Sleep(0.9)
            explosive_device4.Explode(Agent)
            Sleep(0.85)
            explosive_device5.Explode(Agent)
            spawn:
                ResetExplosions(Agent)

    ResetExplosions(Agent: agent)<suspends>:void=
        Print("resetting")
        explosive_device1.Reset
        explosive_device2.Reset
        explosive_device3.Reset
        explosive_device4.Reset
        explosive_device5.Reset
        explosive_device6.Reset
        spawn:
            ResetLogExplosions(Agent)

    ResetLogExplosions(Agent:agent)<suspends>:void=

        Print("ResettingExplosion+logline")

        if:
            FortCharacter := Agent.GetFortCharacter[]
            set AgentMap[Agent] = FortCharacter.GetTransform()
        then:
            Print("Location Set:  {FortCharacter.GetTransform().Translation} {FortCharacter.GetTransform().Rotation}")
            if(Fort := Agent.GetFortCharacter[]):

                Print("1")

                FortTransform := Fort.GetTransform() 
                Rotation := FortTransform.Rotation 
                if(TheLog.TeleportTo[BeginPlace + vector3{Z:=0.0}, Rotation]):
                    Print("2")
                    spawn:
                        ResetLogExplosions2(Agent)


    ResetLogExplosions2(Agent:agent)<suspends>:void=

        if:
            FortCharacter := Agent.GetFortCharacter[]
            set AgentMap[Agent] = FortCharacter.GetTransform()
        then:
            Print("Location Set:  {FortCharacter.GetTransform().Translation} {FortCharacter.GetTransform().Rotation}")
            if(Fort := Agent.GetFortCharacter[]):
                FortTransform := Fort.GetTransform() 
                Rotation := FortTransform.Rotation 
                if(ExplosionLine.TeleportTo[BeginPlace + vector3{Z:=2.0}, Rotation]):
                    Print("3")
                    Print("Explosive devices reset")


<# 
|
|    ███████╗ ██╗   ██╗ ██████╗  ██╗  ██╗  █████╗  ██████╗  ██╗  █████╗  ██╗  ██╗
|    ██╔════╝ ██║   ██║ ██╔══██╗ ██║  ██║ ██╔══██╗ ██╔══██╗ ██║ ██╔══██╗ ╚██╗██╔╝
|    █████╗   ██║   ██║ ██████╔╝ ███████║ ██║  ██║ ██████╔╝ ██║ ███████║  ╚███╔╝
|    ██╔══╝   ██║   ██║ ██╔═══╝  ██╔══██║ ██║  ██║ ██╔══██╗ ██║ ██╔══██║  ██╔██╗
|    ███████╗ ╚██████╔╝ ██║      ██║  ██║ ╚█████╔╝ ██║  ██║ ██║ ██║  ██║ ██╔╝╚██╗
|    ╚══════╝  ╚═════╝  ╚═╝      ╚═╝  ╚═╝  ╚════╝  ╚═╝  ╚═╝ ╚═╝ ╚═╝  ╚═╝ ╚═╝  ╚═╝
|
#>