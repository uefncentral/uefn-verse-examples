# Interactive Progress Bar
# Creates a visual progress bar UI that fills from left to right over time while putting the player in stasis. When the progress bar completes, it triggers a device and releases the player from stasis. 
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/progressbar-1?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors/NamedColors }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters }

ProgressBarUI := class():
    var ProgressCanvas : canvas = canvas{}
    var BackgroundBar : color_block = color_block{DefaultColor := Black}
    var ProgressBarWid : color_block = color_block{DefaultColor := Red}
    var Trigger : trigger_device = trigger_device{}

    Initialize(Agent:agent): void=
        set ProgressCanvas = MakeUI()
        if(Player := player[Agent], PlayerUI := GetPlayerUI[Player] , FortChar := Agent.GetFortCharacter[]):
            FortChar.PutInStasis(stasis_args{})
            PlayerUI.AddWidget(ProgressCanvas)

        spawn{MoveUI(Agent)}


    MoveUI(Agent : agent)<suspends> : void=
        var XValue : float = 0.0
        loop:
            Sleep(0.0)
            set XValue += 4.0
            ProgressBarWid.SetVisibility(widget_visibility.Hidden)
            ProgressCanvas.RemoveWidget(ProgressBarWid)

            ProgressBarWid.SetVisibility(widget_visibility.Visible)
            ProgressCanvas.AddWidget(canvas_slot:
                Anchors := anchors{Minimum := vector2{X:= 0.5, Y:= 0.5}, Maximum := vector2{X:= 0.5, Y:= 0.5}}
                Offsets := margin{Left := -325.0, Top := -105.0, Right := XValue , Bottom := 70.0}
                Alignment := vector2{X:= 0.0, Y:= 0.5}
                SizeToContent := false
                ZOrder := 1
                Widget := ProgressBarWid
            )

            if(XValue >= 655.0):
                ProgressCanvas.RemoveWidget(ProgressBarWid)
                ProgressCanvas.RemoveWidget(BackgroundBar)
                Trigger.Trigger(Agent)
                if(FortChar := Agent.GetFortCharacter[]):
                    FortChar.ReleaseFromStasis()
                break



    MakeUI() : canvas=
        NewCanvas : canvas = canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:= 0.5, Y:= 0.5}, Maximum := vector2{X:= 0.5, Y:= 0.5}}
                    Offsets := margin{Left := 0.0, Top := -105.0, Right := 655.0 , Bottom := 70.0}
                    Alignment := vector2{X:= 0.5, Y:= 0.5}
                    SizeToContent := false
                    ZOrder := 0
                    Widget := BackgroundBar

                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X:= 0.5, Y:= 0.5}, Maximum := vector2{X:= 0.5, Y:= 0.5}}
                    Offsets := margin{Left := -325.0, Top := -105.0, Right := 0.0 , Bottom := 70.0}
                    Alignment := vector2{X:= 0.0, Y:= 0.5}
                    SizeToContent := false
                    ZOrder := 1
                    Widget := ProgressBarWid

ProgressBar := class(creative_device):


    @editable Button : button_device = button_device{}
    @editable Trigger: trigger_device = trigger_device{}
    OnBegin<override>()<suspends>:void=
        Button.InteractedWithEvent.Subscribe(OpenUI)


    OpenUI(Agent:agent) : void= 
        NewProgressBar := ProgressBarUI{Trigger := Trigger}
        NewProgressBar.Initialize(Agent)