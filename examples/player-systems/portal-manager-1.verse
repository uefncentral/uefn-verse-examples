# Timed Portal System
# Manages time-locked portals that unlock after specified durations and teleport players to new areas. Each portal displays a countdown timer on a billboard and activates teleportation when the timer ex
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/portal-manager-1?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

#THIS DEVICE IS USED TO MANAGE DIFFERENT "PORTALS" THAT UNLOCK AFTER CERTAIN TIMES

Portal := class<concrete>():

    var GameManager : Game_Manager = Game_Manager{}                                     #Game Manager to reference players

    @editable PortalBillboard : billboard_device = billboard_device{}                   #Portal billboard to display remaining time

    @editable PortalTeleporter : teleporter_device = teleporter_device{}                #Portal Teleporter that teleports players to the new area

    @editable PortalMutator : mutator_zone_device = mutator_zone_device{}               #Mutator used to activate the teleporter and teleport the player

    @editable PortalCompleteHUD : hud_message_device = hud_message_device{}             #HUD message that shows to everyone when the portal completes and is unlocked 

    @editable var PortalTimerSec : int = 0                                              #Amount of seconds until portal is unlocked

    @editable var PotalTimerMinutes : int =  0                                          #amount of minutes until portal is unlocked

    @editable var PortalTimerHours : int = 0                                              #Amount of hours until portal is unlocked

    var PortalFinished : logic = false                                                  #used to check if portal is finished

    StringToMessage<localizes>(value:string) : message = "{value}"              #Converts a string to message for billboard


    Initialize()<suspends> : void=                                              #Intiializes portals
        spawn:
            Timer()
        PortalMutator.AgentEntersEvent.Subscribe(TeleportPlayer)                #Activated when mutator is entered

    TeleportPlayer(Agent:agent) : void=                                         #Teleports player
        PortalTeleporter.Teleport(Agent)

    Timer()<suspends> : void=                                                   #Loop to decrease time
        loop:
            Sleep(1.0)
            var BonusZeroHours : string = ""
            var BonusZeroMinutes : string = ""
            var BonusZeroSeconds : string = ""
            if(PortalTimerHours < 10){set BonusZeroHours = "0"}
            if(PotalTimerMinutes < 10){set BonusZeroMinutes = "0"}
            if(PortalTimerSec < 10){set BonusZeroSeconds = "0"}
            PortalBillboard.SetText(StringToMessage("{BonusZeroHours}{PortalTimerHours}:{BonusZeroMinutes}{PotalTimerMinutes}:{BonusZeroSeconds}{PortalTimerSec}"))
            set PortalTimerSec -= 1
            if(PortalTimerSec <= 0):
                if(not PotalTimerMinutes <= 0):
                    set PotalTimerMinutes -= 1
                    set PortalTimerSec = 59
                else if(not PortalTimerHours <= 0):
                    set PortalTimerHours -= 1
                    set PotalTimerMinutes = 59
                    set PortalTimerSec = 59
                else:
                    set PortalFinished = true
                    PortalMutator.Enable()
                    PortalBillboard.SetText(StringToMessage(""))
                    PortalCompleteHUD.Show()
                    break

            
Portal_Manager := class(creative_device):

    @editable GameManager : Game_Manager = Game_Manager{}                   #Game manager to track players

    @editable AllPortals : []Portal = array{}                               #Array of portals

    @editable ButtonsToTeleportBack : []button_device = array{}             #Buttons used to teleport the player back from different area

    @editable BackTeleporter : teleporter_device = teleporter_device{}      #Teleporter device that players teleport to when teleporting back

    OnBegin<override>()<suspends>:void=
        
        #Initializes all portals
        for(Port : AllPortals):                     
            set Port.GameManager = GameManager
            spawn:
                Port.Initialize()       

        #Activates when a button is pressed      
        for (B : ButtonsToTeleportBack):
            B.InteractedWithEvent.Subscribe(TeleportBack)


    TeleportBack(Agent : agent) : void =        #Teleports players back
        BackTeleporter.Teleport(Agent)