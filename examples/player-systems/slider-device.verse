# Interactive Player Slider UI
# Creates a dynamic UI slider that responds to player actions, increasing when jumping and decreasing when crouching. The slider displays a visual fill rate that updates in real-time based on player inp
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/slider-device?ref=github


using { /Fortnite.com/UI }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }

slider_device := class(creative_device):

	@editable
	PlayerSpawners : []player_spawner_device = array{}
	TextForUI<localizes>(Text : string) : message = "{Text}"

	var CanvasPerPlayer : [player]canvas = map{}
	
	OnBegin<override>()<suspends> : void=
		Print("OnBegin")

		for (PlayerSpawner : PlayerSpawners):
			PlayerSpawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

	OnPlayerSpawned(Agent : agent):void=
		if (Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
			CustomCanvas := CreateCustomCanvas()
			PlayerUI.AddWidget(CustomCanvas)
			if (set CanvasPerPlayer[Player] = CustomCanvas){}

			if (FortCharacter := Player.GetFortCharacter[]):
				FortCharacter.JumpedEvent().Subscribe(OnPlayerJumped)
				FortCharacter.CrouchedEvent().Subscribe(OnPlayerCrouched)

	OnPlayerJumped(FortCharacter : fort_character):void=
		if (Agent := FortCharacter.GetAgent[], Player := player[Agent], Canvas := CanvasPerPlayer[Player]):
			var CurrentFillRate : float = CalculateSliderFillRate(Canvas) + 0.1
			set CurrentFillRate = Clamp(CurrentFillRate, 0.0, 1.0)
			UpdateSlider(Canvas, CurrentFillRate)

	OnPlayerCrouched((FortCharacter : fort_character, IsCrouching : logic)):void=
		if (IsCrouching?, Agent := FortCharacter.GetAgent[], Player := player[Agent], Canvas := CanvasPerPlayer[Player]):
			var CurrentFillRate : float = CalculateSliderFillRate(Canvas) - 0.1
			set CurrentFillRate = Clamp(CurrentFillRate, 0.0, 1.0)
			UpdateSlider(Canvas, CurrentFillRate)

	CalculateSliderFillRate(Canvas : canvas):float=
		var FillRate : float = 0.0

		if (OverlayWidget := overlay[Canvas.Slots[0].Widget],
		OverlayBackground := color_block[OverlayWidget.Slots[0].Widget],
		OverlayForeground := color_block[OverlayWidget.Slots[1].Widget]):
			set FillRate = OverlayForeground.GetDesiredSize().X / OverlayBackground.GetDesiredSize().X

		return FillRate

	UpdateSlider(Canvas : canvas, FillRate : float):void=
		if (OverlayWidget := overlay[Canvas.Slots[0].Widget],
		OverlayBackground := color_block[OverlayWidget.Slots[0].Widget],
		OverlayForeground := color_block[OverlayWidget.Slots[1].Widget]):
			FullValue := OverlayBackground.GetDesiredSize().X
			NewFillValue := FullValue * FillRate
			OverlayForeground.SetDesiredSize(vector2{ X := NewFillValue, Y := OverlayBackground.GetDesiredSize().Y })

	CreateCustomCanvas():canvas=
		var CustomCanvasSlots : []canvas_slot = array{}

		set CustomCanvasSlots += array
		{
			CanvasSlot0 := canvas_slot:
				Anchors := anchors { Minimum := vector2{ X := 0.01, Y := 0.5 }, Maximum := vector2 { X := 0.01, Y := 0.5 } } 
				Alignment := vector2 { X := 0.0, Y := 0.5 }
				SizeToContent := true
				Widget := overlay:
					Slots := array:
						overlay_slot:
							HorizontalAlignment := horizontal_alignment.Left
							VerticalAlignment := vertical_alignment.Center
							Widget := color_block { DefaultColor := NamedColors.Black,
							DefaultDesiredSize := vector2 { X := 296.0, Y := 40.0 } }
						overlay_slot:
							HorizontalAlignment := horizontal_alignment.Left
							VerticalAlignment := vertical_alignment.Center
							Widget := color_block { DefaultColor := NamedColors.Green,
							DefaultDesiredSize := vector2 { X := 0.0, Y := 40.0 } }
						overlay_slot:
							HorizontalAlignment := horizontal_alignment.Center
							VerticalAlignment := vertical_alignment.Center
							Widget := text_block{ DefaultTextColor := NamedColors.White, DefaultText := TextForUI("JUMP POINTS") }
		}
		
		CustomCanvas : canvas = canvas:
			Slots := CustomCanvasSlots

		return CustomCanvas
