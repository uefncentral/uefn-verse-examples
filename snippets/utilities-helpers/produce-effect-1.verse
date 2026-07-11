# Command Producer Effect
# Creates a custom effect class that produces and signals commands when played. The effect acts as a passthrough that triggers an event whenever a command is executed through it.  **How to use:** Add th
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/produce-effect-1?ref=github

using { Tableau }

produce_effect<public> := class(effect):
    ProduceCommand<public>:event(command) = event(command){}

    Play<override>(Command:command):command=
        ProduceCommand.Signal(Command)

        return Command
