# Super Power Wheel System
# A currency-based power wheel gambling/spin system that allows players to spend in-game currency to spin wheels and potentially unlock superpowers or movement modifiers. The system includes audio feedb
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/horizontalwheel1?ref=github




using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Game }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /Verse.org/Colors }
using { /Verse.org/Colors/NamedColors }

widget_position := enum:
    AboveHealthBar
    UnderMap

Overall1:=struct<concrete>{
    @editable Price1 : int = 0
    @editable WidgetPosition : widget_position = widget_position.AboveHealthBar
    @editable MapMovementModulators : []movement_modulator_device = array{}
    @editable Grant_Audio : audio_player_device = audio_player_device{}
    @editable Gold_Checker : conditional_button_device = conditional_button_device{}
    @editable Not_Enough_Currency_Message : hud_message_device = hud_message_device{}
    @editable XP_Granter : accolades_device = accolades_device{}
    @editable DefaultClassSelector :  class_and_team_selector_device =  class_and_team_selector_device{}
    @editable Player_Spawners : []player_spawner_device = array{}
    @editable RemoveAura : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable RemovePowers : []button_device = array{}
}
Super_Power_Wheel1:=struct<concrete>{
    @editable Spinner1 : creative_prop = creative_prop{}
    @editable WheelButton1 : button_device = button_device{}
    @editable WheelButton_Cinematic1 : cinematic_sequence_device = cinematic_sequence_device{}
    @editable Spin_Audio1 : audio_player_device = audio_player_device{}
}

Super_Power_Wheel2:=struct<concrete>{
    @editable Spinner2 : creative_prop = creative_prop{}
    @editable WheelButton2 : button_device = button_device{}
    @editable WheelButton_Cinematic2 : cinematic_sequence_device = cinematic_sequence_device{}
    @editable Spin_Audio2 : audio_player_device = audio_player_device{}
}
Double_Damage1:=struct<concrete>{
    @editable DamageAmplifier: damage_amplifier_powerup_device = damage_amplifier_powerup_device{}
    @editable DoubleDamagePopUp : hud_message_device = hud_message_device{}
    @editable DDClassSelector :  class_and_team_selector_device =  class_and_team_selector_device{}
    @editable DoubleDamageAura : visual_effect_powerup_device = visual_effect_powerup_device{}

}
Speed_Boost1 := struct<concrete>{
    @editable RegularModulator : movement_modulator_device = movement_modulator_device{}
    @editable SpeedModulator : movement_modulator_device = movement_modulator_device{}
    @editable SuperSpeedPopUp : hud_message_device = hud_message_device{}
    @editable SpeedBoostAura : visual_effect_powerup_device = visual_effect_powerup_device{}
}
Jump_Boost1 := struct<concrete>{
    @editable JumpModulator : movement_modulator_device = movement_modulator_device{}
    @editable SuperJumpPopUp : hud_message_device = hud_message_device{}
    @editable JumpBoostAura : visual_effect_powerup_device = visual_effect_powerup_device{}
}
Passive_Regen1 := struct<concrete>{
    @editable RegenerationClassSelector :  class_and_team_selector_device =  class_and_team_selector_device{}
    @editable RegenerationDevice : health_powerup_device = health_powerup_device{}
    @editable RegenerationPopUp : hud_message_device = hud_message_device{}
    @editable RegenerationAura : visual_effect_powerup_device = visual_effect_powerup_device{}

}
Shield_Boost1 := struct<concrete>{
    @editable JuggernautPopUp : hud_message_device = hud_message_device{}
    @editable ShieldToGrant : float = 500.0
    @editable JuggernautAura : visual_effect_powerup_device = visual_effect_powerup_device{}

}
Vampirism_Power1 := struct<concrete>{
    @editable VampirismPopUp : hud_message_device = hud_message_device{}
    @editable VampirismAura : visual_effect_powerup_device = visual_effect_powerup_device{}

}
Invisibility_Card1 := struct<concrete>{
    @editable CardDetector : conditional_button_device = conditional_button_device{}
    @editable InvisCardGranter : item_granter_device = item_granter_device{}
    @editable InvisPopUp : hud_message_device = hud_message_device{}
    @editable CardRemover : item_remover_device = item_remover_device{}
    @editable InvisibilityAura : visual_effect_powerup_device = visual_effect_powerup_device{}

}
Instant_Reload1 := struct<concrete>{
    @editable InstantRealoadClassSelector :  class_and_team_selector_device =  class_and_team_selector_device{}
    @editable InstantReloadPopUp : hud_message_device = hud_message_device{}
    @editable InstantReloadAura : visual_effect_powerup_device = visual_effect_powerup_device{}

}
Freeze_Gun1:= struct<concrete>{
    @editable FreezeGunGranter : item_granter_device = item_granter_device{}
    @editable FreezeGunPopUp : hud_message_device = hud_message_device{}
    @editable FreezeGunRemover : item_remover_device = item_remover_device{}
    @editable FreezeGunTracker : conditional_button_device = conditional_button_device{}
    @editable Freeze_Player_Duration : float = 2.9
    @editable FreezeGunAura : visual_effect_powerup_device = visual_effect_powerup_device{}

}
Envenomed:=struct<concrete>{
    @editable EnvenomedAura : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable EnvenomedPopUp : hud_message_device = hud_message_device{}

}

