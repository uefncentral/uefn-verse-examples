# Guard Spawner Difficulty Controller
# This device manages NPC guard spawning with three difficulty levels (Easy, Medium, Hard). Players can select a difficulty mode and toggle guard spawning on/off, with HUD messages providing feedback fo
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/guardspawnerwithdificulty?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }

guard_spawner_controller_device := class(creative_device):
    @editable
    SpawnToggleButton : button_device = button_device{}
    
    @editable
    EasyButton : button_device = button_device{}
    
    @editable
    MediumButton : button_device = button_device{}
    
    @editable
    HardButton : button_device = button_device{}

    @editable
    EasySpawners : []guard_spawner_device = array{}
    
    @editable
    MediumSpawners : []guard_spawner_device = array{}
    
    @editable
    HardSpawners : []guard_spawner_device = array{}

    @editable
    SelectDifficultyMessage : hud_message_device = hud_message_device{}

    @editable
    EasySelectedMessage : hud_message_device = hud_message_device{}

    @editable
    MediumSelectedMessage : hud_message_device = hud_message_device{}

    @editable
    HardSelectedMessage : hud_message_device = hud_message_device{}

    @editable
    GuardsEnabledMessage : hud_message_device = hud_message_device{}

    @editable
    GuardsDisabledMessage : hud_message_device = hud_message_device{}

    var SpawnersEnabled : logic = false
    var DifficultySelected : logic = false
    var ActiveSpawners : []guard_spawner_device = array{}

    OnBegin<override>()<suspends>:void=
        SpawnToggleButton.InteractedWithEvent.Subscribe(OnToggleSpawners)
        EasyButton.InteractedWithEvent.Subscribe(OnSetEasyMode)
        MediumButton.InteractedWithEvent.Subscribe(OnSetMediumMode)
        HardButton.InteractedWithEvent.Subscribe(OnSetHardMode)
        
        # Make sure all spawners start disabled
        DisableAllSpawners()
        for (Spawner : EasySpawners):
            Spawner.Despawn()
        for (Spawner : MediumSpawners):
            Spawner.Despawn()
        for (Spawner : HardSpawners):
            Spawner.Despawn()

    DisableAllSpawners():void=
        for (Spawner : EasySpawners):
            Spawner.Disable()
        for (Spawner : MediumSpawners):
            Spawner.Disable()
        for (Spawner : HardSpawners):
            Spawner.Disable()

    OnSetEasyMode(Agent : agent):void=
        set DifficultySelected = true
        set SpawnersEnabled = false
        DisableAllSpawners()
        set ActiveSpawners = EasySpawners
        for (Spawner : ActiveSpawners):
            Spawner.Despawn()
        EasySelectedMessage.Show()

    OnSetMediumMode(Agent : agent):void=
        set DifficultySelected = true
        set SpawnersEnabled = false
        DisableAllSpawners()
        set ActiveSpawners = MediumSpawners
        for (Spawner : ActiveSpawners):
            Spawner.Despawn()
        MediumSelectedMessage.Show()

    OnSetHardMode(Agent : agent):void=
        set DifficultySelected = true
        set SpawnersEnabled = false
        DisableAllSpawners()
        set ActiveSpawners = HardSpawners
        for (Spawner : ActiveSpawners):
            Spawner.Despawn()
        HardSelectedMessage.Show()

    OnToggleSpawners(Agent : agent):void=
        if (DifficultySelected?):
            if (SpawnersEnabled?):
                set SpawnersEnabled = false
                for (Spawner : ActiveSpawners):
                    Spawner.Disable()
                    Spawner.Despawn()
                GuardsDisabledMessage.Show()
            else:
                set SpawnersEnabled = true
                for (Spawner : ActiveSpawners):
                    Spawner.Enable()
                    Spawner.Spawn()
                GuardsEnabledMessage.Show()
        else:
            SelectDifficultyMessage.Show()