# Super Power Vending Machine-code
# Verse code for Super Power Vending Machine-code - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/super-power-vending-machine-code?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/Game }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /Verse.org/Colors }
using { /Verse.org/Colors/NamedColors }
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
General := struct<concrete>{
    @editable Purchased_XP_Giver : accolades_device = accolades_device{}
    @editable Purchased_Audio_Player : audio_player_device = audio_player_device{}
    @editable Gold_Checker : conditional_button_device = conditional_button_device{}
    @editable Not_Enough_MSG : hud_message_device = hud_message_device{}
    @editable Player_Spawners : []player_spawner_device = array{}
}

Speed_Boost := struct<concrete>{
    @editable SpeedBoostButton : button_device = button_device{}
    @editable SpeedModulator : movement_modulator_device = movement_modulator_device{}
    @editable SuperSpeedMessage : hud_message_device = hud_message_device{}
    @editable SpeedBoostPrice : int = 50
    @editable SpeedBoostUIDuration : float = 120.0  #time needs to be the exact time as (Minutes1 & Seconds1) highlight either one and click ctrl + f to find where it is used... make sure the times are the same for each power unless you want each to be 2 minutes then leave it how it is.
}

Jump_Boost := struct<concrete>{
    @editable JumpBoostButton : button_device = button_device{}
    @editable JumpModulator : movement_modulator_device = movement_modulator_device{}
    @editable SuperJumpMessage : hud_message_device = hud_message_device{}
    @editable JumpBoostPrice : int = 50
    @editable JumpBoostDuration : float = 120.0
}

Passive_Regen := struct<concrete>{
    @editable RegenerationButton : button_device = button_device{}
    @editable RegenerationDevice : health_powerup_device = health_powerup_device{}
    @editable RegenerationMessage : hud_message_device = hud_message_device{}
    @editable RegenerationPrice : int = 75
    @editable RegenerationUIDuration : float = 120.0   
}

Shield_Boost := struct<concrete>{
    @editable ShieldBoostButton : button_device = button_device{}
    @editable JuggernautMessage : hud_message_device = hud_message_device{}
    @editable ShieldBoostPrice : int = 100
    @editable ShieldToGrant : float = 500.0
}

Vampirism_Power := struct<concrete>{
    @editable VampirismButton : button_device = button_device{}
    @editable VampirismMessage : hud_message_device = hud_message_device{}
    @editable VampirismPrice : int = 100
    @editable VampirismDuration : float = 120.0
}

Double_Damage := struct<concrete>{
    @editable DoubleDamageButton : button_device = button_device{}
    @editable DamageAmplifier: damage_amplifier_powerup_device = damage_amplifier_powerup_device{}
    @editable DoubleDamageMessage : hud_message_device = hud_message_device{}
    @editable DoubleDamagePrice : int = 100
    @editable DoubleDamageUIDuration : float = 120.0
}

Invisibility_Card := struct<concrete>{
    @editable InvisibilityButton : button_device = button_device{}
    @editable CardDetector : conditional_button_device = conditional_button_device{}
    @editable InvisCardGranter : item_granter_device = item_granter_device{}
    @editable InvisMessage : hud_message_device = hud_message_device{}
    @editable CardRemover : item_remover_device = item_remover_device{}
    @editable InvisibilityPrice : int = 75
    @editable InvisibilityDuration : float = 120.0
}

Instant_Reload := struct<concrete>{
    @editable InstantRealoadButton : button_device = button_device{}
    @editable InstantRealoadClassSelector :  class_and_team_selector_device =  class_and_team_selector_device{}
    @editable InstaReloadMessage : hud_message_device = hud_message_device{}
    @editable InstantRealoadEndClassSelector :  class_and_team_selector_device =  class_and_team_selector_device{}
    @editable InstantReloadPrice : int = 50
    @editable InstantReloadDuration : float = 120.0
}

