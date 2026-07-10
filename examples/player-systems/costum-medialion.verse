# Costum Medialion
# Verse code for Costum Medialion - UEFN/Fortnite Creative implementation
# Difficulty: beginner  |  UEFN: 32.00
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/costum-medialion?ref=github

using { /Verse.org/Simulation }

CustomPlayerr := class():
    MyAgentObj:agent

    var Team: int = 1
    var Class : int = 1
    var Item : int = 0

    SetTeam(T:int):void=
        set Team = T

    GetTeam():int=
        return Team

    SetClass(C:int):void=
        set Class = C

    GetClass():int=
        return Class

    SetItem(I:int):void=
        set Item = I

    GetItem():int=
        return Item