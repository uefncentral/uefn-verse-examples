# Unlockable Props Store
# A progressive unlock system where players can purchase creative props in sequence using gold currency. Players interact with a trigger to buy the next available item, with props moving between hidden 
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/unlockables-device-1?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }

purchase_data<public> := class<concrete>:
    @editable
    CreativeProps : []creative_prop = array{}

    @editable
    Price : int = 0

    @editable
    ClaimerName : string = ""

    @editable
    ClaimerLocation : vector3 = vector3{}

unlockables_device := class(creative_device):    
    @editable
    GoldConditionalButton : conditional_button_device = conditional_button_device{}

    @editable
    ClaimerTrigger : trigger_device = trigger_device{}

    @editable
    ClaimerBillboard : billboard_device = billboard_device{}

    @editable
    MoveOnZ : float = 1500.0

    @editable
    PurchaseDatas : []purchase_data = array{}

    TextForUI<localizes>(InText : string): message = "{InText}"

    var MaybeOwnerAgent : ?agent = false
    var CurrentPurchaseIndex : int = 0
    var bBlockTriggerInteraction : logic = false

    OnBegin<override>()<suspends>:void=
        Print("OnBegin")

        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerLeft)
        ClaimerTrigger.TriggeredEvent.Subscribe(OnClaimerTriggered)

        for (PurchaseData : PurchaseDatas):
            MoveProps(PurchaseData, false)

        if (FirstPurchase := PurchaseDatas[0]):
            MoveClaimerToPurchase(FirstPurchase)

    OnPlayerLeft(Agent : agent):void=
        if (OwnerAgent := MaybeOwnerAgent?, OwnerAgent = Agent):
            set MaybeOwnerAgent = false
            for (I := 0 .. CurrentPurchaseIndex-1, PurchaseData := PurchaseDatas[I]):
                MoveProps(PurchaseData, false)

            set CurrentPurchaseIndex = 0
            if (FirstPurchaseData := PurchaseDatas[0]):
                MoveClaimerToPurchase(FirstPurchaseData)

    AsyncEnableTriggerInteraction()<suspends>:void=
        Sleep(1.0)
        set bBlockTriggerInteraction = false

    MoveProps(PurchaseData : purchase_data, bMoveUp : logic):void=
        SignedMoveOnZ : float = if (bMoveUp = true)
        then MoveOnZ
        else -MoveOnZ

        for (CreativeProp : PurchaseData.CreativeProps):
            Transform := CreativeProp.GetTransform()
            var Location : vector3 = Transform.Translation
            set Location.Z += SignedMoveOnZ
            if (CreativeProp.TeleportTo[Location, Transform.Rotation]){}

    MoveClaimerToPurchase(PurchaseData : purchase_data):void=
        if (ClaimerTrigger.TeleportTo[PurchaseData.ClaimerLocation, IdentityRotation()]){}
        BillboardPriceString : string = if (PurchaseData.Price = 0)
        then "FREE"
        else "{PurchaseData.Price}"

        BillboardString : string = PurchaseData.ClaimerName + "\n" + BillboardPriceString
        ClaimerBillboard.SetText(TextForUI(BillboardString))

    OnClaimerTriggered(MaybeAgent : ?agent):void=
        if (Agent := MaybeAgent?, bBlockTriggerInteraction = false):
            if (OwnerAgent := MaybeOwnerAgent?):
                if (OwnerAgent <> Agent):
                    Print("Only the Owner Can Purchase!")
                    return
            else:
                set MaybeOwnerAgent = option{ Agent }

            OwnedGold : int = GoldConditionalButton.GetItemCount(Agent, 0)
            if (CurrentPurchaseData := PurchaseDatas[CurrentPurchaseIndex]):
                if (OwnedGold < CurrentPurchaseData.Price):
                    Print("Not Enough Money!")
                    return

                set bBlockTriggerInteraction = true
                spawn{ AsyncEnableTriggerInteraction() }

                MoveProps(CurrentPurchaseData, true)
                GoldConditionalButton.SetItemCountRequired(0, CurrentPurchaseData.Price)
                GoldConditionalButton.Activate(Agent)

                set CurrentPurchaseIndex += 1
                if (CurrentPurchaseIndex = PurchaseDatas.Length):
                    var Location : vector3 = ClaimerTrigger.GetTransform().Translation
                    set Location.Z -= MoveOnZ
                    if (ClaimerTrigger.TeleportTo[Location, IdentityRotation()]){}

                else if (NextPurchaseData := PurchaseDatas[CurrentPurchaseIndex]):
                    MoveClaimerToPurchase(NextPurchaseData)
