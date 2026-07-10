# Unlockable Props Purchase System
# Creates a purchase system where players can buy unlockable props using in-game currency. The system manages multiple purchasable items with prices, prerequisites, and visual feedback through billboard
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/unlockables-v2-device?ref=github

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
    PurchasesToOpen : []int = array{}

    @editable
    ClaimerTrigger : trigger_device = trigger_device{}

    @editable
    ClaimerBillboard : billboard_device = billboard_device{}

    var ClaimerFirstZ : float = 0.0

    var MaybeMainDevice : ?unlockables_device = false

    var Index : int = -1

    OnClaimerTriggered(MaybeAgent : ?agent):void=
        if (Agent := MaybeAgent?, MainDevice := MaybeMainDevice?):
            MainDevice.OnClaimerTriggered(Agent, Self, Index)

unlockables_device := class(creative_device):    
    @editable
    GoldConditionalButton : conditional_button_device = conditional_button_device{}

    @editable
    MoveOnZ : float = 1500.0

    @editable
    PurchaseDatas : []purchase_data = array{}

    TextForUI<localizes>(InText : string): message = "{InText}"

    var PurchasedIndexes : []int = array{}
    var MaybeOwnerAgent : ?agent = false
    var bBlockTriggerInteraction : logic = false

    OnBegin<override>()<suspends>:void=
        Print("OnBegin")

        GetPlayspace().PlayerRemovedEvent().Subscribe(OnPlayerLeft)
        for (PurchaseData : PurchaseDatas):            
            PurchaseData.ClaimerTrigger.TriggeredEvent.Subscribe(PurchaseData.OnClaimerTriggered)

        for (I := 0..PurchaseDatas.Length-1, PurchaseData := PurchaseDatas[I]):
            set PurchaseData.MaybeMainDevice = option{ Self }
            set PurchaseData.Index = I
            set PurchaseData.ClaimerFirstZ = PurchaseData.ClaimerTrigger.GetTransform().Translation.Z

        for (PurchaseData : PurchaseDatas):
            MoveProps(PurchaseData, false)

        if (FirstPurchase := PurchaseDatas[0]):
            OpenClaimerOfPurchase(FirstPurchase)

    OnPlayerLeft(Agent : agent):void=
        if (OwnerAgent := MaybeOwnerAgent?, OwnerAgent = Agent):
            set MaybeOwnerAgent = false
            for (PurchasedIndex : PurchasedIndexes, PurchaseData := PurchaseDatas[PurchasedIndex]):
                MoveProps(PurchaseData, false)

            if (FirstPurchaseData := PurchaseDatas[0]):
                OpenClaimerOfPurchase(FirstPurchaseData)

            set PurchasedIndexes = array{}

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

        var ClaimerLoc : vector3 = PurchaseData.ClaimerTrigger.GetTransform().Translation
        set ClaimerLoc.Z = PurchaseData.ClaimerFirstZ - MoveOnZ
        if (PurchaseData.ClaimerTrigger.TeleportTo[ClaimerLoc, IdentityRotation()]){}

        PurchaseData.ClaimerTrigger.Disable()
        PurchaseData.ClaimerBillboard.SetText(TextForUI(""))
        PurchaseData.ClaimerBillboard.HideText()

    OpenClaimerOfPurchase(PurchaseData : purchase_data):void=
        var ClaimerLoc : vector3 = PurchaseData.ClaimerTrigger.GetTransform().Translation
        set ClaimerLoc.Z = PurchaseData.ClaimerFirstZ
        if (PurchaseData.ClaimerTrigger.TeleportTo[ClaimerLoc, IdentityRotation()]){}

        PurchaseData.ClaimerTrigger.Enable()

        BillboardPriceString : string = if (PurchaseData.Price = 0)
        then "FREE"
        else "{PurchaseData.Price}"

        BillboardString : string = PurchaseData.ClaimerName + "\n" + BillboardPriceString
        PurchaseData.ClaimerBillboard.SetText(TextForUI(BillboardString))
        PurchaseData.ClaimerBillboard.ShowText()

    OnClaimerTriggered(Agent : agent, CurrentPurchaseData : purchase_data, PurchaseIndex : int):void=
        if (bBlockTriggerInteraction = false):
            if (OwnerAgent := MaybeOwnerAgent?):
                if (OwnerAgent <> Agent):
                    Print("Only the Owner Can Purchase!")
                    return
            else:
                set MaybeOwnerAgent = option{ Agent }

            OwnedGold : int = GoldConditionalButton.GetItemCount(Agent, 0)
            if (OwnedGold < CurrentPurchaseData.Price):
                Print("Not Enough Money!")
                return

            set bBlockTriggerInteraction = true
            spawn{ AsyncEnableTriggerInteraction() }

            MoveProps(CurrentPurchaseData, true)
            GoldConditionalButton.SetItemCountRequired(0, CurrentPurchaseData.Price)
            GoldConditionalButton.Activate(Agent)

            set PurchasedIndexes += array{ PurchaseIndex }

            for (PurchaseIndexToOpen : CurrentPurchaseData.PurchasesToOpen,
            PurchaseToOpen := PurchaseDatas[PurchaseIndexToOpen]):
                OpenClaimerOfPurchase(PurchaseToOpen)