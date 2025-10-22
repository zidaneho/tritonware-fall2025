# File: enemies/spawners/SlimeSpawner.gd
extends Node2D

@export var slime_scene: PackedScene
@export var spawn_interval: float = 2.0
@export var spawn_width: float = 200.0 # How wide the horizontal spawn area is
@export var spawn_check_distance: float = 100.0 # How far down to check for ground

# --- Scaling Variables ---
@export var max_concurrent_slimes_base: int = 6
@export var total_slimes_base: int = 100
@export var scaling_concurrent_per_day: int = 2 # +2 concurrent slimes per day
@export var scaling_total_per_day: int = 50    # +50 total slimes per day

# --- Pool ---
var slime_pool: Array[CharacterBody2D] = []

# --- Internal Counters ---
var active_slime_count: int = 0
var slimes_spawned_this_night: int = 0
var max_concurrent_slimes: int = 0
var total_slimes_for_night: int = 0

var player: CharacterBody2D

@onready var spawn_timer = $SpawnTimer


func _ready() -> void:
	# 1. Get player reference
	await get_tree().process_frame
	var players = get_tree().get_nodes_in_group("players")
	if not players.is_empty():
		player = players[0]
	else:
		print("SPAWNER ERROR: Cannot find player! Slimes will not spawn.")
		return
		
	# 2. Calculate spawn limits based on day from DataManager
	var current_day = DataManager.get_game_day()
	max_concurrent_slimes = max_concurrent_slimes_base + (scaling_concurrent_per_day * (current_day - 1))
	total_slimes_for_night = total_slimes_base + (scaling_total_per_day * (current_day - 1))
	
	print("Slime Spawner (Day %d): Max Concurrent: %d, Total for Night: %d" % [current_day, max_concurrent_slimes, total_slimes_for_night])

	# 3. Pre-warm the pool (create slimes in advance so spawning is fast)
	pre_warm_pool(max_concurrent_slimes)

	# 4. Start spawn timer
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()


# Create slimes ahead of time and add them to the inactive pool
func pre_warm_pool(amount: int):
	if slime_scene == null:
		print("SPAWNER ERROR: Slime Scene is not set!")
		return
		
	for i in range(amount):
		var slime = _create_new_slime()
		slime_pool.append(slime)


# The master function for creating a single slime instance
func _create_new_slime() -> CharacterBody2D:
	var slime = slime_scene.instantiate() as CharacterBody2D
	add_child(slime)
	slime.died.connect(_on_slime_died) # Connect to the slime's "died" signal
	
	# Disable it until we need it
	slime.hide()
	slime.set_process(false)
	slime.set_physics_process(false)
	slime.get_node("CollisionShape2D").disabled = true
	slime.get_node("DetectionArea/CollisionShape2D").disabled = true
	
	return slime


# This is called by the spawn_timer
func _on_spawn_timer_timeout():
	# Check if we are allowed to spawn a new slime
	if not is_instance_valid(player): return
	if active_slime_count >= max_concurrent_slimes: return # Hit concurrent cap
	if slimes_spawned_this_night >= total_slimes_for_night: return # Hit nightly cap
	
	# --- Find a valid spawn point ---
	
	# 1. Get the 2D physics space
	var space_state = get_world_2d().direct_space_state
	
	# 2. Pick a random horizontal position
	var random_x = (randf() - 0.5) * 2.0 * spawn_width
	
	# 3. Define the start and end of our downward raycast
	var check_start = global_position + Vector2(random_x, -10) # 10px above spawner
	var check_end = check_start + Vector2.DOWN * spawn_check_distance
	
	# 4. Create and run the query. 
	#    We set collision_mask = 1 to ONLY hit layer 1 (default for StaticBody2D)
	var query = PhysicsRayQueryParameters2D.create(check_start, check_end)
	query.collision_mask = 1 # IMPORTANT: Assumes your ground is on layer 1
	var result = space_state.intersect_ray(query)
	
	# 5. Only spawn if we hit the ground
	if result:
		var spawn_pos = result.position # This is the exact point on the ground
		
		var slime: CharacterBody2D
		
		# Get a slime from the pool
		if slime_pool.is_empty():
			print("Slime pool empty! Creating a new one.")
			slime = _create_new_slime()
		else:
			slime = slime_pool.pop_front()
			
		# Generate a random color (HSV works best for bright colors)
		var random_color = Color.from_hsv(randf(), 0.8, 1.0)
		
		# --- Activate the slime ---
		# We assume the slime script has these functions
		slime.spawn_at(spawn_pos, player)
		slime.set_color(random_color)
		
		active_slime_count += 1
		slimes_spawned_this_night += 1
	# else:
		# Optional: print("Failed to find spawn point, skipping.")


# This is called by the slime's "died" signal
func _on_slime_died(slime: CharacterBody2D):
	active_slime_count -= 1
	slime_pool.append(slime) # Add the slime back to the pool
