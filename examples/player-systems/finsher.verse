# Finisher Unlock System
# A system that manages unlockable special finishing moves or abilities in a game. Players can purchase, unlock, and equip different finishers using in-game currency, with progress saved to player persi
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/finsher?ref=github

using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /Verse.org/Random }
using { /Verse.org/Simulation/Tags }



hud := struct<concrete>:
    @editable Green:hud_message_device=hud_message_device{}
    @editable Red:hud_message_device=hud_message_device{}

finisher := class<concrete>:

    @editable Number :int=0
    @editable Time :float=0.0
    @editable Conditional_Button :conditional_button_device=conditional_button_device{}
    @editable Ins_Trgr :trigger_device=trigger_device{}
    @editable Target_Trgr :trigger_device=trigger_device{}
    @editable Cinematic :cinematic_sequence_device=cinematic_sequence_device{}
    @editable Anchor :creative_prop=creative_prop{}
    @editable Tracker :tracker_device=tracker_device{}
    @editable Switch :switch_device=switch_device{}
    @editable Gold :int=0
    @editable Hud_Device:hud=hud{}


# EVENTS
    InitEvents()<suspends>:void=
        Conditional_Button.ActivatedEvent.SubscribeAgent(CheckOwnedFinishers,Number)
        Switch.TurnedOnEvent.SubscribeAgent(EquipFinisher,Number)
        Switch.TurnedOffEvent.SubscribeAgent(UnEquipFinisher,Number)

# FUNCTIONS
    CheckOwnedFinishers(Agent : agent,Idx : int):void=
        # If not OWNED -> add to persistence array
        if(PlayerObj := player[Agent]):
            if(PlayerData := Data[PlayerObj]):
                OwnedFinishers := PlayerData.OwnedFinishers
                if(OwnedFinishers.Find[Idx]):
                    Hud_Device.Red.SetText(StringToMsgLocked(Number+1))
                    Hud_Device.Red.Show(Agent)
                    # Print("Finisher {Number+1} Already unlocked")
                else:
                    if(X := OwnedFinishers.Insert[0,array{Idx}]):
                        if(set Data[PlayerObj] = player_data{player_data_update<constructor>(PlayerData), OwnedFinishers :=X}){
                            # Print("Finisher {Number+1} Unlocked")
                            Hud_Device.Green.SetText(StringToMsgUnLocked(Number+1))
                            Hud_Device.Green.Show(Agent)
                        }
                        else:
                            Print("Cant access player data")

                
    EquipFinisher(Agent : agent, Idx : int):void=
        if(PlayerObj := player[Agent]):
            if(PlayerData := Data[PlayerObj]):
                OwnedFinishers := PlayerData.OwnedFinishers
                if(OwnedFinishers.Find[Idx]):
                    Tracker.SetValue(Agent ,Idx+1)
                    Hud_Device.Green.SetText(StringToMsgEquiped(Number+1))
                    Hud_Device.Green.Show(Agent)
                    # Print("Finisher {Idx+1} Equiped")
                else:
                    Hud_Device.Red.SetText(StringToMsgEquiped_(Number+1))
                    Hud_Device.Red.Show(Agent)
                    Switch.SetState(Agent,false)


    UnEquipFinisher(Agent : agent, Idx : int):void=
        if(PlayerObj := player[Agent]):
            if(PlayerData := Data[PlayerObj]):
                OwnedFinishers := PlayerData.OwnedFinishers
                if(OwnedFinishers.Find[Idx]):
                    var Rand :int= GetRandomInt(0,OwnedFinishers.Length-1)
                    Tracker.SetValue(Agent ,Rand)
                    Hud_Device.Green.SetText(StringToMsgUnEquiped(Number+1))
                    Hud_Device.Green.Show(Agent)
                    # Print("UnEquiped Finisher {Idx+1}")
                    Print("Finisher {Rand} is Equiped")
                else:
                    Hud_Device.Red.SetText(StringToMsgUnEquiped_(Number+1))
                    Hud_Device.Red.Show(Agent)
                    Print("Unlock Finisher {Idx+1} First")

    StringToMsgLocked<localizes>(Idx: int):message="Finisher {Idx} Already Unlocked"
    StringToMsgUnLocked<localizes>(Idx: int):message="Finisher {Idx} Unlocked"

    StringToMsgEquiped<localizes>(Idx: int):message="Finisher {Idx} Equipped"
    StringToMsgEquiped_<localizes>(Idx: int):message="Unlock Finisher {Idx} To Equip"

    StringToMsgUnEquiped<localizes>(Idx: int):message="Finisher {Idx} UnEquipped"
    StringToMsgUnEquiped_<localizes>(Idx: int):message="First Unlock Finisher {Idx}"