# Pull Custom Gun
# Verse code for Pull Custom Gun - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/pull-custom-gun?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters}
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/SpatialMath }

PullCustomGun := class(creative_device):

    @editable var Class : int = 0
    @editable ClassTracker : tracker_device = tracker_device{}
    @editable HUDablity : hud_message_device = hud_message_device{}

    @editable PullGun : conditional_button_device = conditional_button_device{}
    @editable PullGunEffect : movement_modulator_device = movement_modulator_device{}
    @editable ItemGranter:item_granter_device = item_granter_device{}
    
    OnBegin<override>()<suspends>:void=
        InitSpawners()
        for (Player : GetPlayspace().GetPlayers(), FortCharacter := Player.GetFortCharacter[]):
            FortCharacter.DamagedEvent().Subscribe(OnPlayerDamaged)
            FortCharacter.DamagedShieldEvent().Subscribe(OnPlayerDamaged)
            
    InitSpawners() : void=
        Spawners := GetCreativeObjectsWithTag(spawner{})
        for (Obj : Spawners):
            if (Spawner := player_spawner_device[Obj]):
                Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

    OnPlayerSpawned(Agent : agent): void=
        if (Player := player[Agent]):
            spawn{GetWeapon(Agent)}

    GetWeapon(Agent : agent)<suspends>:void=
        Sleep(1.0)
        if(ClassTracker.GetValue(Agent) = Class):
            ItemGranter.GrantItem(Agent)
            HUDablity.Show(Agent)
           
    OnPlayerDamaged(DamageResult: damage_result): void = 
        if: 
            Instigator := DamageResult.Instigator?
            Agent := Instigator.GetInstigatorAgent[]
            PullGun.IsHoldingItem[Agent]
            Target:= fort_character[DamageResult.Target]
        then:
                spawn:
                    PushOrPullGunPlayer(Target,Agent)

    PushOrPullGunPlayer(Target : fort_character,Agent:agent)<suspends> : void=
        if(Player := player[Agent],FC:= Player.GetFortCharacter[], TargetAgent := Target.GetAgent[]):
            if(Target = FC):   
                block:
            else:
                FCRotation := FC.GetTransform().Rotation
                DeviceLocation := PullGunEffect.GetTransform().Translation
                NEWRotation := FCRotation.ApplyYaw(3.14)
                if(PullGunEffect.TeleportTo[DeviceLocation,NEWRotation]){}
                    PullGunEffect.Activate(TargetAgent)