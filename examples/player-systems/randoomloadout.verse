# Randoomloadout
# Verse code for Randoomloadout - UEFN/Fortnite Creative implementation
# Difficulty: intermediate  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/randoomloadout?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /Verse.org/Random }


RandomLoadouts1 := class(creative_device):


    @editable
    Weapon1Array : []item_granter_device = array{}


    @editable
    ButtonArray : []button_device = array{}

    @editable
    Award1 : accolades_device = accolades_device{}
    @editable
    Award2 : accolades_device = accolades_device{}
    @editable
    Award3 : accolades_device = accolades_device{}
    @editable
    Award4 : accolades_device = accolades_device{}
    @editable
    Award5 : accolades_device = accolades_device{}

    # Initialize when the game begins
    OnBegin<override>()<suspends>: void =
        # Get all players
        Playspace := GetPlayspace()
        AllPlayers := Playspace.GetPlayers()

        for (Button : ButtonArray):
            Button.InteractedWithEvent.Subscribe(OnButtonInteracted)

    OnButtonInteracted(Agent : agent) : void =
        Print("Button interacted")
        GenerateLoadout(Agent)


    GenerateLoadout(Agent: agent): void =
        if (Weapon1Array.Length > 0):
            RandomNum1 := GetRandomInt(0, Weapon1Array.Length - 1)
            if (Granter := Weapon1Array[RandomNum1]):
                Granter.GrantItem(Agent)
                Award2.Award(Agent)
