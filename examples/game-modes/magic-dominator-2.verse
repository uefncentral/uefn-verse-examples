# Empty Magic Dominator
# This is a basic template class for a magic dominator device that extends creative_device. Currently contains only an empty OnBegin function with no implemented functionality.  **How to use:** Add this
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/magic-dominator-2?ref=github

using {/Fortnite.com/Devices}
using {/Verse.org/Simulation}
using {/UnrealEngine.com/Temporary/Diagnostics}

magic_dominator := class(creative_device):

    OnBegin<override>()<suspends>:void = {}
