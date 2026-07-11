# Proximity Damage Trap
# This code creates a damage volume that automatically activates when a player enters the detection range of a perception trigger and deactivates when they leave. It provides visual feedback through con
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/nodamage?ref=github

using { /Fortnite.com/Devices }

DamageVolumeController := class(creative_device):

    @editable
    DamageVolume: damage_volume_device = damage_volume_device{}

    @editable
    PerceptionTrigger: perception_trigger_device =  perception_trigger_device{}

    OnBegin<override>()<suspends>: void=

        PerceptionTrigger.DeviceSeesAgentEvent.Subscirbe(OnPlayerFound)
        PerceptionTrigger.DeviceLosesSightOfAgentEvent.Subscribe(OnPlayerLost)

    OnPlayerFound(Agent:agent):void=

        Print("I See You!")
        DamageVolume.Enable()

    OnPlayerLost(Agent:agent):void=

        Print("Where You Go?")
        DamageVolume.Disable()