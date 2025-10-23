extends Node

const SAVE_PATH = "user://game.save"

# This dictionary holds the "runtime" data your game uses.
# We set defaults for a new game.
const saved_npc_states_default = {
	"blacksmith":{"heart_level":0,"is_alive":true},
	"chef":{"heart_level":0,"is_alive":true},
	"nerd":{"heart_level":0,"is_alive":true},
	"trash":{"heart_level":0,"is_alive":true},
	"alcoholic":{"heart_level":0,"is_alive":true},
}
var _last_day_slimes_killed = 0
var game_data = {
	"unlocked_weapons": [] as Array[WeaponData], # This will hold loaded WeaponData resources
	"saved_npc_states" : saved_npc_states_default.duplicate(true),
	"player_gold": 0,
	"current_level": 1,
	"music_volume": 0.8,
	"gametime_day" :1,
	"gametime_hours":8,
	"gametime_minutes":0,
	"gametime_is_am" : true,
	"slime_apoc_progress":0,
	"button_pressed":false,
	"all_npcs_dead" : false
}



# When the game first launches, load all data from the file.
func _ready():
	load_game()

# --- Public Functions (How other scripts talk to it) ---

func is_npc_alive(npc_id : String):
	if game_data.saved_npc_states.has(npc_id):
		return game_data.saved_npc_states[npc_id]['is_alive']
	return false
func kill_random_npc():
	# 1. Create a list of all NPCs who are currently alive
	var alive_npcs = []
	for npc_id in game_data.saved_npc_states:
		if game_data.saved_npc_states[npc_id]["is_alive"]:
			alive_npcs.append(npc_id)
			
	# 2. Check if the list has anyone in it
	if not alive_npcs.is_empty():
		# 3. Pick one at random
		var random_npc_id = alive_npcs.pick_random()
		
		# 4. Set their 'is_alive' status to false
		game_data.saved_npc_states[random_npc_id]["is_alive"] = false
		
		print("DataManager: Killed random NPC: ", random_npc_id)
		if alive_npcs.size() <= 1:
			game_data.all_npcs_dead = true
			print("DataManager: No alive NPCs left to kill.")
		# 5. Save this change
		save_game()
	else:
		print("DataManager: No alive NPCs left to kill.")
		game_data.all_npcs_dead = true
		save_game()
	

# Call this from your shop or pickups
func add_weapon(new_weapon: WeaponData):
	if not game_data.unlocked_weapons.has(new_weapon):
		game_data.unlocked_weapons.append(new_weapon)
		save_game() # Auto-save when a change is made
		print("Data Manager: Added weapon ", new_weapon.resource_name)

func get_unlocked_weapons() -> Array[WeaponData]:
	return game_data.unlocked_weapons

# Call this from your shop or when picking up coins
func set_gold(amount: int):
	game_data.player_gold = amount
	# We can choose to save, or maybe only save at checkpoints
	# save_game() 
	print("Data Manager: Gold set to ", amount)

func get_gold() -> int:
	return game_data.player_gold

# Call this from your settings menu
func set_music_volume(volume: float):
	game_data.music_volume = volume
	save_game() # Good to save settings immediately
	print("Data Manager: Volume set to ", volume)

func get_music_volume() -> float:
	return game_data.music_volume

func get_heart_level(npc_id : String) -> int:
	if game_data.saved_npc_states.has(npc_id):
		return game_data.saved_npc_states[npc_id].heart_level
	push_warning("Tried to get state for unknown NPC: %s" % [npc_id])
	return 0
func set_heart_level(npc_id : String, level : int):
	if game_data.saved_npc_states.has(npc_id):
		game_data.saved_npc_states[npc_id].heart_level = level
	else:
		push_warning("Tried to set state for unknown NPC: %s" % [npc_id])
func set_time(day: int, hours: int, mins: int, is_am : bool):
	#assuming the time is actually correct
	game_data.gametime_day = day
	game_data.gametime_hours = hours
	game_data.gametime_minutes = mins
	game_data.gametime_is_am = is_am
