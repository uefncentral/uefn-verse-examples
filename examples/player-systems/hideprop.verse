# Hideprop
# Verse code for Hideprop - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/hideprop?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }
using { /UnrealEngine.com/Temporary/Diagnostics }
using {/Fortnite.com/Teams}
using {/Verse.org/Simulation}
using {/Fortnite.com/Characters}
using {/Verse.org/Random}
using {/Fortnite.com/Game}
using {/Fortnite.com/FortPlayerUtilities}
using {/UnrealEngine.com/Temporary/SpatialMath}
HideProps := class(creative_device):

    @editable
    Switch : switch_device = switch_device{}

    @editable
    HideBlock : creative_prop = creative_prop{}

    var OgTransform : transform = transform{}

    HideAll(Agent:agent):void=
        spawn{HideBlock.MoveTo(transform{Scale:= vector3{X:= 0.1, Y:= 0.1, Z:= 0.1}, Rotation:= OgTransform.Rotation, Translation:= vector3{X:= 0.0, Y:= -768.0, Z:= -4224.0}}, 0.1)}

    ShowAll(Agent:agent):void=
        spawn{HideBlock.MoveTo(OgTransform, 0.1)}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=

        set OgTransform = HideBlock.GetTransform()

        Switch.TurnedOnEvent.Subscribe(HideAll)
        Switch.TurnedOffEvent.Subscribe(ShowAll)