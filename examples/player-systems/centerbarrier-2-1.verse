# Player Proximity Barrier
# Creates a toggleable barrier system that temporarily removes a blocking prop when players enter a designated area, then restores it after 3 seconds. The barrier can be manually controlled via a switch
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/centerbarrier-2-1?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }


barrier := class(creative_device):
    @editable PlayerCount : player_counter_device = player_counter_device{}    #Counter  device used to remove barrier
    @editable Barrier : barrier_device = barrier_device{}               #Device to block players
    @editable Blocker : creative_prop = creative_prop{}                   #Prop used to separate players
    @editable Switch : switch_device = switch_device{}                   #Switch used to enable/disable barrier
    @editable BlockerPOS : vector3 = vector3{}                          #position in the center of the 1v1


    OnBegin<override>()<suspends>:void=
       PlayerCount.CountSucceedsEvent.Subscribe(TakeDownBarrier)
       Switch.TurnedOnEvent.Subscribe(TurnedOn)
       Switch.TurnedOffEvent.Subscribe(TurnedOff)

    TakeDownBarrier() : void =       #Takes down barrier when players are within range
        if(Blocker.TeleportTo[vector3{X:=100000.0,Y:=100000.0,Z:=-100000.0},Blocker.GetTransform().Rotation]){}
        spawn:
            ShowBar()
    ShowBar()<suspends> : void=            #after three seconds, barrier reappears
        Sleep(3.0)
        if(Blocker.TeleportTo[BlockerPOS,Blocker.GetTransform().Rotation]){}

    TurnedOn(Agent:agent) : void=       #when turned on blocker will be enabled
        if(Blocker.TeleportTo[BlockerPOS,Blocker.GetTransform().Rotation]){}
        PlayerCount.Enable()

    TurnedOff(Agent:agent) : void=       #when turned off, blocker will be disabled
        if(Blocker.TeleportTo[vector3{X:=10000.0,Y:=10000.0,Z:=-10000.0},Blocker.GetTransform().Rotation]){}
        PlayerCount.Disable()
