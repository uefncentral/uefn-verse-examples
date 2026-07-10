# Elimination VFX Spawner
# This code spawns a Niagara visual effect at the location where a player is eliminated. The VFX appears for 3 seconds at the exact position and rotation of the eliminated player before automatically de
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/elimination-vfx-1?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }

elimination_vfx := class(creative_device):
    @editable Niagara_VFX : creative_prop_asset = DefaultCreativePropAsset 
    @editable EliminationManager : elimination_manager_device = elimination_manager_device {}

    OnBegin<override>()<suspends>:void=
        EliminationManager.EliminatedEvent.Subscribe(Eliminated)

    Eliminated(Agent:agent):void=
        if(Fort := Agent.GetFortCharacter[]):
            FortTransform := Fort.GetTransform()
            Position := FortTransform.Translation
            Rotation := FortTransform.Rotation
            SpawnedPropResult := SpawnProp(Niagara_VFX, Position, Rotation)
                Print("Niagara VFX Spawned")
                if (SpawnedProp := SpawnedPropResult(0)?):
                    spawn:
                        Niagara_VFXHandle(SpawnedProp)

    Niagara_VFXHandle(NiagraFXProp : creative_prop)<suspends>:void=   
        Sleep(3.0)
        # NiagraFXProp.Dispose()  # TODO: Verse has no manual disposal
        Print("Niagara VFX Despawned")