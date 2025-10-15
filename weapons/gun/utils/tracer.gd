extends Line2D

var travel_duration = 0.075

# This function will be called by the tween every frame
# It takes the interpolated position and updates the line's second point
func _update_end_point(new_position: Vector2):
	if get_point_count() > 1:
		set_point_position(1, new_position)

# This function will be called from your weapon to set up the tracer.
func setup(start_position, end_position, color, line_width):
	width = line_width
	default_color = color
	var tween = create_tween()
	clear_points()
	# Set the start and end points of the line
	add_point(start_position)
	add_point(end_position)
	
	tween.tween_method(_update_end_point,start_position,end_position,travel_duration)
	tween.finished.connect(queue_free)
