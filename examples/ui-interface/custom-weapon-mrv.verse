# Custom Weapon Mrv
# Verse code for Custom Weapon Mrv - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/custom-weapon-mrv?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }

Custom_Weapon := class<concrete>():
    @editable Conditional : conditional_button_device = conditional_button_device{}
    @editable VFX : visual_effect_powerup_device = visual_effect_powerup_device{}
    @editable CrosshairHUD : hud_message_device = hud_message_device{}
    @editable Projectile : creative_prop_asset = DefaultCreativePropAsset
    @editable WeaponSpeed : float = 0.0
    @editable WeaponRange : float = 0.0
    @editable WeaponDamage : float = 0.0
    var Identifier : int = 0

    Equip(Agent:agent) : void=
        VFX.Pickup(Agent)
        CrosshairHUD.Show(Agent)

    Fire(Agent:agent)<suspends> : void=
        if(FC := Agent.GetFortCharacter[]):
            PlayerPos := FC.GetTransform().Translation
            PlayerViewRot := FC.GetViewRotation()
            PlayerForwardVector := PlayerViewRot.GetLocalForward() * 400.0
            PlayerForwardVectorEnd := PlayerViewRot.GetLocalForward() * WeaponRange
            SpawnPos := PlayerPos + PlayerForwardVector
            FinishPos := PlayerPos + PlayerForwardVectorEnd
            if(NewProp := SpawnProp(Projectile , SpawnPos, IdentityRotation())(0)?):
                race:
                    block:
                        NewProp.MoveTo(FinishPos,IdentityRotation(),WeaponSpeed)
                        # NewProp.Dispose()  # TODO: Verse has no manual disposal
                        return
                    DamageCheck(NewProp , Agent)

    DamageCheck(Prop : creative_prop , Agent : agent)<suspends> : void=
        loop:
            Sleep(0.0)
            for(Player : Prop.GetPlayspace().GetPlayers() ,Player <> Agent , FC := Player.GetFortCharacter[]):
                if(Distance(FC.GetTransform().Translation , Prop.GetTransform().Translation) < 400.0):
                    FC.Damage(WeaponDamage)





Custom_Player := class():
    Player : player
    var CustomWepDevice : CustomWeapon_Manager = CustomWeapon_Manager{}
    var AllWeapons : []Custom_Weapon = array{}
    var ClearTrigger : trigger_device = trigger_device{}
    var BaseCrosshair : hud_message_device = hud_message_device{}
    var CurrentWeapon : ?Custom_Weapon = false
    var InputTrigger : input_trigger_device = input_trigger_device{}

    Initiate() : void=
        spawn:
            CheckWeapons()

    CheckWeapons()<suspends> : void=
        race:
            block:
                loop:
                    Sleep(0.0)
                    LeavingPlayer := CustomWepDevice.GetPlayspace().PlayerRemovedEvent().Await()
                    if(LeavingPlayer = Player):
                        break


            loop:
                Sleep(0.0)
                var IsWeaponFound : logic = false
                for(Wep : AllWeapons , IsWeaponFound = false):
                    if(Wep.Conditional.IsHoldingItem[Player]):
                        set IsWeaponFound = true
                        if(NewCurrentWeapon := CurrentWeapon?):
                            if(NewCurrentWeapon.Identifier <> Wep.Identifier):
                                Wep.Equip(Player)
                                set CurrentWeapon = option{Wep}
                                InputTrigger.Register(Player)
                        else:
                            Wep.Equip(Player)
                            set CurrentWeapon = option{Wep}
                            InputTrigger.Register(Player)
            
                if(IsWeaponFound = false):
                    if(NewCurrentWeapon := CurrentWeapon?):
                        ClearTrigger.Trigger(Player)
                        BaseCrosshair.Show(Player)
                        set CurrentWeapon = false
                        InputTrigger.Unregister(Player)
            

CustomWeapon_Manager := class(creative_device):
    var PlayersMap : [player]Custom_Player = map{}

    @editable AllWeapons : []Custom_Weapon = array{}
    @editable ClearTrigger : trigger_device = trigger_device{}
    @editable BaseCrosshair : hud_message_device = hud_message_device{}
    @editable InputTrigger : input_trigger_device = input_trigger_device{}


    OnBegin<override>()<suspends>:void=
        for(Player : GetPlayspace().GetPlayers()):
            Initialize(Player)

        GetPlayspace().PlayerAddedEvent().Subscribe(Initialize)

        InitializeWeapons()

        InputTrigger.PressedEvent.Subscribe(OnFire)

    OnFire(Agent:agent) : void=
        if(CP := PlayersMap[Agent]):
            if(CurrentWep := CP.CurrentWeapon?):
                spawn:
                    CurrentWep.Fire(Agent)

    InitializeWeapons() : void=
        for(idx -> Wep : AllWeapons):
            set Wep.Identifier = idx + 1



    Initialize(Player : player) : void=
        if(PlayerExists := PlayersMap[Player]):

        else:
            if:
                set PlayersMap[Player] = Custom_Player{
                Player := Player
                CustomWepDevice := Self
                AllWeapons := AllWeapons
                ClearTrigger := ClearTrigger
                BaseCrosshair := BaseCrosshair
                InputTrigger := InputTrigger
                }
                CP := PlayersMap[Player]

            then:
                CP.Initiate()