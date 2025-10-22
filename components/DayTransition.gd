# File: components/TransitionScene.gd (New Script)
extends CanvasLayer

@onready var day_label = $VBoxContainer/DayLabel
@onready var slimes_killed_label = $VBoxContainer/SlimeLabel
@onready var animation_player = $FadeInOut

func _ready():
	get_tree().paused = true
	# 1. Get stats from DataManager
	var new_day = DataManager.get_game_day()
	var old_day = new_day - 1
	var slimes_killed = DataManager.get_last_day_slimes_killed()

	# 2. Set label text
	day_label.text = "Day %d  →  Day %d" % [old_day, new_day]
	slimes_killed_label.text = "Slimes Killed: %d" % slimes_killed

	# 3. Play animation and wait for it to finish
	animation_player.play("FadeInOut")
	await animation_player.animation_finished
	
	get_tree().paused = false

	# 4. Tell SceneChanger to load the DayLevel
	SceneChanger.change_level("res://levels/DayLevel.tscn")

	# 5. Remove self
	queue_free()