Freeze_Gun:= struct<concrete>{
    @editable FreezeGunButton : button_device = button_device{}
    @editable FreezeGunGranter : item_granter_device = item_granter_device{}
    @editable DoublePumpMessage : hud_message_device = hud_message_device{}
    @editable FreezeGunRemover : item_remover_device = item_remover_device{}
    @editable FreezeGunTracker : conditional_button_device = conditional_button_device{}
    @editable Freeze_Gun_Cost : int = 50
    @editable Freeze_Player_Duration : float = 2.9
    @editable Freeze_Gun_Duration : float = 120.0
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sss := class(creative_device):
     
    var SuperPowerMap : [player]Custom_Player_SuperPower = map{}
    
    var Heal_Delay : float = 0.1
    
    @editable General_Devices : General = General{}

    @editable Speed_Boost_Devices : Speed_Boost = Speed_Boost{}

    @editable Jump_Boost_Devices : Jump_Boost = Jump_Boost{}

    @editable Regeneration_Devices : Passive_Regen = Passive_Regen{}

    @editable Shield_Boost_Devices : Shield_Boost = Shield_Boost{}

    @editable Vampirism_Devices : Vampirism_Power = Vampirism_Power{}

    @editable Double_Damage_Devices : Double_Damage = Double_Damage{}

    @editable Invisibility_Devices : Invisibility_Card = Invisibility_Card{}

    @editable Instant_Reload_Devices : Instant_Reload = Instant_Reload{}

    @editable Freeze_Gun_Devices : Freeze_Gun = Freeze_Gun{}

    OnBegin<override>()<suspends>:void=
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
        Speed_Boost_Devices.SpeedBoostButton.InteractedWithEvent.Subscribe(SpeedBoost)
        Jump_Boost_Devices.JumpBoostButton.InteractedWithEvent.Subscribe(JumpBoost)
        Regeneration_Devices.RegenerationButton.InteractedWithEvent.Subscribe(Regeneration)
        Shield_Boost_Devices.ShieldBoostButton.InteractedWithEvent.Subscribe(ShieldBoost)
        Vampirism_Devices.VampirismButton.InteractedWithEvent.Subscribe(Vampirism)
        Double_Damage_Devices.DoubleDamageButton.InteractedWithEvent.Subscribe(DoubleDamage)
        Invisibility_Devices.InvisibilityButton.InteractedWithEvent.Subscribe(Invisibility)
        Instant_Reload_Devices.InstantRealoadButton.InteractedWithEvent.Subscribe(InstantReload)
        Freeze_Gun_Devices.FreezeGunButton.InteractedWithEvent.Subscribe(FreezeGun)

        initializeSpawners()
    
    initializeSpawners():void=
        for(Spawner:General_Devices.Player_Spawners):
                Spawner.SpawnedEvent.Subscribe(InitializePlayer)
    
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------     
        Players := GetPlayspace().GetPlayers()
                for(Player:Players):
                    InitializePlayer(Player)
                    DetectJump(Player)
                    DetectVamp(Player)
                    
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------        
    SpeedBoost(Agent:agent):void=
        OnButtonClicked(Agent,Speed_Boost_Devices.SpeedBoostPrice,"Speed")
    JumpBoost(Agent : agent):void=
        OnButtonClicked(Agent,Jump_Boost_Devices.JumpBoostPrice,"Jump")
    Regeneration(Agent:agent):void=
        OnButtonClicked(Agent,Regeneration_Devices.RegenerationPrice,"Regen")
    ShieldBoost(Agent:agent):void=
        OnButtonClicked(Agent,Shield_Boost_Devices.ShieldBoostPrice,"Jug")                       
    Vampirism(Agent:agent):void=
        OnButtonClicked(Agent,Vampirism_Devices.VampirismPrice,"Vamp")
    DoubleDamage(Agent:agent):void=
        OnButtonClicked(Agent,Double_Damage_Devices.DoubleDamagePrice,"DoubleDmg")
    Invisibility(Agent:agent):void=
        OnButtonClicked(Agent,Invisibility_Devices.InvisibilityPrice,"Invis")
    InstantReload(Agent:agent):void=
        OnButtonClicked(Agent,Instant_Reload_Devices.InstantReloadPrice,"InstaRe")
    FreezeGun(Agent:agent):void=
        OnButtonClicked(Agent,Freeze_Gun_Devices.Freeze_Gun_Cost,"FreezeGu")
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    AgentToMessage1<localizes>(Agent : agent)<computes> : message = "{Agent}"
    AgentToMessage2<localizes>(Agent : agent)<computes> : message = "{Agent}"
    AgentToMessage3<localizes>(Agent : agent)<computes> : message = "{Agent}"
    AgentToMessage4<localizes>(Agent : agent)<computes> : message = "{Agent}"
    AgentToMessage5<localizes>(Agent : agent)<computes> : message = "{Agent}"
    AgentToMessage6<localizes>(Agent : agent)<computes> : message = "{Agent}"
    AgentToMessage7<localizes>(Agent : agent)<computes> : message = "{Agent}"
    AgentToMessage8<localizes>(Agent : agent)<computes> : message = "{Agent}"
    AgentToMessage9<localizes>(Agent : agent)<computes> : message = "{Agent}"

#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    TakeCoins(Agent : agent,Price : int,GoldCount : int):void=
        if (GoldCount >= Price):
            General_Devices.Gold_Checker.SetItemCountRequired(0, Price)
            General_Devices.Gold_Checker.Activate(Agent)

        else:
        
            
    OnButtonClicked(Agent : agent,Price:int,Power:string):void=
        if(PlayerObj := player[Agent]): #Converts The Agent to a type player
            if(CustomPlayer : Custom_Player_SuperPower = SuperPowerMap[PlayerObj]):
                Players := GetPlayspace().GetPlayers()
                CurrentGoldCount := General_Devices.Gold_Checker.GetItemCount(Agent, 0)

                    if (Power = "Speed" and CurrentGoldCount >= Price): 
                        CheckLogic:=CustomPlayer.CheckLogicActive("SuperSpeed")
                        if(CheckLogic = false):
                            CustomPlayer.ChangeLogicActive("SuperSpeed",true)
                            TakeCoins(Agent,Price,CurrentGoldCount)
                            spawn. AddSpeedBoostUI(Agent)
                            spawn. StartSpeedUITimer(Agent)
                            spawn. OnSpeedBought(Agent)
                            General_Devices.Purchased_XP_Giver.Award(Agent)
                            Speed_Boost_Devices.SuperSpeedMessage.Show(Agent)
                            Speed_Boost_Devices.SuperSpeedMessage.SetText(AgentToMessage1(Agent))
                            for (Player: Players):
                                Speed_Boost_Devices.SuperSpeedMessage.Show(Player)
                                General_Devices.Purchased_Audio_Player.Play(Player)

                    else if (Power = "Jump" and CurrentGoldCount >= Price):
                        CheckLogic := CustomPlayer.CheckLogicActive("SuperJump")
                        if(CheckLogic = false):
                            CustomPlayer.ChangeLogicActive("SuperJump",true)
                            TakeCoins(Agent,Price,CurrentGoldCount)
                            spawn. AddSuperJumpUI(Agent)
                            spawn. StartJumpUITimer(Agent)
                            CustomPlayer.ChangeLogicJump(true)
                            spawn. StartTimer(Agent)
                            General_Devices.Purchased_XP_Giver.Award(Agent)
                            Jump_Boost_Devices.SuperJumpMessage.SetText(AgentToMessage2(Agent))

                            for (Player: Players):
                                Jump_Boost_Devices.SuperJumpMessage.Show(Player)
                                General_Devices.Purchased_Audio_Player.Play(Player)

                    else if (Power = "Regen" and CurrentGoldCount >= Price):
                        CheckLogic := CustomPlayer.CheckLogicActive("Regeneration")
                        if(CheckLogic = false):
                            CustomPlayer.ChangeLogicActive("Regeneration",true)
                            TakeCoins(Agent,Price,CurrentGoldCount)
                            spawn. AddRegenerationUI(Agent)
                            spawn. StartRegenerationUITimer(Agent)
                            OnRegenerationBought(Agent)
                            General_Devices.Purchased_XP_Giver.Award(Agent)
                            Regeneration_Devices.RegenerationMessage.SetText(AgentToMessage3(Agent))

                            for (Player: Players):
                                Regeneration_Devices.RegenerationMessage.Show(Player)
                                General_Devices.Purchased_Audio_Player.Play(Player)  

                    else if (Power = "Jug" and CurrentGoldCount >= Price):
                        CheckLogic := CustomPlayer.CheckLogicActive("Juggernaut")
                        if(CheckLogic = false):
                            CustomPlayer.ChangeLogicActive("Juggernaut",true)
                            TakeCoins(Agent,Price,CurrentGoldCount)
                            OnJuggernautBought(Agent)
                            General_Devices.Purchased_XP_Giver.Award(Agent)
                            Shield_Boost_Devices.JuggernautMessage.SetText(AgentToMessage4(Agent))
                            for (Player: Players):
                                Shield_Boost_Devices.JuggernautMessage.Show(Player)
                                General_Devices.Purchased_Audio_Player.Play(Player)
                        
                    else if (Power = "Vamp" and CurrentGoldCount >= Price):
                        CheckLogic := CustomPlayer.CheckLogicActive("Vampirism")
                        if(CheckLogic = false):
                            CustomPlayer.ChangeLogicActive("Vampirism",true)
                            TakeCoins(Agent,Price,CurrentGoldCount)
                            spawn. AddVampirismUI(Agent)
                            spawn. StartVampirismUITimer(Agent)
                            CustomPlayer.ChangeLogicVamp(true)
                            spawn. StartVampTimer(Agent)
                            General_Devices.Purchased_XP_Giver.Award(Agent)
                            Vampirism_Devices.VampirismMessage.SetText(AgentToMessage5(Agent))
                            for (Player: Players):
                                Vampirism_Devices.VampirismMessage.Show(Player)
                                General_Devices.Purchased_Audio_Player.Play(Player)     

                    else if (Power = "DoubleDmg" and CurrentGoldCount >= Price):
                        CheckLogic := CustomPlayer.CheckLogicActive("DoubleDamage")
                        if(CheckLogic = false):
                            CustomPlayer.ChangeLogicActive("DoubleDamage",true)
                            TakeCoins(Agent,Price,CurrentGoldCount)
                            spawn. AddDoubleDamageUI(Agent)
                            spawn. StartDoubleDamageUITimer(Agent)
                            Double_Damage_Devices.DamageAmplifier.Pickup(Agent)    
                            General_Devices.Purchased_XP_Giver.Award(Agent)
                            Double_Damage_Devices.DoubleDamageMessage.SetText(AgentToMessage6(Agent))
                            for (Player: Players):
                                Double_Damage_Devices.DoubleDamageMessage.Show(Player)    
                                General_Devices.Purchased_Audio_Player.Play(Player)     

                    else if (Power = "Invis" and CurrentGoldCount >= Price):
                        CheckLogic := CustomPlayer.CheckLogicActive("Invisibility")
                        if(CheckLogic = false):
                            CustomPlayer.ChangeLogicActive("Invisibility",true)
                            TakeCoins(Agent,Price,CurrentGoldCount)
                            spawn. AddInvisibilityUI(Agent)
                            spawn. StartInvisibilityUITimer(Agent)
                            OnInvisibilityBought(Agent)
                            spawn. StartInvisTimer(Agent)
                            General_Devices.Purchased_XP_Giver.Award(Agent)
                            Invisibility_Devices.InvisMessage.SetText(AgentToMessage7(Agent))
                            for (Player: Players):
                                Invisibility_Devices.InvisMessage.Show(Player)
                                General_Devices.Purchased_Audio_Player.Play(Player)
                            
                    else if (Power = "InstaRe" and CurrentGoldCount >= Price):
                        CheckLogic := CustomPlayer.CheckLogicActive("InstantReload")
                        if(CheckLogic = false):
                            CustomPlayer.ChangeLogicActive("InstantReload",true)
                            TakeCoins(Agent,Price,CurrentGoldCount)
                            spawn. AddInstantReloadUI(Agent)
                            spawn. StartInstantReloadUITimer(Agent)
                            PlayerBoughtInstaReload(Agent)
                            spawn. StartInstaReloadTimer(Agent)
                            General_Devices.Purchased_XP_Giver.Award(Agent)
                            Instant_Reload_Devices.InstaReloadMessage.SetText(AgentToMessage8(Agent))
                            for (Player: Players):
                                Instant_Reload_Devices.InstaReloadMessage.Show(Player)
                                General_Devices.Purchased_Audio_Player.Play(Player)
                    
                    else if (Power = "FreezeGu" and CurrentGoldCount >= Price):
                        CheckLogic := CustomPlayer.CheckLogicActive("FreezeGun")
                        if(CheckLogic = false):
                            CustomPlayer.ChangeLogicActive("FreezeGun",true)
                            TakeCoins(Agent,Price,CurrentGoldCount)
                            spawn. AddFreezeGunUI(Agent)
                            spawn. StartFreezeGunUITimer(Agent)
                            OnFreezeGunBought(Agent)
                            spawn. StartFGTimer(Agent)
                            General_Devices.Purchased_XP_Giver.Award(Agent)
                            Freeze_Gun_Devices.DoublePumpMessage.SetText(AgentToMessage9(Agent))
                            for (Player: Players):
                                Freeze_Gun_Devices.DoublePumpMessage.Show(Player)
                                General_Devices.Purchased_Audio_Player.Play(Player)



                    else:
                        General_Devices.Not_Enough_MSG.Show(Agent)
                     
                        
#---------------------------------------------------------------------------------------------1 SUPER-SPEED-FUNCTIONS-----------------------------------------------------------------------------------------------------------------------------------------#
    OnSpeedBought(Agent : agent)<suspends>:void=
        if(PlayerObj := player[Agent]): #Converts The Agent to a type player
            if(CustomPlayer : Custom_Player_SuperPower = SuperPowerMap[PlayerObj]):
                Speed_Boost_Devices.SpeedModulator.Activate(Agent)
        

    AddSpeedBoostUI(Agent:agent)<suspends>:void=
        if(PlayerObj := player[Agent]): #Converts The Agent to a type player
            if(CustomPlayer : Custom_Player_SuperPower = SuperPowerMap[PlayerObj]):
                set CustomPlayer.TimerText1 = text_block{DefaultText := CustomPlayer.StringToMessage1("{CustomPlayer.Minutes1}:{CustomPlayer.Seconds1}"), DefaultTextColor:=NamedColors.White , DefaultShadowColor:=NamedColors.Yellow,  DefaultShadowOffset:=option{vector2{X:=0.247064,Y:=1.291105}}}
                SpeedUI:canvas = MakeSpeedBoostUI(CustomPlayer.TimerText1)
                if(Player := player[Agent],PlayerUI := GetPlayerUI[Player]):
                    PlayerUI.AddWidget(SpeedUI)
                    Sleep(Speed_Boost_Devices.SpeedBoostUIDuration)
                        PlayerUI.RemoveWidget(SpeedUI)
                        CustomPlayer.ChangeLogicActive("SuperSpeed",false)
    MakeSpeedBoostUI(TimerTextBlock:text_block) : canvas=
        TimerTextBlock.SetShadowOpacity(1.0)
        NewUI : canvas= canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.0}, Maximum := vector2{X := 0.0, Y := 0.0}}
                    Offsets := margin{Top := 58.770683, Left :=-12.0, Right := 182.590073, Bottom := 98.415703}
                    Alignment := vector2{X := 0.0, Y := 0.0}
                    SizeToContent := false
                    Widget := texture_block:
                        DefaultImage := Migrating_Vending_Assets.A_SuperSpeedUI
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.0}, Maximum := vector2{X := 0.0, Y := 0.0}}
                    Offsets := margin{Top := 88.0, Left := 53.0, Right := 70.997879, Bottom := 35.597095}
                    Alignment := vector2{X := 0.0, Y := 0.0}
                    SizeToContent := false
                    Widget := TimerTextBlock
    
    UpdateTimer(Agent:agent,PMins:int,PSecs:int):void=
        if(PlayerObj := player[Agent]): #Converts The Agent to a type player
            if(CustomPlayer : Custom_Player_SuperPower = SuperPowerMap[PlayerObj]):
                set CustomPlayer.Minutes1 = PMins
                set CustomPlayer.Seconds1 = PSecs
                if(CustomPlayer.Seconds1 < 10 and  CustomPlayer.Minutes1 < 10):
                    CustomPlayer.TimerText1.SetText(CustomPlayer.StringToMessage1("0{PMins}:0{PSecs}"))
                else if(CustomPlayer.Seconds1 < 10):
                    CustomPlayer.TimerText1.SetText(CustomPlayer.StringToMessage1("{PMins}:0{PSecs}"))
                else if(CustomPlayer.Minutes1 < 10):
                    CustomPlayer.TimerText1.SetText(CustomPlayer.StringToMessage1("0{PMins}:{PSecs}"))
                else:
                    CustomPlayer.TimerText1.SetText(CustomPlayer.StringToMessage1("{PMins}:{PSecs}"))

    StartSpeedUITimer(Agent:agent)<suspends>:void=
        if(PlayerObj := player[Agent]): #Converts The Agent to a type player
            if(CustomPlayer : Custom_Player_SuperPower = SuperPowerMap[PlayerObj]):
                loop:
                    UpdateTimer(Agent,CustomPlayer.Minutes1, CustomPlayer.Seconds1)
                    Sleep(1.0)
                    if(CustomPlayer.Minutes1 <= 0 and CustomPlayer.Seconds1 <= 1):
                        Print("Timer Ended")
                        CustomPlayer.ChangeLogicActive("SuperSpeed",false)
                        Print("Widget Removed/Powers")
                        Print("Resetting Time")
                        set CustomPlayer.Minutes1 = 2  #needs to be exact time you put for (SpeedBoostUIDuration) highlight inside the "()" and click "ctrl + f" to find where time is used..
                        set CustomPlayer.Seconds1 = 0 
                            break
                            
                    else if(CustomPlayer.Seconds1 <= 1):
                        set CustomPlayer.Minutes1 -= 1
                        set CustomPlayer.Seconds1 = 59
                    else:
                        set CustomPlayer.Seconds1 -= 1       
