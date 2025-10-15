extends Node

class_name Weapon
#We will damage the target. Assume Player ID is 1, otherwise it is damageable.
func do_damage(target : StatComponent):
	if target.team_id != 1:
		return
	target.take_damage()
