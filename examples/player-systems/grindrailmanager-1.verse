# RGB Grind Rail Effect
# Creates a dynamic RGB color-cycling effect on a grind rail that activates when a player starts grinding and stops when they finish. The rail continuously cycles through rainbow colors while being used
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/grindrailmanager-1?ref=github

using { /Fortnite.com/Characters }

using { /Fortnite.com/Devices }

using { /Fortnite.com/Devices/CreativeAnimation }

using { /Fortnite.com/Devices/CreativeAnimation/InterpolationTypes }

using { /Verse.org/Simulation }

using { /Verse.org/Colors }

using { /UnrealEngine.com/Temporary/Diagnostics }

using { /UnrealEngine.com/Temporary/SpatialMath }



GameManagerssss := class(creative_device):





    @editable

    GrindRail:grind_rail_device = grind_rail_device{}



    @editable

    DisablePatchWorkTrigger:trigger_device = trigger_device{}



    @editable

    EnablePatchWorkTrigger:trigger_device = trigger_device{}



    var DoingRGB:logic = false



    OnBegin<override>()<suspends>:void=





        GrindRail.StartedGrindingEvent.Subscribe(OnStartGrinding)

        GrindRail.EndedGrindingEvent.Subscribe(OnEndGrinding)





        





    OnStartGrinding(Agent:agent):void=

        if(DoingRGB = false):

            set DoingRGB = true

            EnablePatchWorkTrigger.Trigger()

            spawn:

                MakeGrindRailRGB()



        



    OnEndGrinding(Agent:agent):void=

        set DoingRGB = false

        DisablePatchWorkTrigger.Trigger()







    MakeGrindRailRGB()<suspends>:void=

        

        DelayTime:float = 0.1

        loop:

            if(DoingRGB = true):

                var C:color = color{R:=0.0, G:=0.0, B:=0.0}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=0.1, G:=0.0, B:=0.0}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=0.2, G:=0.0, B:=0.0}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=0.3, G:=0.0, B:=0.0}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=0.4, G:=0.0, B:=0.0}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=0.5, G:=0.0, B:=0.0}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=0.6, G:=0.0, B:=0.0}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=0.7, G:=0.0, B:=0.0}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=0.8, G:=0.0, B:=0.0}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=0.9, G:=0.0, B:=0.0}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=1.0, G:=0.0, B:=0.0}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=1.0, G:=0.1, B:=0.0}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=1.0, G:=0.2, B:=0.0}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=1.0, G:=0.3, B:=0.0}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=1.0, G:=0.4, B:=0.0}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=1.0, G:=0.5, B:=0.0}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=1.0, G:=0.6, B:=0.0}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=1.0, G:=0.7, B:=0.0}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=1.0, G:=0.8, B:=0.0}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=1.0, G:=0.9, B:=0.0}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=1.0, G:=1.0, B:=0.0}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=0.8, G:=1.0, B:=0.0}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=0.6, G:=1.0, B:=0.0}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=0.4, G:=1.0, B:=0.0}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=0.2, G:=1.0, B:=0.0}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=0.0, G:=1.0, B:=0.0}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=0.0, G:=1.0, B:=0.2}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=0.0, G:=1.0, B:=0.4}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=0.0, G:=1.0, B:=0.6}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=0.0, G:=1.0, B:=0.8}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=0.0, G:=1.0, B:=1.0}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=0.0, G:=0.8, B:=1.0}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=0.0, G:=0.6, B:=1.0}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=0.0, G:=0.4, B:=1.0}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=0.0, G:=0.2, B:=1.0}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=0.0, G:=0.0, B:=1.0}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=0.2, G:=0.0, B:=1.0}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=0.4, G:=0.0, B:=1.0}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=0.6, G:=0.0, B:=1.0}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=0.8, G:=0.0, B:=1.0}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

                set C = color{R:=1.0, G:=0.0, B:=1.0}

                GrindRail.SetRailColor(C)

                Sleep(DelayTime)

            else:

                break