#---------------------------------------------------------------------------------------------2 SUPER-JUMP-FUNCTIONS-----------------------------------------------------------------------------------------------------------------------------------------#
    AddSuperJumpUI(Agent : agent)<suspends>:void=
        if(PlayerObj := player[Agent]): #Converts The Agent to a type player
            if(CustomPlayer : Custom_Player_SuperPower = SuperPowerMap[PlayerObj]):
                set CustomPlayer.TimerText2 = text_block{DefaultText := CustomPlayer.StringToMessage2("{CustomPlayer.Minutes2}:{CustomPlayer.Seconds2}"), DefaultTextColor:=NamedColors.White , DefaultShadowColor:=NamedColors.Purple,  DefaultShadowOffset:=option{vector2{X:=0.247064,Y:=1.291105}}}
                JumpUI:canvas = MakeJumpBoostUI(CustomPlayer.TimerText2)
                if(Player := player[Agent],PlayerUI := GetPlayerUI[Player]):
                    PlayerUI.AddWidget(JumpUI)
                    Sleep(Jump_Boost_Devices.JumpBoostDuration)
                        PlayerUI.RemoveWidget(JumpUI)

    MakeJumpBoostUI(TimerTextBlock:text_block):canvas=
        TimerTextBlock.SetShadowOpacity(1.0)
            NewUI : canvas= canvas:
                Slots := array:
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.0}, Maximum := vector2{X := 0.0, Y := 0.0}}
                        Offsets := margin{Top := 118.791122, Left :=-12.0, Right := 182.590073, Bottom := 98.415703}
                        Alignment := vector2{X := 0.0, Y := 0.0}
                        SizeToContent := false
                        Widget := texture_block:
                            DefaultImage := Migrating_Vending_Assets.B_SuperJumpUI
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.0}, Maximum := vector2{X := 0.0, Y := 0.0}}
                        Offsets := margin{Top := 147.184631, Left := 53.0, Right := 93.289963, Bottom := 35.597095}
                        Alignment := vector2{X := 0.0, Y := 0.0}
                        SizeToContent := false
                        Widget := TimerTextBlock

    UpdateJumpTimer(Agent:agent,PMins:int,PSecs:int):void=
        if(PlayerObj := player[Agent]): #Converts The Agent to a type player
            if(CustomPlayer : Custom_Player_SuperPower = SuperPowerMap[PlayerObj]):
                set CustomPlayer.Minutes2 = PMins
                set CustomPlayer.Seconds2 = PSecs
                if(CustomPlayer.Seconds2 < 10 and  CustomPlayer.Minutes2 < 10):
                    CustomPlayer.TimerText2.SetText(CustomPlayer.StringToMessage2("0{PMins}:0{PSecs}"))
                else if(CustomPlayer.Seconds2 < 10):
                    CustomPlayer.TimerText2.SetText(CustomPlayer.StringToMessage2("{PMins}:0{PSecs}"))
                else if(CustomPlayer.Minutes2 < 10):
                    CustomPlayer.TimerText2.SetText(CustomPlayer.StringToMessage2("0{PMins}:{PSecs}"))
                else:
                    CustomPlayer.TimerText2.SetText(CustomPlayer.StringToMessage2("{PMins}:{PSecs}"))

    StartJumpUITimer(Agent:agent)<suspends>:void=
        if(PlayerObj := player[Agent]): #Converts The Agent to a type player
            if(CustomPlayer : Custom_Player_SuperPower = SuperPowerMap[PlayerObj]):
                loop:
                    UpdateJumpTimer(Agent,CustomPlayer.Minutes2, CustomPlayer.Seconds2)
                    Sleep(1.0)
                    if(CustomPlayer.Minutes2 <= 0 and CustomPlayer.Seconds2 <= 1):
                        Print("Timer Ended")
                        Print("Widget Removed/Powers")
                        Print("Resetting Time")
                        set CustomPlayer.Minutes2 = 2  ###
                        set CustomPlayer.Seconds2 = 0  ###
                            break
                            
                    else if(CustomPlayer.Seconds2 <= 1):
                        set CustomPlayer.Minutes2 -= 1
                        set CustomPlayer.Seconds2 = 59
                    else:
                        set CustomPlayer.Seconds2 -= 1 

    DetectJump(Agent : agent):void=
        if (FC : fort_character = Agent.GetFortCharacter[]):
            FC.JumpedEvent().Subscribe(OnJumpBought)

    OnJumpBought(FC : fort_character):void=
       if (Agent := FC.GetAgent[]):
        if(PlayerObj := player[Agent]):
            if(CustomPlayer : Custom_Player_SuperPower = SuperPowerMap[PlayerObj]):
                ChangeLogic := CustomPlayer.ReturnOnJump()
                if(ChangeLogic = true):
                    Jump_Boost_Devices.JumpModulator.Activate(Agent)

                else:

    StartTimer(Agent : agent)<suspends>:void= 
        Sleep(Jump_Boost_Devices.JumpBoostDuration)
            if(CustomPlayer := ReturnCustomPlayer[Agent]):
                CustomPlayer.ChangeLogicJump(false)
                CustomPlayer.ChangeLogicActive("SuperJump",false)
