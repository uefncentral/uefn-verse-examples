# Petsdevice
# Verse code for Petsdevice - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/petsdevice?ref=github

using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices/CreativeAnimation }
using { /Fortnite.com/Devices/CreativeAnimation/InterpolationTypes }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

agent_data := class:
    var OwnedPets : []tuple(creative_prop, int) = array{}
    var ActivePetIndex : int = -1
    var bPetPlayingAnim : logic = false

pet_purchase_data := class<concrete>:

    @editable
    ButtonForPurchase : button_device = button_device{}

    @editable
    PetPrice : int = 0

    @editable
    PetProps : []creative_prop = array{}

    var Index : int = -1
    var MaybeMainDevice : ?pets_device = false
    var AvailablePetProps : []logic = array{}

    OnPurchase(Agent : agent):void=
        if (MainDevice := MaybeMainDevice?):
            MainDevice.OnPetPurchase(Agent, Self)

pets_device := class(creative_device):
    @editable
    GoldConditionalButton : conditional_button_device = conditional_button_device{}

    @editable
    PlayerSpawners : []player_spawner_device = array{}

    @editable
    PetPurchasesData : []pet_purchase_data = array{}

    @editable
    NotEnoughGoldMessage : hud_message_device = hud_message_device{}

    @editable
    PetPurchaseAudioPlayers : []audio_player_device = array{}  # NEW

    var AgentMap : [agent]agent_data = map{}
    var IdleAnimationKeyFrames : []keyframe_delta = array{}

    OnBegin<override>()<suspends>:void=

        for (PlayerSpawner : PlayerSpawners):
            PlayerSpawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

        for (I := 0 .. PetPurchasesData.Length-1, PetPurchaseData := PetPurchasesData[I]):
            for (J := 0 .. PetPurchaseData.PetProps.Length-1, PetProp := PetPurchaseData.PetProps[J]):
                PetProp.Hide()
                set PetPurchaseData.AvailablePetProps += array{ true }

            set PetPurchaseData.MaybeMainDevice = option{ Self }
            set PetPurchaseData.Index = I

            PetPurchaseData.ButtonForPurchase.InteractedWithEvent.Subscribe(PetPurchaseData.OnPurchase)

        UpMovementKeyFrame : keyframe_delta = keyframe_delta
        {
            DeltaLocation := vector3{ X := 0.0, Y := 0.0, Z := 30.0 }
            DeltaRotation := IdentityRotation()
            DeltaScale := vector3{ X := 1.0, Y := 1.0, Z := 1.0 }
            Time := 0.85
            Interpolation := Ease
        }
        DownMovementKeyFrame : keyframe_delta = keyframe_delta
        {
            DeltaLocation := vector3{ X := 0.0, Y := 0.0, Z := -30.0 }
            DeltaRotation := IdentityRotation()
            DeltaScale := vector3{ X := 1.0, Y := 1.0, Z := 1.0 }
            Time := 0.85
            Interpolation := Ease
        }

        set IdleAnimationKeyFrames = array
        {
            UpMovementKeyFrame, DownMovementKeyFrame
        }

        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerLeft)

        spawn{AsyncPetFollow()}

    OnPlayerSpawned(Agent : agent):void=
        if:
            not AgentMap[Agent]
            set AgentMap[Agent] = agent_data{}

    OnPlayerLeft(Player : player):void=
        if (AgentData := AgentMap[Player]):
            for (OwnedPetTuple : AgentData.OwnedPets):
                PetProp : creative_prop = OwnedPetTuple(0)
                PetPurchaseDataIndex : int = OwnedPetTuple(1)

                PetProp.Hide()
                if (PetPurchaseData := PetPurchasesData[PetPurchaseDataIndex]):
                    var I : int = 0
                    loop:
                        if (Availability : logic = PetPurchaseData.AvailablePetProps[I]):
                            if (Availability = false):
                                if (set PetPurchaseData.AvailablePetProps[I] = true){}
                                break
                        else:
                            break

                        set I += 1

    OnPetPurchase(Agent : agent, PetPurchaseData : pet_purchase_data):void=
        var FoundPetIndex : int = -1
        if (AgentData := AgentMap[Agent]):
            for (I := 0 .. AgentData.OwnedPets.Length-1, OwnedPetTuple := AgentData.OwnedPets[I]):
                PetPurchaseIndex : int = OwnedPetTuple(1)
                if (PetPurchaseIndex = PetPurchaseData.Index):
                    set FoundPetIndex = I

        if (FoundPetIndex = -1):
            var AvailablePetPropIndex : int = -1
            for (I := 0 .. PetPurchaseData.AvailablePetProps.Length-1, AvailablePetProp := PetPurchaseData.AvailablePetProps[I]):
                if (AvailablePetProp = true):
                    set AvailablePetPropIndex = I

            if (AvailablePetPropIndex = -1):
                return

            OwnedGold : int = GoldConditionalButton.GetItemCount(Agent, 0)
            if (OwnedGold < PetPurchaseData.PetPrice):
                NotEnoughGoldMessage.Show(Agent)
                return

            GoldConditionalButton.SetItemCountRequired(0, PetPurchaseData.PetPrice)
            GoldConditionalButton.Activate(Agent)
            if (set PetPurchaseData.AvailablePetProps[AvailablePetPropIndex] = false){}

            if (PetProp : creative_prop = PetPurchaseData.PetProps[AvailablePetPropIndex],
            AgentData := AgentMap[Agent]):
                PetTuple : tuple(creative_prop, int) = (PetProp, PetPurchaseData.Index)
                set AgentData.OwnedPets += array{PetTuple}
                set FoundPetIndex = AgentData.OwnedPets.Length-1

        if (AgentData := AgentMap[Agent]):
            if (PetPropTuple := AgentData.OwnedPets[AgentData.ActivePetIndex]):
                PetProp := PetPropTuple(0)
                PetProp.Hide()

            set AgentData.ActivePetIndex = FoundPetIndex
            if (PetPropTuple := AgentData.OwnedPets[AgentData.ActivePetIndex]):
                PetProp := PetPropTuple(0)
                PetProp.Show()

                if (FortCharacter := Agent.GetFortCharacter[]):
                    var TeleportLoc : vector3 = FortCharacter.GetTransform().Translation
                    set TeleportLoc.X += 50.0
                    if (PetProp.TeleportTo[TeleportLoc, IdentityRotation()]){}

            set AgentData.bPetPlayingAnim = false

            # --- PLAY AUDIO ON PURCHASE ---
            if (AudioPlayer := PetPurchaseAudioPlayers[PetPurchaseData.Index]):
                AudioPlayer.Play(Agent)

    AsyncPetFollow()<suspends>:void=
        FollowDistance : float = 200.0
        WaitDistance : float = 150.0
        SleepTime : float = 0.2

        loop:
            Sleep(SleepTime)
            for (Player : GetPlayspace().GetPlayers(), AgentData := AgentMap[Player],
            PetPropTuple := AgentData.OwnedPets[AgentData.ActivePetIndex], FortCharacter := Player.GetFortCharacter[]):
                PetProp : creative_prop = PetPropTuple(0)

                PetLoc : vector3 = PetProp.GetTransform().Translation
                PlayerLoc : vector3 = FortCharacter.GetTransform().Translation
                DistanceToPlayer : float = Distance(PetLoc, PlayerLoc)

                if (DistanceToPlayer >= FollowDistance):
                    if (Direction := (PlayerLoc - PetLoc).MakeUnitVector[]):
                        DistanceToTravel : float = DistanceToPlayer - WaitDistance
                        var LocationToTravel : vector3 = PetLoc + (Direction * DistanceToTravel)

                        set AgentData.bPetPlayingAnim = false

                        if (PropAnimController := PetProp.GetAnimationController[]):
                            PropAnimController.Stop()

                        PlayerRotation := FortCharacter.GetTransform().Rotation
                        spawn{ PetProp.MoveTo(LocationToTravel, PlayerRotation, SleepTime) }
                else:
                    if (AgentData.bPetPlayingAnim = false):
                        set AgentData.bPetPlayingAnim = true
                        if (PropAnimController := PetProp.GetAnimationController[]):
                            PropAnimController.SetAnimation(IdleAnimationKeyFrames, ?Mode := animation_mode.Loop)
                            PropAnimController.Play()