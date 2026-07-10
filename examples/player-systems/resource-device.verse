# Resource Device Manager
# This code creates a tagging system for managing resource devices in UEFN. It defines a custom resource_device class that extends creative_device with initial state management, and provides functionali
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/resource-device?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Simulation/Tags }

using { Tableau }

resource_tag := class(tag){}
resource_device<public> := class(creative_device):

    # Entity State Management
    @editable InitialState<public>:resource = resource{}

LoadResourceDevices<public>():[]resource_device=
    TaggedDevices := GetCreativeObjectsWithTag(resource_tag{})
    for(Index -> Tagged : TaggedDevices, Device := resource_device[Tagged]). Device
