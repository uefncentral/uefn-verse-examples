# Resource Grant Effect
# A custom effect class that grants resources to players through a command-based system. It uses an event-driven architecture to signal when resources should be added via the AddResourcesCommand event. 
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/grant-resources-effect-1?ref=github

using { Tableau }

grant_resources_effect<public> := class(effect):
    AddResourcesCommand<public>:event(command) = event(command){}

    Play<override>(Command:command):command=
        AddResourcesCommand.Signal(Command)

        return Command
