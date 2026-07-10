# Health Siphon System
# Implements a health siphon mechanic where players gain health when they damage other players. The system tracks damage events and transfers a portion of the damage dealt back to the attacking player a
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/gamemanager-3-1?ref=github

using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/Diagnostics }

GameManager := class(creative_device):

    @editable
    P1Spawner:player_spawner_device = player_spawner_device{}

    @editable
    P2Spawner:player_spawner_device = player_spawner_device{}

    HEAL_DELAY:float = 0.1

    @editable
    AudioDevice1:audio_player_device = audio_player_device{}
    @editable
    AudioDevice2:audio_player_device = audio_player_device{}
    @editable
    AudioDevice3:audio_player_device = audio_player_device{}
    @editable
    AudioDevice4:audio_player_device = audio_player_device{}
    @editable
    CueAudioPlayer:audio_player_device = audio_player_device{}

    OnBegin<override>()<suspends>:void=
        P1Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)
        P2Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

    OnPlayerSpawned(Agent:agent):void=
        if(FC:fort_character = Agent.GetFortCharacter[]):
            FC.DamagedEvent().Subscribe(OnPlayerDamaged)
            FC.DamagedShieldEvent().Subscribe(OnShieldDamaged)
            FC.EliminatedEvent().Subscribe(OnPlayerEliminated)

    OnPlayerDamaged(DR:damage_result):void=
        if(FC:fort_character = fort_character[DR.Target]):
            CurrentHealth:float = FC.GetHealth()
            Print("current health of player: {CurrentHealth}")

        DamagedAmount:float = DR.Amount

        Print("Amount damaged: {DamagedAmount}")

        if(Instigator:game_action_instigator = DR.Instigator?):
            if(InstigatingAgent:agent = Instigator.GetInstigatorAgent[]):
                if(FC:fort_character = InstigatingAgent.GetFortCharacter[]):
                    CurrentHealth:float = FC.GetHealth()
                    Print("current health of player: {CurrentHealth}")
                    DoSiphon(FC, DamagedAmount)

    HealPlayer(Player:fort_character, Amount:float)<suspends>:void=
        var HealedAmount:float = 0.0
        loop:
            CurrentHealth:float = Player.GetHealth()
            if(CurrentHealth = 100.0):
                break
            else:
                set HealedAmount += 1.0
                NewHealth:float = CurrentHealth + 1.0
                Player.SetHealth(NewHealth)

                if(HealedAmount >= Amount):
                    break
                
                Sleep(HEAL_DELAY)


    OnShieldDamaged(DR:damage_result):void=
        if(FC:fort_character = fort_character[DR.Target]):
            CurrentShield:float = FC.GetShield()
            Print("current shield of player: {CurrentShield}")

        DamagedAmount:float = DR.Amount

        Print("Amount damaged: {DamagedAmount}")

        if(Instigator:game_action_instigator = DR.Instigator?):
            if(InstigatingAgent:agent = Instigator.GetInstigatorAgent[]):
                if(FC:fort_character = InstigatingAgent.GetFortCharacter[]):
                    CurrentShield:float = FC.GetShield()
                    Print("current shield of player: {CurrentShield}")
                    DoSiphon(FC, DamagedAmount)

    FixShield(Player:fort_character, Amount:float)<suspends>:void=
        var FixedAmount:float = 0.0
        loop:
            CurrentShield:float = Player.GetShield()
            if(CurrentShield = 100.0):
                break
            else:
                set FixedAmount += 1.0
                NewShield:float = CurrentShield + 1.0
                Player.SetShield(NewShield)

                if(FixedAmount >= Amount):
                    
                    break
                
                Sleep(HEAL_DELAY)


    DoSiphon(Player:fort_character, Amount:float):void=
        CurrentShield:float = Player.GetShield()
        CurrentHealth:float = Player.GetHealth()

        if(CurrentHealth < 100.0):
            Print("heal player first {Amount}")
            spawn:
                HealPlayer(Player, Amount)
        else:
            if(CurrentShield < 100.0):
                Print("fix shield {Amount}")
                spawn:
                    FixShield(Player, Amount)

    #
    PlayElimAudio(Agent:agent):void=
        CueAudioPlayer.Play(Agent)
        <#
        RandomInt:int = GetRandomInt(1,4)
        if(RandomInt = 1):
            AudioDevice1.Play(Agent)
        else if(RandomInt = 2):
            AudioDevice2.Play(Agent)
        else if(RandomInt = 3):
            AudioDevice3.Play(Agent)
        else if(RandomInt = 4):
            AudioDevice4.Play(Agent)
        #>



    OnPlayerEliminated(ElimResult:elimination_result):void=
        Print("somebody got elim'd")
        
        EliminatedFC:fort_character = ElimResult.EliminatedCharacter
        #find out if the player is being forced to spectate mode
        if(FortCharacter := ElimResult.EliminatingCharacter?):
            if(FortCharacter = EliminatedFC):
                if(SelfElimAgent:agent = FortCharacter.GetAgent[]):        
                    #this is a self elim
                    Print("self elim")
            else:
                if(EliminatingAgent := FortCharacter.GetAgent[], EliminatingPlayer:=player[EliminatingAgent]):
                    Print("this is a normal elim")
                    PlayElimAudio(EliminatingAgent)