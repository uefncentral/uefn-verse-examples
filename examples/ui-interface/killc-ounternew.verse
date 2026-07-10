# Killc Ounternew
# Verse code for Killc Ounternew - UEFN/Fortnite Creative implementation
# Difficulty: intermediate  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/killc-ounternew?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /Verse.org/Colors/NamedColors }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
STM<localizes>(String: string): message = "{String}"
TextBlocks := class:
    RedBlock: text_block;
    BlueBlock: text_block;
elim_counter_device := class(creative_device):
    var RedElims: int = 0;
    var BlueElims: int = 0;

    var TextBlockMap: [player]?TextBlocks = map {}

    @editable
    elim_manager_red: elimination_manager_device = elimination_manager_device {}

    @editable
    elim_manager_blue: elimination_manager_device = elimination_manager_device {}

    OnBegin<override>()<suspends>: void =
        Players := GetPlayspace().GetPlayers();
        for (Player : Players):
            CreateWidgetForPlayer(Player);

        GetPlayspace().PlayerAddedEvent().Subscribe(CreateWidgetForPlayer);
        elim_manager_red.EliminationEvent.Subscribe(AddBlueElim);
        elim_manager_blue.EliminationEvent.Subscribe(AddRedElim);

    AddRedElim(Agent: ?agent): void =
        set RedElims += 1;
        RefreshElims();

    AddBlueElim(Agent: ?agent): void =
        set BlueElims += 1;
        RefreshElims();

    RefreshElims(): void =
        for (TextBlock: TextBlockMap, ExistingBlock := TextBlock?):
            ExistingBlock.RedBlock.SetText(STM(ToString(RedElims)));
            ExistingBlock.BlueBlock.SetText(STM(ToString(BlueElims)));

    CreateWidgetForPlayer(Player: player): void =
        RedBlock := text_block:
            DefaultText := STM(ToString(RedElims))
            DefaultTextColor := White

        BlueBlock := text_block:
            DefaultText := STM(ToString(BlueElims))
            DefaultTextColor := White

        Blocks := TextBlocks:
            RedBlock := RedBlock
            BlueBlock := BlueBlock

        Root := canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors { Minimum := vector2 { X := 0.5, Y := 0.0 }, Maximum := vector2 { X := 0.5, Y := 0.0 } }
                    Alignment := vector2 { X := 0.5, Y := 0.0 }
                    Offsets := margin { Left := 0.0, Top := 0.0, Right := 501.0, Bottom := 168.0 }
                    SizeToContent := false
                    Widget := texture_block:
                        DefaultImage := WidgetUI.MapCodeTex

                canvas_slot:
                    Anchors := anchors { Minimum := vector2 { X := 0.5, Y := 0.0 }, Maximum := vector2 { X := 0.5, Y := 0.0 } }
                    Alignment := vector2 { X := 0.5, Y := 0.0 }
                    Offsets := margin { Left := -168.3, Top := 160.0 }
                    SizeToContent := true
                    Widget := RedBlock

                canvas_slot:
                    Anchors := anchors { Minimum := vector2 { X := 0.5, Y := 0.0 }, Maximum := vector2 { X := 0.5, Y := 0.0 } }
                    Alignment := vector2 { X := 0.5, Y := 0.0 }
                    Offsets := margin { Left := 168.3, Top := 160.0 }
                    SizeToContent := true
                    Widget := BlueBlock

        if (PlayerUI := GetPlayerUI[Player]):
            PlayerUI.AddWidget(Root);
            if (set TextBlockMap[Player] = option { Blocks }) { Print("Red vs Blue elim count set up for player"); }