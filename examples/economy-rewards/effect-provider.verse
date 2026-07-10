# Effect System Registry
# This code creates a registry system for managing different types of game effects (AddResources, BuyProducer, Produce). It allows registering and retrieving effect handlers for a resource management or
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/effect-provider?ref=github

effect_type<public> := enum:
    AddResources
    BuyProducer
    Produce

effect_provider<public> := class():
    var Effects:[effect_type]effect = map{}

    Register<public>(EffectType:effect_type, Effect:effect):void=
        if (set Effects[EffectType] = Effect) {}

    Get<public>(Type:effect_type)<decides><transacts>:effect = Effects[Type]
