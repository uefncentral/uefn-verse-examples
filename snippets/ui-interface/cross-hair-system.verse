# Cross Hair System
# Verse code for Cross Hair System - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/cross-hair-system?ref=github

using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Game }
using { /Verse.org/Assets }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Colors }

DefaultSize : vector2 = vector2{X := 50.0, Y := 50.0}
DefaultCrosshair: texture = crosshairs.DefaultCrosshair_

CROSSHAIR_SYSTEM := class(creative_device):

   

    @editable 
    HUD_CONTROLLER_TEAM_1 :hud_controller_device = hud_controller_device {}

    @editable 
    HUD_CONTROLLER_TEAM_2 :hud_controller_device = hud_controller_device {}

    @editable 
    Minimum_size_crosshair : float = 16.0
    
    @editable 
    Maximum_size_crosshair : float = 300.0

    @editable 
    crosshair_grid_size: float = 20.0

    @editable
    trigger_increase_crosshair_size : trigger_device = trigger_device{}
    @editable
    trigger_decrease_crosshair_size : trigger_device = trigger_device{}


    @editable color_yellow_Trigger: trigger_device = trigger_device{}
    @editable color_blue_Trigger: trigger_device = trigger_device{}
    @editable color_red_Trigger: trigger_device = trigger_device{}
    @editable color_pink_Trigger: trigger_device = trigger_device{}
    @editable color_green_Trigger: trigger_device = trigger_device{}
    @editable color_cyan_Trigger: trigger_device = trigger_device{}
    @editable color_white_Trigger: trigger_device = trigger_device{}
    @editable color_black_Trigger: trigger_device = trigger_device{}

    @editable
    trigger_remove_crosshair: trigger_device = trigger_device{}

    @editable
    Triggers: []trigger_device = array{}
 
    CROSSHAIR_TEXTURES: []texture = array{
    crosshairs.crosshair001, crosshairs.crosshair002, crosshairs.crosshair003, 
    crosshairs.crosshair004, crosshairs.crosshair005, crosshairs.crosshair006, 
    crosshairs.crosshair007, crosshairs.crosshair008, crosshairs.crosshair009, 
    crosshairs.crosshair010, crosshairs.crosshair011, crosshairs.crosshair012, 
    crosshairs.crosshair013, crosshairs.crosshair014, crosshairs.crosshair015, 
    crosshairs.crosshair016, crosshairs.crosshair017, crosshairs.crosshair018, 
    crosshairs.crosshair019, crosshairs.crosshair020, crosshairs.crosshair021, 
    crosshairs.crosshair022, crosshairs.crosshair023, crosshairs.crosshair024, 
    crosshairs.crosshair025, crosshairs.crosshair026, crosshairs.crosshair027, 
    crosshairs.crosshair028, crosshairs.crosshair029, crosshairs.crosshair030, 
    crosshairs.crosshair031, crosshairs.crosshair032, crosshairs.crosshair033, 
    crosshairs.crosshair034, crosshairs.crosshair035, crosshairs.crosshair036}

    CancleTriggerEvents: event() = event(){}
    var PlayersMap : [agent]tuple(float, texture_block) = map{}

    OnBegin<override>()<suspends>:void =
            for (Index := 0..Triggers.Length - 1):
                if (Trigger := Triggers[Index]):
                    spawn { Trigger.AwaitTrigger(Index) }
        

        HUD_CONTROLLER_TEAM_1.Disable()
        HUD_CONTROLLER_TEAM_2.Disable()

        color_yellow_Trigger.TriggeredEvent.Subscribe(OnTriggerYELLOW)
        color_blue_Trigger.TriggeredEvent.Subscribe(OnTriggerBLUE)
        color_red_Trigger.TriggeredEvent.Subscribe(OnTriggerRED)
        color_pink_Trigger.TriggeredEvent.Subscribe(OnTriggerPINK)
        color_green_Trigger.TriggeredEvent.Subscribe(OnTriggerGREEN)
        color_cyan_Trigger.TriggeredEvent.Subscribe(OnTriggerCYAN)
        color_white_Trigger.TriggeredEvent.Subscribe(OnTriggerWHITE)
        color_black_Trigger.TriggeredEvent.Subscribe(OnTriggerBLACK)
        trigger_remove_crosshair.TriggeredEvent.Subscribe(OnTrigger2)

        trigger_increase_crosshair_size.TriggeredEvent.Subscribe(OnBigger)
        trigger_decrease_crosshair_size.TriggeredEvent.Subscribe(OnSmaller)

     


    (Trigger: trigger_device).AwaitTrigger(Index: int)<suspends>: void =
            race:
                block:
                    CancleTriggerEvents.Await()
                loop:
                    Result := Trigger.TriggeredEvent.Await()
                    spawn{OnTrigger(Result, Index)}
        

    OnTrigger(Result: ?agent, Index: int)<suspends>:void=
        if(Agent:=Result?):
            TeamCollection := GetPlayspace().GetTeamCollection()
                    if:
                        AgentsTeam := TeamCollection.GetTeam[Agent]
                    then:
                        TeamsArray := TeamCollection.GetTeams()
                        for (TeamNumber -> Team : TeamsArray):
                            if (AgentsTeam = Team):
                                if (TeamNumber = 0):
                                  HUD_CONTROLLER_TEAM_1.Enable()
                                  for (OtherIndex := 0..CROSSHAIR_TEXTURES.Length - 1):
                                    if (OtherIndex = Index):  
                                        if (Crosshair_texture := CROSSHAIR_TEXTURES[Index]):
                                                Data := GetPlayData(Agent)
                                                Data(1).SetImage(Crosshair_texture) 
                                                if:
                                                    set PlayersMap[Agent] = (Data(0), Data(1))
    
                                if (TeamNumber = 1):
                                  HUD_CONTROLLER_TEAM_2.Enable()     
                                  for (OtherIndex := 0..CROSSHAIR_TEXTURES.Length - 1):
                                    if (OtherIndex = Index):  
                                        if (Crosshair_texture := CROSSHAIR_TEXTURES[Index]):
                                                Data := GetPlayData(Agent)
                                                Data(1).SetImage(Crosshair_texture) 
                                                if:
                                                    set PlayersMap[Agent] = (Data(0), Data(1))

    OnTrigger2(Result: ?agent):void=
        if(Agent:=Result?):
            TeamCollection := GetPlayspace().GetTeamCollection()
                    if:
                        AgentsTeam := TeamCollection.GetTeam[Agent]
                    then:
                        TeamsArray := TeamCollection.GetTeams()
                        for (TeamNumber -> Team : TeamsArray):
                            if (AgentsTeam = Team):
                                if (TeamNumber = 0):
                                  HUD_CONTROLLER_TEAM_1.Disable()
                                  Data := GetPlayData(Agent)
                                  Data(1).SetImage(DefaultCrosshair) 
                                        if:
                                            set PlayersMap[Agent] = (Data(0), Data(1))
                                                
    
                                if (TeamNumber = 1):
                                  HUD_CONTROLLER_TEAM_2.Disable() 
                                  Data := GetPlayData(Agent)
                                  Data(1).SetImage(DefaultCrosshair) 
                                        if:
                                            set PlayersMap[Agent] = (Data(0), Data(1))  
                                 
                                                


    OnBigger(MaybeAgent:?agent):void=
      if (Agent := MaybeAgent?):
        Data := GetPlayData(Agent)
        NewValue := Clamp(Data(0) + crosshair_grid_size, Minimum_size_crosshair, Maximum_size_crosshair)
        Data(1).SetDesiredSize(vector2{X := NewValue, Y := NewValue})
        if:
          set PlayersMap[Agent] = (NewValue, Data(1))
  
    OnSmaller(MaybeAgent:?agent):void=
      if (Agent := MaybeAgent?):
        Data := GetPlayData(Agent)
        NewValue := Clamp(Data(0) - crosshair_grid_size, Minimum_size_crosshair, Maximum_size_crosshair)
        Data(1).SetDesiredSize(vector2{X := NewValue, Y := NewValue})
        if:
          set PlayersMap[Agent] = (NewValue, Data(1))


    RESETSIZE(AgentT:?agent):void=
      if (Agent := AgentT?):
        Data := GetPlayData(Agent)
        Data(1).SetDesiredSize(DefaultSize)
        if:
          set PlayersMap[Agent] = (DefaultSize.X, Data(1))

    GetPlayData(Agent:agent):tuple(float, texture_block)=
      if (Data := PlayersMap[Agent]):
        return Data
      else:
        TB := CreateCanvas(Agent)
        if:
          set PlayersMap[Agent] = (DefaultSize.X, TB)
        return (DefaultSize.X, TB)

    CreateCanvas(Agent:agent):texture_block=
            TB := texture_block :
              DefaultImage := DefaultCrosshair
              DefaultDesiredSize := DefaultSize
            Canvas := canvas:
              Slots := array :
                canvas_slot :
                  Anchors := anchors :
                    Minimum := vector2{X := 0.5, Y := 0.5}
                    Maximum := vector2{X := 0.5, Y := 0.5}
                  Alignment := vector2{X := 0.5, Y := 0.5}
                  SizeToContent := true
                  Widget := TB
          
            if (Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
              PlayerUI.AddWidget(Canvas)
          
            return TB

    OnTriggerYELLOW(MaybeAgent:?agent):void=
      if (Agent := MaybeAgent?):
        Data := GetPlayData(Agent)
        Data(1).SetTint(color{R := 1.0, G := 1.0, B := 0.0})  
        if:
          set PlayersMap[Agent] = (Data(0), Data(1))

    OnTriggerBLUE(MaybeAgent:?agent):void=
      if (Agent := MaybeAgent?):
        Data := GetPlayData(Agent)
        Data(1).SetTint(color{R := 0.0, G := 0.0, B := 0.5})  
        if:
          set PlayersMap[Agent] = (Data(0), Data(1))

    OnTriggerRED(MaybeAgent:?agent):void=
      if (Agent := MaybeAgent?):
        Data := GetPlayData(Agent)
        Data(1).SetTint(color{R := 1.0, G := 0.0, B := 0.0}) 
        if:
          set PlayersMap[Agent] = (Data(0), Data(1))

    OnTriggerPINK(MaybeAgent:?agent):void=
      if (Agent := MaybeAgent?):
        Data := GetPlayData(Agent)
        Data(1).SetTint(color{R := 1.0, G := 0.0, B := 1.0})
        if:
            set PlayersMap[Agent] = (Data(0), Data(1))

    OnTriggerGREEN(MaybeAgent:?agent):void=
      if (Agent := MaybeAgent?):
        Data := GetPlayData(Agent)
        Data(1).SetTint(color{R := 0.0, G := 1.0, B := 0.0})  
        if:
          set PlayersMap[Agent] = (Data(0), Data(1))

    OnTriggerCYAN(MaybeAgent:?agent):void=
      if (Agent := MaybeAgent?):
        Data := GetPlayData(Agent)
        Data(1).SetTint(color{R := 0.0, G := 1.0, B := 1.0})  
        if:
          set PlayersMap[Agent] = (Data(0), Data(1))

    OnTriggerWHITE(MaybeAgent:?agent):void=
      if (Agent := MaybeAgent?):
        Data := GetPlayData(Agent)
        Data(1).SetTint(color{R := 1.0, G := 1.0, B := 1.0})  
        if:
          set PlayersMap[Agent] = (Data(0), Data(1))

    OnTriggerBLACK(MaybeAgent:?agent):void=
      if (Agent := MaybeAgent?):
        Data := GetPlayData(Agent)
        Data(1).SetTint(color{R := 0.0, G := 0.0, B := 0.0})  
        if:
          set PlayersMap[Agent] = (Data(0), Data(1))
    

