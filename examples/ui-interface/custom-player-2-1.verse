# Custom Player 2
# Verse code for Custom Player 2 - UEFN/Fortnite Creative implementation
# Difficulty: intermediate  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/custom-player-2-1?ref=github


using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }

custom_player := class<unique>():
    Player : player

    var NbMoney : int = 0
    var LaClasse : int = -1
    var NbMoneyToAdd : int = 0

    UITextMoney<localizes>(pValue : int) : message = "${pValue}"
    var TextWidgetMoney<private> : button_quiet = button_quiet{}

    Init() : void=
        if:
            lAgent := agent[Player]
        then:
            InitUI()

    InitUI<private>() : void=
        NewCanvas : canvas = canvas:
            Slots := array :
                canvas_slot:
                    Widget := TextWidgetMoney
                    Anchors := anchors{ Minimum := vector2{ X := 0.015, Y := 0.5}, Maximum := vector2{ X := 0.015, Y := 0.5} }
                    Offsets := margin{Top := 0.5, Left := 0.0, Right := 0.4, Bottom := 0.0}
                    Alignment := vector2{X := 0.0, Y := 0.0}
                    SizeToContent := true

        if (lPlayerUI := GetPlayerUI[Player], set NbMoney = 0) :
            lPlayerUI.AddWidget(NewCanvas)
            TextWidgetMoney.SetText(UITextMoney(0))

    SetPlayerMoney(pMoney : int) : void=
        set NbMoney = pMoney

    GetPlayerMoney() : int=
        return NbMoney

    SetUIPlayerMoney(pMoney : int) : void=
        TextWidgetMoney.SetText(UITextMoney(pMoney))

    SetClass(pClass : int) : void=
        set LaClasse = pClass

    GetClass() : int=
        return LaClasse

    SetMoneyToAdd(pMoney : int) : void=
        set NbMoneyToAdd = pMoney
        
    GetMoneyToAdd() : int=
        return NbMoneyToAdd    

