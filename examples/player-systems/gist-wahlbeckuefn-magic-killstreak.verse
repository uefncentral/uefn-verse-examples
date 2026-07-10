# Magic Killstreak System
# A player-following system that tracks kills and enables special abilities after reaching a 3-kill streak. When the killstreak threshold is met, it activates a button that triggers magical effects incl
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/gist-wahlbeckuefn-magic-killstreak?ref=github


using { /Fortnite.com/Devices }
using { /Fortnite.com/Game }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

rpg_player := class<concrete>():
    @editable var VFXSpawner : vfx_spawner_device = vfx_spawner_device{}
    @editable var DamageDevice : damage_volume_device = damage_volume_device{}
    @editable var DeviceMover : creative_prop = creative_prop{}
    @editable var SuperButton : button_device = button_device{}
    @editable var SFXPlayer : audio_player_device = audio_player_device{}

    var KillStreak : int = 0
    var TotalKills : int = 0
    var Player : ?player = false

    Init(IPlayer : player):void=
        VFXSpawner.Disable()
        DamageDevice.Disable()
        SuperButton.Disable()
        SuperButton.InteractedWithEvent.Subscribe(OnSuperButtonActivated)

        if (Agent := agent[IPlayer], FortChar := Agent.GetFortCharacter[]):
            set Player = option{IPlayer}
            FortChar.EliminatedEvent().Subscribe(OnPlayerEliminated)
            spawn:
                MoveDevices(FortChar)

    # Keep the devices at player location at all times
    MoveDevices(FortChar : fort_character)<suspends>:void=
        loop:
            Sleep(0.0)
            if (DeviceMover.TeleportTo[FortChar.GetTransform().Translation, FortChar.GetTransform().Rotation]) {}
    
    # Listen for each elimanation and update killstreaks
    OnPlayerEliminated(Result : elimination_result):void=
        # We got the elimination
        if (FortChar := Result.EliminatingCharacter?):
            if (IsFortCharSameAsPlayer(FortChar)?):
                set TotalKills += 1
                set KillStreak += 1
                CheckKillStreak(FortChar)
        # We died
        else if (IsFortCharSameAsPlayer(Result.EliminatedCharacter)?):
            set KillStreak = 0
    
    CheckKillStreak(FortChar : fort_character):void=
        if (KillStreak = 3):
            SuperButton.Enable()

    OnSuperButtonActivated(Agent : agent):void=
        if (IsAgentSameAsPlayer(Agent)?):
            SuperButton.Disable()
            spawn:
                UseSuper()
    
    UseSuper()<suspends>:void=
        VFXSpawner.Enable()
        if (Agent := agent[Player?]) {SFXPlayer.Play(Agent)}
        DamageDevice.Enable()
        Sleep(3.0)
        DamageDevice.Disable()
        VFXSpawner.Disable()
                
    
    IsFortCharSameAsPlayer(Incoming : fort_character)<transacts>:logic=
        if (Agent := Incoming.GetAgent[], IPlayer := player[Agent]):
            if (Player? = IPlayer) { return true }
            else { return false }
        
        return false

    IsAgentSameAsPlayer(Incoming : agent)<transacts>:logic=
        if (IPlayer := player[Incoming]):
            if (Player? = IPlayer) { return true }
            else { return false }
        
        return false


magic_killstreak := class(creative_device):

    @editable var RPGPlayers : []rpg_player = array{}

    
    OnBegin<override>()<suspends>:void=
        AllPlayers := GetPlayspace().GetPlayers()
        for (IDX := 0..AllPlayers.Length - 1):
            if (RPGPlayer := RPGPlayers[IDX], Player := AllPlayers[IDX]):
                RPGPlayer.Init(Player)

