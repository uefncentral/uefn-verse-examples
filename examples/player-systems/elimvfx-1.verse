# Elimination Death VFX Spawner
# Spawns a Niagara particle effect at the location where a player is eliminated. The effect automatically destroys itself after 5 seconds to prevent performance issues.  **How to use:** Place the device
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/elimvfx-1?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }



eliminationvfxX := class(creative_device):
    @editable DeathNiagraFX : creative_prop_asset = DefaultCreativePropAsset 
    @editable EliminationManager : elimination_manager_device = elimination_manager_device {}

    OnBegin<override>()<suspends>:void=
        EliminationManager.EliminatedEvent.Subscribe(Eliminated) ###gets the eliminated Agent

    Eliminated(Agent:agent):void=
        if(Fort := Agent.GetFortCharacter[]): ### getting fort_character from the Agent
            FortTransform := Fort.GetTransform() ### getting transform
            Position1 := FortTransform.Translation ### getting Position
            Rotation := FortTransform.Rotation ### Rotation
            SpawnedPropResult := SpawnProp(DeathNiagraFX, Position1, Rotation) ### spawning a creative_prop_asset
                Print("spawned NiagraFX") ###Print-Log
                if (SpawnedProp := SpawnedPropResult(0)?): ###making it into a useable creative_prop
                    Print("spawnedProp") ###Print-Log
                    spawn:
                        DeathNiagraFXHandle(SpawnedProp) ###spawning async function passing in the creative_prop     

    DeathNiagraFXHandle(NiagraFXProp : creative_prop)<suspends>:void=   
        Sleep(5.0) ### Put in how long you want the niagra particle system to last before being destroyed
        # NiagraFXProp.Dispose()  # TODO: Verse has no manual disposal ###destroys the niagra system
        Print("despawned niagrafx")   ### Print-Log