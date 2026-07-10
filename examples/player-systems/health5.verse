# Player Health Shield Manager
# This device allows dynamic modification of player health and shield values through trigger interactions. Players can increase or decrease maximum health and shield amounts using designated trigger dev
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/health5?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Playspaces }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /Verse.org/Colors }
using { /Verse.org/Colors/NamedColors }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }


PlayerAcces_Device := class(creative_device):

    var MaxHealthF : float = 100.0
    var MaxShieldF : float = 100.0

    @editable PlusHealthTrigger : trigger_device = trigger_device{}
    @editable MinusHealthTrigger : trigger_device = trigger_device{}

    @editable PlusShieldTrigger : trigger_device = trigger_device{}
    @editable MinusShieldTrigger : trigger_device = trigger_device{}

    @editable Health1Trigger : trigger_device = trigger_device{}
    @editable Health2Trigger : trigger_device = trigger_device{}


    OnBegin<override>()<suspends>:void=
        PlusHealthTrigger.TriggeredEvent.Subscribe(OnTrigger1)
        MinusHealthTrigger.TriggeredEvent.Subscribe(OnTrigger2)
        PlusShieldTrigger.TriggeredEvent.Subscribe(OnTrigger3)
        MinusShieldTrigger.TriggeredEvent.Subscribe(OnTrigger4)
        Health1Trigger.TriggeredEvent.Subscribe(OnTrigger5)
        Health2Trigger.TriggeredEvent.Subscribe(OnTrigger6)

    CheckPlayers():[]fort_character=
        Playspace : fort_playspace = GetPlayspace()
        AllPlayers: []player = Playspace.GetPlayers()
        var FortPlayerArray: []fort_character = array{}
        for(Player: AllPlayers):
            if(FortPlayer := Player.GetFortCharacter[]):
                set FortPlayerArray += array{FortPlayer}

        return FortPlayerArray

    OnTrigger1(Agent : ?agent):void=
        set MaxHealthF += 5.0
        FortPlayerArray :=  CheckPlayers()
        for(FortPlayer: FortPlayerArray):
            FortPlayer.SetMaxHealth(MaxHealthF)

    OnTrigger2(Agent : ?agent):void=
        set MaxHealthF -= 5.0
        FortPlayerArray :=  CheckPlayers()
        for(FortPlayer: FortPlayerArray):
                FortPlayer.SetMaxHealth(MaxHealthF)

    OnTrigger3(Agent : ?agent):void=
        set MaxShieldF += 5.0
        FortPlayerArray :=  CheckPlayers()
        for(FortPlayer: FortPlayerArray):
                FortPlayer.SetMaxShield(MaxShieldF)
 
    OnTrigger4(Agent : ?agent):void=
        set MaxShieldF -= 5.0
        FortPlayerArray :=  CheckPlayers()
        for(FortPlayer: FortPlayerArray):
                FortPlayer.SetMaxShield(MaxShieldF)
                
    OnTrigger5(Agent : ?agent):void=
        set MaxShieldF = 100.0
        set MaxHealthF = 100.0
        FortPlayerArray :=  CheckPlayers()
        for(FortPlayer: FortPlayerArray):
                FortPlayer.SetMaxShield(MaxShieldF)
                FortPlayer.SetMaxHealth(MaxHealthF)
    
    OnTrigger6(Agent : ?agent):void=
        set MaxShieldF = 80.0
        set MaxHealthF = 100.0
        FortPlayerArray :=  CheckPlayers()
        for(FortPlayer: FortPlayerArray):
                FortPlayer.SetMaxShield(MaxShieldF)
                FortPlayer.SetMaxHealth(MaxHealthF)