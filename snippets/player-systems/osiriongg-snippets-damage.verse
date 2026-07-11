# Movement Detection Damage
# Monitors the first player's movement over a 10-second period and applies 50 damage if they move less than 10,000 units. This creates a 'move or die' mechanic that encourages player activity.  **How to
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/osiriongg-snippets-damage?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Playspaces }
using { /UnrealEngine.com/Temporary/SpatialMath }

hello_world_device := class(creative_device):

# Runs when the device is started in a running game
OnBegin<override>()<suspends>:void=

    Playspace:fort_playspace = GetPlayspace()
    AllPlayers:[]player = Playspace.GetPlayers()
    
    var FirstPosition:transform = transform{}
    var SecondPosition:transform = transform{}
    
    if:
        Player:player = AllPlayers[0]
        FortniteCharacter:fort_character = Player.GetFortCharacter[]
        set FirstPosition = FortniteCharacter.GetTransform()
    then:
        Print("Move or prepare to take damage!")
        Sleep(10.0)
    
    if:
        Player : player = AllPlayers[0]
        FortniteCharacter : fort_character = Player.GetFortCharacter[]
        set SecondPosition = FortniteCharacter.GetTransform()
        DistanceBetweenPositions: float = DistanceXY(FirstPosition.Translation, SecondPosition.Translation)
        DistanceBetweenPositions < 10000.0
    then:
        Print("Distance Moved: {DistanceBetweenPositions}")
        Print("Applying Damage")
        HurtPlayer(50.0)

# Functions From Previous Lessons
#################################

HurtPlayer(DamageAmount : float):void=
    Playspace: fort_playspace = GetPlayspace()
    AllPlayers: []player = Playspace.GetPlayers()
    if (Player : player = AllPlayers[0]):
        if (FortniteCharacter : fort_character = Player.GetFortCharacter[]):
            MyCharacterHealth : float = FortniteCharacter.GetHealth()
            DamageToDo : float = CalculateDamage(MyCharacterHealth, DamageAmount, 1.0)
            Print("Damage To Do: {DamageToDo}")
            FortniteCharacter.Damage(DamageToDo)

CalculateDamage(PlayerHealth:float, DesiredDamageAmount:float, MinHealth:float):float = 
    # If the damage amount would not eliminate the player, do that amount of damage
    if (PlayerHealth > DesiredDamageAmount):
        return DesiredDamageAmount
    else if (PlayerHealth > MinHealth):
        # Give player one more chance if their health is low
        return PlayerHealth - MinHealth
    else:
        # Eliminate player
        return PlayerHealth