#---------------------------------------------------------------------------------------------3 REGENERATION-FUNCTIONS#---------------------------------------------------------------------------------------------
    OnRegenerationBought(Agent : agent):void=
        Regeneration_Devices.RegenerationDevice.Pickup(Agent)

    AddRegenerationUI(Agent : agent)<suspends>:void=
        if(PlayerObj := player[Agent]): #Converts The Agent to a type player
            if(CustomPlayer : Custom_Player_SuperPower = SuperPowerMap[PlayerObj]):
                set CustomPlayer.TimerText3 = text_block{DefaultText := CustomPlayer.StringToMessage3("{CustomPlayer.Minutes3}:{CustomPlayer.Seconds3}"), DefaultTextColor:=NamedColors.White , DefaultShadowColor:=NamedColors.LightGreen,  DefaultShadowOffset:=option{vector2{X:=0.247064,Y:=1.291105}}}
                RegenUI:canvas = MakeRegenerationUI(CustomPlayer.TimerText3)
                if(Player := player[Agent],PlayerUI := GetPlayerUI[Player]):
                    PlayerUI.AddWidget(RegenUI)
                    Sleep(Regeneration_Devices.RegenerationUIDuration)
                        PlayerUI.RemoveWidget(RegenUI)

    MakeRegenerationUI(TimerTextBlock:text_block):canvas=
        TimerTextBlock.SetShadowOpacity(1.0)
            NewUI : canvas= canvas:
                Slots := array:
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.0}, Maximum := vector2{X := 0.0, Y := 0.0}}
                        Offsets := margin{Top := 178.800003, Left :=-12.0, Right := 182.590073, Bottom := 98.415703}
                        Alignment := vector2{X := 0.0, Y := 0.0}
                        SizeToContent := false
                        Widget := texture_block:
                            DefaultImage := Migrating_Vending_Assets.C_RegenerationUI
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.0}, Maximum := vector2{X := 0.0, Y := 0.0}}
                        Offsets := margin{Top := 208.0, Left := 53.0, Right := 93.289963, Bottom := 35.597095}
                        Alignment := vector2{X := 0.0, Y := 0.0}
                        SizeToContent := false
                        Widget := TimerTextBlock

    UpdateRegenerationTimer(Agent:agent,PMins:int,PSecs:int):void=
        if(PlayerObj := player[Agent]): #Converts The Agent to a type player
            if(CustomPlayer : Custom_Player_SuperPower = SuperPowerMap[PlayerObj]):
                set CustomPlayer.Minutes3 = PMins
                set CustomPlayer.Seconds3 = PSecs
                if(CustomPlayer.Seconds3 < 10 and  CustomPlayer.Minutes3 < 10):
                    CustomPlayer.TimerText3.SetText(CustomPlayer.StringToMessage3("0{PMins}:0{PSecs}"))
                else if(CustomPlayer.Seconds3 < 10):
                    CustomPlayer.TimerText3.SetText(CustomPlayer.StringToMessage3("{PMins}:0{PSecs}"))
                else if(CustomPlayer.Minutes3 < 10):
                    CustomPlayer.TimerText3.SetText(CustomPlayer.StringToMessage3("0{PMins}:{PSecs}"))
                else:
                    CustomPlayer.TimerText3.SetText(CustomPlayer.StringToMessage3("{PMins}:{PSecs}"))

    StartRegenerationUITimer(Agent:agent)<suspends>:void=
        if(PlayerObj := player[Agent]): #Converts The Agent to a type player
            if(CustomPlayer : Custom_Player_SuperPower = SuperPowerMap[PlayerObj]):
                loop:
                    UpdateRegenerationTimer(Agent,CustomPlayer.Minutes3, CustomPlayer.Seconds3)
                    Sleep(1.0)
                    if(CustomPlayer.Minutes3 <= 0 and CustomPlayer.Seconds3 <= 1):
                        Print("Timer Ended")
                        CustomPlayer.ChangeLogicActive("Regeneration",false)
                        Print("Widget Removed/Powers")
                        Print("Resetting Time")
                        set CustomPlayer.Minutes3 = 2 ###
                        set CustomPlayer.Seconds3 = 0 ###
                            break
                            
                    else if(CustomPlayer.Seconds3 <= 1):
                        set CustomPlayer.Minutes3 -= 1
                        set CustomPlayer.Seconds3 = 59
                    else:
                        set CustomPlayer.Seconds3 -= 1
#---------------------------------------------------------------------------------------------4 JUGGERNAUT-FUNCTIONS#---------------------------------------------------------------------------------------------
    OnJuggernautBought(Agent : agent):void=
        if (FC : fort_character = Agent.GetFortCharacter[]):
            FC.SetMaxShield(Shield_Boost_Devices.ShieldToGrant)
                FC.EliminatedEvent().Subscribe(OnEliminated)

    OnEliminated(Result:elimination_result):void=
        Eliminated := Result.EliminatedCharacter
        if (FC := Eliminated, EliminatedAgent := FC.GetAgent[]):
            ChangeActive(EliminatedAgent)

    ChangeActive(Agent : agent) :void=
        if(PlayerObj := player[Agent]): #Converts The Agent to a type player
            if(CustomPlayer : Custom_Player_SuperPower = SuperPowerMap[PlayerObj]):
                CustomPlayer.ChangeLogicActive("Juggernaut",false)
            
