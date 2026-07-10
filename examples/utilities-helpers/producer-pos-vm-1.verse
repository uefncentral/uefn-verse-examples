# Producer Position View Model
# Defines a data structure class for representing producer items in a user interface. The class contains properties for ID, name, cost, and count values using gooey_message types for UI display.  **How 
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/producer-pos-vm-1?ref=github

using { Tableau }

producer_pos_vm<public> := class():
    ID<public>:int
    Name<public>:gooey_message = gooey_message{}
    Cost<public>:gooey_message = gooey_message{}
    Count<public>:gooey_message = gooey_message{}
