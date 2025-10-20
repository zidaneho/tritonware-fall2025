# EventBus.gd
# This script is just a dictionary for all global signals.
# It doesn't need to be attached to any scene.

extends Node

# Define a signal for when the player is damaged.
# You can pass any data you need, like the current health, max health, or damage amount.
signal player_took_damage(current_health, max_health)
