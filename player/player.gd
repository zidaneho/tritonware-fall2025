extends CharacterBody2D

var SPEED = 500
var JUMP_VELOCITY = -500

# runs every frame, for physics
func _physics_process(delta):
	
	# jump
	var on_floor = is_on_floor()
	if not on_floor:
		velocity += get_gravity() * delta
	if on_floor and Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		
	# left/right
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 0.2)

	move_and_slide()
