# HP Switch System
# Creates a toggle system using two switches to dynamically change all players' health between 200 HP and 180 HP configurations. When one switch is activated, it automatically deactivates the other and 
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/changehpbutton-1-1?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }


HpButtonCode := class(creative_device):
    @editable HPSwitch200 : switch_device = switch_device{}       #switch to enable 200hp
    @editable HPSwitch180 : switch_device = switch_device{}       #switch to enable 180hp

    @editable ClassSelector200 : class_and_team_selector_device = class_and_team_selector_device{}     #class selector with all players set to 200hp
    @editable ClassSelector185 : class_and_team_selector_device = class_and_team_selector_device{}     #class selector with all players set to 180hp
    # Runs when the device is started in a running game 
    OnBegin<override>()<suspends>:void=

        HPSwitch200.TurnedOnEvent.Subscribe(ClassSwitch200)
        HPSwitch180.TurnedOnEvent.Subscribe(ClassSwitch180)    
    ClassSwitch200(Agent:agent) : void=#when 200 switch is turned on
        HPSwitch180.TurnOff(Agent)   #turns off 180 switch
        AllPlayers:=GetPlayspace().GetPlayers()
        for (Player : AllPlayers):
            ClassSelector200.ChangeClass(Player)    #changes all players to 200hp class


    ClassSwitch180(Agent:agent) : void= #when 180 switch is turned on
        HPSwitch200.TurnOff(Agent)    #turns off 200 switch
        AllPlayers:=GetPlayspace().GetPlayers()
            for (Player : AllPlayers):
                ClassSelector185.ChangeClass(Player)   #changes all players to 180hp class

