# Team Manager Configuration
# Creates a paired system linking class/team selection with team-specific settings and inventory management. This allows for coordinated team setup where player class selection triggers corresponding te
# Difficulty: beginner  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/nn6n-game-sets-liyability-custom-playspace-team-manager-pair?ref=github

using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

team_manager_pair := class<concrete>:
    @editable
    ClassAndTeamSelector: class_and_team_selector_device = class_and_team_selector_device{}
    @editable
    TeamSettingsDevice: team_settings_and_inventory_device = team_settings_and_inventory_device{}
