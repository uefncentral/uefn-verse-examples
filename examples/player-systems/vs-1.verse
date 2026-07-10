# Gun Game Progression System
# A classic gun game mode where players progress through a sequence of weapons by getting eliminations. Players advance to the next weapon after each kill, with optional weapon shuffling and melee setba
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/vs-1?ref=github

using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /Verse.org/Verse }
using { /Fortnite.com/Game }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/Diagnostics }
 
gun_game := class(creative_device):
 
    @editable
    var WeaponList: []item_granter_device = array{}
 
    @editable
    ShuffleWeapons: logic = false
 
    @editable
    Elim_Score: int = 1
 
    @editable
    ScoreManager: score_manager_device = score_manager_device{}
 
    @editable
    VisualTracker: tracker_device = tracker_device{}
 
    @editable
    TrackerTitle: string = "Weapons Left"
 
    @editable
    MeleeSetbacks: logic = false
 
    @editable
    MeleeSetbackTracker: tracker_device = tracker_device{}
 
    @editable
    EndConditionsOn: logic = true
 
    @editable
    Win: end_game_device = end_game_device{}
 
    MakeMessage<localizes>(Text : string) : message = "{Text}"
    var AgentMap: [agent]int = map{}
 
    OnBegin<override>()<suspends>: void =
        GameSetup()
        
    GameSetup(): void =
        GetPlayspace().PlayerAddedEvent().Subscribe(SetupPlayer)
        MeleeSetbackTracker.CompleteEvent.Subscribe(MeleeSetback)
        ScoreManager.SetScoreAward(Elim_Score)
        if (ShuffleWeapons?):
            set WeaponList = Shuffle(WeaponList)
        ScoreManager.SetScoreAward(Elim_Score)
        AllPlayers := GetPlayspace().GetPlayers()
            for (Player : AllPlayers):
                SetupPlayer(Player)
 
    OnPlayerEliminated(Result: elimination_result): void =
        EliminatingCharacter := Result.EliminatingCharacter
        EliminatedCharacter := Result.EliminatedCharacter
        if:
            EliminatingFortCharacter := EliminatingCharacter?
            EliminatingAgent := EliminatingFortCharacter.GetAgent[]
            EliminatedFortCharacter := EliminatedCharacter
            EliminatedAgent := EliminatedFortCharacter.GetAgent[]
            EliminatedAgent <> EliminatingAgent
        then:
            NextWeapon(EliminatingAgent)
 
    SetupPlayer(Agent: agent): void =
        if (FortCharacter := Agent.GetFortCharacter[]):
            FortCharacter.EliminatedEvent().Subscribe(OnPlayerEliminated)
        if:
            not AgentMap[Agent]
            set AgentMap[Agent] = 0
        VisualTracker.Assign(Agent)
        VisualTracker.SetTarget(WeaponList.Length)
        VisualTracker.SetTitleText(MakeMessage(TrackerTitle))
        if (FirstItem := WeaponList[0]):
            FirstItem.GrantItem(Agent)
 
    NextWeapon(Agent: agent): void =
        ScoreManager.Activate(Agent)
        if (var CurrentItemIndex : int = AgentMap[Agent]):
            set CurrentItemIndex += 1
            if (CurrentItemIndex = WeaponList.Length and EndConditionsOn?):
                Win.Activate(Agent)
            else:
                if (NextItem := WeaponList[CurrentItemIndex]):
                    NextItem.GrantItem(Agent)
                    if {set AgentMap[Agent] = CurrentItemIndex}
 
    MeleeSetback(Agent: agent): void =
        if (var CurrentItemIndex : int = AgentMap[Agent]):
            if (CurrentItemIndex > 0 and MeleeSetbacks?):
                set CurrentItemIndex -= 1
                if (NextItem := WeaponList[CurrentItemIndex]):
                    NextItem.GrantItem(Agent)
                    if:
                        set AgentMap[Agent] = CurrentItemIndex
                VisualTracker.Decrement(Agent)
                ScoreManager.SetScoreAward(-Elim_Score)
                ScoreManager.Activate(Agent)
                ScoreManager.SetScoreAward(Elim_Score)
                MeleeSetbackTracker.Reset(Agent)