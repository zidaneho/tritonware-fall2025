extends CharacterBody2D

var SPEED = 500
var GRAVITY_PERC = 1.5
var JUMP_VELOCITY = -500
var DOUBLE_JUMP_PERC = 0.8
var DOUBLE_JUMP_ALLOWED = true

# runs every frame, for physics
func _physics_process(delta):
	
	# jump (including double)
	var on_floor = is_on_floor()
	var jump = Input.is_action_just_pressed("jump");
	if not on_floor:
		if jump and DOUBLE_JUMP_ALLOWED:
			velocity.y = JUMP_VELOCITY * DOUBLE_JUMP_PERC
			DOUBLE_JUMP_ALLOWED = false
		else:
			velocity += get_gravity() * delta * GRAVITY_PERC
		
	if on_floor and jump:
		velocity.y = JUMP_VELOCITY
		DOUBLE_JUMP_ALLOWED = true
		
	# left/right
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 0.2)

	move_and_slide()
