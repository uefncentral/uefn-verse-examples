# Random Item Effect System
# Creates a random health effect system that triggers when players receive items from granter devices. When items are granted, players have a chance to either take random damage (5-50 HP) or receive hea
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/acid-nine-injure-player-device?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Playspaces }
using { /Verse.org/Simulation }
using { /Verse.org/Verse }
using { /Verse.org/Native }
using { /Verse.org/Random }

# This will injure/heal a player random hp after an item is granted and message the hud reflecting it
injure_player_device := class(creative_device):
    var randomNumber: int = 0 # Var to hold random number for effect chance
    var randomFloatHurt: float = 0.0 # Var to hold random float for hurt amount chance
    var randomFloatHeal: float = 0.0 # Var to hold random float for heal amount chance

    # The devices need to be created and added to the map in order to use them
    # Attach Item Granter Devices
    @editable
    WeaponsGranter:item_granter_device  = item_granter_device {}
    @editable
    ConsumablesGranter:item_granter_device  = item_granter_device {}
    @editable
    CactusGranter:item_granter_device  = item_granter_device {}
    
    # Attach HUD Devices
    @editable
    DamageHUD:hud_message_device = hud_message_device {}
    @editable
    HealHUD:hud_message_device = hud_message_device {}

    # Attach Movement Device
    @editable
    Knockback:movement_modulator_device = movement_modulator_device {}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=

            # Monitor Item Granter Devices
            WeaponsGranter.ItemGrantedEvent.Subscribe(OnItemGranted)
            ConsumablesGranter.ItemGrantedEvent.Subscribe(OnItemGranted)
            CactusGranter.ItemGrantedEvent.Subscribe(OnItemGranted)

    OnItemGranted(InPlayer:agent) : void =
        
        RandomNum:int =  GetRandomInt(0, 20) # Chance to occur
        RandomFloatHurt:float = GetRandomFloat(5.0, 50.0) # Amount to Hurt
        RandomFloatHeal:float = GetRandomFloat(1.0, 10.0) # Amount to Heal
        set randomNumber = RandomNum
        set randomFloatHurt = RandomFloatHurt
        set randomFloatHeal = RandomFloatHeal
        
        # Hurt Player
        if(randomNumber < 5):
            HurtPlayer(randomFloatHurt)
            Knockback.Activate(InPlayer)
            DamageHUD.Show(InPlayer)

        # Heal Player
        else if(randomNumber > 18):
            HealPlayer(randomFloatHeal)
            HealHUD.Show(InPlayer)

    
    CalculateDamage(PlayerHealth : float, DesiredDamageAmount : float, MinHealth : float) : float = 
        # If the damage amount would not eliminate the player, do that amount of damage
        if (PlayerHealth > DesiredDamageAmount):
            return DesiredDamageAmount
        else if (PlayerHealth > MinHealth):
            # Give player one more chance if their health is low
            return PlayerHealth - MinHealth
        else:
            # Eliminate player
            return PlayerHealth

    HurtPlayer(DamageAmount : float) : void =
        Playspace: fort_playspace = GetPlayspace()
        AllPlayers: []player = Playspace.GetPlayers()
        if (FirstPlayer : player = AllPlayers[0]):
            if (FortniteCharacter : fort_character = FirstPlayer.GetFortCharacter[]):
                MyCharacterHealth : float = FortniteCharacter.GetHealth()
                DamageToDo : float = CalculateDamage(MyCharacterHealth, DamageAmount, 1.0)
                FortniteCharacter.Damage(DamageToDo)
                Print("{DamageToDo} damage dealt to player")

    HealPlayer(HealAmount : float) : void =
        Playspace: fort_playspace = GetPlayspace()
        AllPlayers: []player = Playspace.GetPlayers()
        if (FirstPlayer : player = AllPlayers[0]):
            if (FortniteCharacter : fort_character = FirstPlayer.GetFortCharacter[]):
                FortniteCharacter.Heal(HealAmount)
