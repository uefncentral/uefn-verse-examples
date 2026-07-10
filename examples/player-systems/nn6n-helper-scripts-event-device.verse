# Event Publisher-Subscriber System
# Creates a pub-sub pattern using tags to manage communication between devices. Event devices can emit signals that subscriber devices listen for and respond to with custom actions.  **How to use:** Add
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/nn6n-helper-scripts-event-device?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation/Tags }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Simulation }
event_tag := class(tag){}
event_device := class(creative_device):
    Event<public>:event() = event(){}
    Emit<public>():void=
        Event.Signal()
pub_sub_device := class(creative_device):
    #@editable # alternative to using event_tag:
    #Emits:event_device = event_device{}
    Subscribe(TaggedDevice:event_device)<suspends>:void=
        TaggedDevice.Event.Await()
        spawn{Subscribe(TaggedDevice)} #if retriggerable
        Print("Hello, event")
    OnBegin<override>()<suspends>:void=
        All := GetCreativeObjectsWithTag(event_tag{})
        for (Tagged : All, TaggedDevice := event_device[Tagged]):
            spawn{Subscribe(TaggedDevice)} # subscribe example
            TaggedDevice.Emit()            # publish example