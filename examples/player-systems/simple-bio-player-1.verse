# Simple Bio Player System
# Creates a simplified player class for managing basic character states and animations. The code defines animation states (idle, run, attack) and a streamlined bio_player class to handle player movement
# Difficulty: beginner  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/simple-bio-player-1?ref=github

using { /Verse.org/Simulation }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/FortPlayerUtilities }
using { /Fortnite.com/Devices }

simple_anim_state:=enum{
    idle,
    run,
    attack
}

# 由于发现动画状态机尾大不掉，再加上以前有一些在修改过程当中形成的冗余
# 所以建立一个简单的bioPlayer类
simple_bio_player := class<unique>():
    LinkedPlayer:player
    IsMoving:logic=false

    ZombiePreStuff: zombie_pre_stuff