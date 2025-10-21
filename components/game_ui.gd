extends CanvasLayer

@onready var health_progress = $Container/PlayerInfoContainer/VBoxContainer/HealthContainer/ProgressBar
@onready var slime_progress = $Container/GameInfoContainer/VBoxContainer/ProgressBar
@onready var time_label = $Container/GameInfoContainer/VBoxContainer/TimeLabel

@onready var curr_weapon_label = $Container/PlayerInfoContainer/VBoxContainer/WeaponContainer/Label
@onready var curr_weapon_icon = $Container/PlayerInfoContainer/VBoxContainer/WeaponContainer/ItemContainer/TextureRect

func _ready() -> void:
	EventBus.player_took_damage.connect(update_health_bar)
	EventBus.player_weapon_changed.connect(on_player_weapon_change)
func _on_apoc_meter_manager_apoc_progress_updated(new_progress: int, max_progress: int) -> void:
	slime_progress.value = new_progress
	slime_progress.max_value = max_progress


func _on_time_changed(hours: int, minutes: int, is_am: bool) -> void:
	var am_str = "AM" if is_am else "PM"
	
	# Use string formatting to pad the minutes with a leading zero
	# %d = digit
	# %02d = digit, padded with a 0 to be 2 characters wide
	# %s = string
	var time_string = "%d:%02d %s" % [hours, minutes, am_str]
	
	time_label.text = time_string
	
func update_health_bar(current_health, max_health):
	health_progress.value = current_health
	health_progress.max_value = max_health

func on_player_weapon_change(new_weapon):
	if new_weapon == null:
		return
	curr_weapon_icon.texture = new_weapon.icon
	curr_weapon_label.text = new_weapon.weapon_name
	print("Successfully set " + new_weapon.weapon_name + "in ui")
	