#---------------------------------------------------------------------------------------------5 VAMPIRISM-FUNCTIONS#---------------------------------------------------------------------------------------------
    AddVampirismUI(Agent : agent)<suspends>:void=
        if(PlayerObj := player[Agent]): #Converts The Agent to a type player
            if(CustomPlayer : Custom_Player_SuperPower = SuperPowerMap[PlayerObj]):
                set CustomPlayer.TimerText5 = text_block{DefaultText := CustomPlayer.StringToMessage5("{CustomPlayer.Minutes5}:{CustomPlayer.Seconds5}"), DefaultTextColor:=NamedColors.White , DefaultShadowColor:=NamedColors.Red,  DefaultShadowOffset:=option{vector2{X:=0.247064,Y:=1.291105}}}
                VampUI:canvas = MakeVampirismUI(CustomPlayer.TimerText5)
                if(Player := player[Agent],PlayerUI := GetPlayerUI[Player]):
                    PlayerUI.AddWidget(VampUI)
                    Sleep(Vampirism_Devices.VampirismDuration)
                        PlayerUI.RemoveWidget(VampUI)

    MakeVampirismUI(TimerTextBlock:text_block):canvas=
        TimerTextBlock.SetShadowOpacity(1.0)
            NewUI : canvas= canvas:
                Slots := array:
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.0}, Maximum := vector2{X := 0.0, Y := 0.0}}
                        Offsets := margin{Top := 298.799988, Left :=-12.0, Right := 182.590073, Bottom := 98.415703}
                        Alignment := vector2{X := 0.0, Y := 0.0}
                        SizeToContent := false
                        Widget := texture_block:
                            DefaultImage := Migrating_Vending_Assets.E_VampirismUI
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.0}, Maximum := vector2{X := 0.0, Y := 0.0}}
                        Offsets := margin{Top := 328.0, Left := 53.0, Right := 93.289963, Bottom := 35.597095}
                        Alignment := vector2{X := 0.0, Y := 0.0}
                        SizeToContent := false
                        Widget := TimerTextBlock

    UpdateVampTimer(Agent:agent,PMins:int,PSecs:int):void=
        if(PlayerObj := player[Agent]): #Converts The Agent to a type player
            if(CustomPlayer : Custom_Player_SuperPower = SuperPowerMap[PlayerObj]):
                set CustomPlayer.Minutes5 = PMins
                set CustomPlayer.Seconds5 = PSecs
                if(CustomPlayer.Seconds5 < 10 and  CustomPlayer.Minutes5 < 10):
                    CustomPlayer.TimerText5.SetText(CustomPlayer.StringToMessage5("0{PMins}:0{PSecs}"))
                else if(CustomPlayer.Seconds5 < 10):
                    CustomPlayer.TimerText5.SetText(CustomPlayer.StringToMessage5("{PMins}:0{PSecs}"))
                else if(CustomPlayer.Minutes5 < 10):
                    CustomPlayer.TimerText5.SetText(CustomPlayer.StringToMessage5("0{PMins}:{PSecs}"))
                else:
                    CustomPlayer.TimerText5.SetText(CustomPlayer.StringToMessage5("{PMins}:{PSecs}"))

    StartVampirismUITimer(Agent:agent)<suspends>:void=
        if(PlayerObj := player[Agent]): #Converts The Agent to a type player
            if(CustomPlayer : Custom_Player_SuperPower = SuperPowerMap[PlayerObj]):
                loop:
                    UpdateVampTimer(Agent,CustomPlayer.Minutes5, CustomPlayer.Seconds5)
                    Sleep(1.0)
                    if(CustomPlayer.Minutes5 <= 0 and CustomPlayer.Seconds5 <= 1):
                        Print("Timer Ended")
                        CustomPlayer.ChangeLogicActive("Vampirism",false)
                        Print("Widget Removed/Powers")
                        Print("Resetting Time")
                        set CustomPlayer.Minutes5 = 2 ###
                        set CustomPlayer.Seconds5 = 0 ###
                            break
                            
                    else if(CustomPlayer.Seconds5 <= 1):
                        set CustomPlayer.Minutes5 -= 1
                        set CustomPlayer.Seconds5 = 59
                    else:
                        set CustomPlayer.Seconds5 -= 1

    OnVampirismBought(FC : fort_character):void=
        if (Agent := FC.GetAgent[]):
            if(CustomPlayer :=  ReturnCustomPlayer[Agent]):
                    ChangeLogic := CustomPlayer.ReturnOnVamp()
                    if(ChangeLogic = true):
                        DetectVamp(Agent)

    DetectVamp(Agent : agent):void=
        if (FC:fort_character = Agent.GetFortCharacter[]):
            FC.DamagedEvent().Subscribe(OnPlayerDamaged)
            FC.DamagedShieldEvent().Subscribe(OnShieldDamaged)

    OnPlayerDamaged(DR : damage_result):void=
        if(Instigator:game_action_instigator = DR.Instigator?):
            if(InstigatingAgent:agent = Instigator.GetInstigatorAgent[]):
                if(CustomPlayer := ReturnCustomPlayer[InstigatingAgent]):
                    ChangeLogic := CustomPlayer.ReturnOnVamp()
                    if(ChangeLogic = true):
                        if (FC:fort_character = fort_character[DR.Target]):
                            CurrentHealth:float = FC.GetHealth()

                        DamagedAmount:float = DR.Amount/3.0
                
                        if (FC:fort_character = InstigatingAgent.GetFortCharacter[]):
                            CurrentHealth:float = FC.GetHealth()
                            DoSiphon(FC, DamagedAmount)
    
    OnShieldDamaged(DR : damage_result):void=
        if(Instigator:game_action_instigator = DR.Instigator?):
            if(InstigatingAgent:agent = Instigator.GetInstigatorAgent[]):
                if(CustomPlayer := ReturnCustomPlayer[InstigatingAgent]):
                    ChangeLogic := CustomPlayer.ReturnOnVamp()
                    if(ChangeLogic = true):
                        if (FC:fort_character = fort_character[DR.Target]):
                            CurrentShield:float = FC.GetShield()

                        DamagedAmount:float = DR.Amount/3.0

                        if (FC:fort_character = InstigatingAgent.GetFortCharacter[]):
                            CurrentShield:float = FC.GetShield()
                            DoSiphon(FC, DamagedAmount)

    DoSiphon(Player:fort_character, Amount:float):void=
        CurrentShield:float = Player.GetShield()
        CurrentHealth:float = Player.GetHealth()

        if(CurrentHealth < 100.0):
            spawn:
                HealPlayer(Player, Amount)
        else:
            if(CurrentShield < 100.0):
                spawn:
                    FixShield(Player, Amount)
    
    HealPlayer(Player:fort_character, Amount:float)<suspends>:void=
        var HealedAmount:float = 0.0
        loop:
            CurrentHealth:float = Player.GetHealth()
            if(CurrentHealth = 100.0):
                break
            else:
                set HealedAmount += 1.0
                NewHealth:float = CurrentHealth + 1.0
                Player.SetHealth(NewHealth)

                if(HealedAmount >= Amount):
                    break

                Sleep(Heal_Delay)

    FixShield(Player:fort_character, Amount:float)<suspends>:void=
        var FixedAmount:float = 0.0
        loop:
            CurrentShield:float = Player.GetShield()
            if(CurrentShield = 100.0):
                break
            else:
                set FixedAmount += 1.0
                NewShield:float = CurrentShield + 1.0
                Player.SetShield(NewShield)

                if(FixedAmount >= Amount):
                    break

                Sleep(Heal_Delay)

    StartVampTimer(Agent : agent)<suspends>:void= 
        Sleep(Vampirism_Devices.VampirismDuration)
            if(CustomPlayer := ReturnCustomPlayer[Agent]):
                CustomPlayer.ChangeLogicVamp(false)    
