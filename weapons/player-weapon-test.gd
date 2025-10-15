extends Node

@export var gun: Gun
@onready var fire_timer = $FireTimer

func _process(_delta: float) -> void:
	if Input.is_action_pressed("fire") and fire_timer.time_left < 0.01:
		gun.shoot()
		fire_timer.start(1 / gun.fire_rate)
