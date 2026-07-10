# Trigger Reward System
# A system that awards money and accolades to players when they activate specific triggers. Each trigger can be configured with different reward amounts and automatically gives rewards through a game ma
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/moneytrigger-1?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }

Reward_Trigger := class<concrete>():
    @editable
    Trigger : trigger_device = trigger_device{}
    @editable
    CollectAmount : float = 0.0


GiveRewards := class(creative_device):
    @editable
    GameManager : Game_Manager = Game_Manager{}
    @editable
    Triggers : []Reward_Trigger = array{}

    @editable Accolade : accolades_device = accolades_device{}

    OnBegin<override>()<suspends>:void=
        if(T:= Triggers[0]):
            T.Trigger.TriggeredEvent.Subscribe(RewardPlayer1)
        if(T:= Triggers[1]):
            T.Trigger.TriggeredEvent.Subscribe(RewardPlayer2)
        if(T:= Triggers[2]):
            T.Trigger.TriggeredEvent.Subscribe(RewardPlayer3)
        if(T:= Triggers[3]):
            T.Trigger.TriggeredEvent.Subscribe(RewardPlayer4)
        if(T:= Triggers[4]):
            T.Trigger.TriggeredEvent.Subscribe(RewardPlayer5)
        if(T:= Triggers[5]):
            T.Trigger.TriggeredEvent.Subscribe(RewardPlayer6)
        if(T:= Triggers[6]):
            T.Trigger.TriggeredEvent.Subscribe(RewardPlayer7)
        if(T:= Triggers[7]):
            T.Trigger.TriggeredEvent.Subscribe(RewardPlayer8)
        if(T:= Triggers[8]):
            T.Trigger.TriggeredEvent.Subscribe(RewardPlayer9)


    RewardPlayer1(Agent : ?agent) : void=
        if(NewAgent := Agent?):
            if(Player := NewAgent, CP := GameManager.PlayersMap[Player]):
                if (T:= Triggers[0]):
                    CP.Collect(T.CollectAmount, "Money")
                    Accolade.Award(Player)

    RewardPlayer2(Agent : ?agent) : void=
        if(NewAgent := Agent?):
            if(Player := NewAgent, CP := GameManager.PlayersMap[Player]):
                if (T:= Triggers[1]):
                    CP.Collect(T.CollectAmount, "Money")
                    Accolade.Award(Player)

    RewardPlayer3(Agent : ?agent) : void=
        if(NewAgent := Agent?):
            if(Player := NewAgent, CP := GameManager.PlayersMap[Player]):
                if (T:= Triggers[2]):
                    CP.Collect(T.CollectAmount, "Money")
                    Accolade.Award(Player)

    RewardPlayer4(Agent : ?agent) : void=
        if(NewAgent := Agent?):
            if(Player := NewAgent, CP := GameManager.PlayersMap[Player]):
                if (T:= Triggers[3]):
                    CP.Collect(T.CollectAmount, "Money")
                    Accolade.Award(Player)

    RewardPlayer5(Agent : ?agent) : void=
        if(NewAgent := Agent?):
            if(Player := NewAgent, CP := GameManager.PlayersMap[Player]):
                if (T:= Triggers[4]):
                    CP.Collect(T.CollectAmount, "Money")
                    Accolade.Award(Player)

    RewardPlayer6(Agent : ?agent) : void=
        if(NewAgent := Agent?):
            if(Player := NewAgent, CP := GameManager.PlayersMap[Player]):
                if (T:= Triggers[5]):
                    CP.Collect(T.CollectAmount, "Money")
                    Accolade.Award(Player)

    RewardPlayer7(Agent : ?agent) : void=
        if(NewAgent := Agent?):
            if(Player := NewAgent, CP := GameManager.PlayersMap[Player]):
                if (T:= Triggers[6]):
                    CP.Collect(T.CollectAmount, "Money")
                    Accolade.Award(Player)

    RewardPlayer8(Agent : ?agent) : void=
        if(NewAgent := Agent?):
            if(Player := NewAgent, CP := GameManager.PlayersMap[Player]):
                if (T:= Triggers[7]):
                    CP.Collect(T.CollectAmount, "Money")
                    Accolade.Award(Player)

    RewardPlayer9(Agent : ?agent) : void=
        if(NewAgent := Agent?):
            if(Player := NewAgent, CP := GameManager.PlayersMap[Player]):
                if (T:= Triggers[8]):
                    CP.Collect(T.CollectAmount, "Money")
                    Accolade.Award(Player)