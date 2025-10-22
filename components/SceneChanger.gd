extends Node

# This variable will hold a reference to the node in Main.tscn
var level_container: Node
var current_level: Node

func register_main_scene(main_node: Node) -> void:
	if not is_instance_valid(main_node):
		print("ERROR: Invalid node registered with SceneChanger")
		return
		
	# Get the nodes from the Main scene
	level_container = main_node.get_node("LevelContainer")
	var time_manager = main_node.get_node("GameWrapper/TimeManager")
	
	if not level_container or not time_manager:
		print("ERROR: SceneChanger can't find LevelContainer or TimeManager.")
		return
	
	# Connect to the day_over signal
	time_manager.day_over.connect(_on_night_ended)
	
	# --- Load the starting level ---
	# This logic is moved from the old _ready() function.
	change_level("res://levels/DayLevel.tscn")


# This function will swap the scenes (UNCHANGED)
func change_level(scene_path: String) -> void:
	# 1. Free the old level, if one exists
	if is_instance_valid(current_level):
		current_level.queue_free()
		
	# 2. Load and instance the new level
	var scene = load(scene_path)
	if scene:
		current_level = scene.instantiate()
		level_container.add_child(current_level)
	else:
		print("ERROR: Could not load scene: ", scene_path)

# This is the callback for the Night -> Day transition (UNCHANGED)
func _on_night_ended() -> void:
	# The TimeManager just told us the night is over.
	# Go back to the day level.
	var transition_scene = load("res://components/DayTransition.tscn").instantiate()
	get_tree().get_root().add_child(transition_scene)
	