#--------------------------------------------------------------------------------------------6 DOUBLE-DAMAGE-FUNCTIONS#---------------------------------------------------------------------------------------------
    AddDoubleDamageUI(Agent : agent)<suspends>:void=
        if(PlayerObj := player[Agent]): #Converts The Agent to a type player
            if(CustomPlayer : Custom_Player_SuperPower = SuperPowerMap[PlayerObj]):
                set CustomPlayer.TimerText6 = text_block{DefaultText := CustomPlayer.StringToMessage6("{CustomPlayer.Minutes6}:{CustomPlayer.Seconds6}"), DefaultTextColor:=NamedColors.White , DefaultShadowColor:=NamedColors.Orange,  DefaultShadowOffset:=option{vector2{X:=0.247064,Y:=1.291105}}}
                DoubleDamageUI:canvas = MakeDoubleDamageUI(CustomPlayer.TimerText6)
                if(Player := player[Agent],PlayerUI := GetPlayerUI[Player]):
                    PlayerUI.AddWidget(DoubleDamageUI)
                    Sleep(Double_Damage_Devices.DoubleDamageUIDuration)
                        PlayerUI.RemoveWidget(DoubleDamageUI)

    MakeDoubleDamageUI(TimerTextBlock:text_block):canvas=
        TimerTextBlock.SetShadowOpacity(1.0)
            NewUI : canvas= canvas:
                Slots := array:
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.0}, Maximum := vector2{X := 0.0, Y := 0.0}}
                        Offsets := margin{Top := 358.799988, Left :=-12.0, Right := 182.590073, Bottom := 98.415703}
                        Alignment := vector2{X := 0.0, Y := 0.0}
                        SizeToContent := false
                        Widget := texture_block:
                            DefaultImage := Migrating_Vending_Assets.F_DoubleDamageUI
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.0}, Maximum := vector2{X := 0.0, Y := 0.0}}
                        Offsets := margin{Top := 388.0, Left := 53.0, Right := 93.289963, Bottom := 35.597095}
                        Alignment := vector2{X := 0.0, Y := 0.0}
                        SizeToContent := false
                        Widget := TimerTextBlock

    UpdateDoubleDamageTimer(Agent:agent,PMins:int,PSecs:int):void=
        if(PlayerObj := player[Agent]): #Converts The Agent to a type player
            if(CustomPlayer : Custom_Player_SuperPower = SuperPowerMap[PlayerObj]):
                set CustomPlayer.Minutes6 = PMins
                set CustomPlayer.Seconds6 = PSecs
                if(CustomPlayer.Seconds6 < 10 and  CustomPlayer.Minutes6 < 10):
                    CustomPlayer.TimerText6.SetText(CustomPlayer.StringToMessage6("0{PMins}:0{PSecs}"))
                else if(CustomPlayer.Seconds6 < 10):
                    CustomPlayer.TimerText6.SetText(CustomPlayer.StringToMessage6("{PMins}:0{PSecs}"))
                else if(CustomPlayer.Minutes6 < 10):
                    CustomPlayer.TimerText6.SetText(CustomPlayer.StringToMessage6("0{PMins}:{PSecs}"))
                else:
                    CustomPlayer.TimerText6.SetText(CustomPlayer.StringToMessage6("{PMins}:{PSecs}"))

    StartDoubleDamageUITimer(Agent:agent)<suspends>:void=
        if(PlayerObj := player[Agent]): #Converts The Agent to a type player
            if(CustomPlayer : Custom_Player_SuperPower = SuperPowerMap[PlayerObj]):
                loop:
                    UpdateDoubleDamageTimer(Agent,CustomPlayer.Minutes6, CustomPlayer.Seconds6)
                    Sleep(1.0)
                    if(CustomPlayer.Minutes6 <= 0 and CustomPlayer.Seconds6 <= 1):
                        Print("Timer Ended")
                        CustomPlayer.ChangeLogicActive("DoubleDamage",false)
                        Print("Widget Removed/Powers")
                        Print("Resetting Time")
                        set CustomPlayer.Minutes6 = 2 ###
                        set CustomPlayer.Seconds6 = 0 ###
                            break
                            
                    else if(CustomPlayer.Seconds6 <= 1):
                        set CustomPlayer.Minutes6 -= 1
                        set CustomPlayer.Seconds6 = 59
                    else:
                        set CustomPlayer.Seconds6 -= 1

    OnDoubleDamageBought(Agent : agent):void=
        Double_Damage_Devices.DamageAmplifier.Pickup(Agent)

#---------------------------------------------------------------------------------------------7 INVISIBILITY-FUNCTIONS#---------------------------------------------------------------------------------------------
    AddInvisibilityUI(Agent : agent)<suspends>:void=
        if(PlayerObj := player[Agent]): #Converts The Agent to a type player
            if(CustomPlayer : Custom_Player_SuperPower = SuperPowerMap[PlayerObj]):
                set CustomPlayer.TimerText7 = text_block{DefaultText := CustomPlayer.StringToMessage7("{CustomPlayer.Minutes7}:{CustomPlayer.Seconds7}"), DefaultTextColor:=NamedColors.White , DefaultShadowColor:=NamedColors.Grey,  DefaultShadowOffset:=option{vector2{X:=0.247064,Y:=1.291105}}}
                InvisibilityUI:canvas = MakeInvisibilityUI(CustomPlayer.TimerText7)
                if(Player := player[Agent],PlayerUI := GetPlayerUI[Player]):
                    PlayerUI.AddWidget(InvisibilityUI)
                    Sleep(Invisibility_Devices.InvisibilityDuration)
                        PlayerUI.RemoveWidget(InvisibilityUI)

    MakeInvisibilityUI(TimerTextBlock:text_block):canvas=
        TimerTextBlock.SetShadowOpacity(1.0)
            NewUI : canvas= canvas:
                Slots := array:
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.0}, Maximum := vector2{X := 0.0, Y := 0.0}}
                        Offsets := margin{Top := 418.799988, Left :=-12.0, Right := 182.590073, Bottom := 98.415703}
                        Alignment := vector2{X := 0.0, Y := 0.0}
                        SizeToContent := false
                        Widget := texture_block:
                            DefaultImage := Migrating_Vending_Assets.G_InvisibilityUI
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.0}, Maximum := vector2{X := 0.0, Y := 0.0}}
                        Offsets := margin{Top := 448.0, Left := 53.0, Right := 93.289963, Bottom := 35.597095}
                        Alignment := vector2{X := 0.0, Y := 0.0}
                        SizeToContent := false
                        Widget := TimerTextBlock

    UpdateInvisibilityTimer(Agent:agent,PMins:int,PSecs:int):void=
        if(PlayerObj := player[Agent]): #Converts The Agent to a type player
            if(CustomPlayer : Custom_Player_SuperPower = SuperPowerMap[PlayerObj]):
                set CustomPlayer.Minutes7 = PMins
                set CustomPlayer.Seconds7 = PSecs
                if(CustomPlayer.Seconds7 < 10 and  CustomPlayer.Minutes7 < 10):
                    CustomPlayer.TimerText7.SetText(CustomPlayer.StringToMessage7("0{PMins}:0{PSecs}"))
                else if(CustomPlayer.Seconds7 < 10):
                    CustomPlayer.TimerText7.SetText(CustomPlayer.StringToMessage7("{PMins}:0{PSecs}"))
                else if(CustomPlayer.Minutes7 < 10):
                    CustomPlayer.TimerText7.SetText(CustomPlayer.StringToMessage7("0{PMins}:{PSecs}"))
                else:
                    CustomPlayer.TimerText7.SetText(CustomPlayer.StringToMessage7("{PMins}:{PSecs}"))

    StartInvisibilityUITimer(Agent:agent)<suspends>:void=
        if(PlayerObj := player[Agent]): #Converts The Agent to a type player
            if(CustomPlayer : Custom_Player_SuperPower = SuperPowerMap[PlayerObj]):
                loop:
                    UpdateInvisibilityTimer(Agent,CustomPlayer.Minutes7, CustomPlayer.Seconds7)
                    Sleep(1.0)
                    if(CustomPlayer.Minutes7 <= 0 and CustomPlayer.Seconds7 <= 1):
                        Print("Timer Ended")
                        CustomPlayer.ChangeLogicActive("Invisibility",false)
                        Print("Widget Removed/Powers")
                        Print("Resetting Time")
                        set CustomPlayer.Minutes7 = 2 ###
                        set CustomPlayer.Seconds7 = 0 ###
                            break
                            
                    else if(CustomPlayer.Seconds7 <= 1):
                        set CustomPlayer.Minutes7 -= 1
                        set CustomPlayer.Seconds7 = 59
                    else:
                        set CustomPlayer.Seconds7 -= 1
    OnInvisibilityBought(Agent : agent):void=
        Invisibility_Devices.InvisCardGranter.GrantItem(Agent)
        spawn:
            CheckForCard()
            
    CheckForCard()<suspends>:void=
        loop:
            Sleep(1.0)
            AllPlayers := GetPlayspace().GetPlayers()
            for(Player:AllPlayers):
                if(IsAgent:agent=agent[Player]):
                    if(Invisibility_Devices.CardDetector.IsHoldingItem[IsAgent]):
                        HidePlayer(IsAgent)
                    else:
                        ShowPlayer(IsAgent)

    StartInvisTimer(Agent:agent)<suspends>:void=
        Sleep(Invisibility_Devices.InvisibilityDuration)
            Invisibility_Devices.CardRemover.Remove(Agent)

    ShowPlayer(Agent:agent):void=
        if(FC:=Agent.GetFortCharacter[]):
            FC.Show()

    HidePlayer(Agent:agent):void=
        if(FC:=Agent.GetFortCharacter[]):
            FC.Hide()
