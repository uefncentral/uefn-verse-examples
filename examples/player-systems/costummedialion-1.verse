# Custom Player Data Class
# A simple class structure that wraps player data with team, class, and item properties. It provides getter and setter methods to manage these three integer values for a player agent.  **How to use:** C
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/costummedialion-1?ref=github

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