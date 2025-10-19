extends CharacterBody2D

@export var speed = 3
@export var jump_force = 24
@export var jump_cooldown = 3
@export var jump_delay_time = 0.3
@export var jump_air_delay_time = 0.5

@export var attack_delay = 0.3
@export var attack_end_delay = 0.4
@export var attack_forward_force = 5
@export var attack_range = 10


@onready var jump_delay_timer = $JumpDelayTimer
@onready var jump_cooldown_timer = $JumpCooldownTimer
@onready var attack_delay_timer = $AttackDelayTimer
@onready var attack_end_timer = $AttackEndTimer
@onready var jump_air_delay_timer = $JumpAirDelayTimer
enum SlimeStates {
	IDLE,
	JUMP,
	AIR,
	ATTACK,
	ATTACK_END,
	DEATH,
}

var state = SlimeStates.IDLE
var player : CharacterBody2D = null
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_dead = false
var health = 3
var sprite_dictionary = {"Idle": "Sprites/Idle", "Air": "Sprites/Air", "Chomp1": "Sprites/Chomp1", "Chomp2": "Sprites/Chomp2", "Jump" : "Sprites/Jump", "Death" : "Sprites/Death" }
var current_sprite : Sprite2D
var jump_direction : float

func _ready() -> void:
	#assuming we tag the Player scene as in the group "players"
	var players = get_tree().get_nodes_in_group("players")
	if players.size() > 0:
		player = players[0]

func _process(_delta: float) -> void:
	if is_dead:
		return
		
	if not is_dead and health <= 0:
		state = SlimeStates.DEATH
	if state == SlimeStates.IDLE:
		play_sprite("Idle")
		
		if player_in_atk_range():
			state = SlimeStates.ATTACK
			attack_delay_timer.start(attack_delay)
		if jump_cooldown_timer.is_stopped():
			state = SlimeStates.JUMP
			jump_delay_timer.start(jump_delay_time)
			jump_cooldown_timer.start(jump_cooldown)
	elif state == SlimeStates.JUMP:
		play_sprite("Jump")
		if is_on_floor() and jump_delay_timer.is_stopped():
			velocity.y = - jump_force
			jump_direction = sign((player.global_position - global_position).x)
			state = SlimeStates.AIR
			jump_air_delay_timer.start(jump_air_delay_time)
	
			
	elif state == SlimeStates.ATTACK:
		play_sprite("Chomp1")
		if attack_delay_timer.is_stopped():
			state = SlimeStates.ATTACK_END
			attack_end_timer.start(attack_end_delay)
	elif state == SlimeStates.ATTACK_END:
		play_sprite("Chomp2")
		if player_in_atk_range():
			var direction = player.global_position - global_position
			velocity.x = sign(direction.x) * attack_forward_force
			#do damage to the player
		if attack_end_timer.is_stopped():
			state = SlimeStates.IDLE
	elif state == SlimeStates.AIR:
		play_sprite("Air",false)
		if is_on_floor() and jump_air_delay_timer.is_stopped():
			state = SlimeStates.IDLE
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	if player and state == SlimeStates.AIR:
		velocity.x = jump_direction * speed
	else:
		velocity.x = move_toward(velocity.x,0,50)
	move_and_slide()
func player_in_atk_range():
	if player == null:
		return false
	return global_position.distance_to(player.global_position) < attack_range
func play_sprite(key, flip_to_player=true):
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
		current_sprite.flip_h = sign(direction.x)
		print(current_sprite.flip_h)
