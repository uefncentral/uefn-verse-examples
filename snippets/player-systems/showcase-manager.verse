# Interactive Settings Showcase Manager
# A demonstration system that provides interactive controls for testing various game settings and UI features. It uses switches to toggle different display options like hovering ranks, total scores, and
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/showcase-manager?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }
using { /Verse.org/Random }
using { /Verse.org/Colors }

showcase_manager := class(creative_device):

    @editable PointsOnElimSwitch:switch_device = switch_device{}
    @editable PointsOnDeathSwitch:switch_device = switch_device{}
    @editable HoveringRanksSwitch:switch_device = switch_device{}
    @editable ShowTotalScoreSwitch:switch_device = switch_device{}
    @editable ProgressBarStyleSwitch:switch_device = switch_device{}
    @editable ProgressBarTypeSwitch:switch_device = switch_device{}
    @editable ProgressBarCountSwitch:switch_device = switch_device{}
    @editable ProgressBarSmoothSwitch:switch_device = switch_device{}

    @editable UpScoreButton:button_device = button_device{}
    @editable DownScoreButton:button_device = button_device{}

    @editable AddKillButton:button_device = button_device{}
    @editable AddDeathButton:button_device = button_device{}

    OnBegin<override>()<suspends>:void=
        UpScoreButton.InteractedWithEvent.Subscribe(UpScoreButtonInteractedWith)
        DownScoreButton.InteractedWithEvent.Subscribe(DownScoreButtonInteractedWith)

        AddKillButton.InteractedWithEvent.Subscribe(AddKillButtonInteractedWith)
        AddDeathButton.InteractedWithEvent.Subscribe(AddDeathButtonInteractedWith)

        PointsOnElimSwitch.StateChangesEvent.Subscribe(TogglePointsOnElim)
        PointsOnDeathSwitch.StateChangesEvent.Subscribe(TogglePointsOnDeath)

        HoveringRanksSwitch.StateChangesEvent.Subscribe(ToggleHoveringRanks)
        ShowTotalScoreSwitch.StateChangesEvent.Subscribe(ToggleTotalScore)
        ProgressBarStyleSwitch.StateChangesEvent.Subscribe(ToggleProgressBarStyle)
        ProgressBarTypeSwitch.StateChangesEvent.Subscribe(ToggleProgressBarType)
        ProgressBarCountSwitch.StateChangesEvent.Subscribe(ToggleProgressBarCount)
        ProgressBarSmoothSwitch.StateChangesEvent.Subscribe(ToggleProgressBarSmooth)


    TogglePointsOnElim():void=
        if(TaggedObject:=GetCreativeObjectsWithTag(PlacementManagerTag{})[0], PM:=placement_manager[TaggedObject]):
            PM.TogglePointsOnElim()

    TogglePointsOnDeath():void=
        if(TaggedObject:=GetCreativeObjectsWithTag(PlacementManagerTag{})[0], PM:=placement_manager[TaggedObject]):
            PM.TogglePointsOnDeath()

    ToggleHoveringRanks():void=
        if(TaggedObject:=GetCreativeObjectsWithTag(PlacementManagerTag{})[0], PM:=placement_manager[TaggedObject]):
            PM.ToggleHoveringRanks()

    ToggleProgressBarStyle():void=
        if(TaggedObject:=GetCreativeObjectsWithTag(PlacementManagerTag{})[0], PM:=placement_manager[TaggedObject]):
            PM.ToggleProgressBarStyle()

    ToggleTotalScore():void=
        if(TaggedObject:=GetCreativeObjectsWithTag(PlacementManagerTag{})[0], PM:=placement_manager[TaggedObject]):
            PM.ToggleTotalScore()

    ToggleProgressBarType():void=
        if(TaggedObject:=GetCreativeObjectsWithTag(PlacementManagerTag{})[0], PM:=placement_manager[TaggedObject]):
            PM.ToggleProgressBarType()

    ToggleProgressBarCount():void=
        if(TaggedObject:=GetCreativeObjectsWithTag(PlacementManagerTag{})[0], PM:=placement_manager[TaggedObject]):
            PM.ToggleProgressBarCount()

    ToggleProgressBarSmooth():void=
        if(TaggedObject:=GetCreativeObjectsWithTag(PlacementManagerTag{})[0], PM:=placement_manager[TaggedObject]):
            PM.ToggleProgressBarSmooth()

    UpScoreButtonInteractedWith(Agent:agent):void=
        if(TaggedObject:=GetCreativeObjectsWithTag(PlacementManagerTag{})[0], PM:=placement_manager[TaggedObject]):
            PM.AddScore(Agent, 100, true)

    DownScoreButtonInteractedWith(Agent:agent):void=
        if(TaggedObject:=GetCreativeObjectsWithTag(PlacementManagerTag{})[0], PM:=placement_manager[TaggedObject]):
            PM.AddScore(Agent, -100, true)

    AddKillButtonInteractedWith(Agent:agent):void=
        if(TaggedObject:=GetCreativeObjectsWithTag(StatsManagerTag{})[0], SM:=stats_manager[TaggedObject]):
            SM.OnElimination(Agent)

    AddDeathButtonInteractedWith(Agent:agent):void=
        if(TaggedObject:=GetCreativeObjectsWithTag(StatsManagerTag{})[0], SM:=stats_manager[TaggedObject]):
            SM.OnEliminated(Agent)