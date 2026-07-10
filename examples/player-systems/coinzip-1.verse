# Elimination Quip Spawner
# This device allows players to equip custom prop assets that automatically spawn when they eliminate other players. Players can select different quips using trigger devices and optionally unequip them.
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/coinzip-1?ref=github


using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Verse.org/Simulation }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Assets }

quip_equip_trigger := class<concrete>:
    @editable
    QuipAsset:creative_prop_asset = DefaultCreativePropAsset

    @editable
    EquipTrigger:trigger_device = trigger_device{}

elim_quip_device := class(creative_device):

    @editable
    Quips:[]quip_equip_trigger = array{}

    @editable
    AutoEquipFirstQuip:logic = false

    @editable
    UnequipQuip:?trigger_device = false

    var PlayersElimQuip:[agent]?creative_prop_asset = map{}

    OnBegin<override>()<suspends>:void=
        for(Player : GetPlayspace().GetPlayers()):
            OnPlayerJoined(Player)

        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerJoined)

        if(FoundUnequipQuip := UnequipQuip?):
            FoundUnequipQuip.TriggeredEvent.Subscribe(OnQuipUnequip)

        for(Quip : Quips):
            Quip.EquipTrigger.TriggeredEvent.SubscribeOptionalAgent(OnQuipEquipped, Quip.QuipAsset)

    OnPlayerJoined(Player:player):void=
        if(AutoEquipFirstQuip?, QuipToEquip := Quips[0]):
            if(set PlayersElimQuip[Player] = option{QuipToEquip.QuipAsset}) {}

        if(FortCharacter := Player.GetFortCharacter[]):
            FortCharacter.EliminatedEvent().Subscribe(OnPlayerEliminated)

    OnQuipUnequip(Agent:?agent):void=
        if(set PlayersElimQuip[Agent?] = false) {}

    OnQuipEquipped(Agent:?agent, QuipAsset:creative_prop_asset):void=
        if(set PlayersElimQuip[Agent?] = option{QuipAsset}) {}

    OnPlayerEliminated(EliminationResult:elimination_result):void=
        if(EliminatingAgent := EliminationResult.EliminatingCharacter?.GetAgent[]):
            SpawnQuip(EliminatingAgent, EliminationResult.EliminatedCharacter)

    SpawnQuip(Instigator:agent, TargetCharacter:fort_character):void=
        if(QuipAsset := PlayersElimQuip[Instigator]?):
            if(SpawnedProp := SpawnProp(QuipAsset, TargetCharacter.GetTransform().Translation, TargetCharacter.GetTransform().Rotation)(0)?):
                spawn {DisposePropDelayed(SpawnedProp)}

    DisposePropDelayed(Prop:creative_prop)<suspends>:void=
        Sleep(15.0)
        # Prop.Dispose()  # TODO: Verse has no manual disposal

# If this throws an error just delete everything below this
# Wrapping Optional Agent
(Listenable : listenable(?agent)).SubscribeOptionalAgent(OutputFunc : tuple(?agent, t)->void, ExtraData : t where t:type) : cancelable =
    Wrapper := wrapper_optional_agent(t){ExtraData := ExtraData, OutputFunc := OutputFunc}
    Listenable.Subscribe(Wrapper.InputFunc)

wrapper_optional_agent(t : type) := class():
    ExtraData : t;
    OutputFunc : tuple(?agent, t) -> void
    InputFunc(Agent : ?agent):void = OutputFunc(Agent, ExtraData)