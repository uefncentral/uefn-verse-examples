# Laser Doors
# Verse code for Laser Doors - UEFN/Fortnite Creative implementation
# Difficulty: intermediate  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/laser-doors?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

Things := class<concrete>():
    @editable Switch : switch_device = switch_device{}

    @editable Prop : creative_prop = creative_prop{}

    @editable DmgVol : damage_volume_device = damage_volume_device{}

# A Verse-authored creative device that can be placed in a level
LaserDoors := class(creative_device):

    @editable Plot1 : Things = Things{}
    @editable Plot2 : Things = Things{}
    @editable Plot3 : Things = Things{}
    @editable Plot4 : Things = Things{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        Plot1.Switch.TurnedOnEvent.Subscribe(Plot1On)
        Plot1.Switch.TurnedOffEvent.Subscribe(Plot1Off)
        Plot2.Switch.TurnedOnEvent.Subscribe(Plot2On)
        Plot2.Switch.TurnedOffEvent.Subscribe(Plot2Off)
        Plot3.Switch.TurnedOnEvent.Subscribe(Plot3On)
        Plot3.Switch.TurnedOffEvent.Subscribe(Plot3Off)
        Plot4.Switch.TurnedOnEvent.Subscribe(Plot4On)
        Plot4.Switch.TurnedOffEvent.Subscribe(Plot4Off)

    Plot1On(Agent : agent):void=
        Plot1.Prop.Show()
        Plot1.DmgVol.Enable()
    Plot1Off(Agent : agent):void=
        Plot1.Prop.Hide()
        Plot1.DmgVol.Disable()

    Plot2On(Agent : agent):void=
        Plot2.Prop.Show()
        Plot2.DmgVol.Enable()
    Plot2Off(Agent : agent):void=
        Plot2.Prop.Hide()
        Plot2.DmgVol.Disable()

    Plot3On(Agent : agent):void=
        Plot3.Prop.Show()
        Plot3.DmgVol.Enable()
    Plot3Off(Agent : agent):void=
        Plot3.Prop.Hide()
        Plot3.DmgVol.Disable()

    Plot4On(Agent : agent):void=
        Plot4.Prop.Show()
        Plot4.DmgVol.Enable()
    Plot4Off(Agent : agent):void=
        Plot4.Prop.Hide()
        Plot4.DmgVol.Disable()
    

