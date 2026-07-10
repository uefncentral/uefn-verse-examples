# Color Tile System
# This code creates a system for managing and organizing colored tiles (red, green, blue, purple, yellow, white, black) in a Fortnite Creative map. It uses tags to identify and group different colored p
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/color-switch-1?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Simulation/Tags }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }
using { /Fortnite.com/Characters }

##########THIS CODE WAS WRITTEN BY     MAXKSHRUTE
#########IF YOU BOUGHT THIS FROM NOT
########### MAXKSHRUTE please report this to maxkshrute on discord because
########### the map has been stolen

red_tile := class(tag){}
green_tile := class(tag){}
blue_tile := class(tag){}
purple_tile := class(tag){}
yellow_tile := class(tag){}
white_tile := class(tag){}
black_tile := class(tag){}

colored_tiles := class:
        
    var Red:tuple([]creative_prop, string) = (array{}, "")
    var Green:tuple([]creative_prop, string) = (array{}, "")
    var Blue:tuple([]creative_prop, string) = (array{}, "")
    var Purple:tuple([]creative_prop, string) = (array{}, "")
    var Yellow:tuple([]creative_prop, string) = (array{}, "")
    var White:tuple([]creative_prop, string) = (array{}, "")
    var Black:tuple([]creative_prop, string) = (array{}, "")

    var TileGroups:[]tuple([]creative_prop, string) = array{}

    Init():void=

        set Red = (for(Tile:GetCreativeObjectsWithTag(red_tile{}), TileProp := creative_prop[Tile]) {TileProp}, "Red")
        set Green = (for(Tile:GetCreativeObjectsWithTag(green_tile{}), TileProp := creative_prop[Tile]) {TileProp}, "Green")
        set Blue = (for(Tile:GetCreativeObjectsWithTag(blue_tile{}), TileProp := creative_prop[Tile]) {TileProp}, "Blue")
        set Purple = (for(Tile:GetCreativeObjectsWithTag(purple_tile{}), TileProp := creative_prop[Tile]) {TileProp}, "Purple")
        set Yellow = (for(Tile:GetCreativeObjectsWithTag(yellow_tile{}), TileProp := creative_prop[Tile]) {TileProp}, "Yellow")
        set White = (for(Tile:GetCreativeObjectsWithTag(white_tile{}), TileProp := creative_prop[Tile]) {TileProp}, "White")
        set Black = (for(Tile:GetCreativeObjectsWithTag(black_tile{}), TileProp := creative_prop[Tile]) {TileProp}, "Black")

        set TileGroups = array{Red , Green, Blue, Purple, Yellow, White, Black}

        for( TileGroup : TileGroups ):
            Print ( "{TileGroup(0).Length} ")


color_switch_game := class(creative_device):

    Tiles:colored_tiles = colored_tiles{}
    @editable ColorHud:hud_message_device = hud_message_device{}
    @editable TimeTilDrop:float = 5.0
    @editable TimeTilLift:float = 2.0
    @editable StartGameTrigger:trigger_device = trigger_device{}
    @editable EndDroppingTrigger:trigger_device = trigger_device{}
    @editable IsCreativeProp_TEST:creative_prop = creative_prop{}

    OnBegin<override>(Players:[]agent)<suspends>:void=

        Print("Color Switch")
        StartGameTrigger.TriggeredEvent.Await()
        spawn{Game(Players)}
        
    Game(Players:[]agent)<suspends>:void=
        Tiles.Init()
        TeleportAllToTiles(Players)
        Sleep(5.0)
        spawn{TileSequence()}

    TeleportAllToTiles(Players:[]agent):void=

        var AllTiles:[]creative_prop = array{}
        for(TileGroup:Tiles.TileGroups, TileGroupProps:=TileGroup(0)){for(Tile:TileGroupProps){ set AllTiles += array{Tile}}}
        for(Player:Players){RandIDX:=GetRandomInt(0, AllTiles.Length - 1),
            if(RandomTile:=AllTiles[RandIDX], FC:=Player.GetFortCharacter[], TileTran:=RandomTile.GetTransform()){if(FC.TeleportTo[TileTran.Translation + vector3{Z:=50.0}, TileTran.Rotation]){}}}

    DropTiles(Ts:[]creative_prop):void=for(Tile:Ts){spawn{Tile.MoveTo(Tile.GetTransform().Translation - vector3{Z:=3000.0}, Tile.GetTransform().Rotation, 1.0)}}
    LiftTiles(Ts:[]creative_prop):void=for(Tile:Ts){spawn{Tile.MoveTo(Tile.GetTransform().Translation + vector3{Z:=3000.0}, Tile.GetTransform().Rotation, 1.0)}}
    ShowColorHud(Color:string)<suspends>:void=ColorHud.Show(StringToMessage("{Color}"))

    var SafeTileName:[]char = array{}
    GetRandTiles():[]tuple([]creative_prop, string)=

        var TilesToDrop:[]tuple([]creative_prop, string) = array{(array{}, "")}
        RInt:=GetRandomInt(0, Tiles.TileGroups.Length - 1)
        if(RandTileGroup:=Tiles.TileGroups[RInt], Name:=RandTileGroup(1), set SafeTileName = Name):
            for(TileGroup:Tiles.TileGroups, TileGroup(1) <> RandTileGroup(1)){set TilesToDrop += array{TileGroup}}
        return TilesToDrop

    TileSequence()<suspends>:void=

        branch:
            loop:
                TilesToDrop := GetRandTiles()
                ShowColorHud(SafeTileName)
                Sleep(TimeTilDrop)
                ColorHud.Hide()
                for(TileGroup:TilesToDrop){DropTiles(TileGroup(0))}
                Sleep(TimeTilLift)
                for(TileGroup:TilesToDrop){LiftTiles(TileGroup(0))}
        EndDroppingTrigger.TriggeredEvent.Await()
        Print("End Game")

StringToMessage<localizes>(String:string):message="{String}"