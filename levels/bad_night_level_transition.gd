extends Area2D



func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		SceneChanger.call_deferred("change_level","res://levels/BadNightLevel.tscn")
