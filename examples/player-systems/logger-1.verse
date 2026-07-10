# Project Logger Utility
# Creates a global logging system for UEFN Verse projects that can be used from any function, including transactional functions. Provides two overloaded functions to log messages with optional log level
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/logger-1?ref=github

using { /UnrealEngine.com/Temporary/Diagnostics }

my_log_channel<public> := class(log_channel):

# A project-wide "Logger" to print messages from functions that are not in a class with a log.
# The non-Logger Print is <no_rollback>, so it can't be used in a <transacts> function.
ProjectLog<public>(Message:[]char)<transacts>:void=
    Logger := log{Channel := my_log_channel}
    Logger.Print(Message, ?Level := log_level.Normal)

ProjectLog<public>(Message:[]char, Level:log_level)<transacts>:void=
    Logger := log{Channel := my_log_channel}
    Logger.Print(Message, ?Level := Level)

# # Usage:
# ProjectLog("EndGame: Player has won!", ?Level := log_level.Verbose)

# # You don't have to specify the Level
# ProjectLog("Hello Verse!")