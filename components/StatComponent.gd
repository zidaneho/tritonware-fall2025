extends Node

class_name StatComponent

@export var team_id : int = 0
@export var health : int
@export var max_health : int

func take_damage(damage):
	health -= damage
