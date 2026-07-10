# Currency UI Display
# Creates a custom player class that manages and displays currency information (specifically 'Finishers') in a UI overlay. The system tracks player currency values and renders them in a positioned canva
# Difficulty: beginner  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/custom-player?ref=github

using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /Verse.org/Colors }
using { /UnrealEngine.com/Temporary/SpatialMath }

custom_player := class<unique>():
    Player : player
    var Finisher :int=0
    var Finisher_TW :text_block=text_block{DefaultTextColor := color{R:=255.0,G:=255.0,B:=255.0}}
    var Lapel_TW :text_block=text_block{DefaultTextColor := color{R:=255.0,G:=255.0,B:=255.0}}
    TextForUi<localizes>(_Finisher : int):message="{_Finisher}"
    LapelForUi<localizes>(Lapel :string):message="{Lapel} :"
    var OwnedPets:[]int=array{}

    CurrencyUI():void=
        if(PlayerUI := GetPlayerUI[Player]):
            Finisher_TW.SetText(TextForUi(Finisher))
            Lapel_TW.SetText(LapelForUi("FINISHERS"))
            MyOverLay := overlay :
                Slots := array:
                    overlay_slot:
                        Widget:=texture_block:
                            DefaultDesiredSize:=vector2{X:=230.000000,Y:=80.000000}
                            DefaultImage:=black_bg_final_
                        HorizontalAlignment := horizontal_alignment.Fill
                        VerticalAlignment := vertical_alignment.Fill
                    overlay_slot:
                        Widget:=GetCurrencyStackBox()
                        HorizontalAlignment := horizontal_alignment.Fill
                        VerticalAlignment := vertical_alignment.Fill
            MyCanvas:canvas=canvas:
                Slots:=array:
                    canvas_slot:
                        Alignment:= vector2{X:= 0.0,Y:=1.0}
                        Anchors:=anchors{Minimum := vector2{X:=0.046977,Y:=0.84569},Maximum := vector2{X:=0.046977,Y:=0.84569}}
                        Offsets:=margin{}
                        SizeToContent:= true
                        Widget:=MyOverLay
            PlayerUI.AddWidget(MyCanvas)

    GetCurrencyStackBox():stack_box=
        return stack_box:
            Orientation := orientation.Horizontal
            Slots:=array:
                stack_box_slot:
                    Padding:= margin{Top:=20.0,Bottom:=20.0,Left:= 20.0, Right :=20.0}
                    Widget:= Lapel_TW
                stack_box_slot:
                    Padding:= margin{Top:=20.0,Bottom:=20.0,Left:= 20.0, Right :=20.0}
                    Widget:= Finisher_TW