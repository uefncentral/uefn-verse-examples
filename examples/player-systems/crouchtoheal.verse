# Crouch To Heal
# Players with a specific class number can heal by crouching. The system supports healing health only, shield only, or both depending on configuration settings.  **How to use:** Add CrouchToHeal device 
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/crouchtoheal?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }

CrouchToHeal := class(creative_device):
    @editable GameStartDevice : GameStart = GameStart{}
    @editable CrouchToHealClassNumber : int = 100

    @editable CrouchToHealVFX : vfx_spawner_device = vfx_spawner_device{}
    @editable CrouchToHealSound : audio_player_device = audio_player_device{}
    @editable AmountToHeal : float = 0.0

    @editable CrouchToHealSetting : int = 0
    #if 1 : Able to Heal both health and shield
    #if 2 : Only heals shield
    #if 3 : only heals health



    OnBegin<override>()<suspends>:void=
        Sleep(3.0)
        for (Player : GetPlayspace().GetPlayers()):
            if(FC := Player.GetFortCharacter[], Agent := FC.GetAgent[]):
                if(GameStartDevice.EachPlayerMap[Agent].ClassNum = CrouchToHealClassNumber):
                    spawn:
                        CrouchToHealPlayer(Agent)
    CrouchToHealPlayer(Agent:agent) <suspends>: void=
        if(Player := player[Agent] , FC:= Player.GetFortCharacter[]):
            FC.CrouchedEvent().Subscribe(OnCrouch)
    OnCrouch(FC : fort_character, IsCrouched : logic) : void=
        if(Agent := FC.GetAgent[]):
            if(IsCrouched?):
                PlayerPos := FC.GetTransform().Translation
                if(CrouchToHealVFX.TeleportTo[PlayerPos,IdentityRotation()]){}
                CrouchToHealVFX.Enable()
                CrouchToHealSound.Play(Agent)


                SheildAmount := FC.GetShield()
                HealthAmount := FC.GetHealth()
                if(CrouchToHealSetting = 1):
                    if(SheildAmount > 0.0):
                        FC.SetShield(SheildAmount + AmountToHeal)
                    else if(SheildAmount = 0.0 and HealthAmount < 100.0):
                        FC.Heal(AmountToHeal)
                    else:
                        FC.SetShield(SheildAmount + AmountToHeal)
                else if(CrouchToHealSetting = 2):
                    FC.SetShield(SheildAmount + AmountToHeal)
                else if(CrouchToHealSetting = 3):
                    FC.Heal(AmountToHeal)
            else:
                
        
