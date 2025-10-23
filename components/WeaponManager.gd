extends Node2D

var unlocked_weapons : Array[WeaponData]


@export var starting_weapon : WeaponData
@export var right_hand_pivot : Node2D  # The node that will rotate
@export var right_hand_weapon : Node2D # The attachment point for the weapon scene
@export var right_hand : Node2D        # The sprite/node for the empty hand

var current_weapon_index : int = 0 # -1 will be used for "Unarmed"
var current_weapon : WeaponData
var current_weapon_instance : Node

var weapon_instances : Dictionary = {}

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

	instantiate_all_weapons()
			
	# 3. Equip the first weapon. This block will now run correctly on a new game.
	if start_unarmed:
		equip_weapon(-1)
	elif not unlocked_weapons.is_empty():
		equip_weapon(current_weapon_index)
	else:
		# --- Handle starting with no weapons ---
		if right_hand != null:
			right_hand.visible = true
		if right_hand_weapon != null:
			right_hand_weapon.visible = false


func instantiate_all_weapons() -> void:
	# Ensure the weapon holder is valid
	if right_hand_weapon == null:
		print("ERROR: 'right_hand_weapon' is not set. Cannot instantiate weapons.")
		return
		
	# Clear any old instances if this function were to be called again
	for instance in weapon_instances.values():
		if is_instance_valid(instance):
			instance.queue_free()
	weapon_instances.clear()
	
	# Loop through our weapon data and create an instance for each
	for i in range(unlocked_weapons.size()):
		var weapon_data : WeaponData = unlocked_weapons[i]
		
		if weapon_data.scene != null:
			var new_instance = weapon_data.scene.instantiate()
			weapon_instances[i] = new_instance
			right_hand_weapon.add_child(new_instance)
			new_instance.visible = false
			new_instance.process_mode = Node.PROCESS_MODE_DISABLED
		else:
			print("Warning: Weapon '%s' (index %d) has no scene." % [weapon_data.weapon_name, i])


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
			current_weapon_index = -1 
		else:
			current_weapon_index = next_slot
		
		equip_weapon(current_weapon_index)
	
# Call this from your button press or pickup logic
func add_and_instantiate_weapon(new_weapon_data: WeaponData):
	if new_weapon_data == null:
		print("ERROR: Tried to add a null weapon.")
		return

	# 1. Check if we already have it (using DataManager's list)
	var current_unlocked = DataManager.get_unlocked_weapons() #
	if current_unlocked.has(new_weapon_data):
		print("Weapon already unlocked: ", new_weapon_data.weapon_name) #
		return

	# 2. Add to DataManager (updates save file)
	DataManager.add_weapon(new_weapon_data) #

	# 3. Refresh our local list
	unlocked_weapons = DataManager.get_unlocked_weapons() #

	# 4. Find the index of the newly added weapon
	var new_weapon_index = unlocked_weapons.find(new_weapon_data)
	if new_weapon_index == -1:
		print("ERROR: Could not find newly added weapon in DataManager list!")
		return

	# 5. Instantiate and add to our pool
	if new_weapon_data.scene != null: #
		var new_instance = new_weapon_data.scene.instantiate() #
		weapon_instances[new_weapon_index] = new_instance #
		if right_hand_weapon: #
			right_hand_weapon.add_child(new_instance) #
			new_instance.visible = false #
			new_instance.process_mode = Node.PROCESS_MODE_DISABLED #
			print("Instantiated new weapon: ", new_weapon_data.weapon_name) #
		else:
			print("ERROR: 'right_hand_weapon' node is null. Cannot add instance.") #
	else:
		print("Warning: Weapon '%s' has no scene to instantiate." % new_weapon_data.weapon_name) #
func equip_weapon(index: int) -> void:
	# --- 1. Deactivate the OLD weapon ---
	if is_instance_valid(current_weapon_instance):
		current_weapon_instance.visible = false
		current_weapon_instance.process_mode = Node.PROCESS_MODE_DISABLED
		
	current_weapon_instance = null
	current_weapon = null

	# --- 2. Handle "Unarmed" case ---
	if index < 0 or index >= unlocked_weapons.size() or not weapon_instances.has(index):
		current_weapon_index = -1
		
		if right_hand_weapon:
			right_hand_weapon.visible = false
		if right_hand:
			right_hand.visible = true
			
		EventBus.player_weapon_changed.emit(null, -1, -1)
		print("Equipped: Unarmed")
		return

	# --- 3. Set and Activate the NEW weapon ---
	current_weapon_index = index
	current_weapon = unlocked_weapons[current_weapon_index]
	current_weapon_instance = weapon_instances[current_weapon_index]

	if not is_instance_valid(current_weapon_instance):
		print("ERROR: Tried to equip invalid weapon instance at index %d." % index)
		equip_weapon(-1) # Fallback to unarmed
		return
		
	print("Equipped: ", current_weapon.weapon_name)
	
	if right_hand == null or right_hand_weapon == null:
		print("ERROR: 'right_hand' or 'right_hand_weapon' is not set.")
		return

	# --- 4. Show the new weapon ---
	right_hand_weapon.visible = true
	right_hand.visible = false
	
	current_weapon_instance.visible = true
	current_weapon_instance.process_mode = Node.PROCESS_MODE_INHERIT
	
	# --- 5. Update UI ---
	var ammo = -1
	var maxAmmo = -1
	if current_weapon_instance is Gun:
		ammo = current_weapon_instance.current_ammo
		maxAmmo = current_weapon_instance.mag_size
	EventBus.player_weapon_changed.emit(current_weapon, ammo, maxAmmo)
