# Producer Purchase Effect
# Creates a custom effect class that handles producer buying commands in a game economy system. When triggered, it signals a buy producer command event and passes the command through for further process
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/buy-producer-effect?ref=github

using { Tableau }

buy_producer_effect<public> := class(effect):
    BuyProducerCommand<public>:event(command) = event(command){}

    Play<override>(Command:command):command=
        BuyProducerCommand.Signal(Command)

        return Command
