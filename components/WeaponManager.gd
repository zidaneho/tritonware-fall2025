extends Node2D

var unlocked_weapons : Array[WeaponData]

@export var starting_weapon : WeaponData
@export var right_hand_pivot : Node2D  # The node that will rotate
@export var right_hand_weapon : Node2D # The attachment point for the weapon scene
@export var right_hand : Node2D        # The sprite/node for the empty hand
var current_weapon_index : int = 0 # -1 will be used for "Unarmed"
var current_weapon : WeaponData
var current_weapon_instance : Node

@export var start_unarmed := false

@export var test_weapons : Array[WeaponData]

func _ready() -> void:
	# 1. Get the persistent list from our global singleton
	unlocked_weapons = DataManager.get_unlocked_weapons()
	
	# 2. Handle the "new game" case
	
	if unlocked_weapons.is_empty():
		if starting_weapon != null:
			print("No weapons found in DataManager. Adding starting weapon.")
			DataManager.add_weapon(starting_weapon)
			# Re-fetch the list
			unlocked_weapons = DataManager.get_unlocked_weapons()
		else:
			print("ERROR: Player has no weapons and no 'starting_weapon' is set!")
			return
	
	for weapon in test_weapons:
		if not unlocked_weapons.has(weapon):
			unlocked_weapons.append(weapon)
	# 3. Equip the first weapon. This block will now run correctly on a new game.
	if start_unarmed:
		equip_weapon(-1)
	elif not unlocked_weapons.is_empty():
		equip_weapon(current_weapon_index)
	else:
		# --- NEW: Handle starting with no weapons ---
		# This will correctly show the empty hand on game start
		if right_hand != null:
			right_hand.visible = true
		if right_hand_weapon != null:
			right_hand_weapon.visible = false


func _process(_delta: float) -> void:
	if Input.is_action_pressed("fire") and current_weapon_instance:
		if current_weapon_instance.has_method("shoot"):
			current_weapon_instance.shoot()
	
	if right_hand_pivot:
		right_hand_pivot.look_at(get_global_mouse_position())
	
	
	
	


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("change_weapon"):
		if unlocked_weapons.is_empty():
			return
		var num_slots = unlocked_weapons.size() + 1
		var current_slot = current_weapon_index
		if current_slot == -1:
			current_slot = unlocked_weapons.size()
		var next_slot = (current_slot + 1) % num_slots
		if next_slot == unlocked_weapons.size():
			# This is the "unarmed" slot
			current_weapon_index = -1 
		else:
			# This is a weapon slot
			current_weapon_index = next_slot
		
		equip_weapon(current_weapon_index)
	

func equip_weapon(index: int) -> void:
		# --- Clean up the old weapon scene ---
	if current_weapon_instance != null:
		current_weapon_instance.queue_free()
		current_weapon_instance = null # Clear the reference
		
	if index < 0 or index >= unlocked_weapons.size():
		current_weapon_index = -1
		current_weapon = null
		
		if right_hand_weapon:
			right_hand_weapon.visible = false
		if right_hand:
			right_hand.visible = true
			
		EventBus.player_weapon_changed.emit(null) # Send null to the UI
		print("Equipped: Unarmed")
		return



	# --- Set the new weapon data ---
	current_weapon_index = index
	current_weapon = unlocked_weapons[current_weapon_index]
	
	print("Equipped: ", current_weapon.weapon_name)
	
	# --- NEW HIDING/SHOWING LOGIC ---
	if right_hand == null or right_hand_weapon == null:
		print("ERROR: 'right_hand' or 'right_hand_weapon' is not set in Inspector.")
		return

	# Check if the weapon resource has a valid scene to show
	if current_weapon.scene != null:
		# --- We have a weapon to show ---
		right_hand_weapon.visible = true
		right_hand.visible = false # Hide the empty hand

		current_weapon_instance = current_weapon.scene.instantiate()
		right_hand_weapon.add_child(current_weapon_instance)

	else:
		# --- No weapon scene (e.g., "Unarmed" or error) ---
		right_hand_weapon.visible = false # Hide the weapon holder
		right_hand.visible = true       # Show the empty hand
		
		print("Warning: Weapon '%s' has no scene to instantiate." % current_weapon.resource_name)
	
	# Send the new weapon data to the UI or other systems
	EventBus.player_weapon_changed.emit(current_weapon)
