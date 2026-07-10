# NPC Player Tracking System
# Creates an NPC that automatically rotates to face and moves toward the nearest player. The system uses creative props for rotation and translation with configurable movement speed and maximum tracking
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/npc?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath}

# A Verse-authored creative device that can be placed in a level
npc := class(creative_device):

    @editable
    RotationProp<private> : creative_prop = creative_prop{}
    @editable
    TranslationProp<private> : creative_prop = creative_prop{}
    @editable
    UnitsPerSecond<private> : float = 100.0
    @editable
    MaxDistanceToPlayer<private> : float = 25.0

    var MaybePlayer<private> : ?player = false
    var  IsMoving<private> : logic = false
    

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        StorePlayerReference()
        loop:
            RotateToPlayer()
            Sleep(0.0)
            if:
                not IsMoving?
            then:
                set IsMoving = true
                spawn{MoveToPlayer()}
        # TODO: Replace this with your code
        Print("Hello, world!")
        Print("2 + 2 = {2 + 2}")

    StorePlayerReference() : void = 
        if:
            Player : player = Self.GetPlayspace().GetPlayers()[0]
        then:
            set MaybePlayer = option{Player}    
    RotateToPlayer() : void =
        if:
            FortCharacter : fort_character = MaybePlayer?.GetFortCharacter[]
        then:
            PlayerTranslation : vector3 = FortCharacter.GetTransform().Translation
            CurrentTranslation : vector3 = TranslationProp.GetTransform().Translation
            
            # Calculates the rotation to the player.
            VectorToPlayer : vector3 = FortCharacter.GetTransform().Translation
            RadiansToPlayer : float = ArcTan(VectorToPlayer.X, VectorToPlayer.Y)
            RotationAxis := vector3:
                X := 0.0,
                Y := 0.0,
                Z := -1.0
            NewRotation : rotation = MakeRotation(RotationAxis, RadiansToPlayer)
            
            # Looks at Player.
            if (RotationProp.TeleportTo[CurrentTranslation, NewRotation]) {}
    
    MoveToPlayer()<suspends> : void =
        defer:
            set IsMoving = false
        if:
            FortCharacter : fort_character = MaybePlayer?.GetFortCharacter[]
        then:
            PlayerTranslation : vector3 = 
                FortCharacter.GetTransform().Translation
            CurrentTranslation : vector3 =
                TranslationProp.GetTransform().Translation
            CurrentRotation : rotation =
                TranslationProp.GetTransform().Rotation
            TranslationToPlayer := vector3
                X := PlayerTranslation.X
                Y := PlayerTranslation.Y
                Z := CurrentTranslation.Z        

            DistanceToPlayer : float = 
                Distance(CurrentTranslation, PlayerTranslation)
                
            if:
                # Doesn't move if Player is inside its range.
                DistanceToPlayer > MaxDistanceToPlayer
            then:
                # Moves TranslationProp to he Player's translation.
                TranslationProp.MoveTo(
                   PlayerTranslation,
                   CurrentRotation,
                   DistanceToPlayer / UnitsPerSecond
                )
                          
                    