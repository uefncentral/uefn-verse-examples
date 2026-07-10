# Random2
# Verse code for Random2 - UEFN/Fortnite Creative implementation
# Difficulty: advanced  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/random2?ref=github

using { /Verse.org/Random }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }


RNG_device2 := class(creative_device):

    var Players : []player = array{}
    @editable var PlayerSpawner2:player_spawner_device = player_spawner_device{}
    @editable var ItemGranter1:item_granter_device = item_granter_device{}
    @editable var ItemGranter2:item_granter_device = item_granter_device{}
    @editable var ItemGranter3:item_granter_device = item_granter_device{}
    @editable var ItemGranter4:item_granter_device = item_granter_device{}
    @editable var ItemGranter5:item_granter_device = item_granter_device{}
    @editable var ItemGranter6:item_granter_device = item_granter_device{}
    @editable var ItemGranter7:item_granter_device = item_granter_device{}
    @editable var ItemGranter8:item_granter_device = item_granter_device{}
    @editable var ItemGranter9:item_granter_device = item_granter_device{}
    @editable var ItemGranter10:item_granter_device = item_granter_device{}
    @editable var ItemGranter11:item_granter_device = item_granter_device{}
    @editable var ItemGranter12:item_granter_device = item_granter_device{}
    @editable var ItemGranter13:item_granter_device = item_granter_device{}
    @editable var ItemGranter14:item_granter_device = item_granter_device{}
    @editable var ItemGranter15:item_granter_device = item_granter_device{}
    @editable var ItemGranter16:item_granter_device = item_granter_device{}
    @editable var ItemGranter17:item_granter_device = item_granter_device{}
    @editable var ItemGranter18:item_granter_device = item_granter_device{}
    @editable var ItemGranter19:item_granter_device = item_granter_device{}
    @editable var ItemGranter20:item_granter_device = item_granter_device{}
    @editable var ItemGranter21:item_granter_device = item_granter_device{}
    @editable var ItemGranter22:item_granter_device = item_granter_device{}
    @editable var ItemGranter23:item_granter_device = item_granter_device{}
    @editable var ItemGranter24:item_granter_device = item_granter_device{}
    @editable var ItemGranter25:item_granter_device = item_granter_device{}
    @editable var ItemGranter26:item_granter_device = item_granter_device{}
    @editable var ItemGranter27:item_granter_device = item_granter_device{}
    @editable var ItemGranter28:item_granter_device = item_granter_device{}
    @editable var ItemGranter29:item_granter_device = item_granter_device{}
    @editable var ItemGranter30:item_granter_device = item_granter_device{}
    @editable var ItemGranter31:item_granter_device = item_granter_device{}
    @editable var ItemGranter32:item_granter_device = item_granter_device{}
    @editable var ItemGranter33:item_granter_device = item_granter_device{}
    @editable var ItemGranter34:item_granter_device = item_granter_device{}
    @editable var ItemGranter35:item_granter_device = item_granter_device{}
    @editable var ItemGranter36:item_granter_device = item_granter_device{}
    @editable var ItemGranter37:item_granter_device = item_granter_device{}
    @editable var ItemGranter38:item_granter_device = item_granter_device{}
    @editable var ItemGranter39:item_granter_device = item_granter_device{}
    @editable var ItemGranter40:item_granter_device = item_granter_device{}
    @editable var ItemGranter41:item_granter_device = item_granter_device{}
    @editable var ItemGranter42:item_granter_device = item_granter_device{}
    @editable var ItemGranter43:item_granter_device = item_granter_device{}
    @editable var ItemGranter44:item_granter_device = item_granter_device{}
    @editable var ItemGranter45:item_granter_device = item_granter_device{}
    @editable var ItemGranter46:item_granter_device = item_granter_device{}
    
    OnBegin<override>()<suspends>:void=
        PlayerSpawner2.SpawnedEvent.Subscribe(RNGLoadout)

        set Players = GetPlayspace().GetPlayers()


    RNGLoadout(Agent : agent):void=
        rngInt : int = GetRandomInt(1, 45)

        if (rngInt = 1):

            ItemGranter1.GrantItem(Agent)

        if (rngInt = 2):

            ItemGranter2.GrantItem(Agent)

        if (rngInt = 3):

            ItemGranter3.GrantItem(Agent)
            
        if (rngInt = 4):

            ItemGranter4.GrantItem(Agent)

        if (rngInt = 5):

            ItemGranter5.GrantItem(Agent)

        if (rngInt = 6):

            ItemGranter6.GrantItem(Agent)

        if (rngInt = 7):

            ItemGranter7.GrantItem(Agent)

        if (rngInt = 8):

            ItemGranter8.GrantItem(Agent)

        if (rngInt = 9):

            ItemGranter9.GrantItem(Agent)

        if (rngInt = 10):

            ItemGranter10.GrantItem(Agent)

        if (rngInt = 11):
                                                    
            ItemGranter11.GrantItem(Agent)

        if (rngInt = 12):

            ItemGranter12.GrantItem(Agent)

        if (rngInt = 13):
            
            ItemGranter13.GrantItem(Agent)

        if (rngInt = 14):

            ItemGranter14.GrantItem(Agent)

        if (rngInt = 15):

            ItemGranter15.GrantItem(Agent)

        if (rngInt = 16):

            ItemGranter16.GrantItem(Agent)

        if (rngInt = 17):

            ItemGranter17.GrantItem(Agent)

        if (rngInt = 18):
            
            ItemGranter18.GrantItem(Agent)

        if (rngInt = 19):

            ItemGranter19.GrantItem(Agent)

        if (rngInt = 20):

            ItemGranter20.GrantItem(Agent)

        if (rngInt = 21):

            ItemGranter21.GrantItem(Agent)

        if (rngInt = 22):

            ItemGranter22.GrantItem(Agent)

        if (rngInt = 23):

            ItemGranter23.GrantItem(Agent)

        if (rngInt = 24):

            ItemGranter24.GrantItem(Agent)

        if (rngInt = 25):

            ItemGranter25.GrantItem(Agent)

        if (rngInt = 26):

            ItemGranter26.GrantItem(Agent)

        if (rngInt = 27):

            ItemGranter27.GrantItem(Agent)

        if (rngInt = 28):

            ItemGranter28.GrantItem(Agent)

        if (rngInt = 29):

            ItemGranter29.GrantItem(Agent)

        if (rngInt = 30):

            ItemGranter30.GrantItem(Agent)

        if (rngInt = 31):

            ItemGranter31.GrantItem(Agent)

        if (rngInt = 32):

            ItemGranter32.GrantItem(Agent)

        if (rngInt = 33):

            ItemGranter33.GrantItem(Agent)

        if (rngInt = 34):

            ItemGranter34.GrantItem(Agent)

        if (rngInt = 35):

            ItemGranter35.GrantItem(Agent)
                                                            
        if (rngInt = 36):
            ItemGranter36.GrantItem(Agent)
            
        if (rngInt = 37):
            ItemGranter37.GrantItem(Agent)
            
        if (rngInt = 38):
            ItemGranter38.GrantItem(Agent)
            
        if (rngInt = 39):
            ItemGranter39.GrantItem(Agent)
            
        if (rngInt = 40):
            ItemGranter40.GrantItem(Agent)
            
        if (rngInt = 41):
            ItemGranter41.GrantItem(Agent)
            
        if (rngInt = 42):
            ItemGranter42.GrantItem(Agent)
            
        if (rngInt = 43):
            ItemGranter43.GrantItem(Agent)
            
        if (rngInt = 44):
            ItemGranter44.GrantItem(Agent)
            
        if (rngInt = 45):
            ItemGranter45.GrantItem(Agent)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               

            
        if (rngInt = 46):
            ItemGranter46.GrantItem(Agent)              