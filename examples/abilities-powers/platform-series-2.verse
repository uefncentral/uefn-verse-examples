# Sequential Platform Controller
# Creates a timed sequence where platforms appear one by one, then disappear in the same order after a delay. Uses structured concurrency to run appearance and disappearance cycles simultaneously with c
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/platform-series-2?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Native }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

log_platform_series := class(log_channel){}

platform_series := class(creative_device):
    Logger : log = log{Channel := log_platform_series}

    @editable
    HeadStart : float = 2.45 # How long to wait, in seconds, after platforms start appearing before the platforms start disappearing.

    @editable
    AppearDelay : float = 0.98 # How long to wait, in seconds, before the next platform appears.

    @editable
    DisappearDelay : float = 1.11 # How long to wait, in seconds, before the next platform disappears.

    @editable
    Platforms : []color_changing_tiles_device = array{} # The platforms, in order, to make appear/disappear.

    OnBegin() : void =
        <#
        Verse's structured concurrency makes it very expressive to describe concurrent operations and how they should run.
        In this case, there are two coroutines:
        \- One starts immediately and makes the platforms visible in the same order they're stored in the array
        \- The other waits to start before making the same platforms invisible in the same order they're stored in the array
        #>

        loop:
            sync:
                ShowAllPlatforms() # This coroutine starts immediately and is executed the same time as the block expression.
                block: # The block expression starts immediately at the same time as ShowAllPlatforms(). All expressions in this code block are executed sequentially.
                    Sleep(HeadStart) # Waits for HeadStart seconds before HideAllPlatforms() is executed.
                    HideAllPlatforms() # After HeadStart seconds, this coroutine is executed.

    ShowAllPlatforms() : void =
        for (PlatformNumber -> Platform : Platforms):
            Logger.Print("Platform{PlatformNumber} is now shown.")
            Platform.Show()
            Sleep(AppearDelay)

    HideAllPlatforms() : void =
        for (PlatformNumber -> Platform : Platforms):
            Logger.Print("Platform{PlatformNumber} is now hidden.")
            Platform.Hide()
            Sleep(DisappearDelay)