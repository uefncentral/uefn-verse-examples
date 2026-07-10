# Unlockable
# Verse code for Unlockable - UEFN/Fortnite Creative implementation
# Difficulty: intermediate  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/unlockable?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
 
button_config := struct<concrete>:
    @editable
    Button : button_device = button_device{}
    @editable
    Switch : switch_device = switch_device{}
    @editable
    SuccessTrigger : trigger_device = trigger_device{}
    @editable
    FailTrigger : trigger_device = trigger_device{}
 
button_handler := class:
    Config : button_config
 
    OnButtonInteracted(Agent : agent) : void =
        if (Config.Switch.GetCurrentState[Agent]):
            Config.SuccessTrigger.Trigger(Agent)
        else:
            Config.FailTrigger.Trigger(Agent)
 
weapon_button_manager := class(creative_device):
    @editable
    var WeaponButtons : []button_config = array{}
 
    var Subscriptions : []cancelable = array{}
 
    OnBegin<override>()<suspends> : void =
        for (Config : WeaponButtons):
            Handler := button_handler{Config := Config}
            Cancelable := Config.Button.InteractedWithEvent.Subscribe(Handler.OnButtonInteracted)
            set Subscriptions = Subscriptions + array{Cancelable}
