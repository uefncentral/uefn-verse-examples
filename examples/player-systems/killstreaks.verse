# Kill Streak System
# Manages player kill streaks with progressive rewards including weapon upgrades, damage amplification, speed boosts, and special items. The system tracks eliminations and automatically grants increasin
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/killstreaks?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /Fortnite.com/Characters }

KillStreaksClass := class<public>(creative_device):

    @editable
    KillStreakManager :elimination_manager_device = elimination_manager_device{}
    @editable
    SelfEliminationManager :elimination_manager_device = elimination_manager_device{}
    @editable
    MythicHavocGranter :item_granter_device = item_granter_device{}
    @editable
    ShotgunRemover :item_remover_device = item_remover_device{}
    @editable
    SlurpGranter :item_granter_device = item_granter_device{}
    @editable
    DamageAmp :damage_amplifier_powerup_device = damage_amplifier_powerup_device{}
    @editable
    RemoveDamageAmp :damage_amplifier_powerup_device = damage_amplifier_powerup_device{}
    @editable
    SpeedClassSelector :class_and_team_selector_device = class_and_team_selector_device{}
    @editable
    SpeedRemoverClassSelector :class_and_team_selector_device = class_and_team_selector_device{}
    @editable
    SpeedGranter :movement_modulator_device = movement_modulator_device{}
    @editable
    GameStartTeleporter :teleporter_device = teleporter_device{}
    @editable
    SpawnPads :[]player_spawner_device = array{}
    @editable
    TimeAliveTimer :timer_device = timer_device{}
    @editable
    GameStartTimer :timer_device = timer_device{}
    @editable
    RoundTimer :timer_device = timer_device{}
    @editable
    RoundTimer2 :timer_device = timer_device{}
    @editable
    EndRound :end_game_device = end_game_device{}

    @editable
    CakeTeleporter :teleporter_device = teleporter_device{}
    @editable
    CakeBillboard :billboard_device = billboard_device{}

    @editable
    KillStreak0UI :hud_message_device = hud_message_device{}
    @editable
    KillStreak1UI :hud_message_device = hud_message_device{}
    @editable
    KillStreak2UI :hud_message_device = hud_message_device{}
    @editable
    KillStreak3UI :hud_message_device = hud_message_device{}
    @editable
    KillStreak4UI :hud_message_device = hud_message_device{}
    @editable
    KillStreak5UI :hud_message_device = hud_message_device{}
    @editable
    KillStreak6UI :hud_message_device = hud_message_device{}
    @editable
    KillStreak7UI :hud_message_device = hud_message_device{}
    @editable
    KillStreak8UI :hud_message_device = hud_message_device{}
    @editable
    KillStreak9UI :hud_message_device = hud_message_device{}
    @editable
    KillStreak10UI :hud_message_device = hud_message_device{}

    @editable
    KillScoreManager :score_manager_device = score_manager_device{}
    @editable
    PlacementScoreManager :score_manager_device = score_manager_device{}
    @editable
    KillStreak1ScoreManager :score_manager_device = score_manager_device{}
    @editable
    KillStreak2ScoreManager :score_manager_device = score_manager_device{}
    @editable
    KillStreak3ScoreManager :score_manager_device = score_manager_device{}
    @editable
    NukeScoreManager :score_manager_device = score_manager_device{}
    @editable
    DeathScoreManager :score_manager_device = score_manager_device{}
    @editable
    RoundAnnouncement :hud_message_device = hud_message_device{}
    @editable
    Storm :advanced_storm_controller_device = advanced_storm_controller_device{}

    @editable
    AnitaMaxWynn :audio_player_device = audio_player_device{}

    @editable
    NukeSequence :cinematic_sequence_device = cinematic_sequence_device{}
    @editable
    WinnerSequence :cinematic_sequence_device = cinematic_sequence_device{}
    @editable
    NukeExplosion :[]explosive_device = array{}

    @editable
    Trigger :trigger_device = trigger_device{}

    @editable
    KillAudios :[]audio_player_device = array{}

    var WinningPlayer : ?agent = false
    var OldScore : int = 0

    var CustomPlayerDataArray : [agent]CustomPlayerData =map{}


    LocalizeAgentToMessage<localizes>(Agent:agent):message = "{Agent}"
    StringToMessage<localizes>(String:string):message = "{String}"
    FormatMessageNuke<localizes>(Player: player):message= "{Player} JUST DROPPED A NUKE!!!"
    FormatMessageWin<localizes>(Player: player):message= "{Player} Won!"
    FormatPlayerScore<public><localizes>(Player:player, Score: int)<coputes>:message = "{Player}: {Score}"

    OnBegin<override>()<suspends>:void=
        GameStartTimer.SuccessEvent.Subscribe(HandleGameStart)
        TimeAliveTimer.SuccessEvent.Subscribe(GrantPlacementPoints)
        RoundTimer.SuccessEvent.Subscribe(StartTimer2)
        RoundTimer2.SuccessEvent.Subscribe(HandleEndGameSub)
        NukeSequence.StoppedEvent.Subscribe(NukeExplosionStartSub)
        GetPlayspace().PlayerAddedEvent().Subscribe(HandlePlayerJoined)
        Print("Killstreaks loaded")
        AllPlayers := GetPlayspace().GetPlayers()
        for(Player : AllPlayers):
            if(set CustomPlayerDataArray[Player] = CustomPlayerData{}):
                if(set CustomPlayerDataArray[Player].KillStreak = 0 , KillStreak := CustomPlayerDataArray[Player].KillStreak):
                    KillStreak0UI.Show(Player)
                    Print("Killstreak reset new amount  = {KillStreak}")
        for(SpawnPad : SpawnPads):
            SpawnPad.SpawnedEvent.Subscribe(HandleSpawned)

        # KillStreakManager.EliminatedEvent.Subscribe(ResetKillStreak)
        SelfEliminationManager.EliminatedEvent.Subscribe(ResetKillStreak)
        KillStreakManager.EliminationEvent.Subscribe(AddToKillStreak)

    HandlePlayerJoined(Player : agent):void=
        if(set CustomPlayerDataArray[Player] = CustomPlayerData{}):
            if(set CustomPlayerDataArray[Player].KillStreak = 0 , KillStreak := CustomPlayerDataArray[Player].KillStreak ):
                KillStreak0UI.Show(Player)
                Print("Killstreak reset new amount  = {KillStreak}")

    HandleGameStart(Player : ?agent):void=
        TimeAliveTimer.StartForAll()
        RoundTimer.Start()

    StartTimer2(Player : ?agent):void=
        RoundTimer2.Start()

    HandleEndGameSub(Player : ?agent):void=
        spawn:
            HandleEndGame(Player)

    GetWinner():void=
        AllPlayers := GetPlayspace().GetPlayers()
        set OldScore = -100
        for(Player : AllPlayers):
            CurrentScore := KillScoreManager.GetCurrentScore(Player)
            if(CurrentScore > OldScore):
                set OldScore = CurrentScore
                set WinningPlayer = option{Player}
                
    HandleEndGame(Player : ?agent)<suspends>:void=
        GetWinner()
        if(PlayerAgent : agent = WinningPlayer?, Winner := player[PlayerAgent]):
            Score := KillScoreManager.GetCurrentScore(PlayerAgent)  
            Message := FormatMessageWin(Winner)
            BillboardMessage := FormatPlayerScore(Winner, Score)
            RoundAnnouncement.SetText(Message)
            RoundAnnouncement.Show()
            CakeBillboard.SetText(BillboardMessage)
            RoundTimer2.Pause(PlayerAgent)
            RoundTimer.Pause(PlayerAgent)
            TimeAliveTimer.Pause(PlayerAgent)
            CakeTeleporter.Teleport(PlayerAgent)
            WinnerSequence.Play()
            Sleep(3.0)
            EndRound.Activate(PlayerAgent)

    GrantPlacementPoints(Player : ?agent):void=
        if:
            PlayerAgent : agent = Player?
        then:
            PlacementScoreManager.Activate(PlayerAgent)
            Trigger.Trigger(PlayerAgent)
            TimeAliveTimer.Reset(PlayerAgent)
            TimeAliveTimer.Start(PlayerAgent)

    HandleSpawned(Player : agent):void=
        TimeAliveTimer.Reset(Player)
        TimeAliveTimer.Start(Player)

    ResetKillStreak(Player : agent ):void=
        if:
            set CustomPlayerDataArray[Player].KillStreak = 0
            KillStreak := CustomPlayerDataArray[Player].KillStreak
        then:
            DeathScoreManager.Activate(Player)
            Trigger.Trigger(Player)
            KillStreak0UI.Show(Player)
            SpeedRemoverClassSelector.ChangeClass(Player)
            RemoveDamageAmp.Pickup(Player)
            TimeAliveTimer.Pause(Player)
            Print("Killstreak reset new amount  = {KillStreak}")

    RandomKillAudio(Player : agent):void=
        RandomAudio := GetRandomInt(0, KillAudios.Length)
        if (Audio := KillAudios[RandomAudio]):
            Audio.Play(Player)

    AddToKillStreak(Player : ?agent):void=
        if:
            PlayerAgent : agent = Player?
            set CustomPlayerDataArray[PlayerAgent].KillStreak += 1
            KillStreak := CustomPlayerDataArray[PlayerAgent].KillStreak
        then:
            Print("Killstreak added new amount  = {KillStreak}")
            RandomKillAudio(PlayerAgent)
            CheckKillStreak(PlayerAgent)

    NukeExplosionStartSub():void=
        spawn:
            NukeExplosionStart()

    NukeExplosionStart()<suspends>:void=
        AllPlayers := GetPlayspace().GetPlayers()
        for(Player : AllPlayers, Explosion : NukeExplosion):
            Explosion.Explode(Player)
        WinnerSequence.Play()
        Sleep(3.1)
        for(Player : AllPlayers):
            EndRound.Activate(Player)

    CheckKillStreak(Player : agent):void=
        if(KillStreak := CustomPlayerDataArray[Player].KillStreak):
            if:
                KillStreak = 1
            then:
                KillStreak1UI.Show(Player)
                KillScoreManager.Activate(Player)
                Trigger.Trigger(Player)
            else if:
                KillStreak = 2
            then:
                KillStreak2UI.Show(Player)
                KillScoreManager.Activate(Player)
                Trigger.Trigger(Player)
            else if:
                KillStreak = 3
            then:
                KillStreak3UI.Show(Player)
                ShotgunRemover.Remove(Player)
                MythicHavocGranter.GrantItem(Player)
                KillStreak1ScoreManager.Activate(Player)
                Trigger.Trigger(Player)
            else if:
                KillStreak = 4
            then:
                KillStreak4UI.Show(Player)
                KillScoreManager.Activate(Player)
                Trigger.Trigger(Player)
            else if:
                KillStreak = 5
            then:
                KillStreak5UI.Show(Player)
                SlurpGranter.GrantItem(Player)
                KillStreak2ScoreManager.Activate(Player)
                Trigger.Trigger(Player)
            else if:
                KillStreak = 6
            then:
                KillStreak6UI.Show(Player)
                KillScoreManager.Activate(Player)
                Trigger.Trigger(Player)
            else if:
                KillStreak = 7
            then:
                KillStreak7UI.Show(Player)
                # SpeedClassSelector.ChangeClass(Player)
                SpeedGranter.Activate(Player)
                DamageAmp.Pickup(Player)
                KillStreak3ScoreManager.Activate(Player)
                Trigger.Trigger(Player)
            else if:
                KillStreak = 8
            then:
                KillStreak8UI.Show(Player)
                KillScoreManager.Activate(Player)
                Trigger.Trigger(Player)
            else if:
                KillStreak = 9
            then:
                KillStreak9UI.Show(Player)
                KillScoreManager.Activate(Player)
                Trigger.Trigger(Player)
            else if:
                KillStreak = 10
            then:
                AnitaMaxWynn.Play()
                spawn:
                    HandleNukeEvent(Player)
                

    HandleNukeEvent(Player : agent)<suspends>:void=
        if:
            Winner := player[Player]
            WinnerFC := Winner.GetFortCharacter[]
        then:
            Storm.DestroyStorm()
            Score := KillScoreManager.GetCurrentScore(Player)  
            NukeScoreManager.Activate(Player)
            Trigger.Trigger(Player)
            Message := FormatMessageNuke(Winner)
            BillboardMessage := FormatPlayerScore(Winner, Score)
            RoundAnnouncement.SetText(Message)
            RoundAnnouncement.Show()
            KillStreak10UI.Show(Player)
            RoundTimer2.Pause(Player)
            RoundTimer.Pause(Player)
            TimeAliveTimer.Pause(Player)
            CakeBillboard.SetText(BillboardMessage)
            CakeTeleporter.Teleport(Player)
            WinnerFC.PutInStasis(stasis_args{AllowTurning:=false, AllowFalling:=false,AllowEmotes:=true})
            NukeSequence.Play()


