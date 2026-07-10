# Fortnite Tycoon System
# A comprehensive tycoon game system for Fortnite Creative that manages player progression, currency, rebirth mechanics, and purchasable builds. The system tracks player money, implements a tier-based p
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/tycoon2?ref=github

using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /Verse.org/Colors/NamedColors }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Assets }
using { /Verse.org/Simulation/Tags }
using { /Fortnite.com/Game }
using { /Fortnite.com/Characters }

tycoon2 := class(creative_device):

    # AMOUNT OF BUILDS TO BUY = 80

    # 1.25 x for EVERY BUILD
    # 0 for claiming tycoon

    # Green Color: #00FF10
    # Secondary Green Color: #58EE61
    # Red Color: #FF0000
    # Yellow Color: #FFFC00

    # STRINGS

    PlayerBalanceString<localizes>(S : string) : message="{S}"
    PlayerRebirthLevelString<localizes>(S : string) : message="{S}"
    PlayerTycoonCompletionString<localizes>(S : string) : message="{S}"

    @editable PlayerMoneyHUD : hud_message_device = hud_message_device{}
    @editable PlayerRebirthHUD : hud_message_device = hud_message_device{}
    @editable PlayerTycoonCompletionHUD : hud_message_device = hud_message_device{}

    # PLAYER

    @editable PlayerLeavesSpawner : player_spawner_device = player_spawner_device{}
    @editable PlayerLeavesTrigger : trigger_device = trigger_device{}

    @editable CabbageGranter : item_granter_device = item_granter_device{}
    @editable CabbageSeller1 : conditional_button_device = conditional_button_device{}
    @editable CabbageSeller2 : conditional_button_device = conditional_button_device{}
    CabbagePrice : int = 100

    var PlayerBalance : int = 0
    var MoneyPerSecond : int = 0
    var BeforeClaimMoney : int = 0

    var Level1n2Money : int = 0
    var Level3Money : int = 0

    var Level0MoneyCheck : logic = true
    var Level1n2MoneyCheck : logic = false
    var Level3MoneyCheck : logic = false

    @editable TwoXMoneyBillboard : billboard_device = billboard_device{}

    var RebirthLevel : int = 0
    var RebirthReady : logic = false
    @editable RebirthTeleporter : teleporter_device = teleporter_device{}

    @editable Rebirth1NeededText : creative_prop = creative_prop{}
    @editable Rebirth1DescriptionText : creative_prop = creative_prop{}
    @editable Rebirth1NeededCube : prop_manipulator_device = prop_manipulator_device{}

    @editable Rebirth2NeededText : creative_prop = creative_prop{}
    @editable Rebirth2DescriptionText : creative_prop = creative_prop{}
    @editable Rebirth2NeededCube : prop_manipulator_device = prop_manipulator_device{}

    @editable SmallFrySell : conditional_button_device = conditional_button_device{}
    SmallFryPrice : int = 750
    @editable FlopperSell : conditional_button_device = conditional_button_device{}
    FlopperPrice : int = 1250
    @editable ShieldFishSell : conditional_button_device = conditional_button_device{}
    ShieldFishPrice : int = 2000
    @editable CuddleFishSell : conditional_button_device = conditional_button_device{}
    CuddleFishPrice : int = 5000

    @editable Rebirth3NeededText : creative_prop = creative_prop{}
    @editable Rebirth3DescriptionText : creative_prop = creative_prop{}
    @editable Rebirth3NeededCube : prop_manipulator_device = prop_manipulator_device{}

    var TycoonCompletionDecimal : int = 0
    var TycoonCompletionWhole : int = 0
    var TycoonClaimCheck : logic = false

    BuildingMoneyPerSec : int = 2

    @editable Like250kText : creative_prop = creative_prop{}
    @editable Like250kCube : prop_manipulator_device = prop_manipulator_device{}

    @editable x2HUD : hud_message_device = hud_message_device{}
    @editable x3HUD : hud_message_device = hud_message_device{}

    @editable RebirthNeed100kHUD : hud_message_device = hud_message_device{}

    @editable LostMoneyHUD : hud_message_device = hud_message_device{}

    @editable NotEnoughMoneyHUD : hud_message_device = hud_message_device{}
    @editable NotEnoughRadio : radio_device = radio_device{}

    @editable PurchasedHUD : hud_message_device = hud_message_device{}
    @editable PurchasedRadio : radio_device = radio_device{}

    @editable WelcomeTycoonHUD : hud_message_device = hud_message_device{}

    @editable MoneyClaimHUD : hud_message_device = hud_message_device{}

    # TYCOON CLAIM

    @editable TycoonClaimMutator : mutator_zone_device = mutator_zone_device{}
    @editable TycoonClaimCube : prop_manipulator_device = prop_manipulator_device{}

    # BEFORE REBIRTH & MONEY CLAIM

    @editable RebirthProps : prop_manipulator_device = prop_manipulator_device{}
    @editable MoneyProps : prop_manipulator_device = prop_manipulator_device{}

    @editable RebirthReadyText : billboard_device = billboard_device{}
    @editable RebirthNotReadyText : billboard_device = billboard_device{}
    @editable MoneyText : billboard_device = billboard_device{}
    @editable MoneySecText : billboard_device = billboard_device{}

    @editable RebirthMutator : mutator_zone_device = mutator_zone_device{}
    @editable MoneyMutator : mutator_zone_device = mutator_zone_device{}

    @editable RebirthRadio : radio_device = radio_device{}
    @editable MoneyRadio : radio_device = radio_device{}

    # CHICKEN COOP 1

    @editable ChickenCoop1Price : int = 0
    @editable ChickenCoop1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable ChickenCoop1Props : prop_manipulator_device = prop_manipulator_device{}
    @editable ChickenCoop1Text : creative_prop = creative_prop{}
    @editable ChickenCoop1SecText : creative_prop = creative_prop{}
    var ChickenCoop1Money : int = 2
    @editable ChickenCoop1Mutator : mutator_zone_device = mutator_zone_device{}
    var ChickenCoop1Purchase : logic = false

    # CHICKEN COOP 2

    @editable ChickenCoop2Price : int = 50
    @editable ChickenCoop2Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable ChickenCoop2Props : prop_manipulator_device = prop_manipulator_device{}
    @editable ChickenCoop2Text : creative_prop = creative_prop{}
    @editable ChickenCoop2SecText : creative_prop = creative_prop{}
    var ChickenCoop2Money : int = 5
    @editable ChickenCoop2Mutator : mutator_zone_device = mutator_zone_device{}
    var ChickenCoop2Purchase : logic = false

    # CHICKEN COOP 3

    @editable ChickenCoop3Price : int = 250
    @editable ChickenCoop3Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable ChickenCoop3Props : prop_manipulator_device = prop_manipulator_device{}
    @editable ChickenCoop3Text : creative_prop = creative_prop{}
    @editable ChickenCoop3SecText : creative_prop = creative_prop{}
    var ChickenCoop3Money : int = 10
    @editable ChickenCoop3Mutator : mutator_zone_device = mutator_zone_device{}
    var ChickenCoop3Purchase : logic = false

    # CHICKEN COOP 4

    @editable ChickenCoop4Price : int = 750
    @editable ChickenCoop4Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable ChickenCoop4Props : prop_manipulator_device = prop_manipulator_device{}
    @editable ChickenCoop4Text : creative_prop = creative_prop{}
    @editable ChickenCoop4SecText : creative_prop = creative_prop{}
    var ChickenCoop4Money : int = 15
    @editable ChickenCoop4Mutator : mutator_zone_device = mutator_zone_device{}
    var ChickenCoop4Purchase : logic = false

    # CHICKEN COOP 5

    @editable ChickenCoop5Price : int = 3000
    @editable ChickenCoop5Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable ChickenCoop5Props : prop_manipulator_device = prop_manipulator_device{}
    @editable ChickenCoop5Text : creative_prop = creative_prop{}
    @editable ChickenCoop5SecText : creative_prop = creative_prop{}
    var ChickenCoop5Money : int = 20
    @editable ChickenCoop5Mutator : mutator_zone_device = mutator_zone_device{}
    var ChickenCoop5Purchase : logic = false

    # CHICKEN COOP 6

    @editable ChickenCoop6Price : int = 5000
    @editable ChickenCoop6Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable ChickenCoop6Props : prop_manipulator_device = prop_manipulator_device{}
    @editable ChickenCoop6Text : creative_prop = creative_prop{}
    @editable ChickenCoop6SecText : creative_prop = creative_prop{}
    var ChickenCoop6Money : int = 25
    @editable ChickenCoop6Mutator : mutator_zone_device = mutator_zone_device{}
    var ChickenCoop6Purchase : logic = false

    # CABBAGE 1

    @editable Cabbage1Price : int = 500
    @editable Cabbage1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Cabbage1Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Cabbage1Text : creative_prop = creative_prop{}
    @editable Cabbage1SecText : creative_prop = creative_prop{}
    var Cabbage1Money : int = 3
    @editable Cabbage1Mutator : mutator_zone_device = mutator_zone_device{}
    var Cabbage1Purchase : logic = false

    # CABBAGE 2

    @editable Cabbage2Price : int = 750
    @editable Cabbage2Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Cabbage2Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Cabbage2Text : creative_prop = creative_prop{}
    @editable Cabbage2SecText : creative_prop = creative_prop{}
    var Cabbage2Money : int = 5
    @editable Cabbage2Mutator : mutator_zone_device = mutator_zone_device{}
    var Cabbage2Purchase : logic = false

    # CABBAGE 3

    @editable Cabbage3Price : int = 1500
    @editable Cabbage3Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Cabbage3Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Cabbage3Text : creative_prop = creative_prop{}
    @editable Cabbage3SecText : creative_prop = creative_prop{}
    var Cabbage3Money : int = 7
    @editable Cabbage3Mutator : mutator_zone_device = mutator_zone_device{}
    var Cabbage3Purchase : logic = false

    # CABBAGE 4

    @editable Cabbage4Price : int = 2500
    @editable Cabbage4Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Cabbage4Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Cabbage4Text : creative_prop = creative_prop{}
    @editable Cabbage4SecText : creative_prop = creative_prop{}
    var Cabbage4Money : int = 10
    @editable Cabbage4Mutator : mutator_zone_device = mutator_zone_device{}
    var Cabbage4Purchase : logic = false

    # CABBAGE 5

    @editable Cabbage5Price : int = 5000
    @editable Cabbage5Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Cabbage5Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Cabbage5Text : creative_prop = creative_prop{}
    @editable Cabbage5SecText : creative_prop = creative_prop{}
    var Cabbage5Money : int = 15
    @editable Cabbage5Mutator : mutator_zone_device = mutator_zone_device{}
    var Cabbage5Purchase : logic = false

    # WALL 1

    @editable Wall1Price : int = 100
    @editable Wall1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Wall1Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Wall1Text : creative_prop = creative_prop{}
    @editable Wall1Mutator : mutator_zone_device = mutator_zone_device{}
    var Wall1Purchase : logic = false

    # WALL 2

    @editable Wall2Price : int = 250
    @editable Wall2Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Wall2Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Wall2Text : creative_prop = creative_prop{}
    @editable Wall2Mutator : mutator_zone_device = mutator_zone_device{}
    var Wall2Purchase : logic = false

    # WALL 3

    @editable Wall3Price : int = 300
    @editable Wall3Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Wall3Props1 : prop_manipulator_device = prop_manipulator_device{}
    @editable Wall3Props2 : prop_manipulator_device = prop_manipulator_device{}
    @editable Wall3Text : creative_prop = creative_prop{}
    @editable Wall3Mutator : mutator_zone_device = mutator_zone_device{}
    var Wall3Purchase : logic = false

    # WALL 4

    @editable Wall4Price : int = 400
    @editable Wall4Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Wall4Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Wall4Text : creative_prop = creative_prop{}
    @editable Wall4Mutator : mutator_zone_device = mutator_zone_device{}
    var Wall4Purchase : logic = false

    # WALL 5

    @editable Wall5Price : int = 600
    @editable Wall5Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Wall5Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Wall5Text : creative_prop = creative_prop{}
    @editable Wall5Mutator : mutator_zone_device = mutator_zone_device{}
    var Wall5Purchase : logic = false

    # WALL 6

    @editable Wall6Price : int = 800
    @editable Wall6Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Wall6Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Wall6Text : creative_prop = creative_prop{}
    @editable Wall6Mutator : mutator_zone_device = mutator_zone_device{}
    var Wall6Purchase : logic = false

    # WALL 7

    @editable Wall7Price : int = 1000
    @editable Wall7Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Wall7Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Wall7Text : creative_prop = creative_prop{}
    @editable Wall7Mutator : mutator_zone_device = mutator_zone_device{}
    var Wall7Purchase : logic = false

    # WALL 8

    @editable Wall8Price : int = 1000
    @editable Wall8Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Wall8Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Wall8Text : creative_prop = creative_prop{}
    @editable Wall8Mutator : mutator_zone_device = mutator_zone_device{}
    var Wall8Purchase : logic = false

    # PILLARS 1

    @editable Pillars1Price : int = 200
    @editable Pillars1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Pillars1Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Pillars1Text : creative_prop = creative_prop{}
    @editable Pillars1Mutator : mutator_zone_device = mutator_zone_device{}
    var Pillars1Purchase : logic = false

    # COUCH 1

    @editable Couch1Price : int = 300
    @editable Couch1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Couch1Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Couch1Text : creative_prop = creative_prop{}
    @editable Couch1Mutator : mutator_zone_device = mutator_zone_device{}
    var Couch1Purchase : logic = false

    # TABLE 1

    @editable Table1Price : int = 400
    @editable Table1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Table1Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Table1Text : creative_prop = creative_prop{}
    @editable Table1Mutator : mutator_zone_device = mutator_zone_device{}
    var Table1Purchase : logic = false

    # RUG 1

    @editable Rug1Price : int = 150
    @editable Rug1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Rug1Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Rug1Text : creative_prop = creative_prop{}
    @editable Rug1Mutator : mutator_zone_device = mutator_zone_device{}
    var Rug1Purchase : logic = false

    # FLOWERS 1

    @editable Flowers1Price : int = 300
    @editable Flowers1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Flowers1Props1 : prop_manipulator_device = prop_manipulator_device{}
    @editable Flowers1Props2 : prop_manipulator_device = prop_manipulator_device{}
    @editable Flowers1Text : creative_prop = creative_prop{}
    @editable Flowers1Mutator : mutator_zone_device = mutator_zone_device{}
    var Flowers1Purchase : logic = false

    # CHAIR 3

    @editable Chair3Price : int = 175
    @editable Chair3Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Chair3Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Chair3Text : creative_prop = creative_prop{}
    @editable Chair3Mutator : mutator_zone_device = mutator_zone_device{}
    var Chair3Purchase : logic = false

    # CLOCK 1

    @editable Clock1Price : int = 200
    @editable Clock1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Clock1Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Clock1Text : creative_prop = creative_prop{}
    @editable Clock1Mutator : mutator_zone_device = mutator_zone_device{}
    var Clock1Purchase : logic = false

    # PAINTING 1

    @editable Painting1Price : int = 500
    @editable Painting1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Painting1Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Painting1Text : creative_prop = creative_prop{}
    @editable Painting1Mutator : mutator_zone_device = mutator_zone_device{}
    var Painting1Purchase : logic = false

    # JUNK 1

    @editable Junk1Price : int = 200
    @editable Junk1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Junk1Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Junk1Text : creative_prop = creative_prop{}
    @editable Junk1Mutator : mutator_zone_device = mutator_zone_device{}
    var Junk1Purchase : logic = false

    # STAIRS 1

    @editable Stairs1Price : int = 1000
    @editable Stairs1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Stairs1Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Stairs1Text : creative_prop = creative_prop{}
    @editable Stairs1Mutator : mutator_zone_device = mutator_zone_device{}
    var Stairs1Purchase : logic = false

    # CHIMNEY 1

    @editable Chimney1Price : int = 500
    @editable Chimney1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Chimney1Props1 : prop_manipulator_device = prop_manipulator_device{}
    @editable Chimney1Props2 : prop_manipulator_device = prop_manipulator_device{}
    @editable Chimney1Smoke : vfx_spawner_device = vfx_spawner_device{}
    @editable Chimney1Text : creative_prop = creative_prop{}
    @editable Chimney1Mutator : mutator_zone_device = mutator_zone_device{}
    var Chimney1Purchase : logic = false

    # FLOORS 1

    @editable Floors1Price : int = 1250
    @editable Floors1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Floors1Props1 : prop_manipulator_device = prop_manipulator_device{}
    @editable Floors1Props2 : prop_manipulator_device = prop_manipulator_device{}
    @editable Floors1Props3 : prop_manipulator_device = prop_manipulator_device{}
    @editable Floors1Text : creative_prop = creative_prop{}
    @editable Floors1Mutator : mutator_zone_device = mutator_zone_device{}
    var Floors1Purchase : logic = false

    # RAILINGS 1

    @editable Railings1Price : int = 750
    @editable Railings1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Railings1Props1 : prop_manipulator_device = prop_manipulator_device{}
    @editable Railings1Props2 : prop_manipulator_device = prop_manipulator_device{}
    @editable Railings1Text : creative_prop = creative_prop{}
    @editable Railings1Mutator : mutator_zone_device = mutator_zone_device{}
    var Railings1Purchase : logic = false

    # BED 1

    @editable Bed1Price : int = 1000
    @editable Bed1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Bed1Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Bed1Text : creative_prop = creative_prop{}
    @editable Bed1Mutator : mutator_zone_device = mutator_zone_device{}
    var Bed1Purchase : logic = false

    # NIGHTSTAND 1

    @editable Nightstand1Price : int = 1250
    @editable Nightstand1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Nightstand1Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Nightstand1Text : creative_prop = creative_prop{}
    @editable Nightstand1Mutator : mutator_zone_device = mutator_zone_device{}
    var Nightstand1Purchase : logic = false

    # DRESSER 1

    @editable Dresser1Price : int = 2000
    @editable Dresser1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Dresser1Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Dresser1Text : creative_prop = creative_prop{}
    @editable Dresser1Mutator : mutator_zone_device = mutator_zone_device{}
    var Dresser1Purchase : logic = false

    # BOOKSHELF 1

    @editable Bookshelf1Price : int = 2500
    @editable Bookshelf1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Bookshelf1Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Bookshelf1Text : creative_prop = creative_prop{}
    @editable Bookshelf1Mutator : mutator_zone_device = mutator_zone_device{}
    var Bookshelf1Purchase : logic = false

    # DESK 1

    @editable Desk1Price : int = 3000
    @editable Desk1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Desk1Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Desk1Text : creative_prop = creative_prop{}
    @editable Desk1Mutator : mutator_zone_device = mutator_zone_device{}
    var Desk1Purchase : logic = false

    # ROOF 1

    @editable Roof1Price : int = 5000
    @editable Roof1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Roof1Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Roof1Text : creative_prop = creative_prop{}
    @editable Roof1Mutator : mutator_zone_device = mutator_zone_device{}
    var Roof1Purchase : logic = false

    # CHAIRS 1

    @editable Chairs1Price : int = 750
    @editable Chairs1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Chairs1Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Chairs1Text : creative_prop = creative_prop{}
    @editable Chairs1Mutator : mutator_zone_device = mutator_zone_device{}
    var Chairs1Purchase : logic = false

    # CHAIRS 2

    @editable Chairs2Price : int = 1000
    @editable Chairs2Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Chairs2Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Chairs2Text : creative_prop = creative_prop{}
    @editable Chairs2Mutator : mutator_zone_device = mutator_zone_device{}
    var Chairs2Purchase : logic = false

    # APPLES 1

    @editable Apples1Price : int = 300
    @editable Apples1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Apples1Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Apples1Text : creative_prop = creative_prop{}
    @editable Apples1Mutator : mutator_zone_device = mutator_zone_device{}
    var Apples1Purchase : logic = false

    # PORCH 1

    @editable Porch1Price : int = 2500
    @editable Porch1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Porch1Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Porch1Text : creative_prop = creative_prop{}
    @editable Porch1Mutator : mutator_zone_device = mutator_zone_device{}
    var Porch1Purchase : logic = false

    # FENCE 1

    @editable Fence1Price : int = 1000
    @editable Fence1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Fence1Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Fence1Text : creative_prop = creative_prop{}
    @editable Fence1Mutator : mutator_zone_device = mutator_zone_device{}
    var Fence1Purchase : logic = false

    # FENCE 2

    @editable Fence2Price : int = 1500
    @editable Fence2Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Fence2Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Fence2Text : creative_prop = creative_prop{}
    @editable Fence2Mutator : mutator_zone_device = mutator_zone_device{}
    var Fence2Purchase : logic = false

    # FENCE 3

    @editable Fence3Price : int = 2500
    @editable Fence3Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Fence3Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Fence3Text : creative_prop = creative_prop{}
    @editable Fence3Mutator : mutator_zone_device = mutator_zone_device{}
    var Fence3Purchase : logic = false

    # FENCE 4

    @editable Fence4Price : int = 3000
    @editable Fence4Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Fence4Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Fence4Text : creative_prop = creative_prop{}
    @editable Fence4Mutator : mutator_zone_device = mutator_zone_device{}
    var Fence4Purchase : logic = false

    # SILO 1

    @editable Silo1Price : int = 1000
    @editable Silo1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Silo1Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Silo1Text : creative_prop = creative_prop{}
    @editable Silo1Mutator : mutator_zone_device = mutator_zone_device{}
    var Silo1Purchase : logic = false

    # SILO 2

    @editable Silo2Price : int = 1500
    @editable Silo2Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Silo2Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Silo2Text : creative_prop = creative_prop{}
    @editable Silo2Mutator : mutator_zone_device = mutator_zone_device{}
    var Silo2Purchase : logic = false

    # HAYBALES 1

    @editable Haybales1Price : int = 1000
    @editable Haybales1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Haybales1Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Haybales1Text : creative_prop = creative_prop{}
    @editable Haybales1Mutator : mutator_zone_device = mutator_zone_device{}
    var Haybales1Purchase : logic = false

    # HAYBALES 2

    @editable Haybales2Price : int = 2500
    @editable Haybales2Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Haybales2Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Haybales2Text : creative_prop = creative_prop{}
    @editable Haybales2Mutator : mutator_zone_device = mutator_zone_device{}
    var Haybales2Purchase : logic = false

    # CABBAGE FENCE 1

    @editable CabbageFence1Price : int = 1000
    @editable CabbageFence1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable CabbageFence1Props : prop_manipulator_device = prop_manipulator_device{}
    @editable CabbageFence1Text : creative_prop = creative_prop{}
    @editable CabbageFence1Mutator : mutator_zone_device = mutator_zone_device{}
    var CabbageFence1Purchase : logic = false

    # CABBAGE FENCE 2

    @editable CabbageFence2Price : int = 1000
    @editable CabbageFence2Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable CabbageFence2Props : prop_manipulator_device = prop_manipulator_device{}
    @editable CabbageFence2Text : creative_prop = creative_prop{}
    @editable CabbageFence2Mutator : mutator_zone_device = mutator_zone_device{}
    var CabbageFence2Purchase : logic = false

    # CABBAGE FENCE 3

    @editable CabbageFence3Price : int = 1000
    @editable CabbageFence3Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable CabbageFence3Props : prop_manipulator_device = prop_manipulator_device{}
    @editable CabbageFence3Text : creative_prop = creative_prop{}
    @editable CabbageFence3Mutator : mutator_zone_device = mutator_zone_device{}
    var CabbageFence3Purchase : logic = false

    # CABBAGE FENCE 4

    @editable CabbageFence4Price : int = 1000
    @editable CabbageFence4Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable CabbageFence4Props : prop_manipulator_device = prop_manipulator_device{}
    @editable CabbageFence4Text : creative_prop = creative_prop{}
    @editable CabbageFence4Mutator : mutator_zone_device = mutator_zone_device{}
    var CabbageFence4Purchase : logic = false

    # TRACTOR 1

    @editable Tractor1Price : int = 5000
    @editable Tractor1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Tractor1Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Tractor1Text : creative_prop = creative_prop{}
    @editable Tractor1Mutator : mutator_zone_device = mutator_zone_device{}
    var Tractor1Purchase : logic = false

    # TOMATO FENCE 1

    @editable TomatoFence1Price : int = 2500
    @editable TomatoFence1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable TomatoFence1Props : prop_manipulator_device = prop_manipulator_device{}
    @editable TomatoFence1Text : creative_prop = creative_prop{}
    @editable TomatoFence1Mutator : mutator_zone_device = mutator_zone_device{}
    var TomatoFence1Purchase : logic = false

    # TOMATO FENCE 2

    @editable TomatoFence2Price : int = 3000
    @editable TomatoFence2Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable TomatoFence2Props : prop_manipulator_device = prop_manipulator_device{}
    @editable TomatoFence2Text : creative_prop = creative_prop{}
    @editable TomatoFence2Mutator : mutator_zone_device = mutator_zone_device{}
    var TomatoFence2Purchase : logic = false

    # TOMATO FENCE 3

    @editable TomatoFence3Price : int = 5000
    @editable TomatoFence3Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable TomatoFence3Props : prop_manipulator_device = prop_manipulator_device{}
    @editable TomatoFence3Text : creative_prop = creative_prop{}
    @editable TomatoFence3Mutator : mutator_zone_device = mutator_zone_device{}
    var TomatoFence3Purchase : logic = false

    # TOMATO FENCE 4

    @editable TomatoFence4Price : int = 7500
    @editable TomatoFence4Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable TomatoFence4Props : prop_manipulator_device = prop_manipulator_device{}
    @editable TomatoFence4Text : creative_prop = creative_prop{}
    @editable TomatoFence4Mutator : mutator_zone_device = mutator_zone_device{}
    var TomatoFence4Purchase : logic = false

    # TOMATO 1

    @editable Tomato1Price : int = 5000
    @editable Tomato1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Tomato1Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Tomato1Text : creative_prop = creative_prop{}
    @editable Tomato1SecText : creative_prop = creative_prop{}
    var Tomato1Money : int = 17
    @editable Tomato1Mutator : mutator_zone_device = mutator_zone_device{}
    var Tomato1Purchase : logic = false

    # TOMATO 2

    @editable Tomato2Price : int = 6000
    @editable Tomato2Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Tomato2Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Tomato2Text : creative_prop = creative_prop{}
    @editable Tomato2SecText : creative_prop = creative_prop{}
    var Tomato2Money : int = 20
    @editable Tomato2Mutator : mutator_zone_device = mutator_zone_device{}
    var Tomato2Purchase : logic = false

    # TOMATO 3

    @editable Tomato3Price : int = 7500
    @editable Tomato3Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Tomato3Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Tomato3Text : creative_prop = creative_prop{}
    @editable Tomato3SecText : creative_prop = creative_prop{}
    var Tomato3Money : int = 23
    @editable Tomato3Mutator : mutator_zone_device = mutator_zone_device{}
    var Tomato3Purchase : logic = false

    # TOMATO 4

    @editable Tomato4Price : int = 10000
    @editable Tomato4Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Tomato4Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Tomato4Text : creative_prop = creative_prop{}
    @editable Tomato4SecText : creative_prop = creative_prop{}
    var Tomato4Money : int = 26
    @editable Tomato4Mutator : mutator_zone_device = mutator_zone_device{}
    var Tomato4Purchase : logic = false

    # SHED 1

    @editable Shed1Price : int = 12500
    @editable Shed1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Shed1Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Shed1Text : creative_prop = creative_prop{}
    @editable Shed1Mutator : mutator_zone_device = mutator_zone_device{}
    var Shed1Purchase : logic = false

    # CORN 1

    @editable Corn1Price : int = 15000
    @editable Corn1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Corn1Props1 : prop_manipulator_device = prop_manipulator_device{}
    @editable Corn1Props2 : prop_manipulator_device = prop_manipulator_device{}
    @editable Corn1Text : creative_prop = creative_prop{}
    @editable Corn1Mutator : mutator_zone_device = mutator_zone_device{}
    var Corn1Purchase : logic = false

    # HAYBALES 3

    @editable Haybales3Price : int = 15000
    @editable Haybales3Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Haybales3Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Haybales3Text : creative_prop = creative_prop{}
    @editable Haybales3Mutator : mutator_zone_device = mutator_zone_device{}
    var Haybales3Purchase : logic = false

    # HAYBALES 5

    @editable Haybales5Price : int = 25000
    @editable Haybales5Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Haybales5Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Haybales5Text : creative_prop = creative_prop{}
    @editable Haybales5Mutator : mutator_zone_device = mutator_zone_device{}
    var Haybales5Purchase : logic = false

    # WAGON 1

    @editable Wagon1Price : int = 20000
    @editable Wagon1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Wagon1Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Wagon1Text : creative_prop = creative_prop{}
    @editable Wagon1Mutator : mutator_zone_device = mutator_zone_device{}
    var Wagon1Purchase : logic = false

    # STABLE 1

    @editable Stable1Price : int = 20000
    @editable Stable1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Stable1Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Stable1Text : creative_prop = creative_prop{}
    @editable Stable1Mutator : mutator_zone_device = mutator_zone_device{}
    var Stable1Purchase : logic = false

    # STABLE 2

    @editable Stable2Price : int = 30000
    @editable Stable2Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Stable2Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Stable2Text : creative_prop = creative_prop{}
    @editable Stable2Mutator : mutator_zone_device = mutator_zone_device{}
    var Stable2Purchase : logic = false

    # WINDMILL 1

    @editable Windmill1Price : int = 20000
    @editable Windmill1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Windmill1Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Windmill1Text : creative_prop = creative_prop{}
    @editable Windmill1Mutator : mutator_zone_device = mutator_zone_device{}
    var Windmill1Purchase : logic = false

    # POND 1

    @editable Pond1Price : int = 50000
    @editable Pond1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Pond1Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Pond1Text : creative_prop = creative_prop{}
    @editable Pond1Mutator : mutator_zone_device = mutator_zone_device{}
    var Pond1Purchase : logic = false

    # DOCK 1

    @editable Dock1Price : int = 30000
    @editable Dock1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Dock1Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Dock1Text : creative_prop = creative_prop{}
    @editable Dock1Mutator : mutator_zone_device = mutator_zone_device{}
    var Dock1Purchase : logic = false

    # FISHING 1

    @editable Fishing1Price : int = 25000
    @editable Fishing1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Fishing1Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Fishing1FishingZone1 : fishing_zone_device = fishing_zone_device{}
    @editable Fishing1FishingZone2 : fishing_zone_device = fishing_zone_device{}
    @editable Fishing1Waterzone : water_device = water_device{}
    @editable Fishing1Text : creative_prop = creative_prop{}
    @editable FishingHelp1Text : creative_prop = creative_prop{}
    @editable FishingHelp2Text : creative_prop = creative_prop{}
    @editable Fishing1Mutator : mutator_zone_device = mutator_zone_device{}
    var Fishing1Purchase : logic = false

    # BOAR PEN 1

    @editable BoarPen1Price : int = 50000
    @editable BoarPen1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable BoarPen1Props : prop_manipulator_device = prop_manipulator_device{}
    @editable BoarPen1Text : creative_prop = creative_prop{}
    @editable BoarPen1Mutator : mutator_zone_device = mutator_zone_device{}
    var BoarPen1Purchase : logic = false

    # BOAR FENCE 1

    @editable BoarFence1Price : int = 25000
    @editable BoarFence1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable BoarFence1Props : prop_manipulator_device = prop_manipulator_device{}
    @editable BoarFence1Text : creative_prop = creative_prop{}
    @editable BoarFence1Mutator : mutator_zone_device = mutator_zone_device{}
    var BoarFence1Purchase : logic = false

    # BOAR FENCE 2

    @editable BoarFence2Price : int = 30000
    @editable BoarFence2Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable BoarFence2Props : prop_manipulator_device = prop_manipulator_device{}
    @editable BoarFence2Text : creative_prop = creative_prop{}
    @editable BoarFence2Mutator : mutator_zone_device = mutator_zone_device{}
    var BoarFence2Purchase : logic = false

    # BOAR FENCE 3

    @editable BoarFence3Price : int = 35000
    @editable BoarFence3Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable BoarFence3Props : prop_manipulator_device = prop_manipulator_device{}
    @editable BoarFence3Text : creative_prop = creative_prop{}
    @editable BoarFence3Mutator : mutator_zone_device = mutator_zone_device{}
    var BoarFence3Purchase : logic = false

    # HAYBALES 4

    @editable Haybales4Price : int = 25000
    @editable Haybales4Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable Haybales4Props : prop_manipulator_device = prop_manipulator_device{}
    @editable Haybales4Text : creative_prop = creative_prop{}
    @editable Haybales4Mutator : mutator_zone_device = mutator_zone_device{}
    var Haybales4Purchase : logic = false

    # BOAR VEGETATION 1

    @editable BoarVegetation1Price : int = 30000
    @editable BoarVegetation1Cube : prop_manipulator_device = prop_manipulator_device{}
    @editable BoarVegetation1Props : prop_manipulator_device = prop_manipulator_device{}
    @editable BoarVegetation1Text : creative_prop = creative_prop{}
    @editable BoarVegetation1Mutator : mutator_zone_device = mutator_zone_device{}
    @editable Boars : wildlife_spawner_device = wildlife_spawner_device{}
    var BoarVegetation1Purchase : logic = false

