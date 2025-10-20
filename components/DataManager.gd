extends Node

const SAVE_PATH = "user://game.save"

# This dictionary holds the "runtime" data your game uses.
# We set defaults for a new game.
var game_data = {
	"unlocked_weapons": [], # This will hold loaded WeaponData resources
	"player_gold": 0,
	"current_level": 1,
	"music_volume": 0.8
}

# When the game first launches, load all data from the file.
func _ready():
	load_game()


# --- Public Functions (How other scripts talk to it) ---

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
