# Prop Shrink/Grow System
# Creates an interactive system where props can be shrunk or grown by damaging them. Players can toggle between shrink and grow modes using a trigger, then shoot props to dynamically resize them.  **How
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/gist-wahlbeckuefn-shrinkinator?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

shrinkies := class<concrete>():
    @editable PropManip : prop_manipulator_device = prop_manipulator_device{}
    @editable Prop : creative_prop = creative_prop{}
    var ShrinkMode<private> : logic = false

    Init():void=
        PropManip.DamagedEvent.Subscribe(OnPropDamaged)

    ToggleShrinkMode():void=
        if (ShrinkMode?) { set ShrinkMode = false}
        else { set ShrinkMode = true}

    OnPropDamaged<private>(Agent : agent):void=
       ScaleProp()

    ScaleProp():void=
        PropScale := Prop.GetTransform().Scale.X
        if (ShrinkMode?):
            Small := vector3{X:=PropScale - 10.0, Y:=PropScale - 10.0, Z:=PropScale - 10.0}
            Tran := transform{
                Translation := Prop.GetTransform().Translation, 
                Rotation := Prop.GetTransform().Rotation, 
                Scale := Small}
                if (Prop.TeleportTo[Tran]) {}
        else:
            Big := vector3{X:=PropScale + 10.0, Y:=PropScale + 10.0, Z:=PropScale + 10.0}
            Tran := transform{
                Translation := Prop.GetTransform().Translation, 
                Rotation := Prop.GetTransform().Rotation, 
                Scale := Big}
                if (Prop.TeleportTo[Tran]) {}

shrinkinator := class(creative_device):

    @editable Shrinkables :[]shrinkies = array{}
    @editable ShrinkToggle : trigger_device = trigger_device{}

    OnBegin<override>()<suspends>:void=
        ShrinkToggle.TriggeredEvent.Subscribe(OnShrinkToggle)
        for (Shrinkable : Shrinkables):
            Shrinkable.Init()
    
    OnShrinkToggle(Agent : ?agent):void=
        for (Shrinkable : Shrinkables):
            Shrinkable.ToggleShrinkMode()