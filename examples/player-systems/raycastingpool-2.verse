# Raycast Object Pool Manager
# Creates and manages a pool of reusable raycast props to optimize performance by avoiding repeated creation/destruction of objects. The system initializes raycast props from editable parent props and p
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/raycastingpool-2?ref=github

using { /Fortnite.com/AI }
using { /Verse.org/Simulation }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation/Tags }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }

PoolItem:=class:
    Raycast:AdvancedRaycastProp
    var InUse:logic=false
    OriginalPos:vector3

RaycastingPool := class(creative_device):
    @editable ParentProps:[]creative_prop = array{}
    var PoolItems: []PoolItem = array{}

    Start()<suspends>:void=
        Print("boink {ParentProps.Length}")
        if(PoolItems.Length>0):
            return
        Print("starting")
        for(Parent:ParentProps):
            MaybeRaycastingProp :=GetSpawnedPropResources(Parent)
            if(FoundRaycastingProp:= MaybeRaycastingProp?):
                set PoolItems += array{PoolItem{Raycast:=FoundRaycastingProp, OriginalPos:=FoundRaycastingProp.Parent.GetTransform().Translation}}
                FoundRaycastingProp.DistanceProp.MoveTo(FoundRaycastingProp.DistanceProp.GetTransform().Translation.Up(800.0), IdentityRotation(), 0.01)
                FoundRaycastingProp.ScaleProp.MoveTo(transform{
                    Translation:=FoundRaycastingProp.ScaleProp.GetTransform().Translation.Up(800.0)
                    Rotation:=IdentityRotation()
                    Scale:=vector3{X:=0.01,Y:=0.01,Z:=50.0}
                }, 0.01)
                Print("pool item added")
        Print("total {PoolItems.Length} pool items added")

    GetRaycast(CB(Prop:AdvancedRaycastProp)<suspends>:void)<suspends>:void=
        Start()
        Print("getting raycast {PoolItems.Length} pool items")
        for(Item:PoolItems):
            if(Item.InUse = false):
                set Item.InUse=true
                Print("Raycast item found")
                CB(Item.Raycast)

                Print("Raycast item returned")
                set Item.InUse=false

    

