# Spinnerwheel 2
# Verse code for Spinnerwheel 2 - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/spinnerwheel-2-1?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/Diagnostics }

lucky_wheel_entry := class<concrete>:
    @editable
    granter: ?item_granter_device = option { item_granter_device{} }

    @editable
    cinematic: cinematic_sequence_device = cinematic_sequence_device{}

    @editable
    accolade: ?accolades_device = option { accolades_device{} }

lucky_wheel_device := class(creative_device):
    @editable
    entries: []lucky_wheel_entry = array {}

    @editable
    button_cinematic: cinematic_sequence_device = cinematic_sequence_device{}

    @editable
    lever_button: conditional_button_device = conditional_button_device{}

    OnBegin<override>()<suspends>: void =
        lever_button.ActivatedEvent.Subscribe(PullLever);

    PullLever(Agent: agent): void =
        spawn { _pullLeverAsync(Agent) }

    _pullLeverAsync(Agent: agent)<suspends>: void =
        Idx := GetRandomInt(0, entries.Length - 1)
        if:
            Entry := entries[Idx]
        then:
            lever_button.Disable();
            button_cinematic.Play(Agent);

            Entry.cinematic.Play(Agent);
            Entry.cinematic.StoppedEvent.Await();

            if (Grant := Entry.granter?):
                Grant.GrantItem(Agent);

            if (Accolade := Entry.accolade?):
                Accolade.Award(Agent);

            lever_button.Enable();
