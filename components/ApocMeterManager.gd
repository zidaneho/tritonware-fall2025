extends Node2D

@onready var ui = $"../GameUi"

@export var progress_per_day = 500

var progress : int # currently
var max_progress : int = 5000

signal apoc_progress_updated(new_progress : int, max_progress: int)

func _on_time_manager_day_over() -> void:
	progress += progress_per_day
	apoc_progress_updated.emit(progress,max_progress)
	
