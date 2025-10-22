extends Control

@onready var load_game_btn = $VBoxContainer/MarginContainer/VBoxContainer/LoadGameBtn
@onready var new_game_btn = $VBoxContainer/MarginContainer/VBoxContainer/NewGameBtn
@onready var quit_game_btn = $VBoxContainer/MarginContainer/VBoxContainer/QuitGameBtn

func _ready() -> void:
	new_game_btn.pressed.connect(_on_new_game_pressed)
	load_game_btn.pressed.connect(_on_load_game_pressed)
	quit_game_btn.pressed.connect(_on_quit_pressed)
	
func _on_new_game_pressed() -> void:
	# Tell DataManager to reset data and save a fresh file
	DataManager.start_new_game()
	# Change to the persistent game scene
	get_tree().change_scene_to_file("res://components/Main.tscn")


func _on_load_game_pressed() -> void:
	# DataManager already loaded the save file when the app launched.
	# We just need to switch to the game scene, which will
	# read that loaded data.
	get_tree().change_scene_to_file("res://components/Main.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
