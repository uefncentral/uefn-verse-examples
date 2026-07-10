# Powerup and Killstreak UI
# This code creates a UI system that displays HUD messages when players pick up damage or movement powerups, and shows killstreak notifications at different elimination milestones. It tracks player elim
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/game-ui-1?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

powerups := class<concrete>:
    @editable
    Damage_PowerUP : []visual_effect_powerup_device = array{}
    @editable
    Movement_PowerUP : []visual_effect_powerup_device = array{}
    @editable
    Damage_HUD : hud_message_device = hud_message_device{}
    @editable
    Speed_HUD : hud_message_device = hud_message_device{}

    Activate():void=
        for(Damage_PowerUPs : Damage_PowerUP, Movement_PowerUPs : Movement_PowerUP):
            Damage_PowerUPs.ItemPickedUpEvent.Subscribe(ShowDamageHUD)
            Movement_PowerUPs.ItemPickedUpEvent.Subscribe(ShowSpeedHUD)

    ShowDamageHUD(Agent:agent):void=
        Damage_HUD.Show(Agent)
    
    ShowSpeedHUD(Agent:agent):void=
        Speed_HUD.Show(Agent)

killstreak := class<concrete>:

    @editable
    Kill_Tracker : tracker_device = tracker_device{}
    @editable
    KillStreak_2 : hud_message_device = hud_message_device{}
    @editable
    KillStreak_3 : hud_message_device = hud_message_device{}
    @editable
    KillStreak_4 : hud_message_device = hud_message_device{}
    @editable
    KillStreak_5 : hud_message_device = hud_message_device{}
    @editable
    KillStreak_10 : hud_message_device = hud_message_device{}

    @editable
    Elim_Manager : elimination_manager_device = elimination_manager_device{}
    @editable
    Damage_Volume : damage_volume_device = damage_volume_device{}
    
    Activate():void=
        Elim_Manager.EliminationEvent.Subscribe(ShowUI)
        Elim_Manager.EliminatedEvent.Subscribe(Reset)
        Damage_Volume.AgentEntersEvent.Subscribe(Reset)

    ShowUI(Agent:?agent):void=
        if (CastAgent := agent[Agent?]):
            Kill_Tracker.Increment(CastAgent)
            Eliminations := Kill_Tracker.GetValue(CastAgent)
            if(Eliminations = 2):
                KillStreak_2.Show(CastAgent)
            if(Eliminations = 3):
                KillStreak_3.Show(CastAgent)
            if(Eliminations = 4):
                KillStreak_4.Show(CastAgent)
            if(Eliminations = 5):
                KillStreak_5.Show(CastAgent)
            if(Eliminations = 10):
                KillStreak_10.Show(CastAgent)

    Reset(Agent:agent):void=
        Kill_Tracker.Reset(Agent)

Game_UI := class(creative_device):

    @editable
    PowerUPs : powerups = powerups{}

    @editable
    KillStreaks : killstreak = killstreak{}

    OnBegin<override>()<suspends>:void=
        PowerUPs.Activate()
        KillStreaks.Activate()