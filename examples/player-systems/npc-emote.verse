# NPC Music Player
# Creates an interactive NPC that plays guitar music when players interact with it. The system includes a cooldown mechanism to prevent multiple simultaneous music playbacks and ensures smooth audio man
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/npc-emote?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

npc_guitar_behavior := class(creative_device):
    @editable
    NPC : character_device = character_device{}
    
    @editable 
    MusicPlayer : audio_player_device = audio_player_device{}
    
    # Variable to prevent multiple interactions while playing
    var IsPlaying : logic = false

    # This runs when the game starts
    OnBegin<override>()<suspends>:void=
        # Set up interaction when game starts
        NPC.InteractedWithEvent.Subscribe(HandleInteraction)

    # Non-suspending handler to satisfy the event subscription
    HandleInteraction(Agent : agent):void=
        spawn{ DoInteraction(Agent) }

    # Separate suspending function for the interaction logic
    DoInteraction(Agent : agent)<suspends>:void=
        if (IsPlaying = false):
            set IsPlaying = true
            
            # Start the music
            MusicPlayer.Play()
            
            # Add a delay before allowing new interactions
            Sleep(5.0)
            set IsPlaying = false