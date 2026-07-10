# Toggle System
# Verse code for Toggle System - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/toggle-system?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

toggle_system := class(creative_device):

    @editable RemoteManager:signal_remote_manager_device = signal_remote_manager_device{}
    @editable MainVolume:volume_device = volume_device{}
    @editable MainToAwayTeleporter:teleporter_device = teleporter_device{}
    @editable Player1AwayToMainTeleporter:teleporter_device = teleporter_device{}
    @editable Player2AwayToMainTeleporter:teleporter_device = teleporter_device{}

    @editable TurnOnAllButton:button_device = button_device{}
    @editable TurnOffAllButton:button_device = button_device{}

    @editable Switch1:switch_device = switch_device{}
    @editable Switch2:switch_device = switch_device{}
    @editable Switch3:switch_device = switch_device{}
    @editable Switch4:switch_device = switch_device{}
    @editable Switch5:switch_device = switch_device{}
    @editable Switch6:switch_device = switch_device{}
    @editable Switch7:switch_device = switch_device{}
    @editable Switch8:switch_device = switch_device{}
    @editable Switch9:switch_device = switch_device{}
    @editable Switch10:switch_device = switch_device{}
    @editable Switch11:switch_device = switch_device{}
    @editable Switch12:switch_device = switch_device{}
    @editable Switch13:switch_device = switch_device{}
    @editable Switch14:switch_device = switch_device{}
    @editable Switch15:switch_device = switch_device{}
    @editable Switch16:switch_device = switch_device{}
    @editable Switch17:switch_device = switch_device{}
    @editable Switch18:switch_device = switch_device{}
    @editable Switch19:switch_device = switch_device{}
    @editable Switch20:switch_device = switch_device{}
    @editable Switch21:switch_device = switch_device{}
    @editable Switch22:switch_device = switch_device{}
    @editable Switch23:switch_device = switch_device{}
    @editable Switch24:switch_device = switch_device{}
    @editable Switch25:switch_device = switch_device{}
    @editable Switch26:switch_device = switch_device{}
    @editable Switch27:switch_device = switch_device{}
    @editable Switch28:switch_device = switch_device{}
    @editable Switch29:switch_device = switch_device{}
    @editable Switch30:switch_device = switch_device{}
    @editable Switch31:switch_device = switch_device{}
    @editable Switch32:switch_device = switch_device{}
    @editable Switch33:switch_device = switch_device{}
    @editable Switch34:switch_device = switch_device{}
    @editable Switch35:switch_device = switch_device{}
    @editable Switch36:switch_device = switch_device{}

    var Player1InVolume:logic = false
    var Player2InVolume:logic = false

    OnBegin<override>()<suspends>:void=
        RemoteManager.PrimarySignalEvent.Subscribe(OnPrimarySignal)
        MainVolume.AgentEntersEvent.Subscribe(OnPlayerEnters)
        MainVolume.AgentExitsEvent.Subscribe(OnPlayerExits)
        TurnOnAllButton.InteractedWithEvent.Subscribe(TurnOnAll)
        TurnOffAllButton.InteractedWithEvent.Subscribe(TurnOffAll)

    TurnOnAll(Agent:agent):void=
        Switch1.SetState(true)
        Switch2.SetState(true)
        Switch3.SetState(true)
        Switch4.SetState(true)
        Switch5.SetState(true)
        Switch6.SetState(true)
        Switch7.SetState(true)
        Switch8.SetState(true)
        Switch9.SetState(true)
        Switch10.SetState(true)
        Switch11.SetState(true)
        Switch12.SetState(true)
        Switch13.SetState(true)
        Switch14.SetState(true)
        Switch15.SetState(true)
        Switch16.SetState(true)
        Switch17.SetState(true)
        Switch18.SetState(true)
        Switch19.SetState(true)
        Switch20.SetState(true)
        Switch21.SetState(true)
        Switch22.SetState(true)
        Switch23.SetState(true)
        Switch24.SetState(true)
        Switch25.SetState(true)
        Switch26.SetState(true)
        Switch27.SetState(true)
        Switch28.SetState(true)
        Switch29.SetState(true)
        Switch30.SetState(true)
        Switch31.SetState(true)
        Switch32.SetState(true)
        Switch33.SetState(true)
        Switch34.SetState(true)
        Switch35.SetState(true)
        Switch36.SetState(true)

    TurnOffAll(Agent:agent):void=
        Switch1.SetState(false)
        Switch2.SetState(false)
        Switch3.SetState(false)
        Switch4.SetState(false)
        Switch5.SetState(false)
        Switch6.SetState(false)
        Switch7.SetState(false)
        Switch8.SetState(false)
        Switch9.SetState(false)
        Switch10.SetState(false)
        Switch11.SetState(false)
        Switch12.SetState(false)
        Switch13.SetState(false)
        Switch14.SetState(false)
        Switch15.SetState(false)
        Switch16.SetState(false)
        Switch17.SetState(false)
        Switch18.SetState(false)
        Switch19.SetState(false)
        Switch20.SetState(false)
        Switch21.SetState(false)
        Switch22.SetState(false)
        Switch23.SetState(false)
        Switch24.SetState(false)
        Switch25.SetState(false)
        Switch26.SetState(false)
        Switch27.SetState(false)
        Switch28.SetState(false)
        Switch29.SetState(false)
        Switch30.SetState(false)
        Switch31.SetState(false)
        Switch32.SetState(false)
        Switch33.SetState(false)
        Switch34.SetState(false)
        Switch35.SetState(false)
        Switch36.SetState(false)

    OnPrimarySignal(Agent:agent):void=
        Players:=GetPlayspace().GetPlayers()
        if(Player1:=Players[0]):
            if(Agent = Player1):
                if(Player1InVolume = true):
                    MainToAwayTeleporter.Teleport(Player1)
                else:
                    Player1AwayToMainTeleporter.Teleport(Player1)

        if(Player2:=Players[1]):
            if(Agent = Player2):
                if(Player2InVolume = true):
                    MainToAwayTeleporter.Teleport(Player2)
                else:
                    Player2AwayToMainTeleporter.Teleport(Player2)

    GetMinigameArray():[]int=
        var Array:[]int = array{}

        if(Switch1.GetCurrentState[]):
            set Array = Array + array{1}
        
        if(Switch2.GetCurrentState[]):
            set Array = Array + array{2}

        if(Switch3.GetCurrentState[]):
            set Array = Array + array{3}

        if(Switch4.GetCurrentState[]):
            set Array = Array + array{4}

        if(Switch5.GetCurrentState[]):
            set Array = Array + array{5}

        if(Switch6.GetCurrentState[]):
            set Array = Array + array{6}
           
        if(Switch7.GetCurrentState[]):
            set Array = Array + array{7}
            
        if(Switch8.GetCurrentState[]):
            set Array = Array + array{8}
    
        if(Switch9.GetCurrentState[]):
            set Array = Array + array{9}

        if(Switch10.GetCurrentState[]):
            set Array = Array + array{10}

        if(Switch11.GetCurrentState[]):
            set Array = Array + array{11}

        if(Switch12.GetCurrentState[]):
            set Array = Array + array{12}

        if(Switch13.GetCurrentState[]):
            set Array = Array + array{13}

        if(Switch14.GetCurrentState[]):
            set Array = Array + array{14}

        if(Switch15.GetCurrentState[]):
            set Array = Array + array{15}

        if(Switch16.GetCurrentState[]):
            set Array = Array + array{16}

        if(Switch17.GetCurrentState[]):
            set Array = Array + array{17}

        if(Switch18.GetCurrentState[]):
            set Array = Array + array{18}

        if(Switch19.GetCurrentState[]):
            set Array = Array + array{19}

        if(Switch20.GetCurrentState[]):
            set Array = Array + array{20}

        if(Switch21.GetCurrentState[]):
            set Array = Array + array{21}

        if(Switch22.GetCurrentState[]):
            set Array = Array + array{22}

        if(Switch23.GetCurrentState[]):
            set Array = Array + array{23}

        if(Switch24.GetCurrentState[]):
            set Array = Array + array{24}

        if(Switch25.GetCurrentState[]):
            set Array = Array + array{25}

        if(Switch26.GetCurrentState[]):
            set Array = Array + array{26}

        if(Switch27.GetCurrentState[]):
            set Array = Array + array{27}

        if(Switch28.GetCurrentState[]):
            set Array = Array + array{28}

        if(Switch29.GetCurrentState[]):
            set Array = Array + array{29}

        if(Switch30.GetCurrentState[]):
            set Array = Array + array{30}
        
        if(Switch31.GetCurrentState[]):
            set Array = Array + array{31}

        if(Switch32.GetCurrentState[]):
            set Array = Array + array{32}

        if(Switch33.GetCurrentState[]):
            set Array = Array + array{33}

        if(Switch34.GetCurrentState[]):
            set Array = Array + array{34}

        if(Switch35.GetCurrentState[]):
            set Array = Array + array{35}

        if(Switch36.GetCurrentState[]):
            set Array = Array + array{36}

        Print("Possible Minigames: {Array.Length}")
        
        return Array

    OnPlayerEnters(Agent:agent):void=
        Players:=GetPlayspace().GetPlayers()
        if(Player1:=Players[0]):
            if(Agent = Player1):
                set Player1InVolume = true

        if(Player2:=Players[1]):
            if(Agent = Player2):
                set Player2InVolume = true

    OnPlayerExits(Agent:agent):void=
        Players:=GetPlayspace().GetPlayers()
        if(Player1:=Players[0]):
            if(Agent = Player1):
                set Player1InVolume = false

        if(Player2:=Players[1]):
            if(Agent = Player2):
                set Player2InVolume = false