##### CORE FUNCTIONS #####

    OnBegin<override>()<suspends>:void=
        TycoonClaimMutator.AgentEntersEvent.Subscribe(TycoonClaim)
        TycoonClaimMutator.AgentEntersEvent.Subscribe(SpawnedEventSpawn)
        PlayerLeavesSpawner.SpawnedEvent.Subscribe(PlayerLeavesTycoon)
        ChickenCoop1Text.Hide()
        ChickenCoop2Text.Hide()
        ChickenCoop3Text.Hide()
        ChickenCoop4Text.Hide()
        ChickenCoop5Text.Hide()
        ChickenCoop6Text.Hide()
        ChickenCoop1SecText.Hide()
        ChickenCoop2SecText.Hide()
        ChickenCoop3SecText.Hide()
        ChickenCoop4SecText.Hide()
        ChickenCoop5SecText.Hide()
        ChickenCoop6SecText.Hide()
        Wall1Text.Hide()
        Wall2Text.Hide()
        Wall3Text.Hide()
        Wall4Text.Hide()
        Wall5Text.Hide()
        Wall6Text.Hide()
        Wall7Text.Hide()
        Wall8Text.Hide()
        Pillars1Text.Hide()
        Couch1Text.Hide()
        Table1Text.Hide()
        Rug1Text.Hide()
        Junk1Text.Hide()
        Flowers1Text.Hide()
        Chair3Text.Hide()
        Clock1Text.Hide()
        Stairs1Text.Hide()
        Painting1Text.Hide()
        Chimney1Text.Hide()
        Floors1Text.Hide()
        Railings1Text.Hide()
        Nightstand1Text.Hide()
        Dresser1Text.Hide()
        Bed1Text.Hide()
        Bookshelf1Text.Hide()
        Desk1Text.Hide()
        Roof1Text.Hide()
        Chairs1Text.Hide()
        Chairs2Text.Hide()
        Apples1Text.Hide()
        Porch1Text.Hide()
        Fence1Text.Hide()
        Fence2Text.Hide()
        Fence3Text.Hide()
        Fence4Text.Hide()
        Silo1Text.Hide()
        Silo2Text.Hide()
        Haybales1Text.Hide()
        Haybales2Text.Hide()
        CabbageFence1Text.Hide()
        CabbageFence2Text.Hide()
        CabbageFence3Text.Hide()
        CabbageFence4Text.Hide()
        Cabbage1Text.Hide()
        Cabbage2Text.Hide()
        Cabbage3Text.Hide()
        Cabbage4Text.Hide()
        Cabbage5Text.Hide()
        Cabbage1SecText.Hide()
        Cabbage2SecText.Hide()
        Cabbage3SecText.Hide()
        Cabbage4SecText.Hide()
        Cabbage5SecText.Hide()
        Tractor1Text.Hide()
        Tomato1Text.Hide()
        Tomato1SecText.Hide()
        Tomato2Text.Hide()
        Tomato2SecText.Hide()
        Tomato3Text.Hide()
        Tomato3SecText.Hide()
        Tomato4Text.Hide()
        Tomato4SecText.Hide()
        TomatoFence1Text.Hide()
        TomatoFence2Text.Hide()
        TomatoFence3Text.Hide()
        TomatoFence4Text.Hide()
        Rebirth1NeededText.Hide()
        Rebirth1DescriptionText.Hide()
        Shed1Text.Hide()
        Corn1Text.Hide()
        RebirthReadyText.HideText()
        RebirthNotReadyText.HideText()
        Haybales3Text.Hide()
        Wagon1Text.Hide()
        Haybales5Text.Hide()
        Stable1Text.Hide()
        Windmill1Text.Hide()
        Stable2Text.Hide()
        Rebirth2NeededText.Hide()
        Rebirth2DescriptionText.Hide()
        Rebirth3NeededText.Hide()
        Rebirth3DescriptionText.Hide()
        Pond1Text.Hide()
        Fishing1Text.Hide()
        Dock1Text.Hide()
        FishingHelp1Text.Hide()
        FishingHelp2Text.Hide()
        BoarPen1Text.Hide()
        BoarFence1Text.Hide()
        BoarFence2Text.Hide()
        BoarFence3Text.Hide()
        Haybales4Text.Hide()
        BoarVegetation1Text.Hide()

    PlayerLeavesTycoon(Agent : agent):void=
        set TycoonClaimCheck = false
        PlayerLeavesTrigger.Trigger(Agent)
        TycoonClaimCube.ShowProps()
        RebirthProps.HideProps()
        MoneyProps.HideProps()
        Like250kText.Hide()
        Like250kCube.HideProps()
        set ChickenCoop1Purchase = false
        set ChickenCoop2Purchase = false
        set ChickenCoop3Purchase = false
        set ChickenCoop4Purchase = false
        set ChickenCoop5Purchase = false
        set ChickenCoop6Purchase = false
        set Wall1Purchase = false
        set Wall2Purchase = false
        set Wall3Purchase = false
        set Wall4Purchase = false
        set Wall5Purchase = false
        set Wall6Purchase = false
        set Wall7Purchase = false
        set Wall8Purchase = false
        set Pillars1Purchase = false
        set Couch1Purchase = false
        set Table1Purchase = false
        set Rug1Purchase = false
        set Junk1Purchase = false
        set Flowers1Purchase = false
        set Chair3Purchase = false
        set Clock1Purchase = false
        set Stairs1Purchase = false
        set Painting1Purchase = false
        set Chimney1Purchase = false
        set Floors1Purchase = false
        set Railings1Purchase = false
        set Nightstand1Purchase = false
        set Dresser1Purchase = false
        set Bed1Purchase = false
        set Bookshelf1Purchase = false
        set Desk1Purchase = false
        set Roof1Purchase = false
        set Chairs1Purchase = false
        set Chairs2Purchase = false
        set Apples1Purchase = false
        set Porch1Purchase = false
        set Fence1Purchase = false
        set Fence2Purchase = false
        set Fence3Purchase = false
        set Fence4Purchase = false
        set Silo1Purchase = false
        set Silo2Purchase = false
        set Haybales1Purchase = false
        set Haybales2Purchase = false
        set CabbageFence1Purchase = false
        set CabbageFence2Purchase = false
        set CabbageFence3Purchase = false
        set CabbageFence4Purchase = false
        set Cabbage1Purchase = false
        set Cabbage2Purchase = false
        set Cabbage3Purchase = false
        set Cabbage4Purchase = false
        set Cabbage5Purchase = false
        set Tractor1Purchase = false
        set Tomato1Purchase = false
        set Tomato2Purchase = false
        set Tomato3Purchase = false
        set Tomato4Purchase = false
        set TomatoFence1Purchase = false
        set TomatoFence2Purchase = false
        set TomatoFence3Purchase = false
        set TomatoFence4Purchase = false
        set Shed1Purchase = false
        set Corn1Purchase = false
        set Haybales3Purchase = false
        set Haybales5Purchase = false
        set Wagon1Purchase = false
        set Stable1Purchase = false
        set Stable2Purchase = false
        set Windmill1Purchase = false
        set Pond1Purchase = false
        set Dock1Purchase = false
        set Fishing1Purchase = false
        set BoarPen1Purchase = false
        set BoarFence1Purchase = false
        set BoarFence2Purchase = false
        set BoarFence3Purchase = false
        set Haybales4Purchase = false
        set BoarVegetation1Purchase = false
        # TEXT
        ChickenCoop1Text.Hide()
        ChickenCoop2Text.Hide()
        ChickenCoop3Text.Hide()
        ChickenCoop4Text.Hide()
        ChickenCoop5Text.Hide()
        ChickenCoop6Text.Hide()
        ChickenCoop1SecText.Hide()
        ChickenCoop2SecText.Hide()
        ChickenCoop3SecText.Hide()
        ChickenCoop4SecText.Hide()
        ChickenCoop5SecText.Hide()
        ChickenCoop6SecText.Hide()
        Wall1Text.Hide()
        Wall2Text.Hide()
        Wall3Text.Hide()
        Wall4Text.Hide()
        Wall5Text.Hide()
        Wall6Text.Hide()
        Wall7Text.Hide()
        Wall8Text.Hide()
        Pillars1Text.Hide()
        Couch1Text.Hide()
        Table1Text.Hide()
        Rug1Text.Hide()
        Junk1Text.Hide()
        Flowers1Text.Hide()
        Chair3Text.Hide()
        Clock1Text.Hide()
        Stairs1Text.Hide()
        Painting1Text.Hide()
        Chimney1Text.Hide()
        Floors1Text.Hide()
        Railings1Text.Hide()
        Nightstand1Text.Hide()
        Dresser1Text.Hide()
        Bed1Text.Hide()
        Bookshelf1Text.Hide()
        Desk1Text.Hide()
        Roof1Text.Hide()
        Chairs1Text.Hide()
        Chairs2Text.Hide()
        Apples1Text.Hide()
        Porch1Text.Hide()
        Fence1Text.Hide()
        Fence2Text.Hide()
        Fence3Text.Hide()
        Fence4Text.Hide()
        Silo1Text.Hide()
        Silo2Text.Hide()
        Haybales1Text.Hide()
        Haybales2Text.Hide()
        CabbageFence1Text.Hide()
        CabbageFence2Text.Hide()
        CabbageFence3Text.Hide()
        CabbageFence4Text.Hide()
        Cabbage1Text.Hide()
        Cabbage2Text.Hide()
        Cabbage3Text.Hide()
        Cabbage4Text.Hide()
        Cabbage5Text.Hide()
        Cabbage1SecText.Hide()
        Cabbage2SecText.Hide()
        Cabbage3SecText.Hide()
        Cabbage4SecText.Hide()
        Cabbage5SecText.Hide()
        Tractor1Text.Hide()
        Tomato1Text.Hide()
        Tomato1SecText.Hide()
        Tomato2Text.Hide()
        Tomato2SecText.Hide()
        Tomato3Text.Hide()
        Tomato3SecText.Hide()
        Tomato4Text.Hide()
        Tomato4SecText.Hide()
        TomatoFence1Text.Hide()
        TomatoFence2Text.Hide()
        TomatoFence3Text.Hide()
        TomatoFence4Text.Hide()
        Rebirth1NeededText.Hide()
        Rebirth1DescriptionText.Hide()
        Rebirth2NeededText.Hide()
        Rebirth2DescriptionText.Hide()
        Rebirth3NeededText.Hide()
        Rebirth3DescriptionText.Hide()
        Shed1Text.Hide()
        Corn1Text.Hide()
        RebirthReadyText.HideText()
        RebirthNotReadyText.HideText()
        Haybales3Text.Hide()
        Wagon1Text.Hide()
        Haybales5Text.Hide()
        Stable1Text.Hide()
        Stable2Text.Hide()
        Windmill1Text.Hide()
        Dock1Text.Hide()
        Pond1Text.Hide()
        Fishing1Text.Hide()
        FishingHelp1Text.Hide()
        FishingHelp2Text.Hide()
        BoarPen1Text.Hide()
        BoarFence1Text.Hide()
        BoarFence2Text.Hide()
        BoarFence3Text.Hide()
        Haybales4Text.Hide()
        BoarVegetation1Text.Hide()
        # CUBES
        ChickenCoop1Cube.HideProps()
        ChickenCoop2Cube.HideProps()
        ChickenCoop3Cube.HideProps()
        ChickenCoop4Cube.HideProps()
        ChickenCoop5Cube.HideProps()
        ChickenCoop6Cube.HideProps()
        Wall1Cube.HideProps()
        Wall2Cube.HideProps()
        Wall3Cube.HideProps()
        Wall4Cube.HideProps()
        Wall5Cube.HideProps()
        Wall6Cube.HideProps()
        Wall7Cube.HideProps()
        Wall8Cube.HideProps()
        Pillars1Cube.HideProps()
        Couch1Cube.HideProps()
        Table1Cube.HideProps()
        Rug1Cube.HideProps()
        Junk1Cube.HideProps()
        Flowers1Cube.HideProps()
        Chair3Cube.HideProps()
        Clock1Cube.HideProps()
        Stairs1Cube.HideProps()
        Painting1Cube.HideProps()
        Chimney1Cube.HideProps()
        Floors1Cube.HideProps()
        Railings1Cube.HideProps()
        Nightstand1Cube.HideProps()
        Dresser1Cube.HideProps()
        Bed1Cube.HideProps()
        Bookshelf1Cube.HideProps()
        Desk1Cube.HideProps()
        Roof1Cube.HideProps()
        Chairs1Cube.HideProps()
        Chairs2Cube.HideProps()
        Apples1Cube.HideProps()
        Porch1Cube.HideProps()
        Fence1Cube.HideProps()
        Fence2Cube.HideProps()
        Fence3Cube.HideProps()
        Fence4Cube.HideProps()
        Silo1Cube.HideProps()
        Silo2Cube.HideProps()
        Haybales1Cube.HideProps()
        Haybales2Cube.HideProps()
        CabbageFence1Cube.HideProps()
        CabbageFence2Cube.HideProps()
        CabbageFence3Cube.HideProps()
        CabbageFence4Cube.HideProps()
        Cabbage1Cube.HideProps()
        Cabbage2Cube.HideProps()
        Cabbage3Cube.HideProps()
        Cabbage4Cube.HideProps()
        Cabbage5Cube.HideProps()
        Tractor1Cube.HideProps()
        Tomato1Cube.HideProps()
        Tomato2Cube.HideProps()
        Tomato3Cube.HideProps()
        Tomato4Cube.HideProps()
        TomatoFence1Cube.HideProps()
        TomatoFence2Cube.HideProps()
        TomatoFence3Cube.HideProps()
        TomatoFence4Cube.HideProps()
        Rebirth1NeededCube.HideProps()
        Rebirth2NeededCube.HideProps()
        Rebirth3NeededCube.HideProps()
        Shed1Cube.HideProps()
        Corn1Cube.HideProps()
        Haybales3Cube.HideProps()
        Wagon1Cube.HideProps()
        Haybales5Cube.HideProps()
        Stable1Cube.HideProps()
        Stable2Cube.HideProps()
        Windmill1Cube.HideProps()
        Chimney1Smoke.Disable()
        Pond1Cube.HideProps()
        Fishing1Cube.HideProps()
        Dock1Cube.HideProps()
        Fishing1Waterzone.Disable()
        Fishing1FishingZone1.Disable()
        Fishing1FishingZone2.Disable()
        BoarPen1Cube.HideProps()
        BoarFence1Cube.HideProps()
        BoarFence2Cube.HideProps()
        BoarFence3Cube.HideProps()
        Haybales4Cube.HideProps()
        BoarVegetation1Cube.HideProps()
        # PROPS
        ChickenCoop1Props.HideProps()
        ChickenCoop2Props.HideProps()
        ChickenCoop3Props.HideProps()
        ChickenCoop4Props.HideProps()
        ChickenCoop5Props.HideProps()
        ChickenCoop6Props.HideProps()
        Wall1Props.HideProps()
        Wall2Props.HideProps()
        Wall3Props1.HideProps()
        Wall3Props2.HideProps()
        Wall4Props.HideProps()
        Wall5Props.HideProps()
        Wall6Props.HideProps()
        Wall7Props.HideProps()
        Wall8Props.HideProps()
        Pillars1Props.HideProps()
        Couch1Props.HideProps()
        Table1Props.HideProps()
        Rug1Props.HideProps()
        Junk1Props.HideProps()
        Flowers1Props1.HideProps()
        Flowers1Props2.HideProps()
        Chair3Props.HideProps()
        Clock1Props.HideProps()
        Stairs1Props.HideProps()
        Painting1Props.HideProps()
        Chimney1Props1.HideProps()
        Chimney1Props2.HideProps()
        Floors1Props1.HideProps()
        Floors1Props2.HideProps()
        Floors1Props3.HideProps()
        Railings1Props1.HideProps()
        Railings1Props2.HideProps()
        Nightstand1Props.HideProps()
        Dresser1Props.HideProps()
        Bed1Props.HideProps()
        Bookshelf1Props.HideProps()
        Desk1Props.HideProps()
        Roof1Props.HideProps()
        Chairs1Props.HideProps()
        Chairs2Props.HideProps()
        Apples1Props.HideProps()
        Porch1Props.HideProps()
        Fence1Props.HideProps()
        Fence2Props.HideProps()
        Fence3Props.HideProps()
        Fence4Props.HideProps()
        Silo1Props.HideProps()
        Silo2Props.HideProps()
        Haybales1Props.HideProps()
        Haybales2Props.HideProps()
        CabbageFence1Props.HideProps()
        CabbageFence2Props.HideProps()
        CabbageFence3Props.HideProps()
        CabbageFence4Props.HideProps()
        Cabbage1Props.HideProps()
        Cabbage2Props.HideProps()
        Cabbage3Props.HideProps()
        Cabbage4Props.HideProps()
        Cabbage5Props.HideProps()
        Tractor1Props.HideProps()
        Tomato1Props.HideProps()
        Tomato2Props.HideProps()
        Tomato3Props.HideProps()
        Tomato4Props.HideProps()
        TomatoFence1Props.HideProps()
        TomatoFence2Props.HideProps()
        TomatoFence3Props.HideProps()
        TomatoFence4Props.HideProps()
        Shed1Props.HideProps()
        Corn1Props1.HideProps()
        Corn1Props2.HideProps()
        Haybales3Props.HideProps()
        Wagon1Props.HideProps()
        Haybales5Props.HideProps()
        Stable1Props.HideProps()
        Stable2Props.HideProps()
        Windmill1Props.HideProps()
        Fishing1Props.HideProps()
        Dock1Props.HideProps()
        Pond1Props.HideProps()
        BoarPen1Props.HideProps()
        BoarFence1Props.HideProps()
        BoarFence2Props.HideProps()
        BoarFence3Props.HideProps()
        Haybales4Props.HideProps()
        BoarVegetation1Props.HideProps()
        # NEW REBIRTH THANGS
        set PlayerBalance = 0
        set RebirthLevel = 0
        set RebirthReady = false
        set BeforeClaimMoney = 0
        set MoneyPerSecond = 0
        RebirthNotReadyText.ShowText()
        RebirthReadyText.HideText()
        ChickenCoop1Text.Hide()
        ChickenCoop1Cube.HideProps()
        set Level1n2MoneyCheck = false
        set Level3MoneyCheck = false
        set Level0MoneyCheck = true
        set TycoonCompletionDecimal = 0
        set TycoonCompletionWhole = 0

    CheckingTwoXMoney(Agent : agent)<suspends>:void=
        loop:
            Sleep(1.0)
            if(Level0MoneyCheck = true):
                TwoXMoneyBillboard.SetText(PlayerBalanceString("(1x Multiplier)"))
            if(Level1n2MoneyCheck = true):
                TwoXMoneyBillboard.SetText(PlayerBalanceString("(2x Multiplier)"))
                set Level1n2Money = (MoneyPerSecond * 2) 
            if(Level3MoneyCheck = true):
                TwoXMoneyBillboard.SetText(PlayerBalanceString("(3x Multiplier)"))
                set Level3Money = (MoneyPerSecond * 3) 

    RebirthCheck(Agent : agent):void=
        if(RebirthReady = true):
            if(RebirthLevel = 0):
                if(PlayerBalance >= 25000):
                    # PURCHASE CHECKS
                    set ChickenCoop1Purchase = false
                    set ChickenCoop2Purchase = false
                    set ChickenCoop3Purchase = false
                    set ChickenCoop4Purchase = false
                    set ChickenCoop5Purchase = false
                    set ChickenCoop6Purchase = false
                    set Wall1Purchase = false
                    set Wall2Purchase = false
                    set Wall3Purchase = false
                    set Wall4Purchase = false
                    set Wall5Purchase = false
                    set Wall6Purchase = false
                    set Wall7Purchase = false
                    set Wall8Purchase = false
                    set Pillars1Purchase = false
                    set Couch1Purchase = false
                    set Table1Purchase = false
                    set Rug1Purchase = false
                    set Junk1Purchase = false
                    set Flowers1Purchase = false
                    set Chair3Purchase = false
                    set Clock1Purchase = false
                    set Stairs1Purchase = false
                    set Painting1Purchase = false
                    set Chimney1Purchase = false
                    set Floors1Purchase = false
                    set Railings1Purchase = false
                    set Nightstand1Purchase = false
                    set Dresser1Purchase = false
                    set Bed1Purchase = false
                    set Bookshelf1Purchase = false
                    set Desk1Purchase = false
                    set Roof1Purchase = false
                    set Chairs1Purchase = false
                    set Chairs2Purchase = false
                    set Apples1Purchase = false
                    set Porch1Purchase = false
                    set Fence1Purchase = false
                    set Fence2Purchase = false
                    set Fence3Purchase = false
                    set Fence4Purchase = false
                    set Silo1Purchase = false
                    set Silo2Purchase = false
                    set Haybales1Purchase = false
                    set Haybales2Purchase = false
                    set CabbageFence1Purchase = false
                    set CabbageFence2Purchase = false
                    set CabbageFence3Purchase = false
                    set CabbageFence4Purchase = false
                    set Cabbage1Purchase = false
                    set Cabbage2Purchase = false
                    set Cabbage3Purchase = false
                    set Cabbage4Purchase = false
                    set Cabbage5Purchase = false
                    set Tractor1Purchase = false
                    set Tomato1Purchase = false
                    set Tomato2Purchase = false
                    set Tomato3Purchase = false
                    set Tomato4Purchase = false
                    set TomatoFence1Purchase = false
                    set TomatoFence2Purchase = false
                    set TomatoFence3Purchase = false
                    set TomatoFence4Purchase = false
                    set Shed1Purchase = false
                    set Corn1Purchase = false
                    set Haybales3Purchase = false
                    set Haybales5Purchase = false
                    set Wagon1Purchase = false
                    set Stable1Purchase = false
                    set Stable2Purchase = false
                    set Windmill1Purchase = false
                    set Pond1Purchase = false
                    set Dock1Purchase = false
                    set Fishing1Purchase = false
                    set BoarPen1Purchase = false
                    set BoarFence1Purchase = false
                    set BoarFence2Purchase = false
                    set BoarFence3Purchase = false
                    set Haybales4Purchase = false
                    set BoarVegetation1Purchase = false
                    # TEXT
                    ChickenCoop1Text.Hide()
                    ChickenCoop2Text.Hide()
                    ChickenCoop3Text.Hide()
                    ChickenCoop4Text.Hide()
                    ChickenCoop5Text.Hide()
                    ChickenCoop6Text.Hide()
                    ChickenCoop1SecText.Hide()
                    ChickenCoop2SecText.Hide()
                    ChickenCoop3SecText.Hide()
                    ChickenCoop4SecText.Hide()
                    ChickenCoop5SecText.Hide()
                    ChickenCoop6SecText.Hide()
                    Wall1Text.Hide()
                    Wall2Text.Hide()
                    Wall3Text.Hide()
                    Wall4Text.Hide()
                    Wall5Text.Hide()
                    Wall6Text.Hide()
                    Wall7Text.Hide()
                    Wall8Text.Hide()
                    Pillars1Text.Hide()
                    Couch1Text.Hide()
                    Table1Text.Hide()
                    Rug1Text.Hide()
                    Junk1Text.Hide()
                    Flowers1Text.Hide()
                    Chair3Text.Hide()
                    Clock1Text.Hide()
                    Stairs1Text.Hide()
                    Painting1Text.Hide()
                    Chimney1Text.Hide()
                    Floors1Text.Hide()
                    Railings1Text.Hide()
                    Nightstand1Text.Hide()
                    Dresser1Text.Hide()
                    Bed1Text.Hide()
                    Bookshelf1Text.Hide()
                    Desk1Text.Hide()
                    Roof1Text.Hide()
                    Chairs1Text.Hide()
                    Chairs2Text.Hide()
                    Apples1Text.Hide()
                    Porch1Text.Hide()
                    Fence1Text.Hide()
                    Fence2Text.Hide()
                    Fence3Text.Hide()
                    Fence4Text.Hide()
                    Silo1Text.Hide()
                    Silo2Text.Hide()
                    Haybales1Text.Hide()
                    Haybales2Text.Hide()
                    CabbageFence1Text.Hide()
                    CabbageFence2Text.Hide()
                    CabbageFence3Text.Hide()
                    CabbageFence4Text.Hide()
                    Cabbage1Text.Hide()
                    Cabbage2Text.Hide()
                    Cabbage3Text.Hide()
                    Cabbage4Text.Hide()
                    Cabbage5Text.Hide()
                    Cabbage1SecText.Hide()
                    Cabbage2SecText.Hide()
                    Cabbage3SecText.Hide()
                    Cabbage4SecText.Hide()
                    Cabbage5SecText.Hide()
                    Tractor1Text.Hide()
                    Tomato1Text.Hide()
                    Tomato1SecText.Hide()
                    Tomato2Text.Hide()
                    Tomato2SecText.Hide()
                    Tomato3Text.Hide()
                    Tomato3SecText.Hide()
                    Tomato4Text.Hide()
                    Tomato4SecText.Hide()
                    TomatoFence1Text.Hide()
                    TomatoFence2Text.Hide()
                    TomatoFence3Text.Hide()
                    TomatoFence4Text.Hide()
                    Rebirth1NeededText.Hide()
                    Rebirth1DescriptionText.Hide()
                    Shed1Text.Hide()
                    Corn1Text.Hide()
                    RebirthReadyText.HideText()
                    RebirthNotReadyText.HideText()
                    Haybales3Text.Hide()
                    Wagon1Text.Hide()
                    Haybales5Text.Hide()
                    Stable1Text.Hide()
                    Stable2Text.Hide()
                    Windmill1Text.Hide()
                    Dock1Text.Hide()
                    Pond1Text.Hide()
                    Fishing1Text.Hide()
                    FishingHelp1Text.Hide()
                    FishingHelp2Text.Hide()
                    BoarPen1Text.Hide()
                    BoarFence1Text.Hide()
                    BoarFence2Text.Hide()
                    BoarFence3Text.Hide()
                    Haybales4Text.Hide()
                    BoarVegetation1Text.Hide()
                    # CUBES
                    ChickenCoop1Cube.HideProps()
                    ChickenCoop2Cube.HideProps()
                    ChickenCoop3Cube.HideProps()
                    ChickenCoop4Cube.HideProps()
                    ChickenCoop5Cube.HideProps()
                    ChickenCoop6Cube.HideProps()
                    Wall1Cube.HideProps()
                    Wall2Cube.HideProps()
                    Wall3Cube.HideProps()
                    Wall4Cube.HideProps()
                    Wall5Cube.HideProps()
                    Wall6Cube.HideProps()
                    Wall7Cube.HideProps()
                    Wall8Cube.HideProps()
                    Pillars1Cube.HideProps()
                    Couch1Cube.HideProps()
                    Table1Cube.HideProps()
                    Rug1Cube.HideProps()
                    Junk1Cube.HideProps()
                    Flowers1Cube.HideProps()
                    Chair3Cube.HideProps()
                    Clock1Cube.HideProps()
                    Stairs1Cube.HideProps()
                    Painting1Cube.HideProps()
                    Chimney1Cube.HideProps()
                    Floors1Cube.HideProps()
                    Railings1Cube.HideProps()
                    Nightstand1Cube.HideProps()
                    Dresser1Cube.HideProps()
                    Bed1Cube.HideProps()
                    Bookshelf1Cube.HideProps()
                    Desk1Cube.HideProps()
                    Roof1Cube.HideProps()
                    Chairs1Cube.HideProps()
                    Chairs2Cube.HideProps()
                    Apples1Cube.HideProps()
                    Porch1Cube.HideProps()
                    Fence1Cube.HideProps()
                    Fence2Cube.HideProps()
                    Fence3Cube.HideProps()
                    Fence4Cube.HideProps()
                    Silo1Cube.HideProps()
                    Silo2Cube.HideProps()
                    Haybales1Cube.HideProps()
                    Haybales2Cube.HideProps()
                    CabbageFence1Cube.HideProps()
                    CabbageFence2Cube.HideProps()
                    CabbageFence3Cube.HideProps()
                    CabbageFence4Cube.HideProps()
                    Cabbage1Cube.HideProps()
                    Cabbage2Cube.HideProps()
                    Cabbage3Cube.HideProps()
                    Cabbage4Cube.HideProps()
                    Cabbage5Cube.HideProps()
                    Tractor1Cube.HideProps()
                    Tomato1Cube.HideProps()
                    Tomato2Cube.HideProps()
                    Tomato3Cube.HideProps()
                    Tomato4Cube.HideProps()
                    TomatoFence1Cube.HideProps()
                    TomatoFence2Cube.HideProps()
                    TomatoFence3Cube.HideProps()
                    TomatoFence4Cube.HideProps()
                    Rebirth1NeededCube.HideProps()
                    Shed1Cube.HideProps()
                    Corn1Cube.HideProps()
                    Haybales3Cube.HideProps()
                    Wagon1Cube.HideProps()
                    Haybales5Cube.HideProps()
                    Stable1Cube.HideProps()
                    Stable2Cube.HideProps()
                    Windmill1Cube.HideProps()
                    Chimney1Smoke.Disable()
                    Pond1Cube.HideProps()
                    Fishing1Cube.HideProps()
                    Dock1Cube.HideProps()
                    Fishing1Waterzone.Disable()
                    Fishing1FishingZone1.Disable()
                    Fishing1FishingZone2.Disable()
                    BoarPen1Cube.HideProps()
                    BoarFence1Cube.HideProps()
                    BoarFence2Cube.HideProps()
                    BoarFence3Cube.HideProps()
                    Haybales4Cube.HideProps()
                    BoarVegetation1Cube.HideProps()
                    # PROPS
                    ChickenCoop1Props.HideProps()
                    ChickenCoop2Props.HideProps()
                    ChickenCoop3Props.HideProps()
                    ChickenCoop4Props.HideProps()
                    ChickenCoop5Props.HideProps()
                    ChickenCoop6Props.HideProps()
                    Wall1Props.HideProps()
                    Wall2Props.HideProps()
                    Wall3Props1.HideProps()
                    Wall3Props2.HideProps()
                    Wall4Props.HideProps()
                    Wall5Props.HideProps()
                    Wall6Props.HideProps()
                    Wall7Props.HideProps()
                    Wall8Props.HideProps()
                    Pillars1Props.HideProps()
                    Couch1Props.HideProps()
                    Table1Props.HideProps()
                    Rug1Props.HideProps()
                    Junk1Props.HideProps()
                    Flowers1Props1.HideProps()
                    Flowers1Props2.HideProps()
                    Chair3Props.HideProps()
                    Clock1Props.HideProps()
                    Stairs1Props.HideProps()
                    Painting1Props.HideProps()
                    Chimney1Props1.HideProps()
                    Chimney1Props2.HideProps()
                    Floors1Props1.HideProps()
                    Floors1Props2.HideProps()
                    Floors1Props3.HideProps()
                    Railings1Props1.HideProps()
                    Railings1Props2.HideProps()
                    Nightstand1Props.HideProps()
                    Dresser1Props.HideProps()
                    Bed1Props.HideProps()
                    Bookshelf1Props.HideProps()
                    Desk1Props.HideProps()
                    Roof1Props.HideProps()
                    Chairs1Props.HideProps()
                    Chairs2Props.HideProps()
                    Apples1Props.HideProps()
                    Porch1Props.HideProps()
                    Fence1Props.HideProps()
                    Fence2Props.HideProps()
                    Fence3Props.HideProps()
                    Fence4Props.HideProps()
                    Silo1Props.HideProps()
                    Silo2Props.HideProps()
                    Haybales1Props.HideProps()
                    Haybales2Props.HideProps()
                    CabbageFence1Props.HideProps()
                    CabbageFence2Props.HideProps()
                    CabbageFence3Props.HideProps()
                    CabbageFence4Props.HideProps()
                    Cabbage1Props.HideProps()
                    Cabbage2Props.HideProps()
                    Cabbage3Props.HideProps()
                    Cabbage4Props.HideProps()
                    Cabbage5Props.HideProps()
                    Tractor1Props.HideProps()
                    Tomato1Props.HideProps()
                    Tomato2Props.HideProps()
                    Tomato3Props.HideProps()
                    Tomato4Props.HideProps()
                    TomatoFence1Props.HideProps()
                    TomatoFence2Props.HideProps()
                    TomatoFence3Props.HideProps()
                    TomatoFence4Props.HideProps()
                    Shed1Props.HideProps()
                    Corn1Props1.HideProps()
                    Corn1Props2.HideProps()
                    Haybales3Props.HideProps()
                    Wagon1Props.HideProps()
                    Haybales5Props.HideProps()
                    Stable1Props.HideProps()
                    Stable2Props.HideProps()
                    Windmill1Props.HideProps()
                    Fishing1Props.HideProps()
                    Dock1Props.HideProps()
                    Pond1Props.HideProps()
                    BoarPen1Props.HideProps()
                    BoarFence1Props.HideProps()
                    BoarFence2Props.HideProps()
                    BoarFence3Props.HideProps()
                    Haybales4Props.HideProps()
                    BoarVegetation1Props.HideProps()
                    # NEW REBIRTH THANGS
                    set RebirthLevel += 1
                    set RebirthReady = false
                    set PlayerBalance = 0
                    set BeforeClaimMoney = 0
                    set MoneyPerSecond = 0
                    RebirthTeleporter.Teleport(Agent)
                    RebirthRadio.Play()
                    RebirthNotReadyText.ShowText()
                    RebirthReadyText.HideText()
                    ChickenCoop1Text.Show()
                    ChickenCoop1Cube.ShowProps()
                    set Level1n2MoneyCheck = true
                    set Level0MoneyCheck = true
                    set TycoonCompletionDecimal = 0
                    set TycoonCompletionWhole = 0
                    x2HUD.Show(Agent)
        if(RebirthReady = true):
            if(RebirthLevel = 0):
                if(PlayerBalance < 25000):
                    RebirthNeed100kHUD.Show(Agent)
                    NotEnoughRadio.Play()
        if(RebirthReady = true):
            if(RebirthLevel = 1):
                if(PlayerBalance >= 25000):
                    # PURCHASE CHECKS
                    set ChickenCoop1Purchase = false
                    set ChickenCoop2Purchase = false
                    set ChickenCoop3Purchase = false
                    set ChickenCoop4Purchase = false
                    set ChickenCoop5Purchase = false
                    set ChickenCoop6Purchase = false
                    set Wall1Purchase = false
                    set Wall2Purchase = false
                    set Wall3Purchase = false
                    set Wall4Purchase = false
                    set Wall5Purchase = false
                    set Wall6Purchase = false
                    set Wall7Purchase = false
                    set Wall8Purchase = false
                    set Pillars1Purchase = false
                    set Couch1Purchase = false
                    set Table1Purchase = false
                    set Rug1Purchase = false
                    set Junk1Purchase = false
                    set Flowers1Purchase = false
                    set Chair3Purchase = false
                    set Clock1Purchase = false
                    set Stairs1Purchase = false
                    set Painting1Purchase = false
                    set Chimney1Purchase = false
                    set Floors1Purchase = false
                    set Railings1Purchase = false
                    set Nightstand1Purchase = false
                    set Dresser1Purchase = false
                    set Bed1Purchase = false
                    set Bookshelf1Purchase = false
                    set Desk1Purchase = false
                    set Roof1Purchase = false
                    set Chairs1Purchase = false
                    set Chairs2Purchase = false
                    set Apples1Purchase = false
                    set Porch1Purchase = false
                    set Fence1Purchase = false
                    set Fence2Purchase = false
                    set Fence3Purchase = false
                    set Fence4Purchase = false
                    set Silo1Purchase = false
                    set Silo2Purchase = false
                    set Haybales1Purchase = false
                    set Haybales2Purchase = false
                    set CabbageFence1Purchase = false
                    set CabbageFence2Purchase = false
                    set CabbageFence3Purchase = false
                    set CabbageFence4Purchase = false
                    set Cabbage1Purchase = false
                    set Cabbage2Purchase = false
                    set Cabbage3Purchase = false
                    set Cabbage4Purchase = false
                    set Cabbage5Purchase = false
                    set Tractor1Purchase = false
                    set Tomato1Purchase = false
                    set Tomato2Purchase = false
                    set Tomato3Purchase = false
                    set Tomato4Purchase = false
                    set TomatoFence1Purchase = false
                    set TomatoFence2Purchase = false
                    set TomatoFence3Purchase = false
                    set TomatoFence4Purchase = false
                    set Shed1Purchase = false
                    set Corn1Purchase = false
                    set Haybales3Purchase = false
                    set Haybales5Purchase = false
                    set Wagon1Purchase = false
                    set Stable1Purchase = false
                    set Stable2Purchase = false
                    set Windmill1Purchase = false
                    set Pond1Purchase = false
                    set Dock1Purchase = false
                    set Fishing1Purchase = false
                    set BoarPen1Purchase = false
                    set BoarFence1Purchase = false
                    set BoarFence2Purchase = false
                    set BoarFence3Purchase = false
                    set Haybales4Purchase = false
                    set BoarVegetation1Purchase = false
                    # TEXT
                    ChickenCoop1Text.Hide()
                    ChickenCoop2Text.Hide()
                    ChickenCoop3Text.Hide()
                    ChickenCoop4Text.Hide()
                    ChickenCoop5Text.Hide()
                    ChickenCoop6Text.Hide()
                    ChickenCoop1SecText.Hide()
                    ChickenCoop2SecText.Hide()
                    ChickenCoop3SecText.Hide()
                    ChickenCoop4SecText.Hide()
                    ChickenCoop5SecText.Hide()
                    ChickenCoop6SecText.Hide()
                    Wall1Text.Hide()
                    Wall2Text.Hide()
                    Wall3Text.Hide()
                    Wall4Text.Hide()
                    Wall5Text.Hide()
                    Wall6Text.Hide()
                    Wall7Text.Hide()
                    Wall8Text.Hide()
                    Pillars1Text.Hide()
                    Couch1Text.Hide()
                    Table1Text.Hide()
                    Rug1Text.Hide()
                    Junk1Text.Hide()
                    Flowers1Text.Hide()
                    Chair3Text.Hide()
                    Clock1Text.Hide()
                    Stairs1Text.Hide()
                    Painting1Text.Hide()
                    Chimney1Text.Hide()
                    Floors1Text.Hide()
                    Railings1Text.Hide()
                    Nightstand1Text.Hide()
                    Dresser1Text.Hide()
                    Bed1Text.Hide()
                    Bookshelf1Text.Hide()
                    Desk1Text.Hide()
                    Roof1Text.Hide()
                    Chairs1Text.Hide()
                    Chairs2Text.Hide()
                    Apples1Text.Hide()
                    Porch1Text.Hide()
                    Fence1Text.Hide()
                    Fence2Text.Hide()
                    Fence3Text.Hide()
                    Fence4Text.Hide()
                    Silo1Text.Hide()
                    Silo2Text.Hide()
                    Haybales1Text.Hide()
                    Haybales2Text.Hide()
                    CabbageFence1Text.Hide()
                    CabbageFence2Text.Hide()
                    CabbageFence3Text.Hide()
                    CabbageFence4Text.Hide()
                    Cabbage1Text.Hide()
                    Cabbage2Text.Hide()
                    Cabbage3Text.Hide()
                    Cabbage4Text.Hide()
                    Cabbage5Text.Hide()
                    Cabbage1SecText.Hide()
                    Cabbage2SecText.Hide()
                    Cabbage3SecText.Hide()
                    Cabbage4SecText.Hide()
                    Cabbage5SecText.Hide()
                    Tractor1Text.Hide()
                    Tomato1Text.Hide()
                    Tomato1SecText.Hide()
                    Tomato2Text.Hide()
                    Tomato2SecText.Hide()
                    Tomato3Text.Hide()
                    Tomato3SecText.Hide()
                    Tomato4Text.Hide()
                    Tomato4SecText.Hide()
                    TomatoFence1Text.Hide()
                    TomatoFence2Text.Hide()
                    TomatoFence3Text.Hide()
                    TomatoFence4Text.Hide()
                    Rebirth1NeededText.Hide()
                    Rebirth1DescriptionText.Hide()
                    Rebirth2NeededText.Hide()
                    Rebirth2DescriptionText.Hide()
                    Shed1Text.Hide()
                    Corn1Text.Hide()
                    RebirthReadyText.HideText()
                    RebirthNotReadyText.HideText()
                    Haybales3Text.Hide()
                    Wagon1Text.Hide()
                    Haybales5Text.Hide()
                    Stable1Text.Hide()
                    Stable2Text.Hide()
                    Windmill1Text.Hide()
                    Dock1Text.Hide()
                    Pond1Text.Hide()
                    Fishing1Text.Hide()
                    FishingHelp1Text.Hide()
                    FishingHelp2Text.Hide()
                    BoarPen1Text.Hide()
                    BoarFence1Text.Hide()
                    BoarFence2Text.Hide()
                    BoarFence3Text.Hide()
                    Haybales4Text.Hide()
                    BoarVegetation1Text.Hide()
                    # CUBES
                    ChickenCoop1Cube.HideProps()
                    ChickenCoop2Cube.HideProps()
                    ChickenCoop3Cube.HideProps()
                    ChickenCoop4Cube.HideProps()
                    ChickenCoop5Cube.HideProps()
                    ChickenCoop6Cube.HideProps()
                    Wall1Cube.HideProps()
                    Wall2Cube.HideProps()
                    Wall3Cube.HideProps()
                    Wall4Cube.HideProps()
                    Wall5Cube.HideProps()
                    Wall6Cube.HideProps()
                    Wall7Cube.HideProps()
                    Wall8Cube.HideProps()
                    Pillars1Cube.HideProps()
                    Couch1Cube.HideProps()
                    Table1Cube.HideProps()
                    Rug1Cube.HideProps()
                    Junk1Cube.HideProps()
                    Flowers1Cube.HideProps()
                    Chair3Cube.HideProps()
                    Clock1Cube.HideProps()
                    Stairs1Cube.HideProps()
                    Painting1Cube.HideProps()
                    Chimney1Cube.HideProps()
                    Floors1Cube.HideProps()
                    Railings1Cube.HideProps()
                    Nightstand1Cube.HideProps()
                    Dresser1Cube.HideProps()
                    Bed1Cube.HideProps()
                    Bookshelf1Cube.HideProps()
                    Desk1Cube.HideProps()
                    Roof1Cube.HideProps()
                    Chairs1Cube.HideProps()
                    Chairs2Cube.HideProps()
                    Apples1Cube.HideProps()
                    Porch1Cube.HideProps()
                    Fence1Cube.HideProps()
                    Fence2Cube.HideProps()
                    Fence3Cube.HideProps()
                    Fence4Cube.HideProps()
                    Silo1Cube.HideProps()
                    Silo2Cube.HideProps()
                    Haybales1Cube.HideProps()
                    Haybales2Cube.HideProps()
                    CabbageFence1Cube.HideProps()
                    CabbageFence2Cube.HideProps()
                    CabbageFence3Cube.HideProps()
                    CabbageFence4Cube.HideProps()
                    Cabbage1Cube.HideProps()
                    Cabbage2Cube.HideProps()
                    Cabbage3Cube.HideProps()
                    Cabbage4Cube.HideProps()
                    Cabbage5Cube.HideProps()
                    Tractor1Cube.HideProps()
                    Tomato1Cube.HideProps()
                    Tomato2Cube.HideProps()
                    Tomato3Cube.HideProps()
                    Tomato4Cube.HideProps()
                    TomatoFence1Cube.HideProps()
                    TomatoFence2Cube.HideProps()
                    TomatoFence3Cube.HideProps()
                    TomatoFence4Cube.HideProps()
                    Rebirth1NeededCube.HideProps()
                    Rebirth2NeededCube.HideProps()
                    Shed1Cube.HideProps()
                    Corn1Cube.HideProps()
                    Haybales3Cube.HideProps()
                    Wagon1Cube.HideProps()
                    Haybales5Cube.HideProps()
                    Stable1Cube.HideProps()
                    Stable2Cube.HideProps()
                    Windmill1Cube.HideProps()
                    Chimney1Smoke.Disable()
                    Pond1Cube.HideProps()
                    Fishing1Cube.HideProps()
                    Dock1Cube.HideProps()
                    Fishing1Waterzone.Disable()
                    Fishing1FishingZone1.Disable()
                    Fishing1FishingZone2.Disable()
                    BoarPen1Cube.HideProps()
                    BoarFence1Cube.HideProps()
                    BoarFence2Cube.HideProps()
                    BoarFence3Cube.HideProps()
                    Haybales4Cube.HideProps()
                    BoarVegetation1Cube.HideProps()
                    # PROPS
                    ChickenCoop1Props.HideProps()
                    ChickenCoop2Props.HideProps()
                    ChickenCoop3Props.HideProps()
                    ChickenCoop4Props.HideProps()
                    ChickenCoop5Props.HideProps()
                    ChickenCoop6Props.HideProps()
                    Wall1Props.HideProps()
                    Wall2Props.HideProps()
                    Wall3Props1.HideProps()
                    Wall3Props2.HideProps()
                    Wall4Props.HideProps()
                    Wall5Props.HideProps()
                    Wall6Props.HideProps()
                    Wall7Props.HideProps()
                    Wall8Props.HideProps()
                    Pillars1Props.HideProps()
                    Couch1Props.HideProps()
                    Table1Props.HideProps()
                    Rug1Props.HideProps()
                    Junk1Props.HideProps()
                    Flowers1Props1.HideProps()
                    Flowers1Props2.HideProps()
                    Chair3Props.HideProps()
                    Clock1Props.HideProps()
                    Stairs1Props.HideProps()
                    Painting1Props.HideProps()
                    Chimney1Props1.HideProps()
                    Chimney1Props2.HideProps()
                    Floors1Props1.HideProps()
                    Floors1Props2.HideProps()
                    Floors1Props3.HideProps()
                    Railings1Props1.HideProps()
                    Railings1Props2.HideProps()
                    Nightstand1Props.HideProps()
                    Dresser1Props.HideProps()
                    Bed1Props.HideProps()
                    Bookshelf1Props.HideProps()
                    Desk1Props.HideProps()
                    Roof1Props.HideProps()
                    Chairs1Props.HideProps()
                    Chairs2Props.HideProps()
                    Apples1Props.HideProps()
                    Porch1Props.HideProps()
                    Fence1Props.HideProps()
                    Fence2Props.HideProps()
                    Fence3Props.HideProps()
                    Fence4Props.HideProps()
                    Silo1Props.HideProps()
                    Silo2Props.HideProps()
                    Haybales1Props.HideProps()
                    Haybales2Props.HideProps()
                    CabbageFence1Props.HideProps()
                    CabbageFence2Props.HideProps()
                    CabbageFence3Props.HideProps()
                    CabbageFence4Props.HideProps()
                    Cabbage1Props.HideProps()
                    Cabbage2Props.HideProps()
                    Cabbage3Props.HideProps()
                    Cabbage4Props.HideProps()
                    Cabbage5Props.HideProps()
                    Tractor1Props.HideProps()
                    Tomato1Props.HideProps()
                    Tomato2Props.HideProps()
                    Tomato3Props.HideProps()
                    Tomato4Props.HideProps()
                    TomatoFence1Props.HideProps()
                    TomatoFence2Props.HideProps()
                    TomatoFence3Props.HideProps()
                    TomatoFence4Props.HideProps()
                    Shed1Props.HideProps()
                    Corn1Props1.HideProps()
                    Corn1Props2.HideProps()
                    Haybales3Props.HideProps()
                    Wagon1Props.HideProps()
                    Haybales5Props.HideProps()
                    Stable1Props.HideProps()
                    Stable2Props.HideProps()
                    Windmill1Props.HideProps()
                    Fishing1Props.HideProps()
                    Dock1Props.HideProps()
                    Pond1Props.HideProps()
                    BoarPen1Props.HideProps()
                    BoarFence1Props.HideProps()
                    BoarFence2Props.HideProps()
                    BoarFence3Props.HideProps()
                    Haybales4Props.HideProps()
                    BoarVegetation1Props.HideProps()
                    # NEW REBIRTH THANGS
                    set RebirthLevel += 1
                    set RebirthReady = false
                    set BeforeClaimMoney = 0
                    set MoneyPerSecond = 0
                    set PlayerBalance = 0
                    RebirthTeleporter.Teleport(Agent)
                    RebirthRadio.Play()
                    RebirthNotReadyText.ShowText()
                    RebirthReadyText.HideText()
                    ChickenCoop1Text.Show()
                    ChickenCoop1Cube.ShowProps()
                    set TycoonCompletionDecimal = 0
                    set TycoonCompletionWhole = 0
                    x2HUD.Show(Agent)
        if(RebirthReady = true):
            if(RebirthLevel = 1):
                if(PlayerBalance < 25000):
                    RebirthNeed100kHUD.Show(Agent)
                    NotEnoughRadio.Play()
        if(RebirthReady = true):
            if(RebirthLevel = 2):
                if(PlayerBalance >= 25000):
                    # PURCHASE CHECKS
                    set ChickenCoop1Purchase = false
                    set ChickenCoop2Purchase = false
                    set ChickenCoop3Purchase = false
                    set ChickenCoop4Purchase = false
                    set ChickenCoop5Purchase = false
                    set ChickenCoop6Purchase = false
                    set Wall1Purchase = false
                    set Wall2Purchase = false
                    set Wall3Purchase = false
                    set Wall4Purchase = false
                    set Wall5Purchase = false
                    set Wall6Purchase = false
                    set Wall7Purchase = false
                    set Wall8Purchase = false
                    set Pillars1Purchase = false
                    set Couch1Purchase = false
                    set Table1Purchase = false
                    set Rug1Purchase = false
                    set Junk1Purchase = false
                    set Flowers1Purchase = false
                    set Chair3Purchase = false
                    set Clock1Purchase = false
                    set Stairs1Purchase = false
                    set Painting1Purchase = false
                    set Chimney1Purchase = false
                    set Floors1Purchase = false
                    set Railings1Purchase = false
                    set Nightstand1Purchase = false
                    set Dresser1Purchase = false
                    set Bed1Purchase = false
                    set Bookshelf1Purchase = false
                    set Desk1Purchase = false
                    set Roof1Purchase = false
                    set Chairs1Purchase = false
                    set Chairs2Purchase = false
                    set Apples1Purchase = false
                    set Porch1Purchase = false
                    set Fence1Purchase = false
                    set Fence2Purchase = false
                    set Fence3Purchase = false
                    set Fence4Purchase = false
                    set Silo1Purchase = false
                    set Silo2Purchase = false
                    set Haybales1Purchase = false
                    set Haybales2Purchase = false
                    set CabbageFence1Purchase = false
                    set CabbageFence2Purchase = false
                    set CabbageFence3Purchase = false
                    set CabbageFence4Purchase = false
                    set Cabbage1Purchase = false
                    set Cabbage2Purchase = false
                    set Cabbage3Purchase = false
                    set Cabbage4Purchase = false
                    set Cabbage5Purchase = false
                    set Tractor1Purchase = false
                    set Tomato1Purchase = false
                    set Tomato2Purchase = false
                    set Tomato3Purchase = false
                    set Tomato4Purchase = false
                    set TomatoFence1Purchase = false
                    set TomatoFence2Purchase = false
                    set TomatoFence3Purchase = false
                    set TomatoFence4Purchase = false
                    set Shed1Purchase = false
                    set Corn1Purchase = false
                    set Haybales3Purchase = false
                    set Haybales5Purchase = false
                    set Wagon1Purchase = false
                    set Stable1Purchase = false
                    set Stable2Purchase = false
                    set Windmill1Purchase = false
                    set Pond1Purchase = false
                    set Dock1Purchase = false
                    set Fishing1Purchase = false
                    set BoarPen1Purchase = false
                    set BoarFence1Purchase = false
                    set BoarFence2Purchase = false
                    set BoarFence3Purchase = false
                    set Haybales4Purchase = false
                    set BoarVegetation1Purchase = false
                    # TEXT
                    ChickenCoop1Text.Hide()
                    ChickenCoop2Text.Hide()
                    ChickenCoop3Text.Hide()
                    ChickenCoop4Text.Hide()
                    ChickenCoop5Text.Hide()
                    ChickenCoop6Text.Hide()
                    ChickenCoop1SecText.Hide()
                    ChickenCoop2SecText.Hide()
                    ChickenCoop3SecText.Hide()
                    ChickenCoop4SecText.Hide()
                    ChickenCoop5SecText.Hide()
                    ChickenCoop6SecText.Hide()
                    Wall1Text.Hide()
                    Wall2Text.Hide()
                    Wall3Text.Hide()
                    Wall4Text.Hide()
                    Wall5Text.Hide()
                    Wall6Text.Hide()
                    Wall7Text.Hide()
                    Wall8Text.Hide()
                    Pillars1Text.Hide()
                    Couch1Text.Hide()
                    Table1Text.Hide()
                    Rug1Text.Hide()
                    Junk1Text.Hide()
                    Flowers1Text.Hide()
                    Chair3Text.Hide()
                    Clock1Text.Hide()
                    Stairs1Text.Hide()
                    Painting1Text.Hide()
                    Chimney1Text.Hide()
                    Floors1Text.Hide()
                    Railings1Text.Hide()
                    Nightstand1Text.Hide()
                    Dresser1Text.Hide()
                    Bed1Text.Hide()
                    Bookshelf1Text.Hide()
                    Desk1Text.Hide()
                    Roof1Text.Hide()
                    Chairs1Text.Hide()
                    Chairs2Text.Hide()
                    Apples1Text.Hide()
                    Porch1Text.Hide()
                    Fence1Text.Hide()
                    Fence2Text.Hide()
                    Fence3Text.Hide()
                    Fence4Text.Hide()
                    Silo1Text.Hide()
                    Silo2Text.Hide()
                    Haybales1Text.Hide()
                    Haybales2Text.Hide()
                    CabbageFence1Text.Hide()
                    CabbageFence2Text.Hide()
                    CabbageFence3Text.Hide()
                    CabbageFence4Text.Hide()
                    Cabbage1Text.Hide()
                    Cabbage2Text.Hide()
                    Cabbage3Text.Hide()
                    Cabbage4Text.Hide()
                    Cabbage5Text.Hide()
                    Cabbage1SecText.Hide()
                    Cabbage2SecText.Hide()
                    Cabbage3SecText.Hide()
                    Cabbage4SecText.Hide()
                    Cabbage5SecText.Hide()
                    Tractor1Text.Hide()
                    Tomato1Text.Hide()
                    Tomato1SecText.Hide()
                    Tomato2Text.Hide()
                    Tomato2SecText.Hide()
                    Tomato3Text.Hide()
                    Tomato3SecText.Hide()
                    Tomato4Text.Hide()
                    Tomato4SecText.Hide()
                    TomatoFence1Text.Hide()
                    TomatoFence2Text.Hide()
                    TomatoFence3Text.Hide()
                    TomatoFence4Text.Hide()
                    Rebirth1NeededText.Hide()
                    Rebirth1DescriptionText.Hide()
                    Rebirth2NeededText.Hide()
                    Rebirth2DescriptionText.Hide()
                    Rebirth3NeededText.Hide()
                    Rebirth3DescriptionText.Hide()
                    Shed1Text.Hide()
                    Corn1Text.Hide()
                    RebirthReadyText.HideText()
                    RebirthNotReadyText.HideText()
                    Haybales3Text.Hide()
                    Wagon1Text.Hide()
                    Haybales5Text.Hide()
                    Stable1Text.Hide()
                    Stable2Text.Hide()
                    Windmill1Text.Hide()
                    Dock1Text.Hide()
                    Pond1Text.Hide()
                    Fishing1Text.Hide()
                    FishingHelp1Text.Hide()
                    FishingHelp2Text.Hide()
                    BoarPen1Text.Hide()
                    BoarFence1Text.Hide()
                    BoarFence2Text.Hide()
                    BoarFence3Text.Hide()
                    Haybales4Text.Hide()
                    BoarVegetation1Text.Hide()
                    # CUBES
                    ChickenCoop1Cube.HideProps()
                    ChickenCoop2Cube.HideProps()
                    ChickenCoop3Cube.HideProps()
                    ChickenCoop4Cube.HideProps()
                    ChickenCoop5Cube.HideProps()
                    ChickenCoop6Cube.HideProps()
                    Wall1Cube.HideProps()
                    Wall2Cube.HideProps()
                    Wall3Cube.HideProps()
                    Wall4Cube.HideProps()
                    Wall5Cube.HideProps()
                    Wall6Cube.HideProps()
                    Wall7Cube.HideProps()
                    Wall8Cube.HideProps()
                    Pillars1Cube.HideProps()
                    Couch1Cube.HideProps()
                    Table1Cube.HideProps()
                    Rug1Cube.HideProps()
                    Junk1Cube.HideProps()
                    Flowers1Cube.HideProps()
                    Chair3Cube.HideProps()
                    Clock1Cube.HideProps()
                    Stairs1Cube.HideProps()
                    Painting1Cube.HideProps()
                    Chimney1Cube.HideProps()
                    Floors1Cube.HideProps()
                    Railings1Cube.HideProps()
                    Nightstand1Cube.HideProps()
                    Dresser1Cube.HideProps()
                    Bed1Cube.HideProps()
                    Bookshelf1Cube.HideProps()
                    Desk1Cube.HideProps()
                    Roof1Cube.HideProps()
                    Chairs1Cube.HideProps()
                    Chairs2Cube.HideProps()
                    Apples1Cube.HideProps()
                    Porch1Cube.HideProps()
                    Fence1Cube.HideProps()
                    Fence2Cube.HideProps()
                    Fence3Cube.HideProps()
                    Fence4Cube.HideProps()
                    Silo1Cube.HideProps()
                    Silo2Cube.HideProps()
                    Haybales1Cube.HideProps()
                    Haybales2Cube.HideProps()
                    CabbageFence1Cube.HideProps()
                    CabbageFence2Cube.HideProps()
                    CabbageFence3Cube.HideProps()
                    CabbageFence4Cube.HideProps()
                    Cabbage1Cube.HideProps()
                    Cabbage2Cube.HideProps()
                    Cabbage3Cube.HideProps()
                    Cabbage4Cube.HideProps()
                    Cabbage5Cube.HideProps()
                    Tractor1Cube.HideProps()
                    Tomato1Cube.HideProps()
                    Tomato2Cube.HideProps()
                    Tomato3Cube.HideProps()
                    Tomato4Cube.HideProps()
                    TomatoFence1Cube.HideProps()
                    TomatoFence2Cube.HideProps()
                    TomatoFence3Cube.HideProps()
                    TomatoFence4Cube.HideProps()
                    Rebirth1NeededCube.HideProps()
                    Rebirth2NeededCube.HideProps()
                    Rebirth3NeededCube.HideProps()
                    Shed1Cube.HideProps()
                    Corn1Cube.HideProps()
                    Haybales3Cube.HideProps()
                    Wagon1Cube.HideProps()
                    Haybales5Cube.HideProps()
                    Stable1Cube.HideProps()
                    Stable2Cube.HideProps()
                    Windmill1Cube.HideProps()
                    Chimney1Smoke.Disable()
                    Pond1Cube.HideProps()
                    Fishing1Cube.HideProps()
                    Dock1Cube.HideProps()
                    Fishing1Waterzone.Disable()
                    Fishing1FishingZone1.Disable()
                    Fishing1FishingZone2.Disable()
                    BoarPen1Cube.HideProps()
                    BoarFence1Cube.HideProps()
                    BoarFence2Cube.HideProps()
                    BoarFence3Cube.HideProps()
                    Haybales4Cube.HideProps()
                    BoarVegetation1Cube.HideProps()
                    # PROPS
                    ChickenCoop1Props.HideProps()
                    ChickenCoop2Props.HideProps()
                    ChickenCoop3Props.HideProps()
                    ChickenCoop4Props.HideProps()
                    ChickenCoop5Props.HideProps()
                    ChickenCoop6Props.HideProps()
                    Wall1Props.HideProps()
                    Wall2Props.HideProps()
                    Wall3Props1.HideProps()
                    Wall3Props2.HideProps()
                    Wall4Props.HideProps()
                    Wall5Props.HideProps()
                    Wall6Props.HideProps()
                    Wall7Props.HideProps()
                    Wall8Props.HideProps()
                    Pillars1Props.HideProps()
                    Couch1Props.HideProps()
                    Table1Props.HideProps()
                    Rug1Props.HideProps()
                    Junk1Props.HideProps()
                    Flowers1Props1.HideProps()
                    Flowers1Props2.HideProps()
                    Chair3Props.HideProps()
                    Clock1Props.HideProps()
                    Stairs1Props.HideProps()
                    Painting1Props.HideProps()
                    Chimney1Props1.HideProps()
                    Chimney1Props2.HideProps()
                    Floors1Props1.HideProps()
                    Floors1Props2.HideProps()
                    Floors1Props3.HideProps()
                    Railings1Props1.HideProps()
                    Railings1Props2.HideProps()
                    Nightstand1Props.HideProps()
                    Dresser1Props.HideProps()
                    Bed1Props.HideProps()
                    Bookshelf1Props.HideProps()
                    Desk1Props.HideProps()
                    Roof1Props.HideProps()
                    Chairs1Props.HideProps()
                    Chairs2Props.HideProps()
                    Apples1Props.HideProps()
                    Porch1Props.HideProps()
                    Fence1Props.HideProps()
                    Fence2Props.HideProps()
                    Fence3Props.HideProps()
                    Fence4Props.HideProps()
                    Silo1Props.HideProps()
                    Silo2Props.HideProps()
                    Haybales1Props.HideProps()
                    Haybales2Props.HideProps()
                    CabbageFence1Props.HideProps()
                    CabbageFence2Props.HideProps()
                    CabbageFence3Props.HideProps()
                    CabbageFence4Props.HideProps()
                    Cabbage1Props.HideProps()
                    Cabbage2Props.HideProps()
                    Cabbage3Props.HideProps()
                    Cabbage4Props.HideProps()
                    Cabbage5Props.HideProps()
                    Tractor1Props.HideProps()
                    Tomato1Props.HideProps()
                    Tomato2Props.HideProps()
                    Tomato3Props.HideProps()
                    Tomato4Props.HideProps()
                    TomatoFence1Props.HideProps()
                    TomatoFence2Props.HideProps()
                    TomatoFence3Props.HideProps()
                    TomatoFence4Props.HideProps()
                    Shed1Props.HideProps()
                    Corn1Props1.HideProps()
                    Corn1Props2.HideProps()
                    Haybales3Props.HideProps()
                    Wagon1Props.HideProps()
                    Haybales5Props.HideProps()
                    Stable1Props.HideProps()
                    Stable2Props.HideProps()
                    Windmill1Props.HideProps()
                    Fishing1Props.HideProps()
                    Dock1Props.HideProps()
                    Pond1Props.HideProps()
                    BoarPen1Props.HideProps()
                    BoarFence1Props.HideProps()
                    BoarFence2Props.HideProps()
                    BoarFence3Props.HideProps()
                    Haybales4Props.HideProps()
                    BoarVegetation1Props.HideProps()
                    # NEW REBIRTH THANGS
                    set PlayerBalance = 0
                    set RebirthLevel += 1
                    set RebirthReady = false
                    set BeforeClaimMoney = 0
                    set MoneyPerSecond = 0
                    RebirthTeleporter.Teleport(Agent)
                    RebirthRadio.Play()
                    RebirthNotReadyText.ShowText()
                    RebirthReadyText.HideText()
                    ChickenCoop1Text.Show()
                    ChickenCoop1Cube.ShowProps()
                    set Level1n2MoneyCheck = false
                    set Level3MoneyCheck = true
                    set TycoonCompletionDecimal = 0
                    set TycoonCompletionWhole = 0
                    x3HUD.Show(Agent)
        if(RebirthReady = true):
            if(RebirthLevel = 2):
                if(PlayerBalance < 25000):
                    RebirthNeed100kHUD.Show(Agent)
                    NotEnoughRadio.Play()

    SpawnedEventSpawn(Agent : agent):void=
        spawn{SpawnedEvent(Agent)}
        spawn{RebirthCheckSpawn(Agent)}

    RebirthCheckSpawn(Agent : agent)<suspends>:void=
        loop:
            Sleep(1.0)
            RebirthMutator.AgentEntersEvent.Subscribe(RebirthCheck)

    SpawnedEvent(Agent : agent)<suspends>:void=
        loop:
            Sleep(0.1)
            if(TycoonClaimCheck = true):
                ChickenCoop1Mutator.AgentEntersEvent.Subscribe(PurchaseChickenCoop1)
                SmallFrySell.ActivatedEvent.Subscribe(SellSmallFry)
                FlopperSell.ActivatedEvent.Subscribe(SellFlopper)
                ShieldFishSell.ActivatedEvent.Subscribe(SellShieldFish)
                CuddleFishSell.ActivatedEvent.Subscribe(SellCuddleFish)
            if(ChickenCoop1Purchase = true):
                ChickenCoop2Mutator.AgentEntersEvent.Subscribe(PurchaseChickenCoop2)
                Apples1Mutator.AgentEntersEvent.Subscribe(PurchaseApples1)
                Fence1Mutator.AgentEntersEvent.Subscribe(PurchaseFence1)
                Wall1Mutator.AgentEntersEvent.Subscribe(PurchaseWall1)
            if(ChickenCoop2Purchase = true):
                ChickenCoop3Mutator.AgentEntersEvent.Subscribe(PurchaseChickenCoop3)
            if(ChickenCoop3Purchase = true):
                ChickenCoop4Mutator.AgentEntersEvent.Subscribe(PurchaseChickenCoop4)
            if(ChickenCoop4Purchase = true):
                ChickenCoop5Mutator.AgentEntersEvent.Subscribe(PurchaseChickenCoop5)
            if(ChickenCoop5Purchase = true):
                ChickenCoop6Mutator.AgentEntersEvent.Subscribe(PurchaseChickenCoop6)
            if(Wall1Purchase = true):
                Wall2Mutator.AgentEntersEvent.Subscribe(PurchaseWall2)
            if(Wall2Purchase = true):
                Wall3Mutator.AgentEntersEvent.Subscribe(PurchaseWall3)
            if(Wall3Purchase = true):
                Wall4Mutator.AgentEntersEvent.Subscribe(PurchaseWall4)
            if(Wall4Purchase = true):
                Pillars1Mutator.AgentEntersEvent.Subscribe(PurchasePillars1)
                Stairs1Mutator.AgentEntersEvent.Subscribe(PurchaseStairs1)
            if(Pillars1Purchase = true):
                Couch1Mutator.AgentEntersEvent.Subscribe(PurchaseCouch1)
            if(Couch1Purchase = true):
                Table1Mutator.AgentEntersEvent.Subscribe(PurchaseTable1)
            if(Table1Purchase = true):
                Rug1Mutator.AgentEntersEvent.Subscribe(PurchaseRug1)
            if(Rug1Purchase = true):
                Junk1Mutator.AgentEntersEvent.Subscribe(PurchaseJunk1)
                Chimney1Mutator.AgentEntersEvent.Subscribe(PurchaseChimney1)
            if(Junk1Purchase = true):
                Flowers1Mutator.AgentEntersEvent.Subscribe(PurchaseFlowers1)
            if(Flowers1Purchase = true):
                Chair3Mutator.AgentEntersEvent.Subscribe(PurchaseChair3)
            if(Chair3Purchase = true):
                Clock1Mutator.AgentEntersEvent.Subscribe(PurchaseClock1)
            if(Clock1Purchase = true):
                Painting1Mutator.AgentEntersEvent.Subscribe(PurchasePainting1)
            if(Stairs1Purchase = true):
                Floors1Mutator.AgentEntersEvent.Subscribe(PurchaseFloors1)
            if(Floors1Purchase = true):
                Railings1Mutator.AgentEntersEvent.Subscribe(PurchaseRailings1)
                Wall5Mutator.AgentEntersEvent.Subscribe(PurchaseWall5)
                Bed1Mutator.AgentEntersEvent.Subscribe(PurchaseBed1)
            if(Wall5Purchase = true):
                Wall6Mutator.AgentEntersEvent.Subscribe(PurchaseWall6)
            if(Wall6Purchase = true):
                Wall7Mutator.AgentEntersEvent.Subscribe(PurchaseWall7)
            if(Wall7Purchase = true):
                Wall8Mutator.AgentEntersEvent.Subscribe(PurchaseWall8)
            if(Bed1Purchase = true):
                Nightstand1Mutator.AgentEntersEvent.Subscribe(PurchaseNightstand1)
            if(Nightstand1Purchase = true):
                Dresser1Mutator.AgentEntersEvent.Subscribe(PurchaseDresser1)
            if(Dresser1Purchase = true):
                Bookshelf1Mutator.AgentEntersEvent.Subscribe(PurchaseBookshelf1)
            if(Bookshelf1Purchase = true):
                Desk1Mutator.AgentEntersEvent.Subscribe(PurchaseDesk1)
            if(Desk1Purchase = true):
                Roof1Mutator.AgentEntersEvent.Subscribe(PurchaseRoof1)
            if(Apples1Purchase = true):
                Chairs1Mutator.AgentEntersEvent.Subscribe(PurchaseChairs1)
                Chairs2Mutator.AgentEntersEvent.Subscribe(PurchaseChairs2)
                Cabbage1Mutator.AgentEntersEvent.Subscribe(PurchaseCabbage1)
                Haybales1Mutator.AgentEntersEvent.Subscribe(PurchaseHaybales1)
            if(Chairs1Purchase = true):
                Porch1Mutator.AgentEntersEvent.Subscribe(PurchasePorch1)
            if(Fence1Purchase = true):
                Fence2Mutator.AgentEntersEvent.Subscribe(PurchaseFence2)
            if(Fence2Purchase = true):
                Fence3Mutator.AgentEntersEvent.Subscribe(PurchaseFence3)
            if(Fence3Purchase = true):
                Fence4Mutator.AgentEntersEvent.Subscribe(PurchaseFence4)
            if(Fence4Purchase = true):
                Silo1Mutator.AgentEntersEvent.Subscribe(PurchaseSilo1)
            if(Silo1Purchase = true):
                Silo2Mutator.AgentEntersEvent.Subscribe(PurchaseSilo2)
            if(Haybales1Purchase = true):
                Haybales2Mutator.AgentEntersEvent.Subscribe(PurchaseHaybales2)
            if(CabbageFence1Purchase = true):
                CabbageFence2Mutator.AgentEntersEvent.Subscribe(PurchaseCabbageFence2)
            if(CabbageFence2Purchase = true):
                CabbageFence3Mutator.AgentEntersEvent.Subscribe(PurchaseCabbageFence3)
            if(CabbageFence3Purchase = true):
                CabbageFence4Mutator.AgentEntersEvent.Subscribe(PurchaseCabbageFence4)
            if(CabbageFence4Purchase = true):
                Shed1Mutator.AgentEntersEvent.Subscribe(PurchaseShed1)
                if(RebirthLevel >= 1):
                    Tomato1Mutator.AgentEntersEvent.Subscribe(PurchaseTomato1)
            if(Cabbage1Purchase = true):
                Cabbage2Mutator.AgentEntersEvent.Subscribe(PurchaseCabbage2)
            if(Cabbage2Purchase = true):
                Cabbage3Mutator.AgentEntersEvent.Subscribe(PurchaseCabbage3)
            if(Cabbage3Purchase = true):
                Cabbage4Mutator.AgentEntersEvent.Subscribe(PurchaseCabbage4)
                CabbageSeller1.ActivatedEvent.Subscribe(SellCabbage)
                CabbageSeller2.ActivatedEvent.Subscribe(SellCabbage)
            if(Cabbage4Purchase = true):
                Cabbage5Mutator.AgentEntersEvent.Subscribe(PurchaseCabbage5)
            if(Cabbage5Purchase = true):
                CabbageFence1Mutator.AgentEntersEvent.Subscribe(PurchaseCabbageFence1)
            if(Haybales2Purchase = true):
                Tractor1Mutator.AgentEntersEvent.Subscribe(PurchaseTractor1)
            if(Tomato1Purchase = true):
                Tomato2Mutator.AgentEntersEvent.Subscribe(PurchaseTomato2)
            if(Tomato2Purchase = true):
                Tomato3Mutator.AgentEntersEvent.Subscribe(PurchaseTomato3)
            if(Tomato3Purchase = true):
                Tomato4Mutator.AgentEntersEvent.Subscribe(PurchaseTomato4)
            if(Tomato4Purchase = true):
                TomatoFence1Mutator.AgentEntersEvent.Subscribe(PurchaseTomatoFence1)
            if(TomatoFence1Purchase = true):
                TomatoFence2Mutator.AgentEntersEvent.Subscribe(PurchaseTomatoFence2)
            if(TomatoFence2Purchase = true):
                TomatoFence3Mutator.AgentEntersEvent.Subscribe(PurchaseTomatoFence3)
            if(TomatoFence3Purchase = true):
                TomatoFence4Mutator.AgentEntersEvent.Subscribe(PurchaseTomatoFence4)
            if(Shed1Purchase = true):
                Corn1Mutator.AgentEntersEvent.Subscribe(PurchaseCorn1)
            if(Corn1Purchase = true):
                Haybales3Mutator.AgentEntersEvent.Subscribe(PurchaseHaybales3)
                Windmill1Mutator.AgentEntersEvent.Subscribe(PurchaseWindmill1)
            if(Haybales3Purchase = true):
                Wagon1Mutator.AgentEntersEvent.Subscribe(PurchaseWagon1)
            if(Wagon1Purchase = true):
                Haybales5Mutator.AgentEntersEvent.Subscribe(PurchaseHaybales5)
                Stable1Mutator.AgentEntersEvent.Subscribe(PurchaseStable1)
            if(Stable1Purchase = true):
                Stable2Mutator.AgentEntersEvent.Subscribe(PurchaseStable2)
            if(TomatoFence4Purchase = true):
                if(RebirthLevel >= 2):
                    Pond1Mutator.AgentEntersEvent.Subscribe(PurchasePond1)
            if(Pond1Purchase = true):
                Dock1Mutator.AgentEntersEvent.Subscribe(PurchaseDock1)
            if(Dock1Purchase = true):
                Fishing1Mutator.AgentEntersEvent.Subscribe(PurchaseFishing1)
            if(Fishing1Purchase = true):
                if(RebirthLevel >= 3):
                    BoarPen1Mutator.AgentEntersEvent.Subscribe(PurchaseBoarPen1)
            if(BoarPen1Purchase = true):
                BoarFence1Mutator.AgentEntersEvent.Subscribe(PurchaseBoarFence1)
            if(BoarFence1Purchase = true):
                BoarFence2Mutator.AgentEntersEvent.Subscribe(PurchaseBoarFence2)
            if(BoarFence2Purchase = true):
                BoarFence3Mutator.AgentEntersEvent.Subscribe(PurchaseBoarFence3)
            if(BoarFence3Purchase = true):
                Haybales4Mutator.AgentEntersEvent.Subscribe(PurchaseHaybales4)
            if(Haybales4Purchase = true):
                BoarVegetation1Mutator.AgentEntersEvent.Subscribe(PurchaseBoarVegetation1)

    SellCabbage(Agent : agent):void=
        set PlayerBalance += CabbagePrice
        MoneyClaimHUD.SetText(PlayerBalanceString("+ ${CabbagePrice}"))
        MoneyClaimHUD.Show(Agent)

    SellSmallFry(Agent : agent):void=
        set PlayerBalance += SmallFryPrice
        MoneyClaimHUD.SetText(PlayerBalanceString("+ ${SmallFryPrice}"))
        MoneyClaimHUD.Show(Agent)

    SellFlopper(Agent : agent):void=
        set PlayerBalance += FlopperPrice
        MoneyClaimHUD.SetText(PlayerBalanceString("+ ${FlopperPrice}"))
        MoneyClaimHUD.Show(Agent)

    SellShieldFish(Agent : agent):void=
        set PlayerBalance += ShieldFishPrice
        MoneyClaimHUD.SetText(PlayerBalanceString("+ ${ShieldFishPrice}"))
        MoneyClaimHUD.Show(Agent)

    SellCuddleFish(Agent : agent):void=
        set PlayerBalance += CuddleFishPrice
        MoneyClaimHUD.SetText(PlayerBalanceString("+ ${CuddleFishPrice}"))
        MoneyClaimHUD.Show(Agent)
    
    CabbageGranting(Agent : agent)<suspends>:void=
        loop:
            Sleep(10.0)
            if(Cabbage3Purchase = true):
                CabbageGranter.GrantItem(Agent)

    # TYCOON CLAIM

    TycoonClaim(Agent : agent):void=
        WelcomeTycoonHUD.Show(Agent)
        TycoonClaimCube.HideProps()
        set TycoonCompletionDecimal = 0
        set TycoonCompletionWhole = 0
        AssignUI(Agent)
        ChickenCoop1Cube.ShowProps()
        ChickenCoop1Text.Show()
        set TycoonClaimCheck = true
        RebirthProps.ShowProps()
        MoneyProps.ShowProps()
        Like250kText.Show()
        Like250kCube.ShowProps()
        RebirthNotReadyText.ShowText()
        MoneyText.ShowText()
        MoneyMutator.AgentEntersEvent.Subscribe(ClaimMoney)
        spawn{FirstClaim3x(Agent)}
        spawn{CheckingTwoXMoney(Agent)}
        if(RebirthLevel = 0):
            Rebirth1NeededText.Show()
            Rebirth1DescriptionText.Show()
            Rebirth1NeededCube.ShowProps()
            TwoXMoneyBillboard.SetText(PlayerBalanceString("(1x Multiplier)"))
        if(RebirthLevel <= 1):
            Rebirth2NeededText.Show()
            Rebirth2DescriptionText.Show()
            Rebirth2NeededCube.ShowProps()
        if(RebirthLevel <= 2):
            Rebirth3NeededText.Show()
            Rebirth3DescriptionText.Show()
            Rebirth3NeededCube.ShowProps()

    FirstClaim3x(Agent : agent)<suspends>:void=
        set Level0MoneyCheck = false
        set Level3MoneyCheck = true
        Sleep(120.0)
        set Level3MoneyCheck = false
        set Level0MoneyCheck = true

    ClaimMoney(Agent : agent):void=
        MoneyClaimHUD.SetText(PlayerBalanceString("+ ${BeforeClaimMoney}"))
        MoneyClaimHUD.Show(Agent)
        set PlayerBalance += BeforeClaimMoney
        set BeforeClaimMoney = 0
        MoneyRadio.Play()

    AssignUI(Agent : agent):void=
        spawn{RefreshUI(Agent)}
        spawn{MoneyPerSec(Agent)}
        spawn{TycoonCompletionFormat(Agent)}
        spawn{CabbageGranting(Agent)}

    MoneyPerSec(Agent : agent)<suspends>:void=
        loop:
            Sleep(0.9)
            if(Level0MoneyCheck = true):
                set BeforeClaimMoney += MoneyPerSecond
                MoneyText.SetText(PlayerBalanceString("${BeforeClaimMoney}"))
                MoneySecText.SetText(PlayerBalanceString("${MoneyPerSecond} / s"))
            if(Level1n2MoneyCheck = true):
                set BeforeClaimMoney += Level1n2Money
                MoneyText.SetText(PlayerBalanceString("${BeforeClaimMoney}"))
                MoneySecText.SetText(PlayerBalanceString("${Level1n2Money} / s"))
            if(Level3MoneyCheck = true):
                set BeforeClaimMoney += Level3Money
                MoneyText.SetText(PlayerBalanceString("${BeforeClaimMoney}"))
                MoneySecText.SetText(PlayerBalanceString("${Level3Money} / s"))

    TycoonCompletionFormat(Agent : agent)<suspends>:void=
        loop:
            Sleep(0.1)
            if(TycoonCompletionDecimal >= 100):
                set TycoonCompletionDecimal -= 100
                set TycoonCompletionWhole += 1

    RefreshUI(Agent : agent)<suspends>:void=
        loop:
            Sleep(0.1)
            PlayerMoneyHUD.SetText(PlayerBalanceString("${PlayerBalance}"))
            PlayerRebirthHUD.SetText(PlayerRebirthLevelString("{RebirthLevel}"))
            PlayerTycoonCompletionHUD.SetText(PlayerTycoonCompletionString("{TycoonCompletionWhole}.{TycoonCompletionDecimal}%"))
            PlayerMoneyHUD.Show(Agent)
            PlayerRebirthHUD.Show(Agent)
            PlayerTycoonCompletionHUD.Show(Agent)

    # FENCE 1

    PurchaseFence1(Agent : agent):void=
        if(PlayerBalance >= Fence1Price):
            if(Fence1Purchase = false):
                if(ChickenCoop1Purchase = true):
                    Fence1Props.ShowProps()
                    Fence1Cube.HideProps()
                    Fence1Text.Hide()
                    set PlayerBalance -= Fence1Price
                    set Fence1Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Fence1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Fence2Cube.ShowProps()
                    Fence2Text.Show()
        if(PlayerBalance < Fence1Price):
            if(Fence1Purchase = false):
                if(ChickenCoop1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # FENCE 2

    PurchaseFence2(Agent : agent):void=
        if(PlayerBalance >= Fence2Price):
            if(Fence2Purchase = false):
                if(Fence1Purchase = true):
                    Fence2Props.ShowProps()
                    Fence2Cube.HideProps()
                    Fence2Text.Hide()
                    set PlayerBalance -= Fence2Price
                    set Fence2Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Fence2Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Fence3Cube.ShowProps()
                    Fence3Text.Show()
        if(PlayerBalance < Fence2Price):
            if(Fence2Purchase = false):
                if(Fence1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # FENCE 3

    PurchaseFence3(Agent : agent):void=
        if(PlayerBalance >= Fence3Price):
            if(Fence3Purchase = false):
                if(Fence2Purchase = true):
                    Fence3Props.ShowProps()
                    Fence3Cube.HideProps()
                    Fence3Text.Hide()
                    set PlayerBalance -= Fence3Price
                    set Fence3Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Fence3Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Fence4Cube.ShowProps()
                    Fence4Text.Show()
        if(PlayerBalance < Fence3Price):
            if(Fence3Purchase = false):
                if(Fence2Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # FENCE 4

    PurchaseFence4(Agent : agent):void=
        if(PlayerBalance >= Fence4Price):
            if(Fence4Purchase = false):
                if(Fence3Purchase = true):
                    Fence4Props.ShowProps()
                    Fence4Cube.HideProps()
                    Fence4Text.Hide()
                    set PlayerBalance -= Fence4Price
                    set Fence4Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Fence4Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Silo1Cube.ShowProps()
                    Silo1Text.Show()
        if(PlayerBalance < Fence4Price):
            if(Fence4Purchase = false):
                if(Fence3Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # CHICKEN COOP 1

    PurchaseChickenCoop1(Agent : agent):void=
        if(PlayerBalance >= ChickenCoop1Price):
            if(ChickenCoop1Purchase = false):
                ChickenCoop1Props.ShowProps()
                ChickenCoop1Cube.HideProps()
                ChickenCoop1Text.Hide()
                ChickenCoop1SecText.Show()
                set PlayerBalance -= ChickenCoop1Price
                set ChickenCoop1Purchase = true
                set MoneyPerSecond += ChickenCoop1Money
                set TycoonCompletionDecimal += 25
                set TycoonCompletionWhole += 1
                PurchasedHUD.Show(Agent)
                PurchasedRadio.Play()
                # NEXT FUNCTION
                ChickenCoop2Cube.ShowProps()
                ChickenCoop2Text.Show()
                Wall1Cube.ShowProps()
                Wall1Text.Show()
                Apples1Cube.ShowProps()
                Apples1Text.Show()
                Fence1Cube.ShowProps()
                Fence1Text.Show()
        if(PlayerBalance < ChickenCoop1Price):
            if(ChickenCoop1Purchase = false):
                NotEnoughMoneyHUD.Show(Agent)
                NotEnoughRadio.Play()

    # CHICKEN COOP 2

    PurchaseChickenCoop2(Agent : agent):void=
        if(PlayerBalance >= ChickenCoop2Price):
            if(ChickenCoop2Purchase = false):
                if(ChickenCoop1Purchase = true):
                    ChickenCoop2Props.ShowProps()
                    ChickenCoop2Cube.HideProps()
                    ChickenCoop2Text.Hide()
                    ChickenCoop2SecText.Show()
                    set PlayerBalance -= ChickenCoop2Price
                    set ChickenCoop2Purchase = true
                    set MoneyPerSecond += ChickenCoop2Money
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${ChickenCoop2Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    ChickenCoop3Cube.ShowProps()
                    ChickenCoop3Text.Show()
        if(PlayerBalance < ChickenCoop2Price):
            if(ChickenCoop2Purchase = false):
                if(ChickenCoop1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # CHICKEN COOP 3

    PurchaseChickenCoop3(Agent : agent):void=
        if(PlayerBalance >= ChickenCoop3Price):
            if(ChickenCoop3Purchase = false):
                if(ChickenCoop2Purchase = true):
                    ChickenCoop3Props.ShowProps()
                    ChickenCoop3Cube.HideProps()
                    ChickenCoop3Text.Hide()
                    ChickenCoop3SecText.Show()
                    set PlayerBalance -= ChickenCoop3Price
                    set ChickenCoop3Purchase = true
                    set MoneyPerSecond += ChickenCoop3Money
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${ChickenCoop3Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    ChickenCoop4Cube.ShowProps()
                    ChickenCoop4Text.Show()
        if(PlayerBalance < ChickenCoop3Price):
            if(ChickenCoop3Purchase = false):
                if(ChickenCoop2Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # CHICKEN COOP 4

    PurchaseChickenCoop4(Agent : agent):void=
        if(PlayerBalance >= ChickenCoop4Price):
            if(ChickenCoop4Purchase = false):
                if(ChickenCoop3Purchase = true):
                    ChickenCoop4Props.ShowProps()
                    ChickenCoop4Cube.HideProps()
                    ChickenCoop4Text.Hide()
                    ChickenCoop4SecText.Show()
                    set PlayerBalance -= ChickenCoop4Price
                    set ChickenCoop4Purchase = true
                    set MoneyPerSecond += ChickenCoop4Money
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${ChickenCoop4Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    ChickenCoop5Cube.ShowProps()
                    ChickenCoop5Text.Show()
        if(PlayerBalance < ChickenCoop4Price):
            if(ChickenCoop4Purchase = false):
                if(ChickenCoop3Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # CHICKEN COOP 5

    PurchaseChickenCoop5(Agent : agent):void=
        if(PlayerBalance >= ChickenCoop5Price):
            if(ChickenCoop5Purchase = false):
                if(ChickenCoop4Purchase = true):
                    ChickenCoop5Props.ShowProps()
                    ChickenCoop5Cube.HideProps()
                    ChickenCoop5Text.Hide()
                    ChickenCoop5SecText.Show()
                    set PlayerBalance -= ChickenCoop5Price
                    set ChickenCoop5Purchase = true
                    set MoneyPerSecond += ChickenCoop5Money
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${ChickenCoop5Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    ChickenCoop6Cube.ShowProps()
                    ChickenCoop6Text.Show()
        if(PlayerBalance < ChickenCoop5Price):
            if(ChickenCoop5Purchase = false):
                if(ChickenCoop4Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # CHICKEN COOP 6

    PurchaseChickenCoop6(Agent : agent):void=
        if(PlayerBalance >= ChickenCoop6Price):
            if(ChickenCoop6Purchase = false):
                    if(ChickenCoop5Purchase = true):
                    ChickenCoop6Props.ShowProps()
                    ChickenCoop6Cube.HideProps()
                    ChickenCoop6Text.Hide()
                    ChickenCoop6SecText.Show()
                    set PlayerBalance -= ChickenCoop6Price
                    set ChickenCoop6Purchase = true
                    set MoneyPerSecond += ChickenCoop6Money
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${ChickenCoop6Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
        if(PlayerBalance < ChickenCoop6Price):
            if(ChickenCoop6Purchase = false):
                if(ChickenCoop5Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # CABBAGE 1

    PurchaseCabbage1(Agent : agent):void=
        if(PlayerBalance >= Cabbage1Price):
            if(Cabbage1Purchase = false):
                if(Apples1Purchase = true):
                    Cabbage1Props.ShowProps()
                    Cabbage1Cube.HideProps()
                    Cabbage1Text.Hide()
                    Cabbage1SecText.Show()
                    set PlayerBalance -= Cabbage1Price
                    set Cabbage1Purchase = true
                    set MoneyPerSecond += Cabbage1Money
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Cabbage1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Cabbage2Cube.ShowProps()
                    Cabbage2Text.Show()
        if(PlayerBalance < Cabbage1Price):
            if(Cabbage1Purchase = false):
                if(Apples1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # CABBAGE 2

    PurchaseCabbage2(Agent : agent):void=
        if(PlayerBalance >= Cabbage2Price):
            if(Cabbage2Purchase = false):
                if(Cabbage1Purchase = true):
                    Cabbage2Props.ShowProps()
                    Cabbage2Cube.HideProps()
                    Cabbage2Text.Hide()
                    Cabbage2SecText.Show()
                    set PlayerBalance -= Cabbage2Price
                    set Cabbage2Purchase = true
                    set MoneyPerSecond += Cabbage2Money
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Cabbage2Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Cabbage3Cube.ShowProps()
                    Cabbage3Text.Show()
        if(PlayerBalance < Cabbage2Price):
            if(Cabbage2Purchase = false):
                if(Cabbage1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # CABBAGE 3

    PurchaseCabbage3(Agent : agent):void=
        if(PlayerBalance >= Cabbage3Price):
            if(Cabbage3Purchase = false):
                if(Cabbage2Purchase = true):
                    Cabbage3Props.ShowProps()
                    Cabbage3Cube.HideProps()
                    Cabbage3Text.Hide()
                    Cabbage3SecText.Show()
                    set PlayerBalance -= Cabbage3Price
                    set Cabbage3Purchase = true
                    set MoneyPerSecond += Cabbage3Money
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Cabbage3Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Cabbage4Cube.ShowProps()
                    Cabbage4Text.Show()
        if(PlayerBalance < Cabbage3Price):
            if(Cabbage3Purchase = false):
                if(Cabbage2Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # CABBAGE 4

    PurchaseCabbage4(Agent : agent):void=
        if(PlayerBalance >= Cabbage4Price):
            if(Cabbage4Purchase = false):
                if(Cabbage3Purchase = true):
                    Cabbage4Props.ShowProps()
                    Cabbage4Cube.HideProps()
                    Cabbage4Text.Hide()
                    Cabbage4SecText.Show()
                    set PlayerBalance -= Cabbage4Price
                    set Cabbage4Purchase = true
                    set MoneyPerSecond += Cabbage4Money
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Cabbage4Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Cabbage5Cube.ShowProps()
                    Cabbage5Text.Show()
        if(PlayerBalance < Cabbage4Price):
            if(Cabbage4Purchase = false):
                if(Cabbage3Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # CABBAGE 5

    PurchaseCabbage5(Agent : agent):void=
        if(PlayerBalance >= Cabbage5Price):
            if(Cabbage5Purchase = false):
                if(Cabbage4Purchase = true):
                    Cabbage5Props.ShowProps()
                    Cabbage5Cube.HideProps()
                    Cabbage5Text.Hide()
                    Cabbage5SecText.Show()
                    set PlayerBalance -= Cabbage5Price
                    set Cabbage5Purchase = true
                    set MoneyPerSecond += Cabbage5Money
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Cabbage5Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    CabbageFence1Cube.ShowProps()
                    CabbageFence1Text.Show()
        if(PlayerBalance < Cabbage5Price):
            if(Cabbage5Purchase = false):
                if(Cabbage4Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # WALL 1

    PurchaseWall1(Agent : agent):void=
        if(PlayerBalance >= Wall1Price):
            if(Wall1Purchase = false):
                if(ChickenCoop1Purchase = true):
                    Wall1Props.ShowProps()
                    Wall1Cube.HideProps()
                    Wall1Text.Hide()
                    set PlayerBalance -= Wall1Price
                    set Wall1Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Wall1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Wall2Cube.ShowProps()
                    Wall2Text.Show()
        if(PlayerBalance < Wall1Price):
            if(Wall1Purchase = false):
                if(ChickenCoop1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # WALL 2

    PurchaseWall2(Agent : agent):void=
        if(PlayerBalance >= Wall2Price):
            if(Wall2Purchase = false):
                if(Wall1Purchase = true):
                    Wall2Props.ShowProps()
                    Wall2Cube.HideProps()
                    Wall2Text.Hide()
                    set PlayerBalance -= Wall2Price
                    set Wall2Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Wall2Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Wall3Cube.ShowProps()
                    Wall3Text.Show()
        if(PlayerBalance < Wall2Price):
            if(Wall2Purchase = false):
                if(Wall1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # WALL 3

    PurchaseWall3(Agent : agent):void=
        if(PlayerBalance >= Wall3Price):
            if(Wall3Purchase = false):
                if(Wall2Purchase = true):
                    Wall3Props1.ShowProps()
                    Wall3Props2.ShowProps()
                    Wall3Cube.HideProps()
                    Wall3Text.Hide()
                    set PlayerBalance -= Wall3Price
                    set Wall3Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Wall3Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Wall4Cube.ShowProps()
                    Wall4Text.Show()
        if(PlayerBalance < Wall3Price):
            if(Wall3Purchase = false):
                if(Wall2Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # WALL 4

    PurchaseWall4(Agent : agent):void=
        if(PlayerBalance >= Wall4Price):
            if(Wall4Purchase = false):
                if(Wall3Purchase = true):
                    Wall4Props.ShowProps()
                    Wall4Cube.HideProps()
                    Wall4Text.Hide()
                    set PlayerBalance -= Wall4Price
                    set Wall4Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Wall4Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Pillars1Cube.ShowProps()
                    Pillars1Text.Show()
                    Stairs1Cube.ShowProps()
                    Stairs1Text.Show()
        if(PlayerBalance < Wall4Price):
            if(Wall4Purchase = false):
                if(Wall3Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # WALL 5

    PurchaseWall5(Agent : agent):void=
        if(PlayerBalance >= Wall5Price):
            if(Wall5Purchase = false):
                if(Floors1Purchase = true):
                    Wall5Props.ShowProps()
                    Wall5Cube.HideProps()
                    Wall5Text.Hide()
                    set PlayerBalance -= Wall5Price
                    set Wall5Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Wall5Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Wall6Cube.ShowProps()
                    Wall6Text.Show()
        if(PlayerBalance < Wall5Price):
            if(Wall5Purchase = false):
                if(Floors1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # WALL 6
    
    PurchaseWall6(Agent : agent):void=
        if(PlayerBalance >= Wall6Price):
            if(Wall6Purchase = false):
                if(Wall5Purchase = true):
                    Wall6Props.ShowProps()
                    Wall6Cube.HideProps()
                    Wall6Text.Hide()
                    set PlayerBalance -= Wall6Price
                    set Wall6Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Wall6Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Wall7Cube.ShowProps()
                    Wall7Text.Show()
        if(PlayerBalance < Wall6Price):
            if(Wall6Purchase = false):
                if(Wall5Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # WALL 7

    PurchaseWall7(Agent : agent):void=
        if(PlayerBalance >= Wall7Price):
            if(Wall7Purchase = false):
                if(Wall6Purchase = true):
                    Wall7Props.ShowProps()
                    Wall7Cube.HideProps()
                    Wall7Text.Hide()
                    set PlayerBalance -= Wall7Price
                    set Wall7Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Wall7Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Wall8Cube.ShowProps()
                    Wall8Text.Show()
        if(PlayerBalance < Wall7Price):
            if(Wall7Purchase = false):
                if(Wall6Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # WALL 8

    PurchaseWall8(Agent : agent):void=
        if(PlayerBalance >= Wall8Price):
            if(Wall8Purchase = false):
                if(Wall7Purchase = true):
                    Wall8Props.ShowProps()
                    Wall8Cube.HideProps()
                    Wall8Text.Hide()
                    set PlayerBalance -= Wall8Price
                    set Wall8Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Wall8Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
        if(PlayerBalance < Wall8Price):
            if(Wall8Purchase = false):
                if(Wall7Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # PILLARS 1

    PurchasePillars1(Agent : agent):void=
        if(PlayerBalance >= Pillars1Price):
            if(Pillars1Purchase = false):
                if(Wall4Purchase = true):
                    Pillars1Props.ShowProps()
                    Pillars1Cube.HideProps()
                    Pillars1Text.Hide()
                    set PlayerBalance -= Pillars1Price
                    set Pillars1Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Pillars1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Couch1Cube.ShowProps()
                    Couch1Text.Show()
        if(PlayerBalance < Pillars1Price):
            if(Pillars1Purchase = false):
                if(Wall4Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # COUCH 1

    PurchaseCouch1(Agent : agent):void=
        if(PlayerBalance >= Couch1Price):
            if(Couch1Purchase = false):
                if(Pillars1Purchase = true):
                    Couch1Props.ShowProps()
                    Couch1Cube.HideProps()
                    Couch1Text.Hide()
                    set PlayerBalance -= Couch1Price
                    set Couch1Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Couch1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Table1Cube.ShowProps()
                    Table1Text.Show()
        if(PlayerBalance < Couch1Price):
            if(Couch1Purchase = false):
                if(Pillars1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # TABLE 1

    PurchaseTable1(Agent : agent):void=
        if(PlayerBalance >= Table1Price):
            if(Table1Purchase = false):
                if(Couch1Purchase = true):
                    Table1Props.ShowProps()
                    Table1Cube.HideProps()
                    Table1Text.Hide()
                    set PlayerBalance -= Table1Price
                    set Table1Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Table1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Rug1Cube.ShowProps()
                    Rug1Text.Show()
        if(PlayerBalance < Table1Price):
            if(Table1Purchase = false):
                if(Couch1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # RUG 1

    PurchaseRug1(Agent : agent):void=
        if(PlayerBalance >= Rug1Price):
            if(Rug1Purchase = false):
                if(Table1Purchase = true):
                    Rug1Props.ShowProps()
                    Rug1Cube.HideProps()
                    Rug1Text.Hide()
                    set PlayerBalance -= Rug1Price
                    set Rug1Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Rug1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Junk1Cube.ShowProps()
                    Junk1Text.Show()
                    Chimney1Cube.ShowProps()
                    Chimney1Text.Show()
        if(PlayerBalance < Rug1Price):
            if(Rug1Purchase = false):
                if(Table1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # JUNK 1

    PurchaseJunk1(Agent : agent):void=
        if(PlayerBalance >= Junk1Price):
            if(Junk1Purchase = false):
                if(Rug1Purchase = true):
                    Junk1Props.ShowProps()
                    Junk1Cube.HideProps()
                    Junk1Text.Hide()
                    set PlayerBalance -= Junk1Price
                    set Junk1Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Junk1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Flowers1Cube.ShowProps()
                    Flowers1Text.Show()
        if(PlayerBalance < Junk1Price):
            if(Junk1Purchase = false):
                if(Rug1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # FLOWERS 1

    PurchaseFlowers1(Agent : agent):void=
        if(PlayerBalance >= Flowers1Price):
            if(Flowers1Purchase = false):
                if(Junk1Purchase = true):
                    Flowers1Props1.ShowProps()
                    Flowers1Props2.ShowProps()
                    Flowers1Cube.HideProps()
                    Flowers1Text.Hide()
                    set PlayerBalance -= Flowers1Price
                    set Flowers1Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Flowers1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Chair3Cube.ShowProps()
                    Chair3Text.Show()
        if(PlayerBalance < Flowers1Price):
            if(Flowers1Purchase = false):
                if(Junk1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # CHAIR 3

    PurchaseChair3(Agent : agent):void=
        if(PlayerBalance >= Chair3Price):
            if(Chair3Purchase = false):
                if(Flowers1Purchase = true):
                    Chair3Props.ShowProps()
                    Chair3Cube.HideProps()
                    Chair3Text.Hide()
                    set PlayerBalance -= Chair3Price
                    set Chair3Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Chair3Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Clock1Cube.ShowProps()
                    Clock1Text.Show()
        if(PlayerBalance < Chair3Price):
            if(Chair3Purchase = false):
                if(Flowers1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # CLOCK 1

    PurchaseClock1(Agent : agent):void=
        if(PlayerBalance >= Clock1Price):
            if(Clock1Purchase = false):
                if(Chair3Purchase = true):
                    Clock1Props.ShowProps()
                    Clock1Cube.HideProps()
                    Clock1Text.Hide()
                    set PlayerBalance -= Clock1Price
                    set Clock1Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Clock1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Painting1Cube.ShowProps()
                    Painting1Text.Show()
        if(PlayerBalance < Clock1Price):
            if(Clock1Purchase = false):
                if(Chair3Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # PAINTING 1

    PurchasePainting1(Agent : agent):void=
        if(PlayerBalance >= Painting1Price):
            if(Painting1Purchase = false):
                if(Clock1Purchase = true):
                    Painting1Props.ShowProps()
                    Painting1Cube.HideProps()
                    Painting1Text.Hide()
                    set PlayerBalance -= Painting1Price
                    set Painting1Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Painting1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
        if(PlayerBalance < Painting1Price):
            if(Painting1Purchase = false):
                if(Clock1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # STAIRS 1

    PurchaseStairs1(Agent : agent):void=
        if(PlayerBalance >= Stairs1Price):
            if(Stairs1Purchase = false):
                if(Wall4Purchase = true):
                    Stairs1Props.ShowProps()
                    Stairs1Cube.HideProps()
                    Stairs1Text.Hide()
                    set PlayerBalance -= Stairs1Price
                    set Stairs1Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Stairs1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Floors1Cube.ShowProps()
                    Floors1Text.Show()
        if(PlayerBalance < Stairs1Price):
            if(Stairs1Purchase = false):
                if(Wall4Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # CHIMNEY 1

    PurchaseChimney1(Agent : agent):void=
        if(PlayerBalance >= Chimney1Price):
            if(Chimney1Purchase = false):
                if(Rug1Purchase = true):
                    Chimney1Props1.ShowProps()
                    Chimney1Props2.ShowProps()
                    Chimney1Smoke.Enable()
                    Chimney1Cube.HideProps()
                    Chimney1Text.Hide()
                    set PlayerBalance -= Chimney1Price
                    set Chimney1Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Chimney1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
        if(PlayerBalance < Chimney1Price):
            if(Chimney1Purchase = false):
                if(Rug1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # FLOORS 1

    PurchaseFloors1(Agent : agent):void=
        if(PlayerBalance >= Floors1Price):
            if(Floors1Purchase = false):
                if(Stairs1Purchase = true):
                    Floors1Props1.ShowProps()
                    Floors1Props2.ShowProps()
                    Floors1Props3.ShowProps()
                    Floors1Cube.HideProps()
                    Floors1Text.Hide()
                    set PlayerBalance -= Floors1Price
                    set Floors1Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Floors1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Railings1Cube.ShowProps()
                    Railings1Text.Show()
                    Wall5Cube.ShowProps()
                    Wall5Text.Show()
                    Bed1Cube.ShowProps()
                    Bed1Text.Show()
        if(PlayerBalance < Floors1Price):
            if(Floors1Purchase = false):
                if(Stairs1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # RAILINGS 1

    PurchaseRailings1(Agent : agent):void=
        if(PlayerBalance >= Railings1Price):
            if(Railings1Purchase = false):
                if(Floors1Purchase = true):
                    Railings1Props1.ShowProps()
                    Railings1Props2.ShowProps()
                    Railings1Cube.HideProps()
                    Railings1Text.Hide()
                    set PlayerBalance -= Railings1Price
                    set Railings1Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Railings1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
        if(PlayerBalance < Railings1Price):
            if(Railings1Purchase = false):
                if(Floors1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # BED 1

    PurchaseBed1(Agent : agent):void=
        if(PlayerBalance >= Bed1Price):
            if(Bed1Purchase = false):
                if(Floors1Purchase = true):
                    Bed1Props.ShowProps()
                    Bed1Cube.HideProps()
                    Bed1Text.Hide()
                    set PlayerBalance -= Bed1Price
                    set Bed1Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Bed1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Nightstand1Cube.ShowProps()
                    Nightstand1Text.Show()
        if(PlayerBalance < Bed1Price):
            if(Bed1Purchase = false):
                if(Floors1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # NIGHTSTAND 1

    PurchaseNightstand1(Agent : agent):void=
        if(PlayerBalance >= Nightstand1Price):
            if(Nightstand1Purchase = false):
                if(Bed1Purchase = true):
                    Nightstand1Props.ShowProps()
                    Nightstand1Cube.HideProps()
                    Nightstand1Text.Hide()
                    set PlayerBalance -= Nightstand1Price
                    set Nightstand1Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Nightstand1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Dresser1Cube.ShowProps()
                    Dresser1Text.Show()
        if(PlayerBalance < Nightstand1Price):
            if(Nightstand1Purchase = false):
                if(Bed1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # DRESSER 1

    PurchaseDresser1(Agent : agent):void=
        if(PlayerBalance >= Dresser1Price):
            if(Dresser1Purchase = false):
                if(Nightstand1Purchase = true):
                    Dresser1Props.ShowProps()
                    Dresser1Cube.HideProps()
                    Dresser1Text.Hide()
                    set PlayerBalance -= Dresser1Price
                    set Dresser1Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Dresser1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Bookshelf1Cube.ShowProps()
                    Bookshelf1Text.Show()
        if(PlayerBalance < Dresser1Price):
            if(Dresser1Purchase = false):
                if(Nightstand1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # BOOKSHELF 1

    PurchaseBookshelf1(Agent : agent):void=
        if(PlayerBalance >= Bookshelf1Price):
            if(Bookshelf1Purchase = false):
                if(Dresser1Purchase = true):
                    Bookshelf1Props.ShowProps()
                    Bookshelf1Cube.HideProps()
                    Bookshelf1Text.Hide()
                    set PlayerBalance -= Bookshelf1Price
                    set Bookshelf1Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Bookshelf1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Desk1Cube.ShowProps()
                    Desk1Text.Show()
        if(PlayerBalance < Bookshelf1Price):
            if(Bookshelf1Purchase = false):
                if(Dresser1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # DESK 1

    PurchaseDesk1(Agent : agent):void=
        if(PlayerBalance >= Desk1Price):
            if(Desk1Purchase = false):
                if(Bookshelf1Purchase = true):
                    Desk1Props.ShowProps()
                    Desk1Cube.HideProps()
                    Desk1Text.Hide()
                    set PlayerBalance -= Desk1Price
                    set Desk1Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Desk1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Roof1Cube.ShowProps()
                    Roof1Text.Show()
        if(PlayerBalance < Desk1Price):
            if(Desk1Purchase = false):
                if(Bookshelf1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # ROOF 1

    PurchaseRoof1(Agent : agent):void=
        if(PlayerBalance >= Roof1Price):
            if(Roof1Purchase = false):
                if(Desk1Purchase = true):
                    Roof1Props.ShowProps()
                    Roof1Cube.HideProps()
                    Roof1Text.Hide()
                    set PlayerBalance -= Roof1Price
                    set Roof1Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Roof1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
        if(PlayerBalance < Roof1Price):
            if(Roof1Purchase = false):
                if(Desk1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # APPLES 1

    PurchaseApples1(Agent : agent):void=
        if(PlayerBalance >= Apples1Price):
            if(Apples1Purchase = false):
                if(ChickenCoop1Purchase = true):
                    Apples1Props.ShowProps()
                    Apples1Cube.HideProps()
                    Apples1Text.Hide()
                    set PlayerBalance -= Apples1Price
                    set Apples1Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Apples1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Chairs1Cube.ShowProps()
                    Chairs1Text.Show()
                    Chairs2Cube.ShowProps()
                    Chairs2Text.Show()
                    Cabbage1Cube.ShowProps()
                    Cabbage1Text.Show()
                    Haybales1Cube.ShowProps()
                    Haybales1Text.Show()
        if(PlayerBalance < Apples1Price):
            if(Apples1Purchase = false):
                if(ChickenCoop1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # CHAIRS 1

    PurchaseChairs1(Agent : agent):void=
        if(PlayerBalance >= Chairs1Price):
            if(Chairs1Purchase = false):
                if(Apples1Purchase = true):
                    Chairs1Props.ShowProps()
                    Chairs1Cube.HideProps()
                    Chairs1Text.Hide()
                    set PlayerBalance -= Chairs1Price
                    set Chairs1Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Chairs1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Porch1Cube.ShowProps()
                    Porch1Text.Show()
        if(PlayerBalance < Chairs1Price):
            if(Chairs1Purchase = false):
                if(Apples1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # CHAIRS 2

    PurchaseChairs2(Agent : agent):void=
        if(PlayerBalance >= Chairs2Price):
            if(Chairs2Purchase = false):
                if(Apples1Purchase = true):
                    Chairs2Props.ShowProps()
                    Chairs2Cube.HideProps()
                    Chairs2Text.Hide()
                    set PlayerBalance -= Chairs2Price
                    set Chairs2Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Chairs2Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
        if(PlayerBalance < Chairs2Price):
            if(Chairs2Purchase = false):
                if(Apples1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # PORCH 1

    PurchasePorch1(Agent : agent):void=
        if(PlayerBalance >= Porch1Price):
            if(Porch1Purchase = false):
                if(Chairs1Purchase = true):
                    Porch1Props.ShowProps()
                    Porch1Cube.HideProps()
                    Porch1Text.Hide()
                    set PlayerBalance -= Porch1Price
                    set Porch1Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Porch1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
        if(PlayerBalance < Porch1Price):
            if(Porch1Purchase = false):
                if(Chairs1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # SILO 1

    PurchaseSilo1(Agent : agent):void=
        if(PlayerBalance >= Silo1Price):
            if(Silo1Purchase = false):
                if(Fence4Purchase = true):
                    Silo1Props.ShowProps()
                    Silo1Cube.HideProps()
                    Silo1Text.Hide()
                    set PlayerBalance -= Silo1Price
                    set Silo1Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Silo1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Silo2Cube.ShowProps()
                    Silo2Text.Show()
        if(PlayerBalance < Silo1Price):
            if(Silo1Purchase = false):
                if(Fence4Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # SILO 2

    PurchaseSilo2(Agent : agent):void=
        if(PlayerBalance >= Silo2Price):
            if(Silo2Purchase = false):
                if(Silo1Purchase = true):
                    Silo2Props.ShowProps()
                    Silo2Cube.HideProps()
                    Silo2Text.Hide()
                    set PlayerBalance -= Silo2Price
                    set Silo2Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Silo2Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
        if(PlayerBalance < Silo2Price):
            if(Silo2Purchase = false):
                if(Silo1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # HAYBALES 1

    PurchaseHaybales1(Agent : agent):void=
        if(PlayerBalance >= Haybales1Price):
            if(Haybales1Purchase = false):
                if(Apples1Purchase = true):
                    Haybales1Props.ShowProps()
                    Haybales1Cube.HideProps()
                    Haybales1Text.Hide()
                    set PlayerBalance -= Haybales1Price
                    set Haybales1Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Haybales1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Haybales2Cube.ShowProps()
                    Haybales2Text.Show()
        if(PlayerBalance < Haybales1Price):
            if(Haybales1Purchase = false):
                if(Apples1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # HAYBALES 2

    PurchaseHaybales2(Agent : agent):void=
        if(PlayerBalance >= Haybales2Price):
            if(Haybales2Purchase = false):
                if(Haybales1Purchase = true):
                    Haybales2Props.ShowProps()
                    Haybales2Cube.HideProps()
                    Haybales2Text.Hide()
                    set PlayerBalance -= Haybales2Price
                    set Haybales2Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Haybales2Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Tractor1Cube.ShowProps()
                    Tractor1Text.Show()
        if(PlayerBalance < Haybales2Price):
            if(Haybales2Purchase = false):
                if(Haybales1Purchase = true):    
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # TRACTOR 1

    PurchaseTractor1(Agent : agent):void=
        if(PlayerBalance >= Tractor1Price):
            if(Tractor1Purchase = false):
                if(Haybales2Purchase = true):
                    Tractor1Props.ShowProps()
                    Tractor1Cube.HideProps()
                    Tractor1Text.Hide()
                    set PlayerBalance -= Tractor1Price
                    set Tractor1Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Tractor1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
        if(PlayerBalance < Tractor1Price):
            if(Tractor1Purchase = false):
                if(Haybales2Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # CABBAGE FENCE 1

    PurchaseCabbageFence1(Agent : agent):void=
        if(PlayerBalance >= CabbageFence1Price):
            if(CabbageFence1Purchase = false):
                if(Cabbage5Purchase = true):
                    CabbageFence1Props.ShowProps()
                    CabbageFence1Cube.HideProps()
                    CabbageFence1Text.Hide()
                    set PlayerBalance -= CabbageFence1Price
                    set CabbageFence1Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${CabbageFence1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    CabbageFence2Cube.ShowProps()
                    CabbageFence2Text.Show()
        if(PlayerBalance < CabbageFence1Price):
            if(CabbageFence1Purchase = false):
                if(Cabbage5Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # CABBAGE FENCE 2

    PurchaseCabbageFence2(Agent : agent):void=
        if(PlayerBalance >= CabbageFence2Price):
            if(CabbageFence2Purchase = false):
                if(CabbageFence1Purchase = true):
                    CabbageFence2Props.ShowProps()
                    CabbageFence2Cube.HideProps()
                    CabbageFence2Text.Hide()
                    set PlayerBalance -= CabbageFence2Price
                    set CabbageFence2Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${CabbageFence2Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    CabbageFence3Cube.ShowProps()
                    CabbageFence3Text.Show()
        if(PlayerBalance < CabbageFence2Price):
            if(CabbageFence2Purchase = false):
                if(CabbageFence1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # CABBAGE FENCE 3

    PurchaseCabbageFence3(Agent : agent):void=
        if(PlayerBalance >= CabbageFence3Price):
            if(CabbageFence3Purchase = false):
                if(CabbageFence2Purchase = true):
                    CabbageFence3Props.ShowProps()
                    CabbageFence3Cube.HideProps()
                    CabbageFence3Text.Hide()
                    set PlayerBalance -= CabbageFence3Price
                    set CabbageFence3Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${CabbageFence3Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    CabbageFence4Cube.ShowProps()
                    CabbageFence4Text.Show()
        if(PlayerBalance < CabbageFence3Price):
            if(CabbageFence3Purchase = false):
                if(CabbageFence2Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # CABBAGE FENCE 4

    PurchaseCabbageFence4(Agent : agent):void=
        if(PlayerBalance >= CabbageFence4Price):
            if(CabbageFence4Purchase = false):
                if(CabbageFence3Purchase = true):
                    CabbageFence4Props.ShowProps()
                    CabbageFence4Cube.HideProps()
                    CabbageFence4Text.Hide()
                    set PlayerBalance -= CabbageFence4Price
                    set CabbageFence4Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${CabbageFence4Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Shed1Cube.ShowProps()
                    Shed1Text.Show()
                    if(RebirthLevel >= 1):
                        Tomato1Cube.ShowProps()
                        Tomato1Text.Show()
        if(PlayerBalance < CabbageFence4Price):
            if(CabbageFence4Purchase = false):
                if(CabbageFence3Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # TOMATO 1

    PurchaseTomato1(Agent : agent):void=
        if(PlayerBalance >= Tomato1Price):
            if(Tomato1Purchase = false):
                if(CabbageFence4Purchase = true):
                    Tomato1Props.ShowProps()
                    Tomato1Cube.HideProps()
                    Tomato1Text.Hide()
                    Tomato1SecText.Show()
                    set PlayerBalance -= Tomato1Price
                    set Tomato1Purchase = true
                    set MoneyPerSecond += Tomato1Money
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Tomato1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Tomato2Cube.ShowProps()
                    Tomato2Text.Show()
        if(PlayerBalance < Tomato1Price):
            if(Tomato1Purchase = false):
                if(CabbageFence4Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # TOMATO 2

    PurchaseTomato2(Agent : agent):void=
        if(PlayerBalance >= Tomato2Price):
            if(Tomato2Purchase = false):
                if(Tomato1Purchase = true):
                    Tomato2Props.ShowProps()
                    Tomato2Cube.HideProps()
                    Tomato2Text.Hide()
                    Tomato2SecText.Show()
                    set PlayerBalance -= Tomato2Price
                    set Tomato2Purchase = true
                    set MoneyPerSecond += Tomato2Money
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Tomato2Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Tomato3Cube.ShowProps()
                    Tomato3Text.Show()
        if(PlayerBalance < Tomato2Price):
            if(Tomato2Purchase = false):
                if(Tomato1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # TOMATO 3

    PurchaseTomato3(Agent : agent):void=
        if(PlayerBalance >= Tomato3Price):
            if(Tomato3Purchase = false):
                if(Tomato2Purchase = true):
                    Tomato3Props.ShowProps()
                    Tomato3Cube.HideProps()
                    Tomato3Text.Hide()
                    Tomato3SecText.Show()
                    set PlayerBalance -= Tomato3Price
                    set Tomato3Purchase = true
                    set MoneyPerSecond += Tomato3Money
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Tomato3Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Tomato4Cube.ShowProps()
                    Tomato4Text.Show()
        if(PlayerBalance < Tomato3Price):
            if(Tomato3Purchase = false):
                if(Tomato2Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # TOMATO 4

    PurchaseTomato4(Agent : agent):void=
        if(PlayerBalance >= Tomato4Price):
            if(Tomato4Purchase = false):
                if(Tomato3Purchase = true):
                    Tomato4Props.ShowProps()
                    Tomato4Cube.HideProps()
                    Tomato4Text.Hide()
                    Tomato4SecText.Show()
                    set PlayerBalance -= Tomato4Price
                    set Tomato4Purchase = true
                    set MoneyPerSecond += Tomato4Money
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Tomato4Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    TomatoFence1Cube.ShowProps()
                    TomatoFence1Text.Show()
        if(PlayerBalance < Tomato4Price):
            if(Tomato4Purchase = false):
                if(Tomato3Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # TOMATO FENCE 1

    PurchaseTomatoFence1(Agent : agent):void=
        if(PlayerBalance >= TomatoFence1Price):
            if(TomatoFence1Purchase = false):
                if(Tomato4Purchase = true):
                    TomatoFence1Props.ShowProps()
                    TomatoFence1Cube.HideProps()
                    TomatoFence1Text.Hide()
                    set PlayerBalance -= TomatoFence1Price
                    set TomatoFence1Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${TomatoFence1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    TomatoFence2Cube.ShowProps()
                    TomatoFence2Text.Show()
        if(PlayerBalance < TomatoFence1Price):
            if(TomatoFence1Purchase = false):
                if(Tomato4Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # TOMATO FENCE 2

    PurchaseTomatoFence2(Agent : agent):void=
        if(PlayerBalance >= TomatoFence2Price):
            if(TomatoFence2Purchase = false):
                if(TomatoFence1Purchase = true):
                    TomatoFence2Props.ShowProps()
                    TomatoFence2Cube.HideProps()
                    TomatoFence2Text.Hide()
                    set PlayerBalance -= TomatoFence2Price
                    set TomatoFence2Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${TomatoFence2Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    TomatoFence3Cube.ShowProps()
                    TomatoFence3Text.Show()
        if(PlayerBalance < TomatoFence2Price):
            if(TomatoFence2Purchase = false):
                if(TomatoFence1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # TOMATO FENCE 3

    PurchaseTomatoFence3(Agent : agent):void=
        if(PlayerBalance >= TomatoFence3Price):
            if(TomatoFence3Purchase = false):
                if(TomatoFence2Purchase = true):
                    TomatoFence3Props.ShowProps()
                    TomatoFence3Cube.HideProps()
                    TomatoFence3Text.Hide()
                    set PlayerBalance -= TomatoFence3Price
                    set TomatoFence3Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${TomatoFence3Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    TomatoFence4Cube.ShowProps()
                    TomatoFence4Text.Show()
        if(PlayerBalance < TomatoFence3Price):
            if(TomatoFence3Purchase = false):
                if(TomatoFence2Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # TOMATO FENCE 4

    PurchaseTomatoFence4(Agent : agent):void=
        if(PlayerBalance >= TomatoFence4Price):
            if(TomatoFence4Purchase = false):
                if(TomatoFence3Purchase = true):
                    TomatoFence4Props.ShowProps()
                    TomatoFence4Cube.HideProps()
                    TomatoFence4Text.Hide()
                    set PlayerBalance -= TomatoFence4Price
                    set TomatoFence4Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${TomatoFence4Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    if(RebirthLevel = 1):
                        set RebirthReady = true
                        RebirthReadyText.ShowText()
                        RebirthNotReadyText.HideText()
                    if(RebirthLevel >= 2):
                        Pond1Cube.ShowProps()
                        Pond1Text.Show()
        if(PlayerBalance < TomatoFence4Price):
            if(TomatoFence4Purchase = false):
                if(TomatoFence3Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # SHED 1

    PurchaseShed1(Agent : agent):void=
        if(PlayerBalance >= Shed1Price):
            if(Shed1Purchase = false):
                if(CabbageFence4Purchase = true):
                    Shed1Props.ShowProps()
                    Shed1Cube.HideProps()
                    Shed1Text.Hide()
                    set PlayerBalance -= Shed1Price
                    set Shed1Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Shed1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Corn1Cube.ShowProps()
                    Corn1Text.Show()
        if(PlayerBalance < Shed1Price):
            if(Shed1Purchase = false):
                if(CabbageFence4Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # CORN 1

    PurchaseCorn1(Agent : agent):void=
        if(PlayerBalance >= Corn1Price):
            if(Corn1Purchase = false):
                if(Shed1Purchase = true):
                    Corn1Props1.ShowProps()
                    Corn1Props2.ShowProps()
                    Corn1Cube.HideProps()
                    Corn1Text.Hide()
                    set PlayerBalance -= Corn1Price
                    set Corn1Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Corn1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Haybales3Cube.ShowProps()
                    Haybales3Text.Show()
                    Windmill1Cube.ShowProps()
                    Windmill1Text.Show()
        if(PlayerBalance < Corn1Price):
            if(Corn1Purchase = false):
                if(Shed1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # HAYBALES 3

    PurchaseHaybales3(Agent : agent):void=
        if(PlayerBalance >= Haybales3Price):
            if(Haybales3Purchase = false):
                if(Corn1Purchase = true):
                    Haybales3Props.ShowProps()
                    Haybales3Cube.HideProps()
                    Haybales3Text.Hide()
                    set PlayerBalance -= Haybales3Price
                    set Haybales3Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Haybales3Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Wagon1Cube.ShowProps()
                    Wagon1Text.Show()
        if(PlayerBalance < Haybales3Price):
            if(Haybales3Purchase = false):
                if(Corn1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # WAGON 1

    PurchaseWagon1(Agent : agent):void=
        if(PlayerBalance >= Wagon1Price):
            if(Wagon1Purchase = false):
                if(Haybales3Purchase = true):
                    Wagon1Props.ShowProps()
                    Wagon1Cube.HideProps()
                    Wagon1Text.Hide()
                    set PlayerBalance -= Wagon1Price
                    set Wagon1Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Wagon1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Haybales5Cube.ShowProps()
                    Haybales5Text.Show()
                    Stable1Cube.ShowProps()
                    Stable1Text.Show()
        if(PlayerBalance < Wagon1Price):
            if(Wagon1Purchase = false):
                if(Haybales3Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # HAYBALES 5

    PurchaseHaybales5(Agent : agent):void=
        if(PlayerBalance >= Haybales5Price):
            if(Haybales5Purchase = false):
                if(Wagon1Purchase = true):
                    Haybales5Props.ShowProps()
                    Haybales5Cube.HideProps()
                    Haybales5Text.Hide()
                    set PlayerBalance -= Haybales5Price
                    set Haybales5Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Haybales5Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
        if(PlayerBalance < Haybales5Price):
            if(Haybales5Purchase = false):
                if(Wagon1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # STABLE 1

    PurchaseStable1(Agent : agent):void=
        if(PlayerBalance >= Stable1Price):
            if(Stable1Purchase = false):
                if(Wagon1Purchase = true):
                    Stable1Props.ShowProps()
                    Stable1Cube.HideProps()
                    Stable1Text.Hide()
                    set PlayerBalance -= Stable1Price
                    set Stable1Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Stable1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Stable2Cube.ShowProps()
                    Stable2Text.Show()
        if(PlayerBalance < Stable1Price):
            if(Stable1Purchase = false):
                if(Wagon1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # STABLE 2

    PurchaseStable2(Agent : agent):void=
        if(PlayerBalance >= Stable2Price):
            if(Stable2Purchase = false):
                if(Stable1Purchase = true):
                    Stable2Props.ShowProps()
                    Stable2Cube.HideProps()
                    Stable2Text.Hide()
                    set PlayerBalance -= Stable2Price
                    set Stable2Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Stable2Price}"))
                    LostMoneyHUD.Show(Agent)
                    if(RebirthLevel = 0):
                        set RebirthReady = true
                        RebirthReadyText.ShowText()
                        RebirthNotReadyText.HideText()
                    # NEXT FUNCTION
        if(PlayerBalance < Stable2Price):
            if(Stable2Purchase = false):
                if(Stable1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # WINDMILL 1

    PurchaseWindmill1(Agent : agent):void=
        if(PlayerBalance >= Windmill1Price):
            if(Windmill1Purchase = false):
                if(Corn1Purchase = true):
                    Windmill1Props.ShowProps()
                    Windmill1Cube.HideProps()
                    Windmill1Text.Hide()
                    set PlayerBalance -= Windmill1Price
                    set Windmill1Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Windmill1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
        if(PlayerBalance < Windmill1Price):
            if(Windmill1Purchase = false):
                if(Corn1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # POND 1

    PurchasePond1(Agent : agent):void=
        if(PlayerBalance >= Pond1Price):
            if(Pond1Purchase = false):
                if(TomatoFence4Purchase = true):
                    Pond1Props.ShowProps()
                    Pond1Cube.HideProps()
                    Pond1Text.Hide()
                    set PlayerBalance -= Pond1Price
                    set Pond1Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Pond1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Dock1Cube.ShowProps()
                    Dock1Text.Show()
        if(PlayerBalance < Pond1Price):
            if(Pond1Purchase = false):
                if(TomatoFence4Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # DOCK 1

    PurchaseDock1(Agent : agent):void=
        if(PlayerBalance >= Dock1Price):
            if(Dock1Purchase = false):
                if(Pond1Purchase = true):
                    Dock1Props.ShowProps()
                    Dock1Cube.HideProps()
                    Dock1Text.Hide()
                    set PlayerBalance -= Dock1Price
                    set Dock1Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Dock1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Fishing1Cube.ShowProps()
                    Fishing1Text.Show()
        if(PlayerBalance < Dock1Price):
            if(Dock1Purchase = false):
                if(Pond1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # FISHING 1

    PurchaseFishing1(Agent : agent):void=
        if(PlayerBalance >= Fishing1Price):
            if(Fishing1Purchase = false):
                if(Dock1Purchase = true):
                    Fishing1Props.ShowProps()
                    FishingHelp1Text.Show()
                    FishingHelp2Text.Show()
                    Fishing1Waterzone.Enable()
                    Fishing1FishingZone1.Enable()
                    Fishing1FishingZone2.Enable()
                    Fishing1Cube.HideProps()
                    Fishing1Text.Hide()
                    set PlayerBalance -= Fishing1Price
                    set Fishing1Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Fishing1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    if(RebirthLevel = 2):
                        set RebirthReady = true
                        RebirthReadyText.ShowText()
                        RebirthNotReadyText.HideText()
                    if(RebirthLevel >= 3):
                        BoarPen1Cube.ShowProps()
                        BoarPen1Text.Show()
        if(PlayerBalance < Fishing1Price):
            if(Fishing1Purchase = false):
                if(Dock1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # BOAR PEN 1

    PurchaseBoarPen1(Agent : agent):void=
        if(PlayerBalance >= BoarPen1Price):
            if(BoarPen1Purchase = false):
                if(Fishing1Purchase = true):
                    BoarPen1Props.ShowProps()
                    BoarPen1Cube.HideProps()
                    BoarPen1Text.Hide()
                    set PlayerBalance -= BoarPen1Price
                    set BoarPen1Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${BoarPen1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    BoarFence1Cube.ShowProps()
                    BoarFence1Text.Show()
        if(PlayerBalance < BoarPen1Price):
            if(BoarPen1Purchase = false):
                if(Fishing1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # BOAR FENCE 1

    PurchaseBoarFence1(Agent : agent):void=
        if(PlayerBalance >= BoarFence1Price):
            if(BoarFence1Purchase = false):
                if(BoarPen1Purchase = true):
                    BoarFence1Props.ShowProps()
                    BoarFence1Cube.HideProps()
                    BoarFence1Text.Hide()
                    set PlayerBalance -= BoarFence1Price
                    set BoarFence1Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${BoarFence1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    BoarFence2Cube.ShowProps()
                    BoarFence2Text.Show()
        if(PlayerBalance < BoarFence1Price):
            if(BoarFence1Purchase = false):
                if(BoarPen1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # BOAR FENCE 2

    PurchaseBoarFence2(Agent : agent):void=
        if(PlayerBalance >= BoarFence2Price):
            if(BoarFence2Purchase = false):
                if(BoarFence1Purchase = true):
                    BoarFence2Props.ShowProps()
                    BoarFence2Cube.HideProps()
                    BoarFence2Text.Hide()
                    set PlayerBalance -= BoarFence2Price
                    set BoarFence2Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${BoarFence2Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    BoarFence3Cube.ShowProps()
                    BoarFence3Text.Show()
        if(PlayerBalance < BoarFence2Price):
            if(BoarFence2Purchase = false):
                if(BoarFence1Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # BOAR FENCE 3

    PurchaseBoarFence3(Agent : agent):void=
        if(PlayerBalance >= BoarFence3Price):
            if(BoarFence3Purchase = false):
                if(BoarFence2Purchase = true):
                    BoarFence3Props.ShowProps()
                    BoarFence3Cube.HideProps()
                    BoarFence3Text.Hide()
                    set PlayerBalance -= BoarFence3Price
                    set BoarFence3Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${BoarFence3Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    Haybales4Cube.ShowProps()
                    Haybales4Text.Show()
        if(PlayerBalance < BoarFence3Price):
            if(BoarFence3Purchase = false):
                if(BoarFence2Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # HAYBALES 4

    PurchaseHaybales4(Agent : agent):void=
        if(PlayerBalance >= Haybales4Price):
            if(Haybales4Purchase = false):
                if(BoarFence3Purchase = true):
                    Haybales4Props.ShowProps()
                    Haybales4Cube.HideProps()
                    Haybales4Text.Hide()
                    set PlayerBalance -= Haybales4Price
                    set Haybales4Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${Haybales4Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
                    BoarVegetation1Cube.ShowProps()
                    BoarVegetation1Text.Show()
        if(PlayerBalance < Haybales4Price):
            if(Haybales4Purchase = false):
                if(BoarFence3Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()

    # BOAR VEGETATION 1

    PurchaseBoarVegetation1(Agent : agent):void=
        if(PlayerBalance >= BoarVegetation1Price):
            if(BoarVegetation1Purchase = false):
                if(Haybales4Purchase = true):
                    BoarVegetation1Props.ShowProps()
                    Boars.Enable()
                    Boars.Spawn()
                    BoarVegetation1Cube.HideProps()
                    BoarVegetation1Text.Hide()
                    set PlayerBalance -= BoarVegetation1Price
                    set BoarVegetation1Purchase = true
                    set MoneyPerSecond += BuildingMoneyPerSec
                    set TycoonCompletionDecimal += 25
                    set TycoonCompletionWhole += 1
                    PurchasedHUD.Show(Agent)
                    PurchasedRadio.Play()
                    LostMoneyHUD.SetText(PlayerBalanceString("- ${BoarVegetation1Price}"))
                    LostMoneyHUD.Show(Agent)
                    # NEXT FUNCTION
        if(PlayerBalance < BoarVegetation1Price):
            if(BoarVegetation1Purchase = false):
                if(Haybales4Purchase = true):
                    NotEnoughMoneyHUD.Show(Agent)
                    NotEnoughRadio.Play()