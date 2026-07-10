# Resource Money Display
# Creates a real-time UI display that shows each player's money/currency amount in the top corner of their screen. The system tracks resources from a conditional button device and updates the display co
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/counter-device?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /Verse.org/Colors/NamedColors }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
 
# A Verse-authored creative device that can be placed in a level
ResourceUIDevice := class(creative_device):
 
    S2M<localizes>(S:string):message="{S}"
 
    @editable PlayerSpawners : []player_spawner_device = array{}
    @editable RefreshRate : float = 0.1
    @editable ConditButton : conditional_button_device = conditional_button_device{}
    var ResourceTextBlockPerAgent : [agent]?text_block = map{}
 
    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        for(PS:PlayerSpawners):
            PS.SpawnedEvent.Subscribe(PlayerSpawned)
 
    PlayerSpawned(Agent:agent):void=
        Print("Player Spawned")
        if(MyTextBlock:=ResourceTextBlockPerAgent[Agent]?){}
        else:
            AssignUI(Agent)
 
    AssignUI(Agent:agent):void=
        Print("Assigning UI")
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
                TextBlock.SetText(S2M("💸Money: {MyResource}"))
 
 
 
    MakeCanvas(Agent:agent):canvas=
        Print("Making Canvas")
        MyTextBlock:=text_block:
            DefaultTextColor:=Lime
 
        if(set ResourceTextBlockPerAgent[Agent] = option{MyTextBlock}){}
 
        MyCanvas:=canvas:
            Slots:=array:
                canvas_slot:
                    Widget:=MyTextBlock
                    Anchors:=anchors{Minimum:=vector2{X:=0.0,Y:=0.0},Maximum:=vector2{X:=1.0,Y:=1.0}}
                    Offsets:=margin{Left:=124.0,Top:=840.0,Right:=911.0,Bottom:=219.0}
 
        return MyCanvas