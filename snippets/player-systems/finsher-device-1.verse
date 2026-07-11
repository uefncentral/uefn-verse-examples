# Player Finisher System
# A comprehensive player management system that handles player spawning, damage tracking, and finisher mechanics. It monitors player damage events, manages custom player data, and coordinates special fi
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/finsher-device-1?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Simulation/Tags }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }
using { /Fortnite.com/UI }
using { /Verse.org/Colors }
using { /UnrealEngine.com/Temporary/UI }

player_spawner := class(tag){}

var Data : weak_map(player , player_data) = map{}

Finishers_device := class(creative_device):

    var Currency_TW :text_block=text_block{DefaultTextColor := color{R:=255.0,G:=255.0,B:=255.0}}
    TextForUi<localizes>(Finisher : int):message="{Finisher}"

    @editable var Finishers : []finisher = array{}

    var CustomPlayers : [player]custom_player = map{}


    OnPlayerLeftServer(PlayerLeaving : player) :void=
        if (CustomPlayer := CustomPlayers[PlayerLeaving]):
            var NewCustomPlayerMap : [player]custom_player = map{}
            for (Key -> Value : CustomPlayers, Key <> PlayerLeaving):
                set NewCustomPlayerMap = ConcatenateMaps(NewCustomPlayerMap, map{Key => Value})
            set CustomPlayers = NewCustomPlayerMap



    OnBegin<override>()<suspends>:void=
        InitSpawners()
        for(Finisher : Finishers):
            Finisher.InitEvents()

        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerLeftServer)
        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerAdded)

        AllPlayers := GetPlayspace().GetPlayers()
        for (Player : AllPlayers):
            if (FortCharacter := Player.GetFortCharacter[]):
                if(Agent := FortCharacter.GetAgent[]):
                    FortCharacter.DamagedEvent().Subscribe(Damage_Check)
                    FortCharacter.DamagedShieldEvent().Subscribe(Damage_Check)
                    FortCharacter.SetVulnerability(true)

    Damage_Check(Result : damage_result):void=
        if:
            Instigator := Result.Instigator?
            _Instigator := Result.Instigator
            Agent := Instigator.GetInstigatorAgent[]
            Target := Result.Target
            Target_FortCharacter := fort_character[Target]
            Target_Agent := Target_FortCharacter.GetAgent[]
            Instigator_Player := player[Agent]
            Instigator_CustomPlayer := CustomPlayers[Instigator_Player]
            Target_Player := player[Target_Agent]
            Target_CustomPlayer := CustomPlayers[Target_Player]
            var Amount : float = Result.Amount
            Instigator_FortCharacter := Agent.GetFortCharacter[] 
        then:
            Print("{Amount}")
            if(Amount =20.0):
                Print("{Amount}")
                spawn{StartAnimation(Target_FortCharacter,Instigator_FortCharacter,Agent,Target_Agent,Instigator_CustomPlayer.Finisher,_Instigator)}
                    

# --------------------------------------------ANIMATION SCRIPT------------------------------------------------- #
    StartAnimation(Target : fort_character , Instigator : fort_character,Instigator_Agent : agent,Target_Agent : agent, Anim : int,_Instigator: ?game_action_instigator)<suspends>:void=
        if(Tracker :=Finishers[0].Tracker): 
            if(Finisher :=Finishers[Tracker.GetValue(Instigator_Agent)-1]):
                Sleep(0.01)  
                Target.PutInStasis(stasis_args{})
                Sleep(0.01) 
                Instigator.PutInStasis(stasis_args{})
        
                Target.SetVulnerability(false)
                Instigator.SetVulnerability(false)

                Target.Hide()
                Instigator.Hide()

                Finisher.Ins_Trgr.Trigger(Instigator_Agent)
                Finisher.Target_Trgr.Trigger(Target_Agent)
                Finisher.Cinematic.Play()
                if(Finisher.Anchor.TeleportTo[vector3{ X:=Instigator.GetTransform().Translation.X , Y:=Instigator.GetTransform().Translation.Y , Z:= Instigator.GetTransform().Translation.Z-50.0}, Instigator.GetTransform().Rotation]):
                    spawn{StopAnimation(Target,Instigator,_Instigator,Tracker.GetValue(Instigator_Agent),Finisher.Time)}

    StopAnimation(Target : fort_character , Instigator : fort_character,Ins_Agent : ?game_action_instigator, Anim : int,Time : float)<suspends>:void=
        if(Finisher :=Finishers[Anim]):  
            Sleep(Time)
            Target.ReleaseFromStasis()
            Instigator.ReleaseFromStasis()

            Target.SetVulnerability(true)
            Instigator.SetVulnerability(true)

            Target.Show()
            Instigator.Show()

            Finisher.Cinematic.Stop()
            var Target_HP :float=Target.GetHealth()
            var Target_Shield :float=Target.GetShield()
            Target.Damage(damage_args{Instigator:= Ins_Agent , Amount := Target_HP+Target_Shield})

# -----------------------------------------Initiat Player------------------------------------------------------------ #
    InitSpawners() : void=
        Spawners := GetCreativeObjectsWithTag(player_spawner{})
            for (Obj : Spawners):
                if (Spawner := player_spawner_device[Obj]):
                    Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

    OnPlayerSpawned(Agent : agent): void=
        if (Player := player[Agent]):
            spawn {InitPlayer(Player)}

    var PlayerMap :[agent]player_spawner=map{}

    InitPlayer(Player : player)<suspends>:void=
        if:
            Fort := Player.GetFortCharacter[]
        then: 
            if (Existing := CustomPlayers[Player]):
            else:
                if(not Data[Player]):
                    if(set Data[Player] = player_data{}):
                        if(PlayerData := Data[Player]):
                CustomPlayer := custom_player{Player := Player}
                if (set CustomPlayers[Player] = CustomPlayer){
                    Print("DDDDDD")
                    CustomPlayer.CurrencyUI()
                    UpdateFinishersUI(Player , CustomPlayer)
                }

    OnPlayerAdded(Player : player):void=
        if(FC := Player.GetFortCharacter[]):
            FC.DamagedEvent().Subscribe(Damage_Check)
            FC.DamagedShieldEvent().Subscribe(Damage_Check)
# -------------------------------------------------------------------------------------------------------------------- #
    UpdateFinishersUI(Agent:agent,CustomPlayer : custom_player)<suspends>:void=
        loop:
            Sleep(0.1)
            if(FinisherTracker := Finishers[0].Tracker):
                set CustomPlayer.Finisher = FinisherTracker.GetValue(Agent)
                CustomPlayer.Finisher_TW.SetText(TextForUi(CustomPlayer.Finisher))