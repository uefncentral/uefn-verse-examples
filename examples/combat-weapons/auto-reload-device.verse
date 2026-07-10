# Automatic Weapon Reload System
# This code creates an automatic weapon reloading system that monitors player eliminations and refills ammunition for specified weapons. When a player gets an elimination, the system checks if they have
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/auto-reload-device?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

auto_reload_device := class(creative_device):

    @editable
    EliminationManager:elimination_manager_device = elimination_manager_device{}

    @editable
    WeaponsToReload:weapons_to_reload = weapons_to_reload.All

    @editable
    Weapons:[]auto_reload_weapon = array{}

    OnBegin<override>()<suspends>:void=
        Sleep(0.0)
        DeviceSetup()

    DeviceSetup():void=
        EliminationManager.EliminationEvent.Subscribe(CheckWeapons)
        for (Weapon : Weapons):
            Weapon.Init(Self)

    CheckWeapons(MaybeAgent:?agent):void=
        for (Weapon : Weapons, Agent := MaybeAgent?):
            Weapon.CheckForWeapon(Agent)

auto_reload_weapon := class<concrete>:

    @editable
    ConditionalButton:conditional_button_device = conditional_button_device{}

    @editable
    ItemGranter:item_granter_device = item_granter_device{}

    var VerseDevice:auto_reload_device = auto_reload_device{}

    Init(MainDevice:auto_reload_device):void=
        set VerseDevice = MainDevice

    CheckForWeapon(Agent:agent):void=
        case (VerseDevice.WeaponsToReload):
            weapons_to_reload.All =>
                if (ConditionalButton.HasAllItems[Agent]):
                    ConditionalButton.Activate(Agent)
                    ItemGranter.GrantItem(Agent)

            weapons_to_reload.Held =>
                if (ConditionalButton.IsHoldingItem[Agent]):
                    ConditionalButton.Activate(Agent)
                    ItemGranter.GrantItem(Agent)

            weapons_to_reload.None =>

weapons_to_reload := enum:

    All
    Held
    None