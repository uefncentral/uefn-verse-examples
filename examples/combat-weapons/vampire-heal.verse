# Vampire Heal
# Verse code for Vampire Heal - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/vampire-heal?ref=github


using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }


VampireHeal := class(creative_device):

    @editable var Class : int = 0
    @editable ClassTracker : tracker_device = tracker_device{}
    @editable HUDablity : hud_message_device = hud_message_device{}

    @editable ConditionalButton : conditional_button_device = conditional_button_device{}
    @editable ItemGranter:item_granter_device = item_granter_device{}

    OnBegin<override>()<suspends>:void=
        InitSpawners()

    InitSpawners() : void=
        Spawners := GetCreativeObjectsWithTag(spawner{})
        for (Obj : Spawners):
            if (Spawner := player_spawner_device[Obj]):
                Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

    OnPlayerSpawned(Agent : agent): void=
        if (Player := player[Agent]):
            spawn{GetWeapon(Agent)}

    GetWeapon(Agent : agent)<suspends>:void=
        Sleep(1.0)
        if(ClassTracker.GetValue(Agent) = Class):
            ItemGranter.GrantItem(Agent)
            HUDablity.Show(Agent)
            for (Player : GetPlayspace().GetPlayers(), FortCharacter := Player.GetFortCharacter[]):
                FortCharacter.DamagedEvent().Subscribe(HealAttacker)
            GetPlayspace().PlayerAddedEvent().Subscribe(HandlePlayerJoin)

    HealAttacker( Result : damage_result) : void =
        Amount := Result.Amount
        if (Instigator := Result.Instigator?, Agent := Instigator.GetInstigatorAgent[], FortCharacter := Agent.GetFortCharacter[], ConditionalButton.IsHoldingItem[Agent]):
            HealAmount := Amount * 0.14
            FortCharacter.Heal(HealAmount)
            
    HandlePlayerJoin ( Player : player ) : void =
        if (FortCharacter := Player.GetFortCharacter[]):
            FortCharacter.DamagedEvent().Subscribe(HealAttacker)