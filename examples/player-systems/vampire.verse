# Vampire Healing System
# Creates a vampire-like power that allows players to heal when they damage other players. The power is activated via a button and lasts for 180 seconds, with healing occurring each time the vampire pla
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/vampire?ref=github

using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

Vampire_heal := class(creative_device):

    @editable 
    Button:[]conditional_button_device = array{} 

    var Stop_Power_Amount : int = 2 

    HEAL_DELAY:float = 0.1 

    OnBegin<override>()<suspends>:void=
        for(button1:Button):
          button1.ActivatedEvent.Subscribe(Start)
       
    
    Start(Agent : agent):void=
        spawn:
          PowerStarted(Agent)   

    PowerStarted(Agent : agent)<suspends>:void=
        WhenActivated(Agent)
        Sleep(180.0)
        set Stop_Power_Amount = 0
        PowerStoped(Agent)

    PowerStoped(Agent : agent):void=
        if(FC:fort_character = Agent.GetFortCharacter[]):
            FC.DamagedEvent().Subscribe(OnPlayerDamaged).Cancel()
            FC.DamagedShieldEvent().Subscribe(OnShieldDamaged).Cancel()


    StopPower(DR:damage_result):void=
        # Print("Power Stopped")
        # set Stop_Power_Amount = 0
        block:
        
    
    WhenActivated(Agent:agent):void=
        set Stop_Power_Amount = 2
        if(FC:fort_character = Agent.GetFortCharacter[]):
            FC.DamagedEvent().Subscribe(OnPlayerDamaged)
            FC.DamagedShieldEvent().Subscribe(OnShieldDamaged)

    OnPlayerDamaged(DR:damage_result):void=

        if(FC:fort_character = fort_character[DR.Target]):
            CurrentHealth:float = FC.GetHealth()
            Print("current health of player: {CurrentHealth}")

        DamagedAmount:float = DR.Amount

        set Stop_Power_Amount = 2

        Print("Amount_damaged: {DamagedAmount}")

        if(Instigator:game_action_instigator = DR.Instigator?):
            if(InstigatingAgent:agent = Instigator.GetInstigatorAgent[]):
                if(FC:fort_character = InstigatingAgent.GetFortCharacter[]):
                    CurrentHealth:float = FC.GetHealth()
                    Print("current health of player:{CurrentHealth}")
                    DoSiphon(FC, DamagedAmount)

    OnShieldDamaged(DR:damage_result):void=
        if(FC:fort_character = fort_character[DR.Target]):
            CurrentShield:float = FC.GetShield()
            Print("current shield of player: {CurrentShield}")

        set Stop_Power_Amount = 2

        DamagedAmount:float = DR.Amount

        Print("Amount damaged: {DamagedAmount}")

        if(Instigator:game_action_instigator = DR.Instigator?):
            if(InstigatingAgent: agent = Instigator.GetInstigatorAgent[]):
                if(FC:fort_character = InstigatingAgent.GetFortCharacter[]):
                    CurrentShield:float = FC.GetShield()
                    Print("current shlied of player:{CurrentShield}")
                    DoSiphon(FC, DamagedAmount)

    HealPlayer(Player:fort_character, Amount:float)<suspends>:void=
        var HealedAmount:float = 0.0

        if (Stop_Power_Amount > 1):
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

                    if (Stop_Power_Amount < 1):
                        break        
                    
                    Sleep (HEAL_DELAY)

                
    FixShield(Player:fort_character, Amount:float)<suspends>:void=
        var FixedAmount:float = 0.0

        if (Stop_Power_Amount > 1):
            loop:
                CurrentShield:float = Player.GetShield()
                if(CurrentShield =100.0 ):
                    break
                else:
                    set FixedAmount += 1.0
                    NewShield:float = CurrentShield + 1.0
                    Player.SetShield(NewShield)

                    if(FixedAmount >= Amount):

                        break

                    if (Stop_Power_Amount < 1):
                        break    

                    Sleep(HEAL_DELAY)

    DoSiphon(Player:fort_character, Amount:float):void=
        CurrentShield:float = Player.GetShield()
        CurrentHealth:float = Player.GetHealth()
        
        if(CurrentHealth < 100.0):
            Print("Heal player first {Amount}")
            spawn:
                HealPlayer(Player, Amount)
        else:
            Print("Fix shield {Amount}")
            spawn:
                FixShield(Player, Amount)
