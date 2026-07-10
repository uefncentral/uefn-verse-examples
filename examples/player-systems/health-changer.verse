# Health Changer
# Verse code for Health Changer - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/health-changer?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }

<#
 ____  ________  _________       __  _______________   __
/ __ \/ ____/ / /_  __/   |     / / / / ____/ ____/ | / /
/ / / / __/ / /   / / / /| |    / / / / __/ / /_  /  |/ / 
/ /_/ / /___/ /___/ / / ___ |   / /_/ / /___/ __/ / /|  /  
/_____/_____/_____/_/ /_/  |_|   \____/_____/_/   /_/ |_/    
                                                
#>

MODIFICATIONTYPE := enum{Add,Set,Remove}
HPTYPE := enum{Health,Shield}

health_manager := class(creative_device):
    @editable DeviceSettings : DefaultSettingsClass = DefaultSettingsClass{}  
    var SaveHP :logic=true 
    var ReGrantTime : float = 10.0
    var DefaultHP : HPAmounts = HPAmounts{}

    var SavedSubscriptions : [agent]?cancelable = map{} 

    @editable HPTriggers : []HPDeviceClass = array{} 
    OnBegin<override>()<suspends>:void=
        set SaveHP = DeviceSettings.SaveHP;set ReGrantTime = DeviceSettings.ReGrantTime;set DefaultHP = DeviceSettings.DefaultHP
        for(HPClass:HPTriggers){HPClass.Init(Self,SaveHP)}
        if(DeviceSettings.SaveHP?):
            if(TeamSettings:=DeviceSettings.Optional_TeamSettingDevice?,TeamSettings.GetTransform().Translation.X<>0.0): 
                TeamSettings.TeamMemberSpawnedEvent.Subscribe(PlayerSpawned)
            else:
                for(Player:GetPlayspace().GetPlayers()). PlayerAdded(Player)
                GetPlayspace().PlayerAddedEvent().Subscribe(PlayerAdded)
                GetPlayspace().PlayerRemovedEvent().Subscribe(PlayerRemoved) 
            
            SyncHP(false)
        
    PlayerAdded(Player:player):void= 
        if(FC:=Player.GetFortCharacter[]):
            Subscription:=FC.EliminatedEvent().Subscribe(PlayerEliminatedP1)
            if(set SavedSubscriptions[Player]=option{Subscription}){}
            SyncHP(option{FC})

    PlayerRemoved(Player:player):void= 
        if(SavedSubscription:=SavedSubscriptions[Player]?). SavedSubscription.Cancel()


    PlayerEliminatedP1(EliminatedResult:elimination_result):void=spawn{PlayerEliminatedP2(EliminatedResult.EliminatedCharacter)}

    PlayerEliminatedP2(FC:fort_character)<suspends>:void=
        Sleep(ReGrantTime)
        SyncHP(option{FC})

    PlayerSpawned(Agent:agent):void= if(FC:=Agent.GetFortCharacter[]){ SyncHP(option{FC} )}

    SyncHP(MFC:?fort_character):void= 
        if(FC:=MFC?):
            FC.SetMaxHealth(DefaultHP.Health)
        else if(SaveHP?):
            for(Player:GetPlayspace().GetPlayers()):
                if(FC:=Player.GetFortCharacter[]):
                    FC.SetMaxHealth(DefaultHP.Health)
    
    ChangeHP(Type:MODIFICATIONTYPE,HPType:HPTYPE,Amount:float,MFC:?fort_character):void=
        if(SaveHP?):
            case(HPType):
                HPTYPE.Health =>
                    set DefaultHP.Health = CalculateNewHP(DefaultHP.Health,Amount,Type)
                HPTYPE.Shield =>
                    set DefaultHP.Shield = CalculateNewHP(DefaultHP.Shield,Amount,Type)
                    
            SyncHP(false)
        else if(FC:=MFC?):
            case(HPType):
                HPTYPE.Health =>
                    NewHealth:=CalculateNewHP(FC.GetMaxHealth(),Amount,Type)
                    FC.SetMaxHealth(NewHealth)
                HPTYPE.Shield =>
                    NewShield:=CalculateNewHP(FC.GetMaxShield(),Amount,Type)
                    FC.SetMaxShield(NewShield);FC.SetShield(NewShield)

            SyncHP( option{FC} )
        
    CalculateNewHP(PreviousHP:float,Amount:float,ModificationType:MODIFICATIONTYPE):float=
        case(ModificationType):
            MODIFICATIONTYPE.Add => PreviousHP+Amount
            MODIFICATIONTYPE.Remove => PreviousHP-Amount
            MODIFICATIONTYPE.Set => Amount

DefaultSettingsClass:=class<concrete>:
    @editable Optional_TeamSettingDevice : ?team_settings_and_inventory_device = false 
    @editable var DefaultHP : HPAmounts = HPAmounts{}
    @editable ReGrantTime : float = 9.0 
    @editable SaveHP : logic = true 


HPDeviceClass:=class<concrete>:
    @editable ModifyType : MODIFICATIONTYPE = MODIFICATIONTYPE.Add 
    @editable Amount : float = 10.0
    @editable Type : HPTYPE = HPTYPE.Health
    @editable ResetHPOnChange : logic = false
    @editable Trigger : trigger_device = trigger_device{} 
    var SelfDevice : health_manager = health_manager{}
    var SaveHP : logic = true # 
    Init(HealthDevice:health_manager,ShouldSave:logic):void=
        set SelfDevice=HealthDevice;set SaveHP=ShouldSave
        Trigger.TriggeredEvent.Subscribe(Triggered)
    Triggered(MAgent:?agent):void=
        SelfDevice.ChangeHP(ModifyType,Type,Amount,option{MAgent?.GetFortCharacter[]})


HPAmounts:=class<concrete>:
    @editable var Health:float=100.0
    @editable var Shield:float=100.0