#---------------------------------------------------------------------------------------------8 INSTANT-RELOAD-FUNCTIONS#---------------------------------------------------------------------------------------------
    AddInstantReloadUI(Agent : agent)<suspends>:void=
        if(PlayerObj := player[Agent]): #Converts The Agent to a type player
            if(CustomPlayer : Custom_Player_SuperPower = SuperPowerMap[PlayerObj]):
                set CustomPlayer.TimerText8 = text_block{DefaultText := CustomPlayer.StringToMessage8("{CustomPlayer.Minutes8}:{CustomPlayer.Seconds8}"), DefaultTextColor:=NamedColors.White , DefaultShadowColor:=NamedColors.DarkGreen,  DefaultShadowOffset:=option{vector2{X:=0.247064,Y:=1.291105}}}
                InstantReloadUI:canvas = MakeInstantReloadUI(CustomPlayer.TimerText8)
                if(Player := player[Agent],PlayerUI := GetPlayerUI[Player]):
                    PlayerUI.AddWidget(InstantReloadUI)
                    Sleep(Instant_Reload_Devices.InstantReloadDuration)
                        PlayerUI.RemoveWidget(InstantReloadUI)

    MakeInstantReloadUI(TimerTextBlock:text_block):canvas=
        TimerTextBlock.SetShadowOpacity(1.0)
            NewUI : canvas= canvas:
                Slots := array:
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.0}, Maximum := vector2{X := 0.0, Y := 0.0}}
                        Offsets := margin{Top := 478.799988, Left :=-12.0, Right := 182.590073, Bottom := 98.415703}
                        Alignment := vector2{X := 0.0, Y := 0.0}
                        SizeToContent := false
                        Widget := texture_block:
                            DefaultImage := Migrating_Vending_Assets.H_InstantReloadUI
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.0}, Maximum := vector2{X := 0.0, Y := 0.0}}
                        Offsets := margin{Top := 508.0, Left := 53.0, Right := 93.289963, Bottom := 35.597095}
                        Alignment := vector2{X := 0.0, Y := 0.0}
                        SizeToContent := false
                        Widget := TimerTextBlock

    UpdateInstantReloadTimer(Agent:agent,PMins:int,PSecs:int):void=
        if(PlayerObj := player[Agent]): #Converts The Agent to a type player
            if(CustomPlayer : Custom_Player_SuperPower = SuperPowerMap[PlayerObj]):
                set CustomPlayer.Minutes8 = PMins
                set CustomPlayer.Seconds8 = PSecs
                if(CustomPlayer.Seconds8 < 10 and  CustomPlayer.Minutes8 < 10):
                    CustomPlayer.TimerText8.SetText(CustomPlayer.StringToMessage8("0{PMins}:0{PSecs}"))
                else if(CustomPlayer.Seconds8 < 10):
                    CustomPlayer.TimerText8.SetText(CustomPlayer.StringToMessage8("{PMins}:0{PSecs}"))
                else if(CustomPlayer.Minutes8 < 10):
                    CustomPlayer.TimerText8.SetText(CustomPlayer.StringToMessage8("0{PMins}:{PSecs}"))
                else:
                    CustomPlayer.TimerText8.SetText(CustomPlayer.StringToMessage8("{PMins}:{PSecs}"))

    StartInstantReloadUITimer(Agent:agent)<suspends>:void=
        if(PlayerObj := player[Agent]): #Converts The Agent to a type player
            if(CustomPlayer : Custom_Player_SuperPower = SuperPowerMap[PlayerObj]):
                loop:
                    UpdateInstantReloadTimer(Agent,CustomPlayer.Minutes8, CustomPlayer.Seconds8)
                    Sleep(1.0)
                    if(CustomPlayer.Minutes8 <= 0 and CustomPlayer.Seconds8 <= 1):
                        Print("Timer Ended")
                        CustomPlayer.ChangeLogicActive("InstantReload",false)
                        Print("Widget Removed/Powers")
                        Print("Resetting Time")
                        set CustomPlayer.Minutes8 = 2 ###
                        set CustomPlayer.Seconds8 = 0 ###
                            break
                            
                    else if(CustomPlayer.Seconds8 <= 1):
                        set CustomPlayer.Minutes8 -= 1
                        set CustomPlayer.Seconds8 = 59
                    else:
                        set CustomPlayer.Seconds8 -= 1

    PlayerBoughtInstaReload(Agent : agent):void=
        Instant_Reload_Devices.InstantRealoadClassSelector.ChangeClass(Agent)
                    
    
    StartInstaReloadTimer(Agent:agent)<suspends>:void=
        Sleep(Instant_Reload_Devices.InstantReloadDuration)
            Instant_Reload_Devices.InstantRealoadEndClassSelector.ChangeClass(Agent)
