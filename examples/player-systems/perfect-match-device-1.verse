# Perfect Match Memory Game
# A memory matching game device that shows players a sequence of images on tiles, then challenges them to recreate the pattern. Players must remember and select the correct tiles in the proper sequence 
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/perfect-match-device-1?ref=github


using { /Fortnite.com/Game }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Random }
using { /Verse.org/Assets }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

PerfectMatchModule := module:

    ToolTipShowAmounts<localizes> : message := "Determines the total duration of image showing, it's calculated as: TotalIconShowSeconds = 2*IconShowAmounts + 2."
    ToolTipIntermediaryCountdownSeconds<localizes> : message := "This determines the short duration after images are done being shown and before the image countdown begins."
    ToolTipDisabledSeconds<localizes> : message := "Duration that the tiles remain disabled."

    ToolTipIntermediaryCountdownAudio<localizes> : message := "This should be a looping audio."

    ToolTipImageShowAudio<localizes> : message = "A tick sound that is played when image are shown."
    ToolTipImageHideAudio<localizes> : message = "A tick sound that is played when images are hidden."

    ToolTipRow<localizes> : message = "Each tile must be a plane."

    ToolTipGameStartTrigger<localizes> : message = "Trigger this, to start the game."
    ToolTipOnGameEndTrigger<localizes> : message = "Perfect Match Device, triggers this trigger, when the game ends."
    ToolTipOnQualifiedTrigger<localizes> : message = "Perfect Match Device, triggers this trigger for each winner player, when the game ends."

    ToolTipGameStartCountdownHudMessager<localizes> : message = "This hud displays: 3, 2, 1, GO!, at the start of the game. Shown for everyone."
    ToolTipMatchCountdownHudMessager<localizes> : message = "Displays the countdown seconds when the match is active and images are being shown. Shown for everyone."
    ToolTipQualifiedHudMessager<localizes> : message = "'Qualified ui', Shown for all the players that wins the game, at the end of the game. Shown per player."

    row_data := class<concrete>:
        @editable { ToolTip := ToolTipRow }
        Row : []creative_prop = array{}

    agent_data := class:
        var bInGame : logic = false

    perfect_match_device := class(creative_device):

        # FROZENPAWN: Set your desired default tile texture.
        DefaultTileTexture : texture = Textures.T_QuestionMark

        # FROZENPAWN: Set your tile image textures in this array.
        TileImageTextures : []texture = array
        {
            Textures.T_Apple,
            Textures.T_Banana,
            Textures.T_Cherry,
            Textures.T_Coconut,
            Textures.T_Corn,
            Textures.T_Grape,
            Textures.T_Kiwi,
            Textures.T_Klomberry,
            Textures.T_Lemon,
            Textures.T_Lettuce,
            Textures.T_Orange,
            Textures.T_Peach,
            Textures.T_Pineapple,
            Textures.T_RedPepper,
            Textures.T_Watermelon
        }

        @editable { ToolTip := ToolTipGameStartTrigger }
        GameStartTrigger : trigger_device = trigger_device{}

        @editable { ToolTip := ToolTipOnGameEndTrigger }
        OnGameEndTrigger : trigger_device = trigger_device{}

        @editable { ToolTip := ToolTipOnQualifiedTrigger }
        OnQualifiedTrigger  : trigger_device = trigger_device{}

        @editable
        GameAreaTeleporters : []teleporter_device = array{}
        @editable
        LobbyAreaTeleporters : []teleporter_device = array{}

        @editable{ ToolTip := ToolTipShowAmounts }
        IconShowAmounts : type {_X:int where _X >= 1} = 1

        @editable{ ToolTip := ToolTipIntermediaryCountdownSeconds }
        IntermediaryCountdownSeconds : type {_X:float where _X >= 1.0} = 1.0

        @editable
        LastCountdownSeconds : type {_X:int where _X >= 1} = 1

        @editable{ ToolTip := ToolTipDisabledSeconds }
        TilesDisabledSeconds : type {_X:float where _X >= 1.0} = 1.0

        @editable{ ToolTip := ToolTipIntermediaryCountdownAudio }
        IntermediaryCountdownAudio : audio_player_device = audio_player_device{}

        @editable { ToolTip := ToolTipImageShowAudio }
        ImageShowAudio : audio_player_device = audio_player_device{}
        @editable { ToolTip := ToolTipImageHideAudio }
        ImageHideAudio : audio_player_device = audio_player_device{}

        @editable{ ToolTip := ToolTipGameStartCountdownHudMessager }
        GameStartCountdownHudMessager : hud_message_device = hud_message_device{}
        @editable { ToolTip := ToolTipMatchCountdownHudMessager }
        MatchCountdownHudMessager : hud_message_device = hud_message_device{}
        @editable
        LastCountdownHudMessager : hud_message_device = hud_message_device{}
        @editable{ ToolTip := ToolTipQualifiedHudMessager }
        QualifiedHudMessager : hud_message_device = hud_message_device{}

        @editable{}
        TileRows : []row_data = array{}

        @editable
        SelectedImageDisplayPanels : []creative_prop = array{}

        @editable
        MinImageGuessesInAMatch : type {_X:int where _X >= 1} = 1
        @editable
        MaxImageGuessesInAMatch : type {_X:int where _X >= 1} = 1

        @editable
        MinSelectedImages : type {_X:int where _X >= 2} = 2
        @editable
        MaxSelectedImages : type {_X:int where _X >= 2} = 2

        TextForUI<localizes>(Text : string) : message = "{Text}"
        TextForUIPlayer<localizes>(Player : player) : message = "{Player}"

        var AgentMap : [agent]agent_data = map{}
        var PlayingPlayers : []player = array{}
        var TextureMaterials : []Materials.M_Tile_material = array{}
        var DefaultTextureMaterial : Materials.M_Tile_material = Materials.M_Tile_material{}

        var IconShowSeconds : int = 0
        var Rows : int = 0
        var Cols : int = 0

        OnBegin<override>()<suspends>:void=
            Print("OnBegin")

            for (Player : GetPlayspace().GetPlayers()):
                OnPlayerJoined(Player)

            GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerJoined)

            set IconShowSeconds = IconShowAmounts*2 + 2

            GameStartTrigger.TriggeredEvent.Subscribe(OnGameStartTrigger)

            set Rows = TileRows.Length
            set Cols = if (TileRow := TileRows[0])
            then TileRow.Row.Length
            else 0

            # (FROZENPAWN): Set the texture materials.
            set TextureMaterials = for (I := 1 .. TileImageTextures.Length):
                Materials.M_Tile_material{}            
            for (I := 0 .. TextureMaterials.Length-1, Mat := TextureMaterials[I], Tex := TileImageTextures[I]):
                set Mat.Image = Tex

            set DefaultTextureMaterial.Image = DefaultTileTexture

            for (DisplayPanel : SelectedImageDisplayPanels):
                DisplayPanel.SetMaterial(DefaultTextureMaterial)
                DisplayPanel.Hide()
            
            for (TileRow : TileRows):
                for (Tile : TileRow.Row):
                    Tile.SetMaterial(DefaultTextureMaterial)

        OnPlayerJoined(Player : player):void=
            if (not AgentMap[Player]):
                if (set AgentMap[Player] = agent_data{}){}
                if (FC := Player.GetFortCharacter[]):
                    FC.EliminatedEvent().Subscribe(OnPlayerEliminated)

        OnPlayerEliminated(EliminationResult : elimination_result):void=
            if (EliminatedAgent := EliminationResult.EliminatedCharacter.GetAgent[],
            EliminatedAgentData := AgentMap[EliminatedAgent]):
                set EliminatedAgentData.bInGame = false

        OnGameStartTrigger(MaybeAgent : ?agent):void=
            Print("OnGameStartTrigger")

            if (PlayingPlayers.Length > 0):
                Print("Error: Game is already active!")
                return

            set PlayingPlayers = GetPlayspace().GetPlayers()
            if (PlayingPlayers.Length < 2):
                Print("Error: Need at least 2 players.")
                return

            for (I := 0 .. PlayingPlayers.Length-1, PlayingPlayer := PlayingPlayers[I],
            TeleporterIndex := Mod[I, GameAreaTeleporters.Length],
            GameAreaTeleporter := GameAreaTeleporters[TeleporterIndex]):
                GameAreaTeleporter.Teleport(PlayingPlayer)

            spawn { AsyncGameLoop() }

        AsyncGameLoop()<suspends>:void=
            ImageGuesses := GetRandomInt(MinImageGuessesInAMatch, MaxImageGuessesInAMatch)
            var TileImageIndexes : [][]int = array{}

            QuarterTiles : int = if (Quarter := Int[(Rows*Cols*1.0)/4.0])
            then Quarter
            else Rows

            ImageIndexRow : []int = for (I := 1 .. Cols):
                -1

            set TileImageIndexes = for (I := 1 .. Rows):
                ImageIndexRow

            var CurrentGuess : int = -1

            # (FROZENPAWN): Set the state for playing players.
            for (PlayingPlayer : PlayingPlayers, AgentData := AgentMap[PlayingPlayer]):
                set AgentData.bInGame = true

            loop:
                var PlayingPlayersCount : int = 0
                for (PlayingPlayer : PlayingPlayers, AgentData := AgentMap[PlayingPlayer]):
                    if (AgentData.bInGame = true):
                        set PlayingPlayersCount += 1

                Print("Playing Players Count: {PlayingPlayersCount}")
                if (PlayingPlayersCount <= 1):
                    break

                set CurrentGuess += 1
                if (CurrentGuess = ImageGuesses):
                    break

                # (FROZENPAWN): A little wait between image guessings.
                Sleep(1.0)

                # (FROZENPAWN): Generate an array of shuffled indexes to choose textures randomly.
                var ShuffledTextureIndexes : []int = array{}
                set ShuffledTextureIndexes = for (I := 0 .. TileImageTextures.Length-1):
                    I
                set ShuffledTextureIndexes = Shuffle(ShuffledTextureIndexes)

                SelectedTextureCount := GetRandomInt(MinSelectedImages, MaxSelectedImages)
                var SelectedTextureIndexes : []int = array{}
                set SelectedTextureIndexes = for (I := 0 .. SelectedTextureCount-1, ShuffledTextureIndex := ShuffledTextureIndexes[I]):
                    ShuffledTextureIndex

                # (FROZENPAWN): Decide the amounts of each texture type.
                var TexturesToPut : int = Rows*Cols 
                var TextureAmounts : []int = array{}
                set TextureAmounts = for (I := 1 .. SelectedTextureCount):
                    1
    
                set TexturesToPut -= SelectedTextureCount
                for (I := 1 .. TexturesToPut):
                    RandomTextureIndex := GetRandomInt(0, SelectedTextureCount-1)
                    if (set TextureAmounts[RandomTextureIndex] += 1){}

                # (FROZENPAWN): Init and shuffle the tuple array.
                var TileRowColIndexesToShow : []tuple(int, int) = array{}
                for (RowIndex := 0 .. Rows-1):
                    set TileRowColIndexesToShow += for (ColIndex := 0 .. Cols-1):
                        (RowIndex, ColIndex)

                # (FROZENPAWN): Set tile image indexes, according to the amounts.
                set TileRowColIndexesToShow = Shuffle(TileRowColIndexesToShow)
                var IteratedTupleIndex : int = 0
                for (SelectedTextureIndex := 0 .. SelectedTextureCount-1, TextureIndex := SelectedTextureIndexes[SelectedTextureIndex],
                TextureAmount := TextureAmounts[SelectedTextureIndex]):
                    for (I := 0 .. TextureAmount-1, Tuple := TileRowColIndexesToShow[IteratedTupleIndex + I]):
                        RowIndex := Tuple(0)
                        ColIndex := Tuple(1)
                        if (set TileImageIndexes[RowIndex][ColIndex] = TextureIndex){}
                        Print("Row,Col - Texture Index: ({RowIndex},{ColIndex}) - {TextureIndex}")

                    set IteratedTupleIndex += TextureAmount

                # (FROZENPAWN): Initial countdown: 3-2-1-GO!
                for (I := 0 .. 2):
                    GameStartCountdownHudMessager.Show(TextForUI("{3-I}"), ?DisplayTime := 1.0)
                    Sleep(1.0)

                GameStartCountdownHudMessager.Show(TextForUI("GO!"), ?DisplayTime := 1.0)

                MatchCountdownHudMessager.Show()
                for (I := 0 .. (IconShowSeconds-1)):
                    MatchCountdownHudMessager.SetText(TextForUI("{IconShowSeconds-I}"))
                    if (Mod[I, 2] = 0):
                        ImageShowAudio.Play()

                        # (FROZENPAWN): All tiles back to default.
                        for (RowIndex := 0 .. Rows-1):
                            for (ColIndex := 0 .. Cols-1, Tile := TileRows[RowIndex].Row[ColIndex]):
                                Tile.SetMaterial(DefaultTextureMaterial)

                        # (FROZENPAWN): Pick random planes and set their textures.
                        set TileRowColIndexesToShow = Shuffle(TileRowColIndexesToShow)
                        Print("---- SHOWING ----")
                        for (J := 0 .. QuarterTiles-1, Tuple := TileRowColIndexesToShow[J]):
                            RowIndex := Tuple(0)
                            ColIndex := Tuple(1)

                            if (TextureIndex := TileImageIndexes[RowIndex][ColIndex],
                            Tile := TileRows[RowIndex].Row[ColIndex], Mat := TextureMaterials[TextureIndex]):
                                Print("Shown Tile: ({RowIndex},{ColIndex}), ShownTextureIndex: {TextureIndex}")
                                Tile.SetMaterial(Mat)

                        Print("-----------------")
                    else:
                        ImageHideAudio.Play()

                    Sleep(1.0)

                MatchCountdownHudMessager.Hide()

                # (FROZENPAWN): All tiles back to default.
                for (RowIndex := 0 .. Rows-1):
                    for (ColIndex := 0 .. Cols-1, Tile := TileRows[RowIndex].Row[ColIndex]):
                        Tile.SetMaterial(DefaultTextureMaterial)

                IntermediaryCountdownAudio.Play()
                Sleep(IntermediaryCountdownSeconds)
                IntermediaryCountdownAudio.Stop()

                # (FROZENPAWN): Show display panels.
                EnabledSelectedTextureIndex := GetRandomInt(0, SelectedTextureCount-1)
                Print("EnabledSelectedTextureIndex: {EnabledSelectedTextureIndex}")

                if (EnabledTextureIndex := SelectedTextureIndexes[EnabledSelectedTextureIndex],
                EnabledMaterial := TextureMaterials[EnabledTextureIndex]):
                    Print("EnabledTextureIndex: {EnabledTextureIndex}")

                    for (DisplayPanel : SelectedImageDisplayPanels):
                        DisplayPanel.SetMaterial(EnabledMaterial)
                        DisplayPanel.Show()

                LastCountdownHudMessager.Show()

                for (I := 0 .. LastCountdownSeconds):
                    LastCountdownHudMessager.SetText(TextForUI("{LastCountdownSeconds-I}"))
                    Sleep(1.0)

                LastCountdownHudMessager.Hide()

                # (FROZENPAWN): Select a texture index, disable all other tiles.
                if (EnabledTextureIndex := SelectedTextureIndexes[EnabledSelectedTextureIndex],
                EnabledMaterial := TextureMaterials[EnabledTextureIndex]):
                    for (RowIndex := 0 .. Rows-1, TileRow := TileRows[RowIndex]):
                        for (ColIndex := 0 .. Cols-1, Tile := TileRow.Row[ColIndex]):
                            if (TileImageIndexes[RowIndex][ColIndex] = EnabledTextureIndex):
                                Tile.SetMaterial(EnabledMaterial)
                                Tile.Show()
                            else:
                                Tile.Hide()

                Sleep(TilesDisabledSeconds)

                # (FROZENPAWN): Show all tiles, set all tiles to default texture.
                for (RowIndex := 0 .. Rows-1, TileRow := TileRows[RowIndex]):
                    for (ColIndex := 0 .. Cols-1, Tile := TileRow.Row[ColIndex]):
                        Tile.Show()
                        Tile.SetMaterial(DefaultTextureMaterial)

                # (FROZENPAWN): Hide display panels.
                for (I := 0 .. SelectedImageDisplayPanels.Length-1, DisplayPanel := SelectedImageDisplayPanels[I]):
                    DisplayPanel.Hide()

            OnGameEndTrigger.Trigger()
            for (I := 0 .. PlayingPlayers.Length-1, PlayingPlayer := PlayingPlayers[I],
            AgentData := AgentMap[PlayingPlayer], AgentData.bInGame = true,
            TeleporterIndex := Mod[I, LobbyAreaTeleporters.Length],
            LobbyAreaTeleporter := LobbyAreaTeleporters[TeleporterIndex]):
                set AgentData.bInGame = false
                OnQualifiedTrigger.Trigger(PlayingPlayer)
                QualifiedHudMessager.Show(PlayingPlayer)
                LobbyAreaTeleporter.Teleport(PlayingPlayer)

            set PlayingPlayers = array{}