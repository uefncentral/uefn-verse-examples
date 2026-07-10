# Guard Spawner Manager
# Verse code for Guard Spawner Manager - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/guard-spawner-manager?ref=github

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

    HideAllMessages(Player : agent):void=
        SelectDifficultyMessage.Hide(Player)
        EasySelectedMessage.Hide(Player)
        MediumSelectedMessage.Hide(Player)
        HardSelectedMessage.Hide(Player)
        GuardsEnabledMessage.Hide(Player)
        GuardsDisabledMessage.Hide(Player)

    DisableAllSpawners():void=
        for (Spawner : EasySpawners):
            Spawner.Disable()
            Spawner.Despawn()
        for (Spawner : MediumSpawners):
            Spawner.Disable()
            Spawner.Despawn()
        for (Spawner : HardSpawners):
            Spawner.Disable()
            Spawner.Despawn()

    OnSetEasyMode(Agent : agent):void=
        set DifficultySelected = true
        set SpawnersEnabled = false
        DisableAllSpawners()
        set ActiveSpawners = EasySpawners
        HideAllMessages(Agent)
        EasySelectedMessage.Show(Agent)

    OnSetMediumMode(Agent : agent):void=
        set DifficultySelected = true
        set SpawnersEnabled = false
        DisableAllSpawners()
        set ActiveSpawners = MediumSpawners
        HideAllMessages(Agent)
        MediumSelectedMessage.Show(Agent)

    OnSetHardMode(Agent : agent):void=
        set DifficultySelected = true
        set SpawnersEnabled = false
        DisableAllSpawners()
        set ActiveSpawners = HardSpawners
        HideAllMessages(Agent)
        HardSelectedMessage.Show(Agent)

    OnToggleSpawners(Agent : agent):void=
        if (DifficultySelected?):
            if (SpawnersEnabled?):
                set SpawnersEnabled = false
                for (Spawner : ActiveSpawners):
                    Spawner.Disable()
                    Spawner.Despawn()
                HideAllMessages(Agent)
                GuardsDisabledMessage.Show(Agent)
            else:
                set SpawnersEnabled = true
                for (Spawner : ActiveSpawners):
                    Spawner.Enable()
                    Spawner.Spawn()
                HideAllMessages(Agent)
                GuardsEnabledMessage.Show(Agent)
        else:
            HideAllMessages(Agent)
            SelectDifficultyMessage.Show(Agent)