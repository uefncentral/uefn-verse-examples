# Stat Type System
# Defines an abstract stat system with concrete implementations for example and money statistics. Each stat type has a unique ID for identification and transactional operations.  **How to use:** Add thi
# Difficulty: beginner  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/madsmgrin-player-manipulation-scripts-persistence-stattypes?ref=github

# Define an abstract class for stat types
stat_type := class<computes><abstract>:
    Id() <transacts>:int

# Define a module to hold the specific stat types
StatType := module:

    example_stat<public> := class<computes>(stat_type):
        Id<override>()<transacts>:int = 1
    money_stat<public> := class<computes>(stat_type):
        Id<override>()<transacts>:int = 2

    Example<public>:example_stat = example_stat{}
    Money<public>:money_stat = money_stat{}