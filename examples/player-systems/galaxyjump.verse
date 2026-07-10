# Galaxyjump
# Verse code for Galaxyjump - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/galaxyjump?ref=github

using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Input/Character }
using { /UnrealEngine.com/ControlInput }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Assets }
using { /Verse.org/Simulation }



TT_ITEM_Conditional_GalaxyGrappler<localizes>:message = "Conditional button to choose which weapon works as a grappler"
TT_INPUT_Device<localizes>:message = "Input device used to push players (Fire recommended)"
TT_SOUND_Grappler<localizes>:message = "Sound effect for grappler activation"
TT_CLASS_Designer<localizes>:message = "Defines which player class is allowed to use the power, leave empty if everyone can use it"
TT_VFX_Grappler<localizes>:message = "Visual effect spawned at the players location"
TT_MOV_Modulator<localizes>:message = "Movement modulator to adjust player push behavior"
TT_PLAYER_Spawners<localizes>:message = "All player spawners in the game"
TT_CoolDown<localizes>:message = "Cooldown system for grappler usage, leave at 0 no cooldown is required"



GalaxyGrappler := class(creative_device):

    @editable {ToolTip := TT_ITEM_Conditional_GalaxyGrappler} ITEM_Conditional : conditional_button_device = conditional_button_device{}
    @editable {ToolTip := TT_SOUND_Grappler} SOUND_Grappler : audio_player_device = audio_player_device{}
    @editable {ToolTip := TT_CLASS_Designer} CLASS_Designer : ?class_designer_device = false
    @editable {ToolTip := TT_VFX_Grappler} VFX_Grappler : vfx_spawner_device = vfx_spawner_device{}
    @editable {ToolTip := TT_MOV_Modulator} MOV_Modulator : movement_modulator_device = movement_modulator_device{}
    @editable {ToolTip := TT_INPUT_Device} INPUT_Device : input_trigger_device = input_trigger_device {}
    @editable {ToolTip := TT_PLAYER_Spawners} PLAYER_Spawners : []player_spawner_device = array{}

    @editable {ToolTip := TT_CoolDown} CoolDown : float = 0.0

    var PlayerLogicMap : [player]logic = map{}
    var LastStatePlayer : [player]int = map{}

    OnBegin<override>()<suspends>:void=
        INPUT_Device.PressedEvent.Subscribe(ShouldPush)
            
        GetPlayspace().PlayerRemovedEvent().Subscribe(RemovePlayerFromMap)
        for ( EachPlayer : PLAYER_Spawners ):
            EachPlayer.SpawnedEvent.Subscribe(AddPlayerToMap)

    ItemChecker(Agent : agent )<suspends>:void =
        if :
            Player := player[Agent]
        then :
            loop :
                Sleep (0.1)
                    if (CD := CLASS_Designer?):
                        if (CD.IsOfClass[Agent]):
                            if (ITEM_Conditional.IsHoldingItem[Agent]):
                                if (LastState := LastStatePlayer[Player]):
                                    if (LastState = 0):
                                        if (set LastStatePlayer[Player] = 1):
                                        INPUT_Device.Register(Agent)
                            else :
                                if (LastState := LastStatePlayer[Player]):
                                    if (LastState = 1):
                                        if (set LastStatePlayer[Player] = 0):
                                        INPUT_Device.Unregister(Agent)

                    else :
                        if (ITEM_Conditional.IsHoldingItem[Agent]):
                            if (LastState := LastStatePlayer[Player]):
                                if (LastState = 0):
                                    if (set LastStatePlayer[Player] = 1):
                                    INPUT_Device.Register(Agent)
                        else :
                            if (LastState := LastStatePlayer[Player]):
                                if (LastState = 1):
                                    if (set LastStatePlayer[Player] = 0):
                                    INPUT_Device.Unregister(Agent)

    AddPlayerToMap(Agent : agent) : void =

        if :
            Player := player[Agent]
        then :
            if (set PlayerLogicMap[Player] = true):
            if (set LastStatePlayer[Player] = 0):

            spawn :
                ItemChecker(Agent)

    RemovePlayerFromMap(Player : player) : void =
        if (PlayerLogicMap[Player]):
            var NewMap : [player]logic = map{}
            for (Key -> Value : PlayerLogicMap, Key <> Player):
                if (set NewMap[Key] = Value) {}
            set PlayerLogicMap = NewMap

        if (LastStatePlayer[Player]):
            var NewMap : [player]int = map{}
            for (Key -> Value : LastStatePlayer, Key <> Player):
                if (set NewMap[Key] = Value) {}
            set LastStatePlayer = NewMap
            
    ShouldPush(Agent : agent):void =
            if :
                Player := player[Agent]
            then :
                if (AllowPush := PlayerLogicMap[Player]):
                    if (AllowPush = true):
                            if (CD := CLASS_Designer?):
                                if (CD.IsOfClass[Agent]):
                                    if (ITEM_Conditional.IsHoldingItem[Agent]):
                                        if (set PlayerLogicMap[Player] = false):
                                            PrePushPlayer( Agent )
                            else :
                                if (ITEM_Conditional.IsHoldingItem[Agent]):
                                    if (set PlayerLogicMap[Player] = false):
                                        PrePushPlayer( Agent )

    PrePushPlayer ( Agent : agent ) : void =
        spawn :
            PushPlayer(Agent)

    PushPlayer ( Agent : agent )<suspends> : void =
        if (TargetFC := Agent.GetFortCharacter[]):
            AgentFCPos := TargetFC.GetTransform().Translation
                    if (VFX_Grappler.TeleportTo[
                        vector3{
                            X := AgentFCPos.X,
                            Y := AgentFCPos.Y,
                            Z := AgentFCPos.Z
                        },
                        IdentityRotation()
                    ]):
                        Sleep(0.05)
                        VFX_Grappler.Restart()
                        SOUND_Grappler.Play(Agent)
                        MOV_Modulator.Activate(Agent)
                            Sleep(CoolDown)
                                if :
                                    Player := player[Agent]
                                then :
                                    if (set PlayerLogicMap[Player] = true):