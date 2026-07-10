# Responsive Text Block
# Creates a UI text block that automatically updates its content whenever the underlying gooey_message changes. The system continuously listens for text updates and refreshes the display in real-time.  
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/responsive-text-block-1?ref=github

using { /Fortnite.com/UI }

responsive_text_block<public> := class():
    GooeyText<public>:gooey_message = gooey_message{}
    TextBlock<public>:text_block

    Initialize<public>()<suspends>:void=
        spawn. GooeyText.Init(Str2Msg(""))
        TextBlock.SetText(GooeyText.Get())
        loop:
            Msg := GooeyText.UpdatedEvent().Await()
            if (1 = 0). break
            TextBlock.SetText(Msg)
