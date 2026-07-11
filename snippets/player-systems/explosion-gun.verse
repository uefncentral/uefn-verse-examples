# Explosion Gun
# Verse code for Explosion Gun - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/explosion-gun?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters}
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/SpatialMath }

ExplosionGUN := class(creative_device):
    @editable GameStartDevice : GameStart = GameStart{}
    @editable ExplosionGunClassNumber : int = 100
    @editable ClassRequirement : int = 0
    #0 : no class requirement
    #1 : class requirement

    @editable ExplodeGUNConditional: conditional_button_device = conditional_button_device{}
    @editable ExplodeGUNExploder : explosive_device = explosive_device{}
    @editable ExplodeGUNVFX : vfx_spawner_device = vfx_spawner_device{}
    @editable ExplodeGUNSound : audio_player_device = audio_player_device{}

    @editable ExplodeGUNItemRemover : item_remover_device = item_remover_device{}
    @editable ExplodeGUNItemGranter : item_granter_device = item_granter_device{}
    @editable ExplodeGUNCooldownTime : float = 0.0


    OnBegin<override>()<suspends>:void=
        for (Player : GetPlayspace().GetPlayers(), FortCharacter := Player.GetFortCharacter[]):
            FortCharacter.DamagedEvent().Subscribe(OnPlayerDamaged)
            FortCharacter.DamagedShieldEvent().Subscribe(OnPlayerDamaged)
    OnPlayerDamaged(DamageResult: damage_result): void = 
        if: 
            Instigator := DamageResult.Instigator?
            Agent := Instigator.GetInstigatorAgent[]
            ExplodeGUNConditional.IsHoldingItem[Agent]
            Target:= fort_character[DamageResult.Target]
        then:
            if(ClassRequirement = 0):
                spawn:
                    ExplodePlayer(Target,Agent)
            else if(ClassRequirement = 1):
                if(GameStartDevice.EachPlayerMap[Agent].ClassNum = ExplosionGunClassNumber):
                    spawn:
                        ExplodePlayer(Target,Agent)
                else:

    ExplodePlayer(Target : fort_character,Agent:agent)<suspends> : void=
        if(Player := player[Agent], FC:= Player.GetFortCharacter[]):
            if(Target = FC):
                block:
            else:
                spawn:
                    RemoveandGive(Agent)
                if(TargetAgent := Target.GetAgent[]):
                    TargetPOS := Target.GetTransform().Translation
                    if(ExplodeGUNExploder.TeleportTo[TargetPOS,ExplodeGUNExploder.GetTransform().Rotation]){}
                    if(ExplodeGUNVFX.TeleportTo[TargetPOS,ExplodeGUNVFX.GetTransform().Rotation]){}
                    ExplodeGUNSound.Play(TargetAgent)
                    ExplodeGUNExploder.Explode(Agent)
                    ExplodeGUNVFX.Enable()
                    Sleep(0.1)
                    if(ExplodeGUNExploder.TeleportTo[vector3{X:=1000.0,Y:=1000.0,Z:=1000.0},ExplodeGUNExploder.GetTransform().Rotation]){}
                    if(ExplodeGUNVFX.TeleportTo[vector3{X:=1000.0,Y:=1000.0,Z:=1000.0},ExplodeGUNVFX.GetTransform().Rotation]){}
                    ExplodeGUNVFX.Disable()


    RemoveandGive(Agent : agent)<suspends> : void=
        ExplodeGUNItemRemover.Remove(Agent)
        Sleep(ExplodeGUNCooldownTime)
        ExplodeGUNItemGranter.GrantItem(Agent)