#---------------------------------------------------------------------------------------------9 FREEZE-GUN-FUNCTIONS#---------------------------------------------------------------------------------------------
    AddFreezeGunUI(Agent : agent)<suspends>:void=
        if(PlayerObj := player[Agent]): #Converts The Agent to a type player
            if(CustomPlayer : Custom_Player_SuperPower = SuperPowerMap[PlayerObj]):
                set CustomPlayer.TimerText9 = text_block{DefaultText := CustomPlayer.StringToMessage9("{CustomPlayer.Minutes9}:{CustomPlayer.Seconds9}"), DefaultTextColor:=NamedColors.White , DefaultShadowColor:=NamedColors.Blue,  DefaultShadowOffset:=option{vector2{X:=0.247064,Y:=1.291105}}}
                FreezeGunUI:canvas = MakeFreezeGunUI(CustomPlayer.TimerText9)
                if(Player := player[Agent],PlayerUI := GetPlayerUI[Player]):
                    PlayerUI.AddWidget(FreezeGunUI)
                    Sleep(Freeze_Gun_Devices.Freeze_Gun_Duration)
                        PlayerUI.RemoveWidget(FreezeGunUI)

    MakeFreezeGunUI(TimerTextBlock:text_block):canvas=
        TimerTextBlock.SetShadowOpacity(1.0)
            NewUI : canvas= canvas:
                Slots := array:
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.0}, Maximum := vector2{X := 0.0, Y := 0.0}}
                        Offsets := margin{Top := 538.799988, Left :=-12.0, Right := 182.590073, Bottom := 98.415703}
                        Alignment := vector2{X := 0.0, Y := 0.0}
                        SizeToContent := false
                        Widget := texture_block:
                            DefaultImage := Migrating_Vending_Assets.I_FreezeGunUI
                    canvas_slot:
                        Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.0}, Maximum := vector2{X := 0.0, Y := 0.0}}
                        Offsets := margin{Top := 568.0, Left := 53.0, Right := 93.289963, Bottom := 35.597095}
                        Alignment := vector2{X := 0.0, Y := 0.0}
                        SizeToContent := false
                        Widget := TimerTextBlock

    UpdateFreezeGunTimer(Agent:agent,PMins:int,PSecs:int):void=
        if(PlayerObj := player[Agent]): #Converts The Agent to a type player
            if(CustomPlayer : Custom_Player_SuperPower = SuperPowerMap[PlayerObj]):
                set CustomPlayer.Minutes9 = PMins
                set CustomPlayer.Seconds9 = PSecs
                if(CustomPlayer.Seconds9 < 10 and  CustomPlayer.Minutes9 < 10):
                    CustomPlayer.TimerText9.SetText(CustomPlayer.StringToMessage9("0{PMins}:0{PSecs}"))
                else if(CustomPlayer.Seconds9 < 10):
                    CustomPlayer.TimerText9.SetText(CustomPlayer.StringToMessage9("{PMins}:0{PSecs}"))
                else if(CustomPlayer.Minutes9 < 10):
                    CustomPlayer.TimerText9.SetText(CustomPlayer.StringToMessage9("0{PMins}:{PSecs}"))
                else:
                    CustomPlayer.TimerText9.SetText(CustomPlayer.StringToMessage9("{PMins}:{PSecs}"))

    StartFreezeGunUITimer(Agent:agent)<suspends>:void=
        if(PlayerObj := player[Agent]): #Converts The Agent to a type player
            if(CustomPlayer : Custom_Player_SuperPower = SuperPowerMap[PlayerObj]):
                loop:
                    UpdateFreezeGunTimer(Agent,CustomPlayer.Minutes9, CustomPlayer.Seconds9)
                    Sleep(1.0)
                    if(CustomPlayer.Minutes9 <= 0 and CustomPlayer.Seconds9 <= 1):
                        Print("Timer Ended")
                        CustomPlayer.ChangeLogicActive("FreezeGun",false)
                        Print("Widget Removed/Powers")
                        Print("Resetting Time")
                        set CustomPlayer.Minutes9 = 2 ###
                        set CustomPlayer.Seconds9 = 0 ###
                            break
                            
                    else if(CustomPlayer.Seconds9 <= 1):
                        set CustomPlayer.Minutes9 -= 1
                        set CustomPlayer.Seconds9 = 59
                    else:
                        set CustomPlayer.Seconds9 -= 1

    OnFreezeGunBought(Agent : agent):void= 
        Freeze_Gun_Devices.FreezeGunGranter.GrantItem(Agent)
        for (Player : GetPlayspace().GetPlayers(), FortCharacter := Player.GetFortCharacter[]):
            FortCharacter.DamagedEvent().Subscribe(OnDamaged)
            FortCharacter.DamagedShieldEvent().Subscribe(OnDamaged)
    
    OnDamaged(DR:damage_result):void=
        if:
            Instigator := DR.Instigator?
            Agent := Instigator.GetInstigatorAgent[]
            Freeze_Gun_Devices.FreezeGunTracker.IsHoldingItem[Agent]
            Target := fort_character[DR.Target]
        then:
            spawn:
                FreezePlayer(Target)            

    FreezePlayer(Target : fort_character)<suspends>:void=
        Target.PutInStasis(stasis_args{})
        Sleep(Freeze_Gun_Devices.Freeze_Player_Duration)
        Target.ReleaseFromStasis()

    StartFGTimer(Agent : agent)<suspends>:void= 
        Sleep(Freeze_Gun_Devices.Freeze_Gun_Duration)
            Freeze_Gun_Devices.FreezeGunRemover.Remove(Agent)
#-----------------------------------------------------------------------------------------------------------#---------------------------------------------------------------------------------------------
    InitializePlayer(Agent:agent):void=
        if(PlayerObj := player[Agent]): #Converts The Agent to a type player
            if(PlayerExists := SuperPowerMap[PlayerObj]): #if the player exists in the map we should not make a copy because it will make a duplicate 
                #do nothing
            else:
               CustomPlayer: Custom_Player_SuperPower = Custom_Player_SuperPower{Player := Agent}  # Create a Copy  Set the Player
               option{ set SuperPowerMap[PlayerObj] = CustomPlayer }

    ReturnCustomPlayer(Agent:agent)<transacts><decides>:Custom_Player_SuperPower=    
        var MaybeCustomPlayer: ?Custom_Player_SuperPower=false         
            if(PlayerObj := player[Agent]):
                if(CustomPlayer : Custom_Player_SuperPower = SuperPowerMap[PlayerObj]):
                    set MaybeCustomPlayer = option{CustomPlayer}
        return MaybeCustomPlayer?
#-----------------------------------------------------------------------------------------------------------#---------------------------------------------------------------------------------------------
Custom_Player_SuperPower:=class<unique>:
    Player:agent

    var PlayerBoughtJump : logic = false

    var PlayerBoughtVampire : logic = false

    var PlayerBoughtFreezeGun : logic = false
    
    var CustomPlayerPower : [string]logic = map {"SuperSpeed" => false,"SuperJump" => false,"Regeneration" => false,"Juggernaut" => false,"Vampirism" => false,"DoubleDamage" => false,"Invisibility" => false,"InstantReload" => false,"FreezeGun" => false}

#SUPER-SPEED
    var SpeedUI : canvas = canvas{}
    var Minutes1:int= 2             #YOU CAN CHANGE THE INT TO WHATEVER TIME YOU WANT JUST MAKE SURE IT IS THE SAME TIME AS WHAT YOU PUT IN FOR THE DURATION IN GAME MANAGER do for each one "if" you are making different times
    var Seconds1:int=0
    var TimerText1:text_block = text_block{}
    StringToMessage1<localizes>(value:string)<computes> : message = "{value}"
#SUPER-JUMP
    var JumpUI : canvas = canvas{}
    var Minutes2:int=2
    var Seconds2:int=0
    var TimerText2:text_block = text_block{}
    StringToMessage2<localizes>(value:string)<computes> : message = "{value}"
#REGENERATION
    var RegenUI : canvas = canvas{}
    var Minutes3:int=2
    var Seconds3:int=0
    var TimerText3:text_block = text_block{}
    StringToMessage3<localizes>(value:string)<computes> : message = "{value}"
#JUGGERNAUT
    var JugUI : canvas = canvas{}
    var Minutes4:int=2
    var Seconds4:int=0
    var TimerText4:text_block = text_block{}
    StringToMessage4<localizes>(value:string)<computes> : message = "{value}"
#VAMPIRISM    
    var VampUI : canvas = canvas{}
    var Minutes5:int=2
    var Seconds5:int=0
    var TimerText5:text_block = text_block{}
    StringToMessage5<localizes>(value:string)<computes> : message = "{value}"
#DOUBLE-DAMAGE
    var DoubleDamageUI : canvas = canvas{}
    var Minutes6:int=2
    var Seconds6:int=0
    var TimerText6:text_block = text_block{}
    StringToMessage6<localizes>(value:string)<computes> : message = "{value}"
#INVISIBILITY
    var InvisUI : canvas = canvas{}
    var Minutes7:int=2
    var Seconds7:int=0
    var TimerText7:text_block = text_block{}
    StringToMessage7<localizes>(value:string)<computes> : message = "{value}"
#INSTANT-RELOAD
    var InstaReUI : canvas = canvas{}
    var Minutes8:int=2
    var Seconds8:int=0
    var TimerText8:text_block = text_block{}
    StringToMessage8<localizes>(value:string)<computes> : message = "{value}"
#FREEZE-GUN
    var FreezeGunUI : canvas = canvas{}
    var Minutes9:int=2
    var Seconds9:int=0
    var TimerText9:text_block = text_block{}
    StringToMessage9<localizes>(value:string)<computes> : message = "{value}"
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    CheckLogicActive(String:string):logic=
     var Logic2: logic = false
        if(Logic:=CustomPlayerPower[String]):
            set Logic2 = Logic
        return Logic2

    ChangeLogicActive(String:string,ChangeLogic:logic):void=
        if(set CustomPlayerPower[String] = ChangeLogic):
        
    ReturnOnVamp():logic=
        return PlayerBoughtVampire

    ChangeLogicVamp(Logic:logic):void=
        set PlayerBoughtVampire = Logic

    ReturnOnJump():logic=
        return PlayerBoughtJump

    ChangeLogicJump(Logic:logic):void= 
        set PlayerBoughtJump = Logic