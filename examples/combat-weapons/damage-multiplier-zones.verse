# Damage Multiplier Zones
# Create zones where players deal increased or decreased damage. Great for power-up areas or defensive zones.
# Difficulty: intermediate  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/damage-multiplier-zones?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# Damage multiplier zone system
damage_zone_controller := class(creative_device):

    @editable
    ZoneTrigger : trigger_device = trigger_device{}

    @editable
    DamageMultiplier : float = 2.0  # 2.0 = double damage

    @editable
    VisualIndicator : vfx_spawner_device = vfx_spawner_device{}

    @editable
    AudioCue : audio_player_device = audio_player_device{}

    var PlayersInZone : []player = array{}
    var PlayerDamageMultipliers : [player]float = map{}

    OnBegin<override>()<suspends> : void =
        ZoneTrigger.TriggeredEvent.Subscribe(OnPlayerEnterZone)
        # Note: You'll need a second trigger for exit, or use volume device
        Print("Damage zone initialized with {DamageMultiplier}x multiplier")

    OnPlayerEnterZone(MaybeAgent : ?agent) : void =
        if (Agent := MaybeAgent?):
            if (Player := player[Agent]):
                if (not PlayersInZone.Find[Player]):
                    set PlayersInZone = PlayersInZone + array{Player}
                    if (set PlayerDamageMultipliers[Player] = DamageMultiplier) {}

                    # Visual/audio feedback
                    VisualIndicator.Enable()
                    AudioCue.Play()

                    Print("Player entered damage zone")

    OnPlayerExitZone(Player : player) : void =
        set PlayersInZone = PlayersInZone.RemoveAllElements(Player)
        if (set PlayerDamageMultipliers[Player] = 1.0) {}
        Print("Player exited damage zone")

    # Call this from damage calculation to get multiplier
    GetDamageMultiplier(Player : player) : float =
        if (Multiplier := PlayerDamageMultipliers[Player]):
            return Multiplier
        return 1.0

    IsPlayerInZone(Player : player) : logic =
        return PlayersInZone.Find[Player]
