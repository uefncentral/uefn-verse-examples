# Resource Counter UI
# Creates a dynamic UI text display that shows a player's resource count from a conditional button device. The UI automatically updates at a configurable refresh rate and appears when players spawn.  **
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/resui-device?ref=github


using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /Verse.org/Colors/NamedColors }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }

ResourceUIDevice := class(creative_device):

    S2M<localizes>(S:string):message="{S}"
    @editable Left : float = 955.0
    @editable Top : float = 130.0
    @editable Right : float = 955.0
    @editable Buttom : float = 1000.0


    @editable PlayerSpawners : []player_spawner_device = array{}
    @editable RefreshRate : float = 0.1
    @editable ConditButton : conditional_button_device = conditional_button_device{}
    var ResourceTextBlockPerAgent : [agent]?text_block = map{}

    OnBegin<override>()<suspends>:void=
        for(PS:PlayerSpawners):
            PS.SpawnedEvent.Subscribe(PlayerSpawned)

    PlayerSpawned(Agent:agent):void=
        Print("Player Spawned")
        if(MyTextBlock:=ResourceTextBlockPerAgent[Agent]?){}
        else:
            AssignUI(Agent)
    
    AssignUI(Agent:agent):void=
        MyCanvas:=MakeCanvas(Agent)
        if:
            PlayerUI:=GetPlayerUI[player[Agent]]
        then:
            PlayerUI.AddWidget(MyCanvas)
            spawn{RefreshUI(Agent)}
    
    RefreshUI(Agent:agent)<suspends>:void=
        Print("Starting to Refresh")
        if(TextBlock := ResourceTextBlockPerAgent[Agent]?):
            loop:
                Sleep(RefreshRate)
                MyResource := ConditButton.GetItemCount(Agent,0)
                TextBlock.SetText(S2M("{MyResource}"))



    MakeCanvas(Agent:agent):canvas=
        MyTextBlock:=text_block:
            DefaultTextColor:=White

        if(set ResourceTextBlockPerAgent[Agent] = option{MyTextBlock}){}

        MyCanvas:=canvas:
            Slots:=array:
                canvas_slot:
                    Widget:=MyTextBlock
                    Anchors:=anchors{Minimum:=vector2{X:=0.084,Y:=0.7952},Maximum:=vector2{X:=0.084,Y:=0.7952}}
                    Offsets:=margin{Left:=0.0,Top:=0.0 ,Right:=0.0,Bottom:=0.0}
                    SizeToContent:= true
        return MyCanvas

                                                              #༶•┈┈୨ T.FAM ୧┈┈•༶#