func get_game_hours():
	return game_data.gametime_hours
func get_game_minutes():
	return game_data.gametime_minutes
func get_game_is_am():
	return game_data.gametime_is_am
func get_game_day():
	return game_data.gametime_day
func set_slime_apoc_progress(progress : int):
	game_data.slime_apoc_progress = progress
func get_slime_apoc_progress():
	return game_data.slime_apoc_progress
func set_last_day_stats(slimes_killed: int):
	_last_day_slimes_killed = slimes_killed
func get_all_npcs_dead():
	return game_data.all_npcs_dead
func get_last_day_slimes_killed() -> int:
	return _last_day_slimes_killed

func get_button_pressed():
	return game_data.button_pressed
func set_button_pressed(pressed: bool):
	game_data.button_pressed = pressed

# --- Save/Load Logic (The core of the manager) ---
func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		print("Error: Could not save game file.")
		return

	# --- Prepare data for saving ---
	# We must convert resource objects (like WeaponData) 
	# into a simple format (like their file path string)
	
	# 1. Duplicate the main dictionary
	var save_dict = game_data.duplicate()
	
	# 2. Convert the 'unlocked_weapons' array
	var weapon_paths: Array[String] = []
	for weapon in game_data.unlocked_weapons:
		if weapon != null and not weapon.resource_path.is_empty():
			weapon_paths.append(weapon.resource_path)
	
	# 3. Overwrite the array in our save_dict with the new string array
	save_dict["unlocked_weapons"] = weapon_paths
	
	
	# 4. Store the *prepared* dictionary
	file.store_var(save_dict)
	
	file.close()
	print("Game saved successfully.")


func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found. Starting new game with defaults.")
		return # File doesn't exist, so we'll just use the default 'game_data'

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		print("Error: Could not open save file for loading.")
		return

	# Load the dictionary from the file
	var save_dict = file.get_var(true)
	file.close()
	
	# --- Repopulate the runtime 'game_data' ---
	
	# 1. Load simple values. Use .get() to avoid errors if a key is missing.
	game_data.player_gold = save_dict.get("player_gold", 0)
	game_data.current_level = save_dict.get("current_level", 1)
	game_data.music_volume = save_dict.get("music_volume", 0.8)
	game_data.saved_npc_states = save_dict.get("saved_npc_states",saved_npc_states_default.duplicate(true))
	
	
	game_data.gametime_day = save_dict.get("gametime_day",1)
	game_data.gametime_hours = save_dict.get("gametime_hours",8)
	game_data.gametime_minutes = save_dict.get("gametime_minutes",0)
	game_data.gametime_is_am = save_dict.get("gametime_is_am",true)
	game_data.slime_apoc_progress = save_dict.get("slime_apoc_progress",0)
	game_data.button_pressed = save_dict.get("button_pressed",false)
	game_data.all_npcs_dead = save_dict.get("all_npcs_dead",false)
	# 2. Convert saved weapon paths back into loaded WeaponData resources
	game_data.unlocked_weapons.clear()
	var weapon_paths = save_dict.get("unlocked_weapons", [])
	for path in weapon_paths:
		var weapon_resource = load(path)
		if weapon_resource is WeaponData:
			game_data.unlocked_weapons.append(weapon_resource)
		else:
			print("Error loading weapon from path: ", path)
	
	print("Game loaded successfully.")

func start_new_game():
	game_data = {
		"unlocked_weapons": [] as Array[WeaponData], # This will hold loaded WeaponData resources
		"saved_npc_states" : saved_npc_states_default.duplicate(true),
		"player_gold": 0,
		"current_level": 1,
		"music_volume": game_data.music_volume,
		"gametime_day" :1,
		"gametime_hours":8,
		"gametime_minutes":0,
		"gametime_is_am" : true,
		"slime_apoc_progress":0,
		"button_pressed":false,
		"all_npcs_dead":false,
	}
	save_game()
	print("Data Manager: Started new game, save file reset to defaults.")
