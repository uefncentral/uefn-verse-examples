# Fortnite Medallion System
# Creates a collectible medallion system with three different types: Nitro (speed boost), Regenerating (health restoration), and Infinite Ammo medallions. Each medallion can be picked up by players thro
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/medalionss?ref=github

using { /Verse.org/Random }
using { /Fortnite.com/Game }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }

#Color for the TakingVHX: (R=0.893750,G=0.263138,B=0.000000,A=1.000000)

nitro_medallion_inf:=struct<concrete>:

    @editable
    Nitro_Medallion: creative_prop = creative_prop{}

    @editable
    Button : button_device = button_device{}

    @editable
    NitroClassSelector : class_and_team_selector_device = class_and_team_selector_device{}

    @editable
    DefaultClassSelector : class_and_team_selector_device = class_and_team_selector_device{}

    @editable
    PropManipulator : prop_manipulator_device = prop_manipulator_device{}

    @editable
    RedPowerup : visual_effect_powerup_device = visual_effect_powerup_device{}

    @editable
    TakingVFX : visual_effect_powerup_device = visual_effect_powerup_device{}


regenerating_medallion_inf:=struct<concrete>:

    @editable
    MaxHealth : float = 75.0

    @editable
    HealNum : float = 5.0

    @editable
    Button : button_device = button_device{}

    @editable
    The_Regen_Medallion : creative_prop = creative_prop{}

    @editable
    PropManipulator : prop_manipulator_device = prop_manipulator_device{}

    @editable
    TakingVFX : visual_effect_powerup_device = visual_effect_powerup_device{}

inf_ammo_medallion_inf:=struct<concrete>:

    @editable
    Inf_Ammo_Medallion: creative_prop = creative_prop{}

    @editable
    Button : button_device = button_device{}

    @editable
    InfAmmoClassSelector : class_and_team_selector_device = class_and_team_selector_device{}

    @editable
    ClassSelector : class_and_team_selector_device = class_and_team_selector_device{}

    @editable
    PropManipulator : prop_manipulator_device = prop_manipulator_device{}

    @editable
    TakingVFX : visual_effect_powerup_device = visual_effect_powerup_device{}


MedallionTaker := class():
    MyAgentObj:agent
    
    var Nitro : int = 0
    var Health : int = 0
    var Ammo : int = 0

    HasMedallionNitro():int=
        return Nitro

    SetMedallionNitro(N:int):void=
        set Nitro = N

    HasMedallionHealth():int=
        return Health

    SetMedallionHealth(H:int):void=
        set Health = H

    HasMedallionAmmo():int=
        return Ammo
    
    SetMedallionAmmo(A:int):void=
        set Ammo = A