ui1 := class(creative_device):

   @editable General_Devices : Overall1 = Overall1{}

   @editable Team1_Wheel : Super_Power_Wheel1 = Super_Power_Wheel1{}

   @editable Team2_Wheel : Super_Power_Wheel2 = Super_Power_Wheel2{}

   @editable Double_Damage1_Devices : Double_Damage1 = Double_Damage1{}

   @editable Speed_Boost1_Devices : Speed_Boost1 = Speed_Boost1{}

   @editable Jump_Boost1_Devices : Jump_Boost1 = Jump_Boost1{}

   @editable Regeneration_Devices : Passive_Regen1 = Passive_Regen1{}

   @editable Shield_Boost1_Devices : Shield_Boost1 = Shield_Boost1{}

   @editable Vampirism_Devices : Vampirism_Power1 = Vampirism_Power1{}

   @editable Invisibility_Devices : Invisibility_Card1 = Invisibility_Card1{}

   @editable Instant_Reload1_Devices : Instant_Reload1 = Instant_Reload1{}

   @editable Freeze_Gun1_Devices : Freeze_Gun1 = Freeze_Gun1{}

   @editable Envenomed_Devices : Envenomed = Envenomed{}

    var MaybeAgent : ?agent = false

    var CP_Map : [player]Custom_Player_SuperPower1 = map{}
    
    var Heal_Delay : float = 0.1

    var IsRotating1 : logic = false
    var IsRotating2 : logic = false
    
    var Degrees1 : []float = array{0.0, 36.0,72.0, 108.0, 144.0, -180.0, -144.0, -108.0, -72.0, -36.0}
    var Degrees2 : []float = array{0.0, 36.0,72.0, 108.0, 144.0, -180.0, -144.0, -108.0, -72.0, -36.0}

    var RandomInt1 : int = 0
    var RandomInt2 : int = 0

    var InitialSpeed1 : float = 0.10
    var InitialSpeed2 : float = 0.10

    var InitialDelay1 : int = 20
    var InitialDelay2 : int = 20



    OnBegin<override>()<suspends>:void=
        initializeSpawners()
        spawn. CheckForCard()
        
        Team1_Wheel.WheelButton1.InteractedWithEvent.Subscribe(Wheel1)
        Team2_Wheel.WheelButton2.InteractedWithEvent.Subscribe(Wheel2)

        for(RemoveButton:General_Devices.RemovePowers):
            RemoveButton.InteractedWithEvent.Subscribe(RemovePowers)
        for(MV: General_Devices.MapMovementModulators):
            MV.ActivationEvent.Subscribe(CheckSpeedPower)
        
    RemovePowers(Agent:agent):void=
        RemovePower(Agent)
    
    Wheel1(Agent:agent):void=
       OnButtonClicked(Agent,General_Devices.Price1,"Wheel1")
       Print("Wheel1 Clicked")
    
    Wheel2(Agent:agent):void=
        OnButtonClicked(Agent,General_Devices.Price1,"Wheel2")
        Print("Wheel1 Clicked")
     
    OnButtonClicked(Agent : agent,Price:int,Wheel:string):void=
     if (Wheel = "Wheel1" and IsRotating1 = false or Wheel ="Wheel2" and IsRotating2 = false ):
        CurrentGoldCount := General_Devices.Gold_Checker.GetItemCount (Agent, 0) # Grabs how much gold the player has then stores it in a variable
        if (CurrentGoldCount >= Price):
            General_Devices.Gold_Checker.SetItemCountRequired(0, Price)
            General_Devices.Gold_Checker.Activate(Agent)
            if(Wheel = "Wheel1"):
                Team1_Wheel.WheelButton_Cinematic1.Play(Agent)
                set RandomInt1 = GetRandomInt(0, Degrees1.Length -1)
                if (Angle := Degrees1[RandomInt1]):
                    spawn {MakePropsSpin1(Agent, Angle)}
                    Print("angle{Angle}")
            else:
                Team2_Wheel.WheelButton_Cinematic2.Play(Agent)
                set RandomInt2 = GetRandomInt(0, Degrees2.Length -1)
                if (Angle := Degrees2[RandomInt2]):
                    spawn {MakePropsSpin2(Agent, Angle)}
                    Print("angle{Angle}")

        else:
            General_Devices.Not_Enough_Currency_Message.Show(Agent)
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------     
    initializeSpawners():void=
        for(Spawner:General_Devices.Player_Spawners):
            Spawner.SpawnedEvent.Subscribe(InitializePlayer)

    CheckSpeedPower(Agent:agent):void=
        if(PlayerObj := player[Agent]): #Converts The Agent to a type player
            if(CustomPlayer : Custom_Player_SuperPower1 = CP_Map[PlayerObj]):
                CheckLogic := CustomPlayer.CheckLogicActive("SuperSpeed")
                if(CheckLogic = true):
                    Speed_Boost1_Devices.SpeedModulator.Activate(Agent)
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------     
    MakePropsSpin1(Agent : agent, Angle : float)<suspends>:void=

        set IsRotating1 = true
        var CurrentSpeed : float = InitialSpeed1
        var CurrentDelay : int = InitialDelay1
        loop:
            Team1_Wheel.Spin_Audio1.Play(Agent)
            
            Transform := Team1_Wheel.Spinner1.GetTransform()
            Position := Transform.Translation
            Rotation := Transform.Rotation
            NewRotation := Rotation.ApplyYaw((36.0 * Pi / 180.0)
            Team1_Wheel.Spinner1.MoveTo(Position, NewRotation, CurrentSpeed)
            if (CurrentDelay <= 5):
                if(CurrentSpeed < 0.3):
                   set CurrentSpeed += 0.2
                Print("Current speed:{CurrentSpeed}")
                PropCurrentRotation : []float = Team1_Wheel.Spinner1.GetTransform().Rotation.GetYawPitchRollDegrees()
                if (CurrentAngle := PropCurrentRotation[0]):
                    Print("Current angle is :{CurrentAngle}/{Angle}")
                    if (RoundedCurrentAngle := Round[CurrentAngle] * 1.0):
                        if (RoundedCurrentAngle < Angle + 10.0 and RoundedCurrentAngle > Angle - 10.0):
                            set IsRotating1 = false
                            WhenStopped(Agent,Angle)
                         
                            break
                            
            else:
                set CurrentDelay -= 1
            Print("Current Delay:{CurrentDelay}")
            Sleep(0.0)
    MakePropsSpin2(Agent : agent, Angle : float)<suspends>:void=

        set IsRotating2 = true
        var CurrentSpeed : float = InitialSpeed2
        var CurrentDelay : int = InitialDelay2
        loop:
            Team2_Wheel.Spin_Audio2.Play(Agent)
            
            Transform := Team2_Wheel.Spinner2.GetTransform()
            Position := Transform.Translation
            Rotation := Transform.Rotation
            NewRotation := Rotation.ApplyYaw((36.0 * Pi / 180.0)
            Team2_Wheel.Spinner2.MoveTo(Position, NewRotation, CurrentSpeed)
            if (CurrentDelay <= 5):
                if(CurrentSpeed < 0.3):
                    set CurrentSpeed += 0.2
                Print("Current speed:{CurrentSpeed}")
                PropCurrentRotation : []float = Team2_Wheel.Spinner2.GetTransform().Rotation.GetYawPitchRollDegrees()
                if (CurrentAngle := PropCurrentRotation[0]):
                    Print("Current angle is :{CurrentAngle}/{Angle}")
                    if (RoundedCurrentAngle := Round[CurrentAngle] * 1.0):
                        if (RoundedCurrentAngle < Angle + 10.0 and RoundedCurrentAngle > Angle - 10.0):
                            set IsRotating2 = false
                            WhenStopped(Agent,Angle)
                            
                            break
                            
            else:
                set CurrentDelay -= 1
            Print("Current Delay:{CurrentDelay}")
            Sleep(0.0)     

    AssignPowerDoubleDamage(CP:Custom_Player_SuperPower1):void=
                Agent:= CP.Player
                set CP.Power = "DoubleDamage"
                Double_Damage1_Devices.DamageAmplifier.Pickup(Agent)
                Double_Damage1_Devices.DDClassSelector.ChangeClass(Agent)
                Double_Damage1_Devices.DoubleDamagePopUp.Show(Agent)
                Print("You now have Double Damage")
                Double_Damage1_Devices.DoubleDamageAura.Pickup(Agent)
                CP.ChangeLogicActive("DoubleDamage",true)

    AssignPowerVampirism(CP:Custom_Player_SuperPower1):void=
        Agent:= CP.Player
        if(FC := Agent.GetFortCharacter[]):
            set CP.Power = "Vamp"
            CP.ChangeLogicActive("Vampirism",true)
            OnVampirismBought(FC)
            Print("You now have Vamp")
            Vampirism_Devices.VampirismAura.Pickup(Agent)
            CP.ChangeLogicVamp(true)
            Vampirism_Devices.VampirismPopUp.Show(Agent)
    
    AssignPowerSuperSpeed(CP:Custom_Player_SuperPower1):void=
        Agent:= CP.Player
        set CP.Power = "SuperSpeed"
        CP.ChangeLogicActive("SuperSpeed",true)
        spawn. OnSpeedBought(Agent)
        Speed_Boost1_Devices.SuperSpeedPopUp.Show(Agent)
        Print("You now have superspeed")
        Speed_Boost1_Devices.SpeedBoostAura.Pickup(Agent)

    AssignPowerSuperJump(CP:Custom_Player_SuperPower1):void=
        Agent:= CP.Player
        set CP.Power = "SuperJump"
        CP.ChangeLogicActive("SuperJump",true)
        Jump_Boost1_Devices.SuperJumpPopUp.Show(Agent)
        Print("You now have superjump")
        Jump_Boost1_Devices.JumpBoostAura.Pickup(Agent)

    AssignPowerRegeneration(CP:Custom_Player_SuperPower1):void=
        Agent:= CP.Player
        set CP.Power = "Regeneration"
        CP.ChangeLogicActive("Regeneration",true)
        Regeneration_Devices.RegenerationClassSelector.ChangeClass(Agent)
        Regeneration_Devices.RegenerationPopUp.Show(Agent)
        Print("You now have regeneration")
        Regeneration_Devices.RegenerationAura.Pickup(Agent)

    AssignPowerJuggernaut(CP:Custom_Player_SuperPower1):void=
        Agent:= CP.Player
        set CP.Power = "Juggernaut"
        CP.ChangeLogicActive("Juggernaut",true)
        OnJuggernautBought(Agent)
        Shield_Boost1_Devices.JuggernautAura.Pickup(Agent)
        Shield_Boost1_Devices.JuggernautPopUp.Show(Agent)
        Print("You now have Juggernaut")
    
    AssignPowerInvisibility(CP:Custom_Player_SuperPower1):void=
        Agent:= CP.Player
        set CP.Power = "Invisibility"
        CP.ChangeLogicActive("Invisibility",true)
        OnInvisibilityBought(Agent)
        Invisibility_Devices.InvisibilityAura.Pickup(Agent)
        Invisibility_Devices.InvisPopUp.Show(Agent)
        Print("You now have Invisibility")

    AssignPowerInstantReload(CP:Custom_Player_SuperPower1):void=
        Agent:= CP.Player
        set CP.Power = "InstantReload"
        CP.ChangeLogicActive("InstantReload",true)
        PlayerBoughtInstaReload(Agent)
        Instant_Reload1_Devices.InstantReloadPopUp.Show(Agent)
        Instant_Reload1_Devices.InstantReloadAura.Pickup(Agent)
        Print("You now have InstantReload")

    AssignPowerFreezeGun(CP:Custom_Player_SuperPower1):void=
        Agent:= CP.Player
        set CP.Power = "FreezeGun"
        CP.ChangeLogicFreeze(true)
        if(FC := Agent.GetFortCharacter[]):
            CP.ChangeLogicActive("FreezeGun",true)
            OnFreezeGunBought(FC)
            Freeze_Gun1_Devices.FreezeGunPopUp.Show(Agent)
            Freeze_Gun1_Devices.FreezeGunAura.Pickup(Agent)   

    AssignPowerEnvemoned(CP:Custom_Player_SuperPower1):void=
        Agent:= CP.Player
        set CP.Power = "ENVENOMED"
   
        if(FC := Agent.GetFortCharacter[]):
            CP.ChangeLogicActive("Envenomed",true)
            Envenomed_Devices.EnvenomedAura.Pickup(Agent)
            Envenomed_Devices.EnvenomedPopUp.Show(Agent)

   
    WhenStopped(Agent : agent,Angle : float):void=
        if(PlayerObj := player[Agent]): 
            if(CustomPlayer : Custom_Player_SuperPower1 = CP_Map[PlayerObj]):
                RemovePower(Agent)
                General_Devices.XP_Granter.Award(Agent)
                General_Devices.Grant_Audio.Play(Agent)
                if (Angle = 0.0):
                    AssignPowerDoubleDamage(CustomPlayer)
                else if (Angle = -36.0):
                    AssignPowerVampirism(CustomPlayer)
                else if (Angle = -72.0):
                    AssignPowerSuperSpeed(CustomPlayer)
                else if (Angle = -108.0):
                    AssignPowerSuperJump(CustomPlayer)
                else if (Angle = -144.0):
                    AssignPowerRegeneration(CustomPlayer)
                else if (Angle = -180.0):
                    AssignPowerJuggernaut(CustomPlayer)
                else if (Angle = 144.0):
                    AssignPowerInvisibility(CustomPlayer)
                else if (Angle = 108.0):
                    AssignPowerInstantReload(CustomPlayer)
                else if (Angle = 72.0):
                    AssignPowerFreezeGun(CustomPlayer)
                else if (Angle = 36.0):
                    AssignPowerEnvemoned(CustomPlayer)
                else: 
                    Print("No Valid angle Assigned")
                CustomPlayer.UpdateUi()
            else:
                Print("No Custom Player Found")
            
    RemovePower(Agent:agent):void=
        if(PlayerObj := player[Agent]): 

                if(CP :=  CP_Map[player[Agent]]):
                    if(CP.Power = "DoubleDamage"):
                        CP.ChangeLogicActive("DoubleDamage",false)
                        General_Devices.DefaultClassSelector.ChangeClass(Agent)

                    else if(CP.Power = "Vamp"):
                        CP.ChangeLogicActive("Vampirism",false)
                        CP.ChangeLogicVamp(false)

                    else if(CP.Power = "SuperSpeed"):
                        CP.ChangeLogicActive("SuperSpeed",false)
                        Speed_Boost1_Devices.RegularModulator.Activate(Agent)
                    

                    else if(CP.Power = "SuperJump"):
                        CP.ChangeLogicActive("SuperJump",false)
                        CP.ChangeLogicJump(false)
                   

                    else if(CP.Power = "Regeneration"):
                        General_Devices.DefaultClassSelector.ChangeClass(Agent)
                        CP.ChangeLogicActive("Regeneration",false)

                    else if(CP.Power = "Juggernaut"):
                        CP.ChangeLogicActive("Juggernaut",false)
                        SetDefaultShield(Agent)
                 

                    else if(CP.Power = "Invisibility"):
                        Invisibility_Devices.CardRemover.Remove(Agent)
                        CP.ChangeLogicActive("Invisibility",false)

                       

                    else if(CP.Power = "InstantReload"):
                        General_Devices.DefaultClassSelector.ChangeClass(Agent)
                        CP.ChangeLogicActive("InstantReload",false)
                        

                    else if(CP.Power = "FreezeGun"):
                        CP.ChangeLogicActive ("FreezeGun",false)
                        CP.ChangeLogicFreeze(false)
                        Freeze_Gun1_Devices.FreezeGunRemover.Remove(Agent)
        
                    else if(CP.Power = "ENVENOMED"):
                        CP.ChangeLogicActive("Envenomed",false)   

                    else:
                        Print("No Power Found")
                    set CP.Power = "false"
                    General_Devices.RemoveAura.Pickup(Agent)
                    CP.UpdateUi()
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    OnVampirismBought(FC : fort_character):void=
        if (Agent := FC.GetAgent[]):
            if(CustomPlayer :=  ReturnCustomPlayer[Agent]):
                    ChangeLogicVamp := CustomPlayer.ReturnOnVamp()
                    if(ChangeLogicVamp = true):
        

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
            Print("Player Healed")

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
            Print("Shield Fixed")
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------     
    OnSpeedBought(Agent : agent)<suspends>:void=
        if(PlayerObj := player[Agent]): #Converts The Agent to a type player
            if(CustomPlayer : Custom_Player_SuperPower1 = CP_Map[PlayerObj]):
                Speed_Boost1_Devices.SpeedModulator.Activate(Agent)
                Print("speed Activated")
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------     
    DoJumpPower(FC : fort_character):void=
        if (Agent := FC.GetAgent[]):
          if(PlayerObj := player[Agent]):
            if(CP : Custom_Player_SuperPower1 = CP_Map[PlayerObj]):
                if(Power := CP.CustomPlayerPower["SuperJump"], Power?):
    
                    Jump_Boost1_Devices.JumpModulator.Activate(Agent)
                    Print("Jump Activated")
                else: 
                    Print("No Jump Power")
    #-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    OnJuggernautBought(Agent : agent):void=
        if (FC : fort_character = Agent.GetFortCharacter[]):
            FC.SetMaxShield(Shield_Boost1_Devices.ShieldToGrant)
            FC.SetShield(Shield_Boost1_Devices.ShieldToGrant)
            Print("Shield Granted")

    SetDefaultShield(Agent : agent):void=     
        if (FC : fort_character = Agent.GetFortCharacter[]):
            FC.SetMaxShield(100.0)
            FC.SetShield(100.0)
            Print("Default Shield Granted")      
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    OnInvisibilityBought(Agent : agent):void=
        Invisibility_Devices.InvisCardGranter.GrantItem(Agent)

    CheckForCard()<suspends>:void=
        loop:
            Sleep(1.0)
            AllPlayers := GetPlayspace().GetPlayers()
            for(Player:AllPlayers):
                if(IsAgent:agent=agent[Player]):
                    if(Invisibility_Devices.CardDetector.IsHoldingItem[IsAgent]):
                        HidePlayer(IsAgent)
                        Print("Player Hidden")
                    else:
                        ShowPlayer(IsAgent)
                        Print("Player Shown")

    ShowPlayer(Agent:agent):void=
        if(FC:=Agent.GetFortCharacter[]):
            FC.Show()

    HidePlayer(Agent:agent):void=
        if(FC:=Agent.GetFortCharacter[]):
            FC.Hide()
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------   
    PlayerBoughtInstaReload(Agent : agent):void=
        if(PlayerObj := player[Agent]): #Converts The Agent to a type player
            if(CustomPlayer : Custom_Player_SuperPower1 = CP_Map[PlayerObj]):
                Instant_Reload1_Devices.InstantRealoadClassSelector.ChangeClass(Agent)
                Print("Player Given InstantReload")
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------   
    OnFreezeGunBought(FC : fort_character):void= 
        if (Agent := FC.GetAgent[]):
            if(CustomPlayer :=  ReturnCustomPlayer[Agent]):
                ChangeLogicFreeze := CustomPlayer.ReturnOnFreeze()
                    if(ChangeLogicFreeze = true):
                        Freeze_Gun1_Devices.FreezeGunGranter.GrantItem(Agent)

    FreezePlayer(Target : fort_character)<suspends>:void=
        Target.PutInStasis(stasis_args{})
        Print("Target Frozen for {Freeze_Gun1_Devices.Freeze_Player_Duration} seconds")
        Sleep(Freeze_Gun1_Devices.Freeze_Player_Duration)
        Target.ReleaseFromStasis()
        Print("Target Released")
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    InitPlayerEvents(Agent:agent):void=
        if (FC:fort_character = Agent.GetFortCharacter[]):
            FC.DamagedEvent().Subscribe(OnDamagedPlayer)
            FC.EliminatedEvent().Subscribe(OnEliminatedPlayer) 
            FC.JumpedEvent().Subscribe(DoJumpPower)
            FC.DamagedShieldEvent().Subscribe(OnDamagedPlayer)
            
    OnDamagedPlayer(DR:damage_result):void=
        if:
            Instigator := DR.Instigator?.GetInstigatorAgent[]
            Target := fort_character[DR.Target].GetAgent[]
            Target <> Instigator
            TeamCollection := GetPlayspace().GetTeamCollection()
            TeamCollection.GetTeam[Instigator] <> TeamCollection.GetTeam[Target]

        then:
            if(CP :=  CP_Map[player[Instigator]],CPTarget := CP_Map[player[Target]]):
                if(CP.Power = "ENVENOMED"):
                    CPTarget.DoPoison(Instigator)
                else if(CP.Power = "FreezeGun"):
                    CheckForFreezeGun(DR)
                else if(CP.Power = "Vamp"):
                    if(Target  = Instigator):
                    else:
                        DamagedAmount:float = DR.Amount/3.0
                        if (FC:fort_character = Instigator.GetFortCharacter[]):
                            CurrentHealth:float = FC.GetHealth()
                            DoSiphon(FC, DamagedAmount)

    CheckForFreezeGun(DR:damage_result):void=
        if:
            Instigator := DR.Instigator?
            Agent := Instigator.GetInstigatorAgent[]
            Freeze_Gun1_Devices.FreezeGunTracker.IsHoldingItem[Agent]
            Target := fort_character[DR.Target]
        then:
            spawn:
                FreezePlayer(Target)        
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    InitializePlayer(Agent:agent):void=

        if(PlayerObj := player[Agent]): #Converts The Agent to a type player
            if(PlayerExists := CP_Map[PlayerObj]):
                ReInitAura(PlayerExists)
                CheckLogicSpeed:=PlayerExists.CheckLogicActive("SuperSpeed")
                CheckLogicJug:=PlayerExists.CheckLogicActive("Juggernaut")
                    if(CheckLogicSpeed = true):
                        Speed_Boost1_Devices.SpeedModulator.Activate(Agent)
                    if(CheckLogicJug = true):
                        OnJuggernautBought(Agent)
            else:
                

                CustomPlayer: Custom_Player_SuperPower1 = Custom_Player_SuperPower1{Player := Agent}  # Create a Copy  Set the Player
                option. set CP_Map[PlayerObj] = CustomPlayer 
                if(General_Devices.WidgetPosition = widget_position.AboveHealthBar):
                    #do Nothing use default position
                else:
                    set CustomPlayer.Anchors = anchors{Minimum := vector2{X := 1.0, Y := 0.0}, Maximum := vector2{X := 1.0, Y := 0.0}}
                    set CustomPlayer.Offsets = margin{Left:=  -391.642334, Top := 372.0, Right := 0.0, Bottom := 0.0}
              

                CustomPlayer.AddUiToPlayer()
                
                    
                InitPlayerEvents(Agent)

    ReInitAura(CP : Custom_Player_SuperPower1):void=
        for(Key  -> Value : CP.CustomPlayerPower):
            if(Value = true):
                case (Key):
                    "SuperSpeed" => Speed_Boost1_Devices.SpeedBoostAura.Pickup(CP.Player)
                    "SuperJump" =>  Jump_Boost1_Devices.JumpBoostAura.Pickup(CP.Player)
                    "Regeneration" =>  Regeneration_Devices.RegenerationAura.Pickup(CP.Player)
                    "Juggernaut" => Shield_Boost1_Devices.JuggernautAura.Pickup(CP.Player)
                    "Vampirism" =>  Vampirism_Devices.VampirismAura.Pickup(CP.Player)
                    "DoubleDamage" =>  Double_Damage1_Devices.DoubleDamageAura.Pickup(CP.Player)
                    "Invisibility" =>  Invisibility_Devices.InvisibilityAura.Pickup(CP.Player)
                    "InstantReload" => Instant_Reload1_Devices.InstantReloadAura.Pickup(CP.Player)
                    "FreezeGun" =>  Freeze_Gun1_Devices.FreezeGunAura.Pickup(CP.Player)
                    "Envenomed" =>  Envenomed_Devices.EnvenomedAura.Pickup(CP.Player)
                    _ => General_Devices.RemoveAura.Pickup(CP.Player)

    ReturnCustomPlayer(Agent:agent)<transacts><decides>:Custom_Player_SuperPower1=    
        var MaybeCustomPlayer: ?Custom_Player_SuperPower1=false         
            if(PlayerObj := player[Agent]):
                if(CustomPlayer : Custom_Player_SuperPower1 = CP_Map[PlayerObj]):
                    set MaybeCustomPlayer = option{CustomPlayer}
        return MaybeCustomPlayer?

    OnEliminatedPlayer(ER:elimination_result):void=
        if(EliminatedPlayer := player[ER.EliminatedCharacter.GetAgent[]] , EliminatingPlayer := player[ER.EliminatingCharacter?.GetAgent[]]):      
            if(EliminatedCP := Custom_Player_SuperPower1[EliminatedPlayer]):
                CheckLogicSpeed:=EliminatedCP.CheckLogicActive("SuperSpeeda")
                CheckLogicJug:=EliminatedCP.CheckLogicActive("Juggernaut")
                if(CheckLogicSpeed = true):
                    Speed_Boost1_Devices.SpeedModulator.Activate(EliminatedPlayer)
                if(CheckLogicJug = true):
                    OnJuggernautBought(EliminatedPlayer)
                    
        else:
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Custom_Player_SuperPower1:=class<unique>:
        
    Player:agent
    
    var Power : string = "false"

    var PlayerBoughtPoison : logic = false

    var PlayerBoughtJump : logic = false

    var PlayerBoughtVampire : logic = false
    
    var PlayerBoughtFreezeGun : logic = false

    var Anchors : anchors = anchors{Minimum := vector2{X := 0.0, Y := 1.0}, Maximum := vector2{X := 0.0, Y := 1.0}}
    var Offsets : margin = margin{Left:=  53.388683, Top := -332.93, Right := 0.0, Bottom := 0.0}
    
    var CustomPlayerPower : [string]logic = map {"SuperSpeed" => false,"SuperJump" => false,"Regeneration" => false,"Juggernaut" => false,"Vampirism" => false,"DoubleDamage" => false,"Invisibility" => false,"InstantReload" => false,"FreezeGun" => false,"Envenomed" => false}

    var PoisonOn : logic = false

    var Repeats : int = 5
   
    DoRecurringDamage(PlayerToDamage:agent,AmountToDmg:float,Delay:float, InstigatorAgent : agent)<suspends>:void=
        if(FortCharacter := PlayerToDamage.GetFortCharacter[]):
            loop:
                if(Repeats > 0):
                    
                    FortCharacter.Damage(AmountToDmg)
                    Print("Player Damaged - poison")
                    Sleep(Delay)
                    set Repeats -= 1
                else:
                    set PoisonOn = false
                    set Repeats = 5
                    break
            Print("Repeats:{Repeats}")

     # Does damage to the player


    DoPoison(Instigator : agent):void=
        if(PoisonOn?):
            set Repeats = 5
        else:
            
                spawn. DoRecurringDamage(Player,5.0,1.0,Instigator)
                set PoisonOn = true
                Print("Poison Activated")

            

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

    ReturnOnFreeze():logic=
        return PlayerBoughtFreezeGun

    ChangeLogicFreeze(Logic:logic):void= 
        set PlayerBoughtFreezeGun = Logic

    ReturnOnPoison():logic=
        return PlayerBoughtPoison

    ChangeLogicPoison(Logic:logic):void= 
        set PlayerBoughtPoison = Logic

    PowerImage : texture_block =  texture_block{  DefaultImage := PowersWheelAssets.DamageBoost02, DefaultDesiredSize := vector2{X := 443.077881, Y := 108.996826}}

    var PowerCanvas : canvas =  canvas{}

    AddUiToPlayer():void=
        if(PlayerObj := player[Player]):
            if(PlayerUI := GetPlayerUI[PlayerObj]):
                set PowerCanvas = CreateCanvas()
          
                HideUi()
                PlayerUI.AddWidget(PowerCanvas)
                Print("UI Added")
              
    HideUi():void=PowerImage.SetVisibility(widget_visibility.Collapsed)
    
    ShowUi():void=PowerImage.SetVisibility(widget_visibility.Visible)
        
    UpdateUi():void=
        var PowerFound : logic = false
        for(Key  -> value : CustomPlayerPower):
            if(value = true):
                set PowerFound = true
                ShowUi()
                case (Key):
                    "SuperSpeed" => PowerImage.SetImage(PowersWheelAssets.SuperSpeed02)
                    "SuperJump" => PowerImage.SetImage(PowersWheelAssets.SuperJump02)
                    "Regeneration" => PowerImage.SetImage(PowersWheelAssets.Regeneration02)
                    "Juggernaut" => PowerImage.SetImage(PowersWheelAssets.Juggernaut02)
                    "Vampirism" => PowerImage.SetImage(PowersWheelAssets.Vampirism02)
                    "DoubleDamage" => PowerImage.SetImage(PowersWheelAssets.DamageBoost02)
                    "Invisibility" => PowerImage.SetImage(PowersWheelAssets.Invisibility02)
                    "InstantReload" => PowerImage.SetImage(PowersWheelAssets.InstantReload02)
                    "FreezeGun" => PowerImage.SetImage(PowersWheelAssets.FreezeGun02) 
                    "Envenomed" => PowerImage.SetImage(PowersWheelAssets.Envenomed02) 
                    _ => HideUi()
        if(PowerFound = false):
            HideUi()

    CreateCanvas():canvas=
        var Canvas : canvas = canvas:
            Slots := array:
                canvas_slot:
                    Widget := PowerImage
                    Anchors := Anchors
                    Offsets := Offsets
                    Alignment := vector2{X := 0.0, Y := 0.0}
                    SizeToContent := true
                    
        return Canvas
