# Pt Health Recharge Weapon
# Verse code for Pt Health Recharge Weapon - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/pt-health-recharge-weapon?ref=github

using { /Verse.org }
using { /Fortnite.com/Game }
using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/Diagnostics }



pt_HealthRechargeWeapon := class(creative_device):
    @editable HealthRechargeGun : conditional_button_device = conditional_button_device{}
    @editable HealthPowerup : health_powerup_device = health_powerup_device{}
    @editable SecondsToRecharge : float = 3.0

    @editable NPCs : npc_spawner_device = npc_spawner_device{}

    var AgentRecharging : [agent]logic = map{}


    OnBegin<override>()<suspends>: void=
        Players := GetPlayspace().GetPlayers()
        for(Player: Players):
            if(Agent := agent[Player]):
                OnPlayerJoins(Agent)

        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerJoins)
        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerLeaves)

        NPCs.SpawnedEvent.Subscribe(OnPlayerJoins)
        

    OnPlayerJoins(Agent: agent): void=
        if(FC := Agent.GetFortCharacter[]):
            FC.DamagedEvent().Subscribe(OnPlayerDamaged)
            FC.DamagedShieldEvent().Subscribe(OnPlayerDamaged)


    OnPlayerLeaves(Agent: agent): void=
        set AgentRecharging = RemoveKeyFromMap(AgentRecharging, Agent)


    OnPlayerDamaged(Result: damage_result): void=
        if:
            Instigator := Result.Instigator?
            InstigatorFC := fort_character[Instigator]
            InstigatorAgent := Instigator.GetInstigatorAgent[]
            DamagedFC := fort_character[Result.Target]
            DamagedAgent := DamagedFC.GetAgent[]
            not InstigatorAgent = DamagedAgent

        then:
            if(HealthRechargeGun.IsHoldingItem[InstigatorAgent], not AgentRecharging[InstigatorAgent]?):
                Rot := InstigatorFC.GetTransform().Rotation
                spawn{RechargeHealth(InstigatorFC, InstigatorAgent)}     
                

    RechargeHealth(InstigatorFC: fort_character, InstigatorAgent: agent)<suspends>: void=
        if(set AgentRecharging[InstigatorAgent] = true):

        HealthPowerup.Pickup(InstigatorAgent)
        Sleep(SecondsToRecharge)

        if(set AgentRecharging[InstigatorAgent] = false):



    RemoveKeyFromMap(OldMap:[agent]logic, KeyToRemove:agent):[agent]logic =
        var NewMap:[agent]logic = map{}
        for (Key -> Value : OldMap):
            if (Key <> KeyToRemove):
                if (set NewMap[Key] = Value) {}
        return NewMap