extends Node2D

var unlocked_weapons : Array[WeaponData]

@export var starting_weapon : WeaponData
var current_weapon_index : int = 0
var current_weapon : WeaponData

func _ready() -> void:
	unlocked_weapons.clear()
	if starting_weapon:
		# Add the starting weapon to our "unlocked" list
		add_weapon_to_inventory(starting_weapon)
	else:
		print("Warning: Player has no starting_weapon assigned!")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("change_weapon"):
		# 4. We only cycle through the weapons we have unlocked
		if unlocked_weapons.size() < 2:
			return # Can't change weapon if we only have one (or zero)
		current_weapon_index = (current_weapon_index + 1) % unlocked_weapons.size()
		equip_weapon(current_weapon_index)
func equip_weapon(index: int) -> void:
	if index < 0 or index >= unlocked_weapons.size():
		return

	current_weapon_index = index
	current_weapon = unlocked_weapons[current_weapon_index]
	
	print("Equipped: ", current_weapon.resource_name) # Or whatever property it has
	EventBus.player_weapon_changed.emit(current_weapon)
func add_weapon_to_inventory(new_weapon: WeaponData) -> void:
	# Don't add it if the player already has it
	if not unlocked_weapons.has(new_weapon):
		unlocked_weapons.append(new_weapon)
		
		# Optional: automatically equip the new weapon
		equip_weapon(unlocked_weapons.size() - 1)
		
		print("Unlocked new weapon: ", new_weapon.resource_name)
