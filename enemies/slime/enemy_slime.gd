extends CharacterBody2D

signal died(slime: CharacterBody2D)

@export var health = 5
@export var speed = 3
@export var jump_force = 24
@export var jump_cooldown = 3
@export var jump_delay_time = 0.3
@export var jump_air_delay_time = 0.5
@export var damage = 1

@export var recoil_strength = 150.0
@export var flash_color : Color = Color.RED
@export var flash_duration = 0.3

@onready var jump_delay_timer = $JumpDelayTimer
@onready var jump_cooldown_timer = $JumpCooldownTimer
@onready var jump_air_delay_timer = $JumpAirDelayTimer
@onready var detection_area = $DetectionArea
@onready var flash_timer = $FlashTimer
@onready var sprites = $Sprites # <--- ADD THIS
@onready var collision_shape = $CollisionShape2D # <--- ADD THIS
@onready var detection_shape = $DetectionArea/CollisionShape2D

enum SlimeStates {
	IDLE,
	JUMP,
	AIR,
	DEATH,
}

var state = SlimeStates.IDLE
var player : CharacterBody2D = null
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_dead = false
var sprite_dictionary = {
	"Idle": "Sprites/Idle",
	"Air": "Sprites/Air",
	"Jump": "Sprites/Jump",
	"Death": "Sprites/Death"
}
var current_sprite : Sprite2D
var jump_direction : float
var base_color : Color = Color.WHITE

func _ready() -> void:
	detection_area.connect("body_entered", Callable(self, "_on_body_entered"))
	
	flash_timer.one_shot = true
	flash_timer.wait_time = flash_duration
	flash_timer.timeout.connect(_on_flash_timer_timeout)

func _process(_delta: float) -> void:
	if is_dead:
		return
		
	if not is_dead and health <= 0:
		state = SlimeStates.DEATH
		is_dead = true
		EventBus.slime_killed.emit()
		get_tree().create_timer(0.3).timeout.connect(return_to_pool)
	
	match state:
		SlimeStates.IDLE:
			play_sprite("Idle")
			
			if jump_cooldown_timer.is_stopped():
				state = SlimeStates.JUMP
				jump_delay_timer.start(jump_delay_time)
				jump_cooldown_timer.start(jump_cooldown)
				
		SlimeStates.JUMP:
			play_sprite("Jump")
			if is_on_floor() and jump_delay_timer.is_stopped():
				velocity.y = -jump_force
				if player:
					jump_direction = sign((player.global_position - global_position).x)
				else:
					jump_direction = 1.0
				state = SlimeStates.AIR
				jump_air_delay_timer.start(jump_air_delay_time)
				
		SlimeStates.AIR:
			play_sprite("Air")
			if is_on_floor() and jump_air_delay_timer.is_stopped():
				state = SlimeStates.IDLE
		
		SlimeStates.DEATH:
			play_sprite("Death")
			velocity.x = move_toward(velocity.x, 0, 50)
			pass


func _physics_process(delta: float) -> void:
	if is_dead and is_on_floor():
		velocity.y = 0
		velocity.x = move_toward(velocity.x, 0, 50)
		move_and_slide()
		return

	if not is_on_floor():
		velocity.y += gravity * 0.5 * delta
		
	if player and state == SlimeStates.AIR:
		velocity.x = jump_direction * speed
	elif state != SlimeStates.DEATH:
		velocity.x = move_toward(velocity.x, 0, 50)
		
	move_and_slide()

func _on_body_entered(body):
	if body.is_in_group("players") and not is_dead:
		attack_player(body)

func attack_player(body):
	if not player:
		return
	if body.has_method("take_damage"):
		body.take_damage(damage, global_position)

func play_sprite(key, flip_to_player = true):
	var sprite_path = sprite_dictionary.get(key)
	if sprite_path == null:
		return
	var sprite = get_node(sprite_path)
	if current_sprite == sprite:
		if flip_to_player and player and state != SlimeStates.DEATH:
			var direction = player.global_position - global_position
			current_sprite.flip_h = sign(direction.x) < 0
		return
		
	if sprite:
		if current_sprite:
			current_sprite.visible = false
		sprite.visible = true
	current_sprite = sprite
	
	if flash_timer.is_stopped():
		current_sprite.modulate = base_color
	
	if flip_to_player and player and state != SlimeStates.DEATH:
		var direction = player.global_position - global_position
		current_sprite.flip_h = sign(direction.x) < 0

func take_damage(damage_amount, attacker_pos):
	if is_dead:
		return
		
	health -= damage_amount
	
	var recoil_direction = (global_position - attacker_pos).normalized()
	velocity = recoil_direction * recoil_strength
	velocity.y -= 100
	
	if current_sprite:
		current_sprite.modulate = flash_color
	flash_timer.start(flash_duration)

func _on_flash_timer_timeout():
	if current_sprite:
		current_sprite.modulate = base_color
func spawn_at(spawn_position: Vector2, new_player: CharacterBody2D):
	# Reset state
	global_position = spawn_position
	velocity = Vector2.ZERO
	health = 5 # Or whatever the starting health should be
	is_dead = false
	state = SlimeStates.IDLE
	player = new_player
	
	# Reset timers
	jump_cooldown_timer.start(jump_cooldown)
	
	# Enable node
	show()
	set_process(true)
	set_physics_process(true)
	collision_shape.disabled = false
	detection_shape.disabled = false
	
	# Set a default color
	set_color(Color.WHITE)
func set_color(color: Color):
	base_color = color
	sprites.modulate = base_color
func return_to_pool():
	# Disable and hide
	hide()
	set_process(false)
	set_physics_process(false)
	collision_shape.disabled = true
	detection_shape.disabled = true
	
	# Emit signal to spawner
	emit_signal("died", self)
