# Map Utility Functions
# This module extends Verse's built-in map functionality with utility methods for common operations like extracting keys/values, merging maps, filtering by keys, and deleting entries. It provides a more
# Difficulty: beginner  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/map-2?ref=github

Map<public> := module:
    # Make an Array of the Keys of a Map
    (Input:[k]v where v : type, k:subtype(comparable)).Keys<public>()<computes>:[]k = 
        for (Key -> Value : Input). Key

    # Make an Array of the Values of a Map
    (Input:[k]v where v : type, k:subtype(comparable)).Values<public>()<computes>:[]v = 
        for (Key -> Value : Input). Value

    # Make an Map with the merging of two Maps
    (Input:[k]v where v : type, k:subtype(comparable)).Merge<public>(MergeWith:[k]v)<computes>:[k]v = 
        ConcatenateMaps(Input, MergeWith)

    # Make an Map with all the key value pairs in `Keys`
    (Input:[k]v where v : type, k:subtype(comparable)).Take<public>(Keys:[]k)<transacts>:[k]v = 
        var NewMap:[k]v = map{}
        for (Key -> Value : Input, Keys.Find[Key] > -1):
            set NewMap = NewMap.Merge(map{Key => Value})
        return NewMap

    # Make a Map with a Key Value dropped
    (Input:[k]v where v : type, k:subtype(comparable)).Delete<public>(DeleteKey : k)<transacts>:[k]v = 
        var NewMap:[k]v = map{}
        for (Key -> Value : Input, Key <> DeleteKey):
            set NewMap = NewMap.Merge(map{Key => Value})
        return NewMap