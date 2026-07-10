# Player Figure System
# Creates an extensible player representation system with spawnable props and labels that can move smoothly across surfaces. Provides abstract classes for managing player figures with movement tracking,
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/player-extensions-1?ref=github

using { /Verse.org/Simulation }
using { MovementExtensions }
using { SimulationExtensions }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Devices }

PlayerExtensions<public> := module:
    MakeAgentName<localizes>(Agent:agent):message= "{Agent}"

    figure<public> := class<abstract><unique>:
        Player<public>:player

        RequestMove<public>(Direction:direction):void

        Spawn<public>(SpawnTranslation:vector3)<decides><transacts>:dimensional

        Show<public>():void

        Move<public>(NewTranslation:vector3)<suspends>:void

    prop_figure<public> := class<abstract>(figure):
        Asset<public>:asset
        PlayerName<public>:label
        var Prop<protected>:dimensional = dimensional{}
        var IsMoving<protected>:logic = false

        SetUp<public>():void =
            PlayerName.Display.SetText(MakeAgentName(Player))

        Spawn<override>(SpawnTranslation:vector3)<decides><transacts>:dimensional =
            OldProp := Prop
            SpawnedProp := Asset.SpawnOnSurface[SpawnTranslation]
            set Prop = SpawnedProp
            PlayerName.TeleportTo[Prop.ToSurface(SpawnTranslation)]
            OldProp

        Show<override>():void =
            PlayerName.Display.ShowText()

        Move<override>(NewTranslation:vector3)<suspends>:void =
            set IsMoving = true
            sync:
                Prop.MoveToSurface(NewTranslation, 0.4)
                PlayerName.MoveTo(Prop.ToSurface(NewTranslation), 0.4)
            set IsMoving = false

    respawnable_prop_figure<public> := class(prop_figure, monitorable):
        PlacementRequest<public>:event(respawnable_prop_figure)
        MoveRequest<public>:event(tuple(respawnable_prop_figure, direction))
        RemovalRequest<public>:event(player)
        MoveComplete<public>:event(respawnable_prop_figure)

        Move<override>(NewTranslation:vector3)<suspends>:void =
            (super:)Move(NewTranslation)
            MoveComplete.Signal(Self)

        RequestMove<override>(Direction:direction):void =
            if (not IsMoving?):
                MoveRequest.Signal((Self, Direction))

        Update<override>():void =
            if (not Prop.# Object.IsValid[]  # TODO: use type cast (e.g., player[Agent]?) instead):
                PlayerName.Display.HideText()
                PlacementRequest.Signal(Self)
