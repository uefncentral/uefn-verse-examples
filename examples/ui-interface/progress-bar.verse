# Custom Progress Bar UI
# Creates a customizable progress bar widget with configurable colors, orientation, size, and smooth animation. The progress bar consists of layered color blocks that can be oriented in different direct
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/progress-bar?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }

RightToLeft:tuple(horizontal_alignment, vertical_alignment) = (horizontal_alignment.Right, vertical_alignment.Fill)
LeftToRight:tuple(horizontal_alignment, vertical_alignment) = (horizontal_alignment.Left, vertical_alignment.Fill)
DownToUp:tuple(horizontal_alignment, vertical_alignment) = (horizontal_alignment.Fill, vertical_alignment.Bottom)
UpToDown:tuple(horizontal_alignment, vertical_alignment) = (horizontal_alignment.Fill, vertical_alignment.Top)

MakeProgressBar(InProgress:float, InOrientation:tuple(horizontal_alignment,vertical_alignment), InSize:vector2, InFrontColor:color, InBackColor:color, InSmoothUpdate:logic):progress_bar=
    return progress_bar{Progress:=InProgress, Orientation:=InOrientation, Size:=InSize, FrontColor:=InFrontColor, BackColor:=InBackColor, SmoothUpdate:=InSmoothUpdate}
    
progress_bar:=class:
    NewProgressUpdateEvent<private> : event() = event(){}

    var Progress:float = 0.0
    Orientation:tuple(horizontal_alignment, vertical_alignment)
    Size:vector2
    var FrontColor:color = color{}
    var BackColor:color = color{}
    var SmoothUpdate:logic = true

    var FrontColorBlock:color_block = color_block{}
    var AnimationColorBlock:color_block = color_block{}
    var BackColorBlock:color_block = color_block{}

    GetWidget():overlay=
        set FrontColorBlock=color_block{DefaultColor:=FrontColor, DefaultDesiredSize:=vector2{X:=0.0, Y:=0.0}}
        set AnimationColorBlock=color_block{DefaultColor:=MakeColorFromSRGBValues(190,190,190), DefaultDesiredSize:=vector2{X:=0.0, Y:=0.0}, DefaultOpacity:=0.5}
        set BackColorBlock=color_block{DefaultColor:=BackColor, DefaultDesiredSize:=Size}
        SetProgress(Progress)
        return overlay:
            Slots:=array:
                overlay_slot:
                    Widget:=BackColorBlock
                    HorizontalAlignment:=horizontal_alignment.Fill
                    VerticalAlignment:=vertical_alignment.Fill
                overlay_slot:
                    Widget:=AnimationColorBlock
                    HorizontalAlignment:=Orientation(0)
                    VerticalAlignment:=Orientation(1)
                overlay_slot:
                    Widget:=FrontColorBlock
                    HorizontalAlignment:=Orientation(0)
                    VerticalAlignment:=Orientation(1)
        
    SetProgress(InProgress:float):void=
        NewProgressUpdateEvent.Signal()
        if(SmoothUpdate = true):
            if(InProgress > Progress):
                AnimationColorBlock.SetDesiredSize(vector2{X:=Size.X*InProgress})
                spawn{UpdateBarLengthToProgressSmooth(FrontColorBlock, 0.3, InProgress)}
            else:
                FrontColorBlock.SetDesiredSize(vector2{X:=Size.X*InProgress})
                spawn{UpdateBarLengthToProgressSmooth(AnimationColorBlock, 0.3, InProgress)}
        else:
            FrontColorBlock.SetDesiredSize(vector2{X:=Size.X*InProgress})
        
        set Progress = InProgress

    UpdateBarLengthToProgressSmooth<private>(Block:color_block, InDuration:float, ProgressPercent:float)<suspends> : void =
        TargetBarLength := Size.X * ProgressPercent
        StartX := Block.GetDesiredSize().X
        EndTime := GetSimulationElapsedTime() + InDuration
        race:
            block:
                NewProgressUpdateEvent.Await()
                return
            loop:
                CurrentTime := GetSimulationElapsedTime()
                if (CurrentTime >= EndTime):
                    break
    
                t := (CurrentTime - (EndTime - InDuration)) / InDuration
    
                BezierFactor := (3*Pow(1.0-t, 2.0)*t*0.2) + (3*(1.0-t)*Pow(t, 2.0)*1) + Pow(t, 3.0)
    
                InterpolatedLength := Lerp(StartX, TargetBarLength, BezierFactor)
                Block.SetDesiredSize(vector2{ X := InterpolatedLength, Y := Size.Y })
                Sleep(0.0)
    
        Block.SetDesiredSize(vector2{ X := TargetBarLength, Y := Size.Y })
        
    GetProgress():float=Progress

    SetFrontColor(MyColor:color):void=
        set FrontColor = MyColor
        FrontColorBlock.SetColor(FrontColor)

    SetBackColor(MyColor:color):void=
        set BackColor = MyColor
        BackColorBlock.SetColor(BackColor)