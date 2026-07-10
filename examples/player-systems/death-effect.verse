# Death Effect
# Verse code for Death Effect - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/death-effect?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
#VERSE SCRIPT
#A device that spawns a Blueprint Prop (in the example shown, inside is a Niagra Particle System Component) upon player death

#TO-DO: 
eliminationvfx := class(creative_device):

    @editable 
    DeathNiagraFX : creative_prop_asset = DefaultCreativePropAsset 
    @editable 
    ElimMan : elimination_manager_device = elimination_manager_device {}
    @editable 
    EffectDuration : float = 15.0

    OnBegin<override>()<suspends>:void=

        ElimMan.EliminatedEvent.Subscribe(Eliminated) ###gets the eliminated Agent

    Eliminated(Agent:agent):void=

        if(Fort := Agent.GetFortCharacter[]): ### getting fort_character from the Agent

            FortTransform := Fort.GetTransform() ### getting transform
            Position := FortTransform.Translation ### getting Position
            Rotation := FortTransform.Rotation ### Rotation
            SpawnedPropResult := SpawnProp(DeathNiagraFX, Position, Rotation) ### spawning a creative_prop_asset

                Print("spawned NiagraFX") ###Print-Log
                if (SpawnedProp := SpawnedPropResult(0)?): ###making it into a useable creative_prop
                    Print("spawnedProp") ###Print-Log
                    spawn:
                        DeathNiagraFXHandle(SpawnedProp) ###spawning async function passing in the creative_prop

    DeathNiagraFXHandle(NiagraFXProp : creative_prop)<suspends>:void=
        Sleep(EffectDuration) ### Put in how long you want the niagra particle system to last before being destroyed
        # NiagraFXProp.Dispose()  # TODO: Verse has no manual disposal ###destroys the niagra system
        Print("despawned niagrafx")   ### Print-Log
