# Player Health/Shield Modifier
# This device allows dynamic modification of all players' maximum health and shield values through trigger interactions. When triggers are activated, it applies predefined health and shield limits to al
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/overshield?ref=github

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


ChangerHealth := class(creative_device):

    var MaxHealthH : float = 100.0
    var MaxHealthG : float = 100.0
    var MaxShieldH : float = 100.0
    var MaxShieldG : float = 80.0

    @editable PlusHealthTrigger : trigger_device = trigger_device{}
    @editable MinusHealthTrigger : trigger_device = trigger_device{}

    @editable PlusShieldTrigger : trigger_device = trigger_device{}
    @editable MinusShieldTrigger : trigger_device = trigger_device{}


    OnBegin<override>()<suspends>:void=
        PlusHealthTrigger.TriggeredEvent.Subscribe(OnTrigger1)
        MinusHealthTrigger.TriggeredEvent.Subscribe(OnTrigger2)

    CheckPlayers():[]fort_character=
        Playspace : fort_playspace = GetPlayspace()
        AllPlayers: []player = Playspace.GetPlayers()
        var FortPlayerArray: []fort_character = array{}
        for(Player: AllPlayers):
            if(FortPlayer := Player.GetFortCharacter[]):
                set FortPlayerArray += array{FortPlayer}

        return FortPlayerArray

    OnTrigger1(Agent : ?agent):void=
        set MaxHealthH = 100.0
        set MaxShieldH = 100.0
        FortPlayerArray :=  CheckPlayers()
        for(FortPlayer: FortPlayerArray):
            FortPlayer.SetMaxHealth(MaxHealthH)
            FortPlayer.SetMaxShield(MaxShieldG)

    OnTrigger2(Agent : ?agent):void=
        set MaxHealthG = 80.0
        set MaxShieldG = 100.0
        FortPlayerArray :=  CheckPlayers()
        for(FortPlayer: FortPlayerArray):
                FortPlayer.SetMaxHealth(MaxHealthG)
                FortPlayer.SetMaxShield(MaxShieldG)