# Player Data System
# Defines a persistent player data structure that tracks game statistics including memes collected, rebirth count, owned finishers, and reset status. Includes a constructor for updating existing player 
# Difficulty: beginner  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/persistance?ref=github

player_data := class<final><persistable>{
    HaveReseted :logic=false
    Memes_Count :int=0
    Collected_Memes :[]string=array{}
    Rebirths_Count:int=0
    OwnedFinishers:[]int=array{}
}

player_data_update<constructor>(OldStat : player_data)<transacts> := player_data{
    OwnedFinishers := OldStat.OwnedFinishers
}