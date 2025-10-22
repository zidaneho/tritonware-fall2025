# EventBus.gd
# This script is just a dictionary for all global signals.
# It doesn't need to be attached to any scene.

extends Node

# Define a signal for when the player is damaged.
# You can pass any data you need, like the current health, max health, or damage amount.
signal player_took_damage(current_health : int, max_health : int)

signal player_weapon_changed(new_weapon : WeaponData, ammo : int, maxAmmo : int)

signal player_ammo_changed(new_ammo : int, max_ammo : int)

signal player_reloaded(new_ammo : int, max_ammo : int)

signal slime_killed()
