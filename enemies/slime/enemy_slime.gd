extends CharacterBody2D

@export var speed = 3
@export var jump_force = 24
@export var jump_cooldown = 3
@export var jump_delay_time = 0.3
@export var jump_air_delay_time = 0.5
@export var damage = 1

@onready var jump_delay_timer = $JumpDelayTimer
@onready var jump_cooldown_timer = $JumpCooldownTimer
@onready var jump_air_delay_timer = $JumpAirDelayTimer
@onready var detection_area = $DetectionArea

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
var health = 3
var sprite_dictionary = {
	"Idle": "Sprites/Idle",
	"Air": "Sprites/Air",
	"Jump": "Sprites/Jump",
	"Death": "Sprites/Death"
}
var current_sprite : Sprite2D
var jump_direction : float

func _ready() -> void:
	var players = get_tree().get_nodes_in_group("players")
	if players.size() > 0:
		player = players[0]
		
	# Connect the detection signal
	detection_area.connect("body_entered", Callable(self, "_on_body_entered"))

func _process(_delta: float) -> void:
	if is_dead:
		return
		
	if not is_dead and health <= 0:
		state = SlimeStates.DEATH
	
	if state == SlimeStates.IDLE:
		play_sprite("Idle")
		
		if jump_cooldown_timer.is_stopped():
			state = SlimeStates.JUMP
			jump_delay_timer.start(jump_delay_time)
			jump_cooldown_timer.start(jump_cooldown)
			
	elif state == SlimeStates.JUMP:
		play_sprite("Jump")
		if is_on_floor() and jump_delay_timer.is_stopped():
			velocity.y = -jump_force
			jump_direction = sign((player.global_position - global_position).x)
			state = SlimeStates.AIR
			jump_air_delay_timer.start(jump_air_delay_time)
			
	elif state == SlimeStates.AIR:
		play_sprite("Air")
		if is_on_floor() and jump_air_delay_timer.is_stopped():
			state = SlimeStates.IDLE

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	if player and state == SlimeStates.AIR:
		velocity.x = jump_direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, 50)
	move_and_slide()

# Called when the player enters the slime’s detection zone
func _on_body_entered(body):
	if body.is_in_group("players") and not is_dead:
		attack_player(body)

func attack_player(body):
	if not player:
		return
	# Apply damage to player (assuming player has a `take_damage(amount)` method)
	if body.has_method("take_damage"):
		body.take_damage(damage, global_position)

func play_sprite(key, flip_to_player = true):
	var sprite_path = sprite_dictionary.get(key)
	if sprite_path == null:
		return
	var sprite = get_node(sprite_path)
	if current_sprite == sprite:
		return
	if sprite:
		if current_sprite:
			current_sprite.visible = false
		sprite.visible = true
	current_sprite = sprite
	if flip_to_player and player:
		var direction = player.global_position - global_position
		current_sprite.flip_h = sign(direction.x) < 0
