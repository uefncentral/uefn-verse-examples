# Button Hello World UI
# Creates a simple interactive button that displays a "Hello, world!" text message to players when pressed. The text appears as a UI widget that is only visible to the player who interacted with the but
# Difficulty: intermediate  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/nn6n-ui-show-ui?ref=github

using { /Fortnite.com/Devices }
 using { /Verse.org/Simulation }
 using { /UnrealEngine.com/Temporary/UI }
 using { /Fortnite.com/UI }
 using { /UnrealEngine.com/Temporary/SpatialMath}

 hello_world_device := class(creative_device):

     # Set the Button device in the Editor to reference the device in the level
     @editable
     MyButton : button_device = button_device{}

     # A localizable message to display as text in the UI
     TextForMyUI<localizes> : message = "Hello, world!"

     # Runs when the device is started in a running game
     OnBegin<override>()<suspends> : void =
         MyButton.InteractedWithEvent.Subscribe(HandleButtonInteraction)

     # A custom UI can only be associated with a specific player, and only that player can see it
     HandleButtonInteraction(Agent : agent) : void =
         # Agents can be a player or AI, but you can only get the UI of a player
         # so you must cast the Agent, who interacted with the Button device, to the player type
         if (InPlayer := player[Agent], PlayerUI := GetPlayerUI[InPlayer]):
             MyUI : text_block = text_block{DefaultText := TextForMyUI}
             PlayerUI.AddWidget(MyUI)