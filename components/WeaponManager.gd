extends Node2D

var unlocked_weapons : Array[WeaponData]

@export var starting_weapon : WeaponData
@export var right_hand : Node2D # The attachment point for the weapon scene
var current_weapon_index : int = 0
var current_weapon : WeaponData
var current_weapon_instance : Node # The currently equipped weapon scene

func _ready() -> void:
	# 1. Get the persistent list from our global singleton
	unlocked_weapons = DataManager.get_unlocked_weapons()
	
	# 2. Handle the "new game" case
	if unlocked_weapons.is_empty():
		if starting_weapon != null:
			print("No weapons found in DataManager. Adding starting weapon.")
			DataManager.add_weapon(starting_weapon)
			
			# --- FIX 1: Re-fetch the list ---
			# After adding the starting weapon, we must update our local
			# 'unlocked_weapons' variable so it's no longer empty.
			unlocked_weapons = DataManager.get_unlocked_weapons()
		else:
			print("ERROR: Player has no weapons and no 'starting_weapon' is set!")
			return

	# 3. Equip the first weapon. This block will now run correctly on a new game.
	if not unlocked_weapons.is_empty():
		equip_weapon(current_weapon_index)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("change_weapon"):
		if unlocked_weapons.size() < 2:
			return # Can't cycle
		
		current_weapon_index = (current_weapon_index + 1) % unlocked_weapons.size()
		equip_weapon(current_weapon_index)

func equip_weapon(index: int) -> void:
	if index < 0 or index >= unlocked_weapons.size():
		return

	# --- Clean up the old weapon scene ---
	# (It's safer to do this *before* equipping the new one)
	if current_weapon_instance != null:
		current_weapon_instance.queue_free()
		current_weapon_instance = null # Clear the reference

	# --- Set the new weapon data ---
	current_weapon_index = index
	current_weapon = unlocked_weapons[current_weapon_index]
	
	print("Equipped: ", current_weapon.resource_name)
	
	# --- FIX 3: Add safety checks before instantiating ---
	if right_hand != null:
		# Check if the weapon resource has a scene to spawn
		if current_weapon.scene != null:
			current_weapon_instance = current_weapon.scene.instantiate()
			right_hand.add_child(current_weapon_instance)
		else:
			print("Warning: Weapon '%s' has no scene to instantiate." % current_weapon.resource_name)
	else:
		print("Warning: 'right_hand' node is not set in WeaponManager.")
	
	# Send the new weapon data to the UI or other systems
	EventBus.player_weapon_changed.emit(current_weapon)
