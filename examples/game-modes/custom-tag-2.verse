# Custom Gameplay Tag
# Creates a custom gameplay tag by deriving from the base tag class. This allows developers to define their own unique tags for identifying, categorizing, or filtering game objects and entities in their
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/custom-tag-2?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }

# Derive from the `tag` class in the Verse.org/Simulation/Tags module to create a new gameplay tag.
custom_tag := class(tag){}