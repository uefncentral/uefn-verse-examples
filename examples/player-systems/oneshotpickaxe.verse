# One-Shot Pickaxe System
# Creates a one-shot elimination mechanic for players with a specific class number when using pickaxe attacks. Players assigned to the OneShot class can instantly eliminate other players with pickaxe da
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/oneshotpickaxe?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }

OneShotPickaxe := class(creative_device):
    @editable GameStartDevice : GameStart = GameStart{}
    @editable OneShotClassNumber : int = 100

    @editable OneShotConditionals : []conditional_button_device = array{}
    @editable OneShotSound : audio_player_device = audio_player_device{}
    var IsHoldingAnItem : logic = false

    OnBegin<override>()<suspends>:void=
        for (Player : GetPlayspace().GetPlayers(), FortCharacter := Player.GetFortCharacter[]):
            FortCharacter.DamagedEvent().Subscribe(OnPlayerDamaged)
            FortCharacter.DamagedShieldEvent().Subscribe(OnPlayerDamaged)
    OnPlayerDamaged(DamageResult: damage_result): void = 
        if: 
            Instigator := DamageResult.Instigator?
            Agent := Instigator.GetInstigatorAgent[]
            Target:= fort_character[DamageResult.Target]
        then:
            if(InstiPlayer := player[Agent] ,  InstiFC := InstiPlayer.GetFortCharacter[]):
                if(GameStartDevice.EachPlayerMap[Agent].ClassNum = OneShotClassNumber):
                    if(not Target = InstiFC):
                        set IsHoldingAnItem = false
                        for(Conditional : OneShotConditionals):
                            if(Conditional.IsHoldingItem[Agent]):
                                set IsHoldingAnItem = true
                        if(IsHoldingAnItem = false):
                            spawn:
                                OneShotPlayer(Target,Agent)

    OneShotPlayer(Target : fort_character,Agent:agent)<suspends> : void=
        OneShotSound.Play(Agent)
        Target.Damage(1000.0)
