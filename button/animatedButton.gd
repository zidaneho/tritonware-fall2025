extends AnimatedSprite2D

signal clicked

	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fire"):
		if getCurrentFrameRect().has_point(to_local(event.global_position)):
			emit_signal("clicked")

func getCurrentFrameRect() -> Rect2:
	var size = self.frames.get_frame(self.animation, self.frame).get_size()
	var pos = offset
	if centered:
		pos -= 0.5 * size
	return Rect2(pos, size)
