extends Node2D

@onready var ui = $"../GameUi"

@export var progress_per_day = 500

var progress : int # currently
var max_progress : int = 5000

var slimes_killed_today = 0

signal apoc_progress_updated(new_progress : int, max_progress: int)

func _ready() -> void:
	progress = DataManager.get_slime_apoc_progress()
	EventBus.slime_killed.connect(_on_slime_killed)
func poll_initial_progress():
	apoc_progress_updated.emit(progress, max_progress)
func _on_time_manager_day_over() -> void:
	DataManager.set_last_day_stats(slimes_killed_today)
	# Reset the counter for the new day
	slimes_killed_today = 0
	
	progress += progress_per_day
	apoc_progress_updated.emit(progress,max_progress)
	DataManager.set_slime_apoc_progress(progress)
	
func _on_slime_killed():
	slimes_killed_today += 1
	progress -= 1
	apoc_progress_updated.emit(progress,max_progress)
	DataManager.set_slime_apoc_progress(progress)
	
	
