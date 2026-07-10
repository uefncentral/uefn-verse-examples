# Custom Health Shield UI
# Creates a custom health and shield bar display system for players using UI widgets. The code initializes horizontal stack boxes with color blocks to represent health (green) and shield (light blue) ba
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/animatedhealth?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors/NamedColors }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Characters }

CustomHealth_Manager := class(creative_device):

    OnBegin<override>()<suspends>:void=
        for(Player : GetPlayspace().GetPlayers()):
            Initiate(Player)

        GetPlayspace().PlayerAddedEvent().Subscribe(Initiate)


    Initiate(Agent : agent) : void=
        var HealthStackBox : stack_box = stack_box{Orientation := orientation.Horizontal}
        var HealthFiller : color_block = color_block{DefaultOpacity := 0.0}
        var HealthBackgroundBar : color_block = color_block{DefaultColor := Black , DefaultOpacity := 0.5}
        var HealthBar : color_block = color_block{DefaultColor := Green , DefaultOpacity := 1.0}

        var ShieldStackBox : stack_box = stack_box{Orientation := orientation.Horizontal}
        var ShieldFiller : color_block = color_block{DefaultOpacity := 0.0}
        var ShieldBackgroundBar : color_block = color_block{DefaultColor := Black , DefaultOpacity := 0.5}
        var ShieldBar : color_block = color_block{DefaultColor := LightBlue , DefaultOpacity := 1.0}

        HealthStackBox.AddWidget(
            stack_box_slot:
                Widget := HealthBar
                HorizontalAlignment := horizontal_alignment.Fill
                VerticalAlignment := vertical_alignment.Fill
                Distribution := option{1.0}
        )
        HealthStackBox.AddWidget(
            stack_box_slot:
                Widget := HealthFiller
                HorizontalAlignment := horizontal_alignment.Fill
                VerticalAlignment := vertical_alignment.Fill
        )

        ShieldStackBox.AddWidget(
            stack_box_slot:
                Widget := ShieldBar
                HorizontalAlignment := horizontal_alignment.Fill
                VerticalAlignment := vertical_alignment.Fill
                Distribution := option{1.0}
        )
        ShieldStackBox.AddWidget(
            stack_box_slot:
                Widget := ShieldFiller
                HorizontalAlignment := horizontal_alignment.Fill
                VerticalAlignment := vertical_alignment.Fill
        )


        if(Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
            NewCanvas := canvas:
                Slots := array:
                    canvas_slot:
                        Widget := HealthBackgroundBar
                        Anchors := anchors{Minimum := vector2{X:=0.0, Y:= 1.0} , Maximum := vector2{X:=0.0, Y:= 1.0}}
                        Offsets := margin{Left := 132.0, Top := -190.0, Right := 386.0, Bottom := 35.0}
                        Alignment := vector2{X:= 0.0, Y:= 0.0}
                        ZOrder := 0
                        SizeToContent := false
                    canvas_slot:
                        Widget := HealthStackBox
                        Anchors := anchors{Minimum := vector2{X:=0.0, Y:= 1.0} , Maximum := vector2{X:=0.0, Y:= 1.0}}
                        Offsets := margin{Left := 132.0, Top := -190.0, Right := 386.0, Bottom := 35.0}
                        Alignment := vector2{X:= 0.0, Y:= 0.0}
                        ZOrder := 1
                        SizeToContent := false

                    canvas_slot:
                        Widget := ShieldBackgroundBar
                        Anchors := anchors{Minimum := vector2{X:=0.0, Y:= 1.0} , Maximum := vector2{X:=0.0, Y:= 1.0}}
                        Offsets := margin{Left := 132.0, Top := -250.0, Right := 386.0, Bottom := 35.0}
                        Alignment := vector2{X:= 0.0, Y:= 0.0}
                        ZOrder := 0
                        SizeToContent := false

                    canvas_slot:
                        Widget := ShieldStackBox
                        Anchors := anchors{Minimum := vector2{X:=0.0, Y:= 1.0} , Maximum := vector2{X:=0.0, Y:= 1.0}}
                        Offsets := margin{Left := 132.0, Top := -250.0, Right := 386.0, Bottom := 35.0}
                        Alignment := vector2{X:= 0.0, Y:= 0.0}
                        ZOrder := 1
                        SizeToContent := false

            PlayerUI.AddWidget(NewCanvas)
            spawn:
                TrackPlayerHealth(Agent, NewCanvas, HealthFiller, ShieldFiller)


    TrackPlayerHealth(Agent : agent, Canvas : canvas, HPFiller : color_block, ShieldFiller : color_block)<suspends> : void=
        if(FC := Agent.GetFortCharacter[]):
            var CustomHealth : float = FC.GetHealth()
            var CustomShield : float = FC.GetShield()
            race:
                block:
                    loop:
                        LeavingPlayer := GetPlayspace().PlayerRemovedEvent().Await()
                        if(LeavingPlayer = Agent):
                            break

                block:
                    loop:
                        Sleep(0.0)
                        if(CustomHealth > FC.GetHealth()):
                            set CustomHealth -= 1.0
                        else if(CustomHealth < FC.GetHealth()):
                            set CustomHealth += 1.0
                        
                        if(CustomShield > FC.GetShield()):
                            set CustomShield -= 1.0
                        else if(CustomShield < FC.GetShield()):
                            set CustomShield += 1.0
                loop:
                    Sleep(0.0)
                    HealthPercentage := CustomHealth / 100.0
                    ShieldPercentage := CustomShield / 100.0
                    NewHPXValue := 386.0 - (386.0 * HealthPercentage)
                    NewShieldXValue := 386.0 - (386.0 * ShieldPercentage)
                    HPFiller.SetDesiredSize(vector2{X:= NewHPXValue , Y:= 0.0})
                    ShieldFiller.SetDesiredSize(vector2{X:= NewShieldXValue , Y:= 0.0})
