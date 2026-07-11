# Boss Health Bar UI
# Creates a custom visual health bar interface that tracks and displays a boss creature's health status in real-time. The system spawns a boss enemy and shows all players a dynamic health bar that updat
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/boss-custom-health-bar-device-1?ref=github


using { /Verse.org/Assets }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }
using { /Fortnite.com/UI }
using { /Fortnite.com/Game }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

boss_custom_health_bar_device := class(creative_device):

    @editable
    PlayerSpawners : []player_spawner_device = array{}

    @editable
    BossSpawner : creature_spawner_device = creature_spawner_device{}

    TextForUI<localizes>(InText : string) : message = "{InText}"

    var CanvasPerAgent : [agent]canvas = map{}

    var BossMaxHealth : float = 0.0
    var BossPreviousHealth : float = 0.0
    var BossCurrentHealth : float = 0.0
    var BossHealthUIMGLastSetTime : float = 0.0
    var bUpdateBossHealthUI : logic = false

    OnBegin<override>()<suspends>:void=
        Print("OnBegin")

        for (PlayerSpawner : PlayerSpawners):
            PlayerSpawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

        BossSpawner.SpawnedEvent.Subscribe(OnBossSpawned)

    AsyncUpdateBossHealthUI()<suspends>:void=
        BGIndex := 0
        MGIndex := 1
        FGIndex := 2

        for (Player : GetPlayspace().GetPlayers(), Canvas := CanvasPerAgent[Player],
        BarCanvas : canvas = canvas[Canvas.Slots[0].Widget]):
            if (BGBlock : texture_block = texture_block[BarCanvas.Slots[BGIndex].Widget],
            MGBlock : texture_block = texture_block[BarCanvas.Slots[MGIndex].Widget],
            FGBlock : texture_block = texture_block[BarCanvas.Slots[FGIndex].Widget]):

                BGBlockSize := BGBlock.GetDesiredSize()
                FGBlock.SetDesiredSize(BGBlockSize)
                MGBlock.SetDesiredSize(BGBlockSize)

            Canvas.SetVisibility(widget_visibility.Visible)
            BarCanvas.SetVisibility(widget_visibility.Visible)

        BossHealthUIDepleteSecondsFG : float = 5.0
        BossHealthUIDepleteSecondsMG : float = 7.0
        BossHealthUIWaitSecondsMG : float = 0.75
        ExitWaitSeconds : float = 3.0
        DeltaTime := 0.033

        FGDepleteDivision := BossHealthUIDepleteSecondsFG / DeltaTime
        MGDepleteDivision := BossHealthUIDepleteSecondsMG / DeltaTime
        FGDepleteRate := 1.0 / FGDepleteDivision
        MGDepleteRate := 1.0 / MGDepleteDivision

        var bSetToTargetFG : logic = false
        var bSetToTargetMG : logic = false
        var bBossDead : logic = false

        loop:
            Sleep(DeltaTime)
            if (bUpdateBossHealthUI = true):
                CurrentTime := GetSimulationElapsedTime()
                Players := GetPlayspace().GetPlayers()

                TargetFillRate := BossCurrentHealth / BossMaxHealth

                for (Player : Players, Canvas := CanvasPerAgent[Player],
                BarCanvas : canvas = canvas[Canvas.Slots[0].Widget]):
                    if (BGBlock : texture_block = texture_block[BarCanvas.Slots[BGIndex].Widget],
                    MGBlock : texture_block = texture_block[BarCanvas.Slots[MGIndex].Widget],
                    FGBlock : texture_block = texture_block[BarCanvas.Slots[FGIndex].Widget]):

                        BGBlockSize := BGBlock.GetDesiredSize()
                        FillRateFG := FGBlock.GetDesiredSize().X / BGBlockSize.X

                        var NewFillRateFG : float = FillRateFG - FGDepleteRate
                        if (NewFillRateFG <= TargetFillRate or bSetToTargetFG = true):
                            set NewFillRateFG = TargetFillRate
                            set bSetToTargetFG = true

                        FGBlock.SetDesiredSize(vector2{ X:= BGBlockSize.X * NewFillRateFG, Y := BGBlockSize.Y })

                        if ((BossHealthUIMGLastSetTime + BossHealthUIWaitSecondsMG) < CurrentTime):
                            FillRateMG := MGBlock.GetDesiredSize().X / BGBlockSize.X

                            var NewFillRateMG : float = FillRateMG - MGDepleteRate
                            if (NewFillRateMG <= TargetFillRate or bSetToTargetMG = true):
                                set NewFillRateMG = TargetFillRate
                                set bSetToTargetMG = true
                                set bUpdateBossHealthUI = false

                            MGBlock.SetDesiredSize(vector2{ X := BGBlockSize.X * NewFillRateMG, Y := BGBlockSize.Y })

                set bSetToTargetFG = false
                set bSetToTargetMG = false
                if (TargetFillRate = 0.0 and bUpdateBossHealthUI = false):
                    break

        Sleep(ExitWaitSeconds)
        for (Player : GetPlayspace().GetPlayers(), Canvas := CanvasPerAgent[Player],
        BarCanvas : canvas = canvas[Canvas.Slots[0].Widget]):
            BarCanvas.SetVisibility(widget_visibility.Collapsed)

    OnPlayerSpawned(Agent : agent):void=
        if (not CanvasPerAgent[Agent], Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
            CustomCanvas := CreateUI()
            CustomCanvas.SetVisibility(widget_visibility.Collapsed)

            PlayerUI.AddWidget(CustomCanvas)
            if (set CanvasPerAgent[Agent] = CustomCanvas){}

    OnBossSpawned(Agent : agent):void=
        if (FortCharacter := Agent.GetFortCharacter[]):
            set BossMaxHealth = FortCharacter.GetMaxHealth()
            set BossPreviousHealth = BossMaxHealth
            set BossCurrentHealth = BossMaxHealth
            set bUpdateBossHealthUI = false

            FortCharacter.DamagedEvent().Subscribe(OnBossDamaged)
            spawn{AsyncUpdateBossHealthUI()}

    OnBossDamaged(DamageResult : damage_result):void=
        if (FortCharacter := fort_character[DamageResult.Target]):
            Health := FortCharacter.GetHealth()

            set BossCurrentHealth = if (Health < 0.0)
            then 0.0
            else Health

            if (bUpdateBossHealthUI = false):
                set BossHealthUIMGLastSetTime = GetSimulationElapsedTime()

            set bUpdateBossHealthUI = true

    CreateUI():canvas=
        var CanvasSlots : []canvas_slot = array{}

        set CanvasSlots += array
        {
            CanvasSlot0 := canvas_slot:
                Anchors := anchors{ Minimum := vector2{ X := 0.5, Y := 0.0 }, Maximum := vector2{ X := 0.5, Y := 0.0 } }
                Offsets := margin{ Top := 96.0, Left := 0.0, Right := 0.0, Bottom := 0.0 }
                Alignment := vector2{ X := 0.5, Y := 0.5 }
                ZOrder := 1
                Widget := CreateBar(1024.0, 40.0, Textures.BossBarBG, Textures.BossBarMG, Textures.BossBarFG,
                Textures.BossBarBorder, "SOME BOSS", NamedColors.White)
        }

        Canvas : canvas = canvas:
            Slots := CanvasSlots

        return Canvas

    CreateBar(SizeX : float, SizeY : float, BGImage : texture, MGImage : texture, FGImage : texture,
    BorderImage : texture, TextToPut : string, TextColor : color):canvas=
        var CanvasSlots : []canvas_slot = array{}

        set CanvasSlots += array
        {            
            CanvasSlot0 := canvas_slot:
                Anchors := anchors{ Minimum := vector2{}, Maximum := vector2{} }
                Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                Alignment := vector2{ X := 0.0, Y := 0.0 }
                SizeToContent := true
                ZOrder := 1
                Widget := texture_block{ DefaultImage := BGImage, DefaultDesiredSize := vector2{ X := SizeX, Y := SizeY} }
        }

        set CanvasSlots += array
        {            
            CanvasSlot1 := canvas_slot:
                Anchors := anchors{ Minimum := vector2{}, Maximum := vector2{} }
                Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                Alignment := vector2{ X := 0.0, Y := 0.0 }
                SizeToContent := true
                ZOrder := 1
                Widget := texture_block{ DefaultImage := MGImage, DefaultDesiredSize := vector2{ X := SizeX, Y := SizeY} }
        }

        set CanvasSlots += array
        {            
            CanvasSlot2 := canvas_slot:
                Anchors := anchors{ Minimum := vector2{}, Maximum := vector2{} }
                Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                Alignment := vector2{ X := 0.0, Y := 0.0 }
                SizeToContent := true
                ZOrder := 1
                Widget := texture_block{ DefaultImage := FGImage, DefaultDesiredSize := vector2{ X := SizeX, Y := SizeY} }
        }

        set CanvasSlots += array
        {            
            CanvasSlot3 := canvas_slot:
                Anchors := anchors{ Minimum := vector2{}, Maximum := vector2{} }
                Offsets := margin{ Top := -15.0, Left := -15.0, Right := 0.0, Bottom := 0.0}
                Alignment := vector2{ X := 0.0, Y := 0.0 }
                SizeToContent := true
                ZOrder := 1
                Widget := texture_block{ DefaultImage := BorderImage, DefaultDesiredSize := vector2{ X := SizeX + 30.0, Y := SizeY + 30.0 } }
        }

        set CanvasSlots += array
        {
            CanvasSlot4 := canvas_slot:
                Anchors := anchors{ Minimum := vector2{ X := 0.5, Y := 0.0 }, Maximum := vector2{ X := 0.5, Y := 0.0 } }
                Offsets := margin{ Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                Alignment := vector2{ X := 0.5, Y := 0.0 }
                SizeToContent := true
                ZOrder := 1
                Widget := text_block{ DefaultText := TextForUI(TextToPut), DefaultTextColor := TextColor }
        }

        Canvas : canvas = canvas:
            Slots := CanvasSlots

        return Canvas