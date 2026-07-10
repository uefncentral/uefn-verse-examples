# Arena Game Manager
# A game management system that controls arena-based gameplay with configurable boundaries, power-ups, and round timing. It manages arena dimensions, validates player positions within bounds, and coordi
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/zgame-manager?ref=github


using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Fortnite.com/FortPlayerUtilities }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }

arena_size := class<concrete>:
    @editable
    ARENA_HALF_WIDTH_X : float = 0.0

    @editable
    ARENA_HALF_LENGTH_Y : float = 0.0

    @editable
    ARNEA_HEIGHT_Z : float = 0.0

    MIN_X : float = -1792.0
    MAX_X : float = 1792.0

    MIN_Y : float = -1792.0
    MAX_Y : float = 1792.0

    MIN_Z : float = 0.0
    MAX_Z : float = 768.0

    BOX_SIZE : float = 512.0

    GetArenaHalfWidthX()<transacts>:float=
        ARENA_HALF_WIDTH_X

    GetArenaHalfLengthY()<transacts>:float=
        ARENA_HALF_LENGTH_Y

    GetArenaHeightZ()<transacts>:float=
        ARNEA_HEIGHT_Z

    WithinArenaBounds(X : float, Y : float, Z : float):logic=
        if:
            X > MIN_X
            Y > MIN_Y
            Z > MIN_Z
            X < MAX_X
            Y < MAX_Y
            Z < MAX_Z
        then:
            Print("Valid bounds: {X}, {Y}, {Z}")
            true
        else:
            Print("Invalid bounds: {X}, {Y}, {Z}")
            false

    WithinArenaBounds(Location : vector3):logic=
        WithinArenaBounds(Location.X, Location.Y, Location.Z)

power_options := class<concrete>:
    @editable
    EmoteMutatorZone : mutator_zone_device = mutator_zone_device{}

    @editable
    SignalRemoteManager : signal_remote_manager_device = signal_remote_manager_device{}

    @editable
    ArenaSize : arena_size = arena_size{}

    @editable
    RoundStartTimer: timer_device = timer_device{}

    @editable
    RoundStartAudio : audio_player_device = audio_player_device{}

    @editable
    RoundStartAudioTimer : timer_device = timer_device{}


    NumberOfPowers : int = 12


game_manager_device := class(creative_device):


    @editable
    RoundStartMutator: mutator_zone_device = mutator_zone_device{}

    @editable
    PowerOptions : power_options = power_options{}

    @editable
    Powers : powers = powers{}

    var PlayerPowerHud: [player]hud_message_device = map{}


    #NumberOfPowers : int = 16

    # This is what initializes the game
    OnBegin<override>()<suspends>: void =
        Sleep(0.0)
        PlaySpace := GetPlayspace()
        Players := PlaySpace.GetPlayers()
        for (Player : Players, FortCharacter := Player.GetFortCharacter[]):
            # Make sure at the start all characters are shown and not invincible
            # PlayerReference.Register(Player)
            FortCharacter.SetVulnerability(true)
            FortCharacter.Show()

        Print("Subscribing to round start audio")
        PowerOptions.RoundStartAudioTimer.SuccessEvent.Subscribe(StartRoundAudio)
        Print("Subscribed to round start audio")


        sync:
            #set PlayerPowerHud = Powers.SetupPowers(Players, EmoteMutatorZone, SignalRemoteManager, NumberOfPowers, RoundStartTimer, ArenaSize)
            set PlayerPowerHud = Powers.SetupPowers(Players, PowerOptions, PlaySpace)
            SpectatorHudMessageLoop(Players)
            block:
                PowerOptions.RoundStartTimer.SuccessEvent.Await()
                RoundStartMutator.Disable()

    SpectatorHudMessageLoop(InPlayerArray: []player)<suspends>: void =
        var PlayerSpectators: [player][]player = map{}
        loop:
            Sleep(1.0)
            for (Player : InPlayerArray, PlayerHudMessageDevice := PlayerPowerHud[Player]):
                if (FortCharacter := Player.GetFortCharacter[].IsActive[]):
                    PlayersSpectating := Player.GetPlayersSpectating()
                    for (Spectator : PlayersSpectating, not PlayerSpectators[Player].Find[Spectator]):
                        if (SpectatorHudMessageDevice := PlayerPowerHud[Spectator]):
                            SpectatorHudMessageDevice.Hide()
                        PlayerHudMessageDevice.Show(Spectator)
                    if:
                        set PlayerSpectators[Player] = PlayersSpectating

    StartRoundAudio(Agent : ?agent):void=
        Print("Starting round audio")
        PowerOptions.RoundStartAudio.Play()