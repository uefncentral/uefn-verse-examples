# Weapon Pickup System
# Create custom weapon pickup points with respawn timers and visual indicators.
# Difficulty: beginner  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/weapon-pickup-system?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/Game }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# Weapon pickup with respawn timer
weapon_pickup_point := class(creative_device):

    @editable
    ItemGranter : item_granter_device = item_granter_device{}

    @editable
    PickupTrigger : trigger_device = trigger_device{}

    @editable
    RespawnTime : float = 30.0

    @editable
    PickupVFX : vfx_spawner_device = vfx_spawner_device{}

    @editable
    RespawnVFX : vfx_spawner_device = vfx_spawner_device{}

    @editable
    PickupAudio : audio_player_device = audio_player_device{}

    var IsAvailable : logic = true

    OnBegin<override>()<suspends> : void =
        PickupTrigger.TriggeredEvent.Subscribe(OnPickupAttempt)
        ShowPickupAvailable()

    OnPickupAttempt(MaybeAgent : ?agent) : void =
        if (IsAvailable?):
            if (Agent := MaybeAgent?):
                PickupWeapon(Agent)

    PickupWeapon(Agent : agent) : void =
        set IsAvailable = false

        # Grant the weapon
        ItemGranter.GrantItem(Agent)

        # Effects
        PickupAudio.Play()
        HidePickup()

        # Start respawn timer
        spawn { RespawnTimer() }

    RespawnTimer()<suspends> : void =
        Sleep(RespawnTime)
        set IsAvailable = true
        ShowPickupAvailable()
        RespawnVFX.Enable()
        Sleep(1.0)
        RespawnVFX.Disable()

    ShowPickupAvailable() : void =
        PickupVFX.Enable()
        ItemGranter.Enable()

    HidePickup() : void =
        PickupVFX.Disable()
        ItemGranter.Disable()
