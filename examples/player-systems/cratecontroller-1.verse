# Interactive Crate System
# Creates an interactive crate that players can activate via a button to receive rewards. When a player interacts with the button, they receive items from the item granter and both the button and waypoi
# Difficulty: beginner  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/cratecontroller-1?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }

CrateController<public> := class<unique><concrete>():

    @editable Button : button_device = button_device{}
    @editable Waypoint : beacon_device = beacon_device{}
    @editable Reward : item_granter_device = item_granter_device{}
    _CrateService : CrateService = CrateService{}

    Initialize():void=
        Button.InteractedWithEvent.Subscribe(HandleInteractedWithEvent)
        buttonTransform := Button.GetTransform().Translation
        if(Waypoint.TeleportTo[vector3{X:=buttonTransform.X, Y:=buttonTransform.Y, Z:= buttonTransform.Z}, IdentityRotation()]):

    HandleInteractedWithEvent(Agent:agent):void=
        _CrateService.HandleEvent(Agent, Reward)
        Button.Disable()
        Waypoint.Disable()