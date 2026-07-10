# Player Profile Data
# This code defines a persistable data structure for storing player statistics and progress including score, eliminations, coins, playtime, and level. It includes a constructor for creating copies of pl
# Difficulty: beginner  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/player-profile-data-1?ref=github

player_profile_data<public> := class<final><persistable>:
    Version<public>:int = 0
    Score<public>:int = 0
    Elims<public>:int = 0
    Coins<public>:int = 0
    HighScore<public>:int = 0
    AllTimeScore<public>:int=0
    Playtime<public> : int = 0
    Level<public> : int = 1

MakePlayerProfileData<public><constructor>(Src:player_profile_data)<transacts> := player_profile_data:
    Version<public> := Src.Version
    Score<public> := Src.Score
    Elims<public> := Src.Elims
    Coins<public> := Src.Coins
    HighScore<public> := Src.HighScore
    AllTimeScore<public> := Src.AllTimeScore
    Playtime<public> := Src.Playtime
    Level<public> := Src.Level