AllMedallions := class(creative_device):
    
    var PlayersMap:[agent]CustomPlayerr=map{}

    var MedallionsMap:[agent]MedallionTaker=map{}

    @editable
    NitroClass : int = 2

    @editable
    AmmoClass : int = 3

    @editable
    ExtraClass : int = 4 

    @editable
    ExtraClassSelector : class_and_team_selector_device = class_and_team_selector_device{}

    @editable
    NitroMedallion : nitro_medallion_inf = nitro_medallion_inf{}

    @editable
    RegeneratingMedallion : regenerating_medallion_inf = regenerating_medallion_inf{}

    @editable
    AmmoMedallion : inf_ammo_medallion_inf = inf_ammo_medallion_inf{}

    OnBegin<override>()<suspends>:void=
        AllPlayers := GetPlayspace().GetPlayers()
        for (Player : AllPlayers):
            if(Agent := agent[Player]):
                OnStart(Agent)
        #Nitro Medallion start
        NitroMedallionTransform := NitroMedallion.Nitro_Medallion.GetTransform()
        NitroPosition := NitroMedallionTransform.Translation
        NitroRotation := NitroMedallionTransform.Rotation        
        NitroMedallion.TakingVFX.Despawn()
        NitroMedallion.RedPowerup.Despawn()
        if:
            NitroMedallion.Button.TeleportTo[NitroPosition, NitroRotation]
            NitroMedallion.TakingVFX.TeleportTo[NitroPosition, NitroRotation]
            NitroMedallion.PropManipulator.TeleportTo[NitroPosition, NitroRotation]
        then:
            NitroMedallion.Button.InteractedWithEvent.Subscribe(AfterInteractionNitro)

        #InfAmmo Medallion start
        RegenMedallionTransform := AmmoMedallion.Inf_Ammo_Medallion.GetTransform()
        RegenPosition := RegenMedallionTransform.Translation
        RegenRotation := RegenMedallionTransform.Rotation
        AmmoMedallion.TakingVFX.Despawn()
        if:
            AmmoMedallion.Button.TeleportTo[RegenPosition, RegenRotation]
            AmmoMedallion.TakingVFX.TeleportTo[RegenPosition, RegenRotation]
            AmmoMedallion.PropManipulator.TeleportTo[RegenPosition, RegenRotation]
        then:
            AmmoMedallion.Button.InteractedWithEvent.Subscribe(AfterInteractionAmmo)

        #Regen Medallion start
        MedallionTransform := RegeneratingMedallion.The_Regen_Medallion.GetTransform()
        Position := MedallionTransform.Translation
        Rotation := MedallionTransform.Rotation
        RegeneratingMedallion.TakingVFX.Despawn()
        if:
            RegeneratingMedallion.Button.TeleportTo[Position, Rotation]
            RegeneratingMedallion.TakingVFX.TeleportTo[Position, Rotation]
            RegeneratingMedallion.PropManipulator.TeleportTo[Position, Rotation]
        then:
            RegeneratingMedallion.Button.InteractedWithEvent.Subscribe(AfterInteractionRegen)



    OnStart(Agent: agent):void=
        if(PlayerExists := PlayersMap[Agent]):
            #do nothing
        else:
            CP:CustomPlayerr = CustomPlayerr{MyAgentObj:= Agent}
            option:
                set PlayersMap[Agent] = CP

        if(PlayerExists := MedallionsMap[Agent]):
            #do nothing
        else:
            MT:MedallionTaker = MedallionTaker{MyAgentObj:= Agent}
            option:
                set MedallionsMap[Agent] = MT

    #Nitro Medallion funcs
    AfterInteractionNitro(Agent : agent):void=
        if (CP:CustomPlayerr = PlayersMap[Agent]):
            CurClass := CP.GetClass()
            if (CurClass = AmmoClass):
                ExtraClassSelector.ChangeClass(Agent)
                CP.SetClass(ExtraClass)
            else:
                NitroMedallion.NitroClassSelector.ChangeClass(Agent)
                CP.SetClass(NitroClass)

        if (MT:MedallionTaker = MedallionsMap[Agent]):
            MT.SetMedallionNitro(1)
        NitroMedallion.Button.Disable()
        NitroMedallion.PropManipulator.HideProps()
        NitroMedallion.TakingVFX.Spawn()
        NitroMedallion.RedPowerup.Spawn()

        NitroMedallion.RedPowerup.Pickup(Agent)
        NitroMedallion.TakingVFX.Pickup(Agent)

        NitroMedallion.RedPowerup.Despawn()
        NitroMedallion.TakingVFX.Despawn()
        if (FC: fort_character = Agent.GetFortCharacter[]):
            FC.EliminatedEvent().Subscribe(OnEliminatedNitro)

    OnEliminatedNitro(ElimRes : elimination_result):void=
        DeadOwner := ElimRes.EliminatedCharacter
        if (Agent := DeadOwner.GetAgent[]):
            if (MT:MedallionTaker = MedallionsMap[Agent]):
                HasIt := MT.HasMedallionNitro()
                if (HasIt = 1):
                    NitroMedallion.DefaultClassSelector.ChangeClass(Agent)
                    NitroMedallion.PropManipulator.ShowProps()
                    FortTransform := DeadOwner.GetTransform()
                    Position := FortTransform.Translation
                    Rotation := FortTransform.Rotation
                    RandomNitroYNitro := GetRandomFloat(-100.0,100.0)
                    RandomNitroXNitro := GetRandomFloat(-100.0,100.0)
                    NewYNitro := Position.Y + RandomNitroYNitro
                    NewXNitro := Position.X + RandomNitroXNitro
                    NewVerctor := vector3 {X:=NewXNitro, Y:=NewYNitro, Z:=Position.Z}
                    MT.SetMedallionNitro(0)
                    res := MT.HasMedallionNitro()
                    if:
                        NitroMedallion.Nitro_Medallion.TeleportTo[NewVerctor, Rotation]
                        NitroMedallion.PropManipulator.TeleportTo[NewVerctor, Rotation]
                        NitroMedallion.Button.TeleportTo[NewVerctor, Rotation]
                        NitroMedallion.TakingVFX.TeleportTo[NewVerctor, Rotation]
                    then:
                        NitroMedallion.Button.Enable()
                else:
                    #do nothing

    
    #Ammo Medallion funcs
    AfterInteractionAmmo(Agent : agent):void=
        Print("Class func has been started")
        if (CP:CustomPlayerr = PlayersMap[Agent]):
            CurClass := CP.GetClass()
            if (CurClass = NitroClass):
                ExtraClassSelector.ChangeClass(Agent)
                CP.SetClass(ExtraClass)
            else:
                AmmoMedallion.InfAmmoClassSelector.ChangeClass(Agent)
                CP.SetClass(AmmoClass)

        if (MT:MedallionTaker = MedallionsMap[Agent]):
            MT.SetMedallionAmmo(1)
        AmmoMedallion.Button.Disable()
        AmmoMedallion.PropManipulator.HideProps()

        AmmoMedallion.TakingVFX.Spawn()
        AmmoMedallion.TakingVFX.Pickup(Agent)
        AmmoMedallion.TakingVFX.Despawn()
        
        if (FC: fort_character = Agent.GetFortCharacter[]):
            FC.EliminatedEvent().Subscribe(OnEliminatedAmmo)

    OnEliminatedAmmo(ElimRes : elimination_result):void=
        DeadOwner := ElimRes.EliminatedCharacter
        if (Agent := DeadOwner.GetAgent[]):
            if (MT:MedallionTaker = MedallionsMap[Agent]):
                HasItNitro := MT.HasMedallionAmmo()
                if (HasItNitro = 1):
                    AmmoMedallion.ClassSelector.ChangeClass(Agent)
                    AmmoMedallion.PropManipulator.ShowProps()
                    FortTransform := DeadOwner.GetTransform()
                    Position := FortTransform.Translation
                    Rotation := FortTransform.Rotation
                    RandomNitroYAmmo := GetRandomFloat(-100.0,100.0)
                    RandomNitroXAmmo := GetRandomFloat(-100.0,100.0)
                    NewYAmmo := Position.Y + RandomNitroYAmmo
                    NewXAmmo := Position.X + RandomNitroXAmmo
                    NewVerctorAmmo := vector3 {X:=NewXAmmo, Y:=NewYAmmo, Z:=Position.Z}
                    MT.SetMedallionAmmo(0)
                    res := MT.HasMedallionNitro()
                    if:
                        AmmoMedallion.Inf_Ammo_Medallion.TeleportTo[NewVerctorAmmo, Rotation]
                        AmmoMedallion.PropManipulator.TeleportTo[NewVerctorAmmo, Rotation]
                        AmmoMedallion.Button.TeleportTo[NewVerctorAmmo, Rotation]
                        AmmoMedallion.TakingVFX.TeleportTo[NewVerctorAmmo, Rotation]
                    then:
                        AmmoMedallion.Button.Enable()
                else:
                    #do nothing

    
    #Regen Medallion funcs
    IfHasMedallion(Agent : agent)<suspends>:void=
        loop:
            Sleep(1.0)
            if (CP:CustomPlayerr = PlayersMap[Agent]):
                CurItem := CP.GetItem()
                if (CurItem = 1):
                    if (FC:= Agent.GetFortCharacter[]):
                        if (FC.GetShield() < RegeneratingMedallion.MaxHealth):
                            ShiledRenewal(FC)

    ShiledRenewal(FC : fort_character):void=
        var CurShield : float = 0.0
        if (FC.GetShield() < RegeneratingMedallion.MaxHealth):
            set CurShield = FC.GetShield() 
            Rest := RegeneratingMedallion.MaxHealth - CurShield - RegeneratingMedallion.HealNum
            if (Rest <= 0.0):
                set CurShield = CurShield + RegeneratingMedallion.HealNum + Rest
            else:
                set CurShield = CurShield + RegeneratingMedallion.HealNum
            FC.SetShield(CurShield)

    AfterInteractionRegen(Agent : agent):void=
        if (CP:CustomPlayerr = PlayersMap[Agent]):
            CurClass := CP.SetItem(1)
        RegeneratingMedallion.Button.Disable()
        RegeneratingMedallion.PropManipulator.HideProps()
        
        RegeneratingMedallion.TakingVFX.Spawn()
        RegeneratingMedallion.TakingVFX.Pickup(Agent)
        RegeneratingMedallion.TakingVFX.Despawn()
        if (MT:MedallionTaker = MedallionsMap[Agent]):
            MT.SetMedallionHealth(1)
        
        if (FC: fort_character = Agent.GetFortCharacter[]):
            FC.EliminatedEvent().Subscribe(OnEliminatedRegen)

        spawn:
            IfHasMedallion(Agent)

    OnEliminatedRegen(ElimRes : elimination_result):void=
        DeadOwner := ElimRes.EliminatedCharacter
        if (Agent := DeadOwner.GetAgent[]):
            if (MT:MedallionTaker = MedallionsMap[Agent]):
                HasIt := MT.HasMedallionHealth()
                if (HasIt = 1):
                    if (CP:CustomPlayerr = PlayersMap[Agent]):
                        CurClass := CP.SetItem(0)
                    RegeneratingMedallion.PropManipulator.ShowProps()
                    FortTransform := DeadOwner.GetTransform()
                    Position := FortTransform.Translation
                    Rotation := FortTransform.Rotation
                    RandomNitroYRegen := GetRandomFloat(-100.0,100.0)
                    RandomNitroXRegen := GetRandomFloat(-100.0,100.0)
                    NewYRegen := Position.Y + RandomNitroYRegen
                    NewXRegen := Position.X + RandomNitroXRegen
                    NewVerctorRegen := vector3 {X:=NewXRegen, Y:=NewYRegen, Z:=Position.Z}
                    MT.SetMedallionHealth(0)
                    if:
                        RegeneratingMedallion.The_Regen_Medallion.TeleportTo[NewVerctorRegen, Rotation]
                        RegeneratingMedallion.PropManipulator.TeleportTo[NewVerctorRegen, Rotation]
                        RegeneratingMedallion.Button.TeleportTo[NewVerctorRegen, Rotation]
                        RegeneratingMedallion.TakingVFX.TeleportTo[NewVerctorRegen, Rotation]
                    then:
                        RegeneratingMedallion.Button.Enable()
                else:
                    #do nothing