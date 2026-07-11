# Utils System
# Verse code for Utils System - UEFN/Fortnite Creative implementation
# Difficulty: intermediate  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/utils-system?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Simulation/Tags }

UtilsTag:= class(tag){}

utils_system := class(creative_device):

    @editable ClearItems:item_remover_device = item_remover_device{}

    #ITEM GRANTERS

    @editable StandardAR1:item_granter_device = item_granter_device{}
    @editable StandardAR2:item_granter_device = item_granter_device{}
    @editable StandardAR3:item_granter_device = item_granter_device{}
    @editable StandardAR4:item_granter_device = item_granter_device{}

    @editable StandardShotgun1:item_granter_device = item_granter_device{}
    @editable StandardShotgun2:item_granter_device = item_granter_device{}
    @editable StandardShotgun3:item_granter_device = item_granter_device{}
    @editable StandardShotgun4:item_granter_device = item_granter_device{}

    @editable StandardSMG1:item_granter_device = item_granter_device{}
    @editable StandardSMG2:item_granter_device = item_granter_device{}
    @editable StandardSMG3:item_granter_device = item_granter_device{}
    @editable StandardSMG4:item_granter_device = item_granter_device{}

    @editable StandardGrappler:item_granter_device = item_granter_device{}
    @editable StandardGrappleBlade:item_granter_device = item_granter_device{}
    @editable StandardMini:item_granter_device = item_granter_device{}

    #SWITCHES

    @editable AR1Switch:switch_device = switch_device{}
    @editable AR2Switch:switch_device = switch_device{}
    @editable AR3Switch:switch_device = switch_device{}
    @editable AR4Switch:switch_device = switch_device{}

    @editable Shotgun1Switch:switch_device = switch_device{}
    @editable Shotgun2Switch:switch_device = switch_device{}
    @editable Shotgun3Switch:switch_device = switch_device{}
    @editable Shotgun4Switch:switch_device = switch_device{}

    @editable SMG1Switch:switch_device = switch_device{}
    @editable SMG2Switch:switch_device = switch_device{}
    @editable SMG3Switch:switch_device = switch_device{}
    @editable SMG4Switch:switch_device = switch_device{}

    @editable GrapplerSwitch:switch_device = switch_device{}
    @editable GrappleBladeSwitch:switch_device = switch_device{}
    @editable MiniSwitch:switch_device = switch_device{}

    @editable StandardClass:class_and_team_selector_device = class_and_team_selector_device{}

    OnBegin<override>():void=
        AR1Switch.TurnedOnEvent.SubscribeAgent(ChangedSwitch, "AR1")
        AR2Switch.TurnedOnEvent.SubscribeAgent(ChangedSwitch, "AR2")
        AR3Switch.TurnedOnEvent.SubscribeAgent(ChangedSwitch, "AR3")
        AR4Switch.TurnedOnEvent.SubscribeAgent(ChangedSwitch, "AR4")

        Shotgun1Switch.TurnedOnEvent.SubscribeAgent(ChangedSwitch, "Shotgun1")
        Shotgun2Switch.TurnedOnEvent.SubscribeAgent(ChangedSwitch, "Shotgun2")
        Shotgun3Switch.TurnedOnEvent.SubscribeAgent(ChangedSwitch, "Shotgun3")
        Shotgun4Switch.TurnedOnEvent.SubscribeAgent(ChangedSwitch, "Shotgun4")

        SMG1Switch.TurnedOnEvent.SubscribeAgent(ChangedSwitch, "SMG1")
        SMG2Switch.TurnedOnEvent.SubscribeAgent(ChangedSwitch, "SMG2")
        SMG3Switch.TurnedOnEvent.SubscribeAgent(ChangedSwitch, "SMG3")
        SMG4Switch.TurnedOnEvent.SubscribeAgent(ChangedSwitch, "SMG4")

        GrapplerSwitch.TurnedOnEvent.SubscribeAgent(ChangedSwitch, "Grappler")
        GrappleBladeSwitch.TurnedOnEvent.SubscribeAgent(ChangedSwitch, "GrappleBlade")

    ChangedSwitch(Agent:agent, Type:string):void=
        if(Type = "AR1"):
            AR2Switch.TurnOff(Agent)
            AR3Switch.TurnOff(Agent)
            AR4Switch.TurnOff(Agent)

        if(Type = "AR2"):
            AR1Switch.TurnOff(Agent)
            AR3Switch.TurnOff(Agent)
            AR4Switch.TurnOff(Agent)

        if(Type = "AR3"):
            AR1Switch.TurnOff(Agent)
            AR2Switch.TurnOff(Agent)
            AR4Switch.TurnOff(Agent)

        if(Type = "AR4"):
            AR1Switch.TurnOff(Agent)
            AR2Switch.TurnOff(Agent)
            AR3Switch.TurnOff(Agent)

        if(Type = "Shotgun1"):
            Shotgun2Switch.TurnOff(Agent)
            Shotgun3Switch.TurnOff(Agent)
            Shotgun4Switch.TurnOff(Agent)

        if(Type = "Shotgun2"):
            Shotgun1Switch.TurnOff(Agent)
            Shotgun3Switch.TurnOff(Agent)
            Shotgun4Switch.TurnOff(Agent)

        if(Type = "Shotgun3"):
            Shotgun1Switch.TurnOff(Agent)
            Shotgun2Switch.TurnOff(Agent)
            Shotgun4Switch.TurnOff(Agent)

        if(Type = "Shotgun4"):
            Shotgun1Switch.TurnOff(Agent)
            Shotgun2Switch.TurnOff(Agent)
            Shotgun3Switch.TurnOff(Agent)

        if(Type = "SMG1"):
            SMG2Switch.TurnOff(Agent)
            SMG3Switch.TurnOff(Agent)
            SMG4Switch.TurnOff(Agent)

        if(Type = "SMG2"):
            SMG1Switch.TurnOff(Agent)
            SMG3Switch.TurnOff(Agent)
            SMG4Switch.TurnOff(Agent)

        if(Type = "SMG3"):
            SMG1Switch.TurnOff(Agent)
            SMG2Switch.TurnOff(Agent)
            SMG4Switch.TurnOff(Agent)

        if(Type = "SMG4"):
            SMG1Switch.TurnOff(Agent)
            SMG2Switch.TurnOff(Agent)
            SMG3Switch.TurnOff(Agent)
        
        if(Type = "Grappler"):
            GrappleBladeSwitch.TurnOff(Agent)

        if(Type = "GrappleBlade"):
            GrapplerSwitch.TurnOff(Agent)
        
    GrantStandardItems():void=
        Players:=GetPlayspace().GetPlayers()
        for(Player:Players):
            ClearItems.Remove(Player)
            if(AR1Switch.GetCurrentState[]):
                StandardAR1.GrantItem(Player)
            if(AR2Switch.GetCurrentState[]):
                StandardAR2.GrantItem(Player)
            if(AR3Switch.GetCurrentState[]):
                StandardAR3.GrantItem(Player)
            if(AR4Switch.GetCurrentState[]):
                StandardAR4.GrantItem(Player)
            if(Shotgun1Switch.GetCurrentState[]):
                StandardShotgun1.GrantItem(Player)
            if(Shotgun2Switch.GetCurrentState[]):
                StandardShotgun2.GrantItem(Player)
            if(Shotgun3Switch.GetCurrentState[]):
                StandardShotgun3.GrantItem(Player)
            if(Shotgun4Switch.GetCurrentState[]):
                StandardShotgun4.GrantItem(Player)
            if(SMG1Switch.GetCurrentState[]):
                StandardSMG1.GrantItem(Player)
            if(SMG2Switch.GetCurrentState[]):
                StandardSMG2.GrantItem(Player)
            if(SMG3Switch.GetCurrentState[]):
                StandardSMG3.GrantItem(Player)
            if(SMG4Switch.GetCurrentState[]):
                StandardSMG4.GrantItem(Player)
            if(GrapplerSwitch.GetCurrentState[]):
                StandardGrappler.GrantItem(Player)
            if(GrappleBladeSwitch.GetCurrentState[]):
                StandardGrappleBlade.GrantItem(Player)
            if(MiniSwitch.GetCurrentState[]):
                StandardMini.GrantItem(Player)

    ChangeToStandardClass():void=
        Players:=GetPlayspace().GetPlayers()
        for(Player:Players):
            StandardClass.ChangeClass(Player)

    ClearPlayerItems(Agent:agent):void=
        ClearItems.Remove(Agent)