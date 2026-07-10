# Jump Counter System
# Tracks and displays player jump counts with UI feedback. Features jump boost modulation and reset functionality for competitive or challenge-based gameplay modes.  **How to use:** Add Jump_Manager dev
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/jumpcounter-mrv?ref=github


using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }

Player_Jumps := class():
    Player : player
    var JumpValue : float = 0.0

    var JumpText : text_block = text_block{}

    StringToMessage<localizes>(String : string) : message = "{String}"


    AddUI() : void=
        if(PlayerUI := GetPlayerUI[Player]):
            NewCanvas := canvas{
                Slots := array:
                    canvas_slot:
                        Widget := JumpText
                        Anchors := anchors{Minimum := vector2{X:= 0.5, Y:= 0.0} , Maximum := vector2{X:= 0.5, Y:= 0.0}}
                        Offsets := margin{Left := 0.0, Top := 135.0, Right := 165.0, Bottom := 40.0}
                        Alignment := vector2{X:= 0.5 , Y:= 0.0}
                        SizeToContent := false
                        ZOrder := 0
            }
            PlayerUI.AddWidget(NewCanvas)



    CollectJump(Amount : float) : void=
        set JumpValue += Amount
        if(NewJumpValue := Int[JumpValue]):
            JumpText.SetText(StringToMessage("{NewJumpValue}"))

    ResetJump() : void=
        set JumpValue = 0.0
        if(NewJumpValue := Int[JumpValue]):
            JumpText.SetText(StringToMessage("{NewJumpValue}"))

Jump_Manager := class(creative_device):

    var PlayerJumpMap : [player]Player_Jumps = map{}

    @editable InputTrigger : input_trigger_device = input_trigger_device{}

    @editable JumpBoosters : []movement_modulator_device = array{}

    @editable ResetTrigger : trigger_device = trigger_device{}

    OnBegin<override>()<suspends>:void=
        for(Player : GetPlayspace().GetPlayers()):
            InitializePlayer(Player)

        GetPlayspace().PlayerAddedEvent().Subscribe(InitializePlayer)

        InputTrigger.PressedEvent.Subscribe(PreHandleJump)

        ResetTrigger.TriggeredEvent.Subscribe(ResetPlayer)

        spawn:
            IncreasePlayerJumpsLoop()

    ResetPlayer(MAgent : ?agent) : void=
        if(Agent := MAgent?):
            if(PJ := PlayerJumpMap[Agent]):
                PJ.ResetJump()


    PreHandleJump(Agent: agent) : void=
        spawn:
            HandleJump(Agent)
    HandleJump(Agent: agent)<suspends> : void=
        if(FC := Agent.GetFortCharacter[] , PJ := PlayerJumpMap[Agent]):
            if(not FC.IsInAir[]):
                if(JumpValueInt := Int[PJ.JumpValue] , NewJB := JumpBoosters[JumpValueInt]):
                    Sleep(0.0)
                    NewJB.Activate(Agent)

                else:
                    if(MaximumJB := JumpBoosters[JumpBoosters.Length - 1]):
                        Sleep(0.0)
                        MaximumJB.Activate(Agent)



    IncreasePlayerJumpsLoop()<suspends> : void=
        loop:
            Sleep(1.0)
            for(Player : GetPlayspace().GetPlayers() , PJ := PlayerJumpMap[Player]):
                PJ.CollectJump(1.0)

    InitializePlayer(Agent:agent) : void=
        if(Player := player[Agent]):
            if(PlayerExists := PlayerJumpMap[Player]):

            else:
                if:
                    set PlayerJumpMap[Player] = Player_Jumps{Player := Player}
                then:
                    if(PJ := PlayerJumpMap[Player]):
                        PJ.AddUI()