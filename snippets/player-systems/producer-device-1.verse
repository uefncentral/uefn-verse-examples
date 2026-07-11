# Producer Device Manager
# Creates a system for managing producer devices in UEFN using tags. The code defines a producer_device class that extends creative_device with state management capabilities, and provides functionality 
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/producer-device-1?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }

using { Tableau }

producer_tag := class(tag){}
producer_device<public> := class(creative_device):
    # Entity State Management
    @editable InitialState<public>:producer = producer{}

LoadProducerDevices<public>():[]producer_device=
    TaggedDevices := GetCreativeObjectsWithTag(producer_tag{})
    for(Index -> Tagged : TaggedDevices, Device := producer_device[Tagged]). Device
