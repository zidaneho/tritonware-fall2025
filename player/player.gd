extends CharacterBody2D

@onready var sprites = $Sprites
@onready var invincibility_timer = $InvincibilityTimer
@onready var animation_player = $AnimationPlayer
@onready var weapon_manager = $WeaponManager

var SPEED = 500
var GRAVITY_PERC = 1.5
var JUMP_VELOCITY = -500
var DOUBLE_JUMP_PERC = 0.8
var DOUBLE_JUMP_ALLOWED = true
var SPRITE_SCALE = 0.01
var health = 3
var MAX_HEALTH = 3

var is_invincible = false
var invincible_time = 1

var is_in_knockback := false
var knockback_decay := 2400.0        # higher = quicker decay
var max_knockback_speed := 1400.0

var npc_instances = {}
var in_dialogue : bool = false


func _ready() -> void:
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _process(_delta: float) -> void:
	if not in_dialogue and not npc_instances.is_empty() and Input.is_action_just_pressed("interact"):
		var closest_dist = INF
		var closest_npc = null
		for npc_instance in npc_instances.values():
			if npc_instance.global_position.distance_to(global_position) < closest_dist:
				closest_npc = npc_instance
		if closest_npc:
			closest_npc.interact(self)
		

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
	if is_in_knockback:
		velocity.x = move_toward(velocity.x, 0, knockback_decay * delta)
	else:
		var direction := Input.get_axis("move_left", "move_right")
		if direction:
			animation_player.play("Run")
			velocity.x = direction * SPEED
			sprites.scale.x = sign(direction) * SPRITE_SCALE
		else:
			animation_player.play("Idle")
			velocity.x = move_toward(velocity.x, 0, SPEED * 0.2)

	move_and_slide()

func take_damage(damage, attacker_position):
	if  is_invincible:
		return
	
	health -= damage
	EventBus.player_took_damage.emit(health,MAX_HEALTH)
	
	var recoilForce = 0
	if damage <= 1:
		recoilForce = 2000
	var recoilDir = (global_position - attacker_position)
	recoilDir = Vector2(recoilDir.x,0)
	recoilDir = recoilDir.normalized() * recoilForce
	velocity.x = clamp(velocity.x + recoilDir.x, -max_knockback_speed, max_knockback_speed)
	is_in_knockback = true
	
	get_tree().create_timer(0.18).timeout.connect(func(): is_in_knockback = false)
	
	is_invincible = true
	invincibility_timer.start(invincible_time)
	
	Engine.time_scale = 0
	await get_tree().create_timer(0.04,false,false,true).timeout
	Engine.time_scale = 1


func _on_invincibility_timer_timeout() -> void:
	is_invincible = false


func _on_interact_area_body_entered(body: Node2D) -> void:
	if body.has_method("interact"):
		npc_instances.set(body.name,body)
func _on_interact_area_body_exited(body: Node2D) -> void:
	if npc_instances.has(body.name):
		npc_instances.erase(body.name)
func _on_dialogue_started(_resource : DialogueResource):
	in_dialogue = true
func _on_dialogue_ended(_resource : DialogueResource):
	in_dialogue = false
