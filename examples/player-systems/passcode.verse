# Interactive Keypad System
# Creates a customizable keypad interface that players can interact with by entering secret codes. Upon successful code entry, it can trigger various actions like removing barriers, teleporting players,
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/passcode?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/Colors }
using { /Verse.org/Colors/NamedColors }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }

keypad_device := class(creative_device):
    STM<localizes>(String : string) : message = "{String}"

    @editable
    open_keypad: button_device = button_device {}

    @editable
    failure_message: ?hud_message_device = false

    @editable
    success_message: ?hud_message_device = false

    @editable
    disable_barrier_on_success: ?barrier_device = false

    @editable
    disable_barrier_on_code_two_success: ?barrier_device = false

    @editable
    teleport_on_success: ?teleporter_device = false

    @editable
    teleport_on_code_two_success: ?teleporter_device = false

    @editable
    accolades: []accolades_device = array {}

    @editable
    code: string = "12345";

    @editable
    code2: ?string = false;

    @editable
    start_granting_xp_upon_success: logic = false;

    @editable
    allow_code_entry_only_once: logic = false;

    var PlayersWhoAlreadyGuessed: []player = array {}
    var GrantTo: []player = array {}
    var PlayerUI: [player]?canvas = map {}
    var PlayerCodeEntries : [player]?text_block = map {}
    var EnteredCodes: [player]?string = map {}

    OpenKeypadForAgent(Agent: agent): void =
        if (Player := player[Agent], TheirUI := GetPlayerUI[Player]):
            if (allow_code_entry_only_once?, PlayersWhoAlreadyGuessed.Find[Player] > -1) { Print("Player already guessed correctly"); return; }

            if (PlayerUI[Player]?) { Print("player already has ui - not creating new instance"); return; }

            CodeEntry := CreateCodeEntry();
            KeypadUI := CreateNewKeypadUI("", CodeEntry)
            TheirUI.AddWidget(KeypadUI, player_ui_slot { InputMode := ui_input_mode.All })
            if (set EnteredCodes[Player] = option { "" }) { Print("Created new entered code instance") }
            if (set PlayerCodeEntries[Player] = option { CodeEntry }) { Print("Created new code entry text block instance") }
            if (set PlayerUI[Player] = option { KeypadUI }) { Print("Created new keypad ui instance") }

    CloseKeypad(Agent: agent, Successful: logic, IsSecondCode: logic): void =
        if (Player := player[Agent]):
            if (Successful?):
                if (IsSecondCode?):
                    if (TP := teleport_on_code_two_success?):
                        TP.Teleport(Player);

                    if (Barrier := disable_barrier_on_code_two_success?):
                        Barrier.AddToIgnoreList(Agent);
                else:
                    if (TP := teleport_on_success?):
                        TP.Teleport(Player);

                    if (Barrier := disable_barrier_on_success?):
                        Barrier.AddToIgnoreList(Agent);

                if (HUDDevice := success_message?):
                    HUDDevice.Show(Agent);

                if (allow_code_entry_only_once?):
                    set PlayersWhoAlreadyGuessed = PlayersWhoAlreadyGuessed + array { Player }

                Print("Player correctly entered code!");

                if (start_granting_xp_upon_success?):
                    set GrantTo = GrantTo + array { Player }
            else:
                Print("Player entered incorrect code.");
            
            if:
                TheirUI := GetPlayerUI[Player]
                TheirCanvas := PlayerUI[Player]?
            then:
                TheirUI.RemoveWidget(TheirCanvas);
                Print("Removed widget from player.");

                if (set EnteredCodes[Player] = false) { Print("Reset entered code instance for player.") }
                if (set PlayerCodeEntries[Player] = false) { Print("Reset code entry instance for player.") }
                if (set PlayerUI[Player] = false) { Print("Reset keypad ui instance for player.") }
            else:
                Print("Failed to remove widget from player");

    OnBegin<override>()<suspends>: void =
        open_keypad.InteractedWithEvent.Subscribe(OpenKeypadForAgent);
        Print("Mc's Keypad Device set up correctly!")

        if (start_granting_xp_upon_success?):
            spawn { XPLoop() }
            for (Acc: accolades):
                Acc.TestAwardEvent.Subscribe(TestAccolade);

    TestAccolade(Agent: agent): void =
        Print("Agent received accolade!");

    XPLoop()<suspends>: void =
        loop:
            for (Player: GrantTo, Accolade: accolades):
                Accolade.Award(Player);
            Sleep(0.125);

    <#
    -- OBSOLETE -- I do not use this.
    CreateKeypadButtons(EnteredCode: string): []overlay_slot =
        var Root: []overlay_slot = {
            overlay_slot {
                HorizontalAlignment := horizontal_alignment.Center
                VerticalAlignment := vertical_alignment.Top
                Padding := margin { Top := 50.0 }
                Widget := text_block:
                    DefaultText := STM("Enter the secret code...")
                    DefaultJustification := text_justification.Center
            },
            overlay_slot {
                HorizontalAlignment := horizontal_alignment.Center
                VerticalAlignment := vertical_alignment.Top
                Padding := margin { Top := 120.0 }
                Widget := text_block:
                    DefaultText := STM(EnteredCode)
                    DefaultJustification := text_justification.Center
            }
        }

        for(idx := 0..9):
            var Val: message = STM(if (idx = 9) then "0" else ToString(idx + 1));
            var Marg: margin = margin {};
            var Horiz: horizontal_alignment = horizontal_alignment.Center;
            var Vert: vertical_alignment = vertical_alignment.Center;

            if (fl := Floor(idx / 3)):
                if (Mod[idx, 3] = 0):
                    set Marg = margin { Left := 130.0, Top := fl * 130.0 }
                    set Horiz = horizontal_alignment.Left;
                else if (Mod[idx, 3] = 1):
                    set Marg = margin { Right := 130.0, Top := fl * 130.0 }
                    set Horiz = horizontal_alignment.Right;

            set Root += array {
                overlay_slot {
                    HorizontalAlignment := Horiz
                    VerticalAlignment := Vert
                    Padding := Marg
                    Widget := button_loud:
                        DefaultText := Val
                }
            }

        return Root;
        #>

    HandleKeypadPress(Message: widget_message): void =
        if:
            CodeFromPlayer := EnteredCodes[Message.Player]?
            PreviousUI := PlayerUI[Message.Player]?
            SelectedButton := text_button_base[Message.Source]
            PlayerHUD := GetPlayerUI[Message.Player]
        then:
            BtnText := SelectedButton.GetText();
            if (BtnText = "Cancel"):
                CloseKeypad(Message.Player, false, false);
                return;

            Print("Player entered: {CodeFromPlayer}");
            Print("Player has updated full code: {CodeFromPlayer}{BtnText}");

            if ("{CodeFromPlayer}{BtnText}" = code):
                CloseKeypad(Message.Player, true, false);
                return;
            
            if (CodeReal := code2?, "{CodeFromPlayer}{BtnText}" = CodeReal):
                CloseKeypad(Message.Player, true, true);
                return;
            
            if ("{CodeFromPlayer}{BtnText}".Length > code.Length):
                if (HUDDevice := failure_message?):
                    HUDDevice.Show(Message.Player);
                if (set EnteredCodes[Message.Player] = option { "" }) {}
            else:
                if (set EnteredCodes[Message.Player] = option { "{CodeFromPlayer}{BtnText}" }) {}

            if (Entry := PlayerCodeEntries[Message.Player]?):
                Entry.SetText(STM(if ("{CodeFromPlayer}{BtnText}".Length > code.Length) then "" else "{CodeFromPlayer}{BtnText}"));

            <#KeypadUI := CreateNewKeypadUI(if ("{CodeFromPlayer}{BtnText}".Length > code.Length) then "" else "{CodeFromPlayer}{BtnText}");
            PlayerHUD.RemoveWidget(PreviousUI);
            PlayerHUD.AddWidget(KeypadUI, player_ui_slot { InputMode := ui_input_mode.All })

            if (set PlayerUI[Message.Player] = option { KeypadUI }) { Print("Created new keypad ui instance") }#>
        else:
            Print("Failed to handle keypad press");

    CreateKeypadButton(Key: string): button_loud =
        Btn := button_loud:
            DefaultText := STM(Key)

        Btn.OnClick().Subscribe(HandleKeypadPress);

        return Btn
    
    CreateCodeEntry(): text_block = 
        return text_block:
            DefaultText := STM("")
            DefaultTextColor := WhiteSmoke
            DefaultJustification := text_justification.Center

    CreateNewKeypadUI(EnteredCode: string, CodeEntry: text_block): canvas =
        Root: canvas = canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors { Minimum := vector2 { X := 0.5, Y := 0.5 }, Maximum := vector2 { X := 0.5, Y := 0.5 } }
                    Alignment := vector2 { X := 0.5, Y := 0.5 }
                    SizeToContent := true
                    Widget := overlay:
                        Slots := array:
                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment := vertical_alignment.Top
                                Padding := margin { Top := 50.0 }
                                Widget := text_block:
                                    DefaultText := STM("Enter the secret code...")
                                    DefaultTextColor := WhiteSmoke
                                    DefaultJustification := text_justification.Center

                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment := vertical_alignment.Top
                                Padding := margin { Top := 90.0 }
                                Widget := CodeEntry

                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment := vertical_alignment.Center
                                Padding := margin { Right := 130.0, Bottom := 100.0 }
                                Widget := CreateKeypadButton("1")

                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment := vertical_alignment.Center
                                Padding := margin { Bottom := 100.0 }
                                Widget := CreateKeypadButton("2")

                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment := vertical_alignment.Center
                                Padding := margin { Left := 130.0, Bottom := 100.0 }
                                Widget := CreateKeypadButton("3")

                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment := vertical_alignment.Center
                                Padding := margin { Right := 130.0, Top := 130.0, Bottom := 100.0 }
                                Widget := CreateKeypadButton("4")

                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment := vertical_alignment.Center
                                Padding := margin { Top := 130.0, Bottom := 100.0 }
                                Widget := CreateKeypadButton("5")

                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment := vertical_alignment.Center
                                Padding := margin { Left := 130.0, Top := 130.0, Bottom := 100.0 }
                                Widget := CreateKeypadButton("6")

                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment := vertical_alignment.Center
                                Padding := margin { Right := 130.0, Top := 260.0, Bottom := 100.0 }
                                Widget := CreateKeypadButton("7")

                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment := vertical_alignment.Center
                                Padding := margin { Top := 260.0, Bottom := 100.0 }
                                Widget := CreateKeypadButton("8")

                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment := vertical_alignment.Center
                                Padding := margin { Left := 130.0, Top := 260.0, Bottom := 100.0 }
                                Widget := CreateKeypadButton("9")

                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment := vertical_alignment.Center
                                Padding := margin { Top := 390.0, Bottom := 100.0 }
                                Widget := CreateKeypadButton("0")

                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment := vertical_alignment.Center
                                Padding := margin { Top := 430.0 }
                                Widget := CreateKeypadButton("Cancel")

        return Root;