extends Gun

@onready var reload_timer = $ReloadTimer
@onready var fire_rate_timer = $FireRateTimer

@export var muzzlePosition : Marker2D
@export var muzzleParticle : GPUParticles2D
const TracerScene = preload('res://weapons/gun/utils/tracer.tscn')

var can_fire : bool = true

func _ready() -> void:
	reload_timer.timeout.connect(_on_reload_timer_timeout)
	fire_rate_timer.timeout.connect(_on_fire_rate_timer_timeout)
	reload_timer.autostart = false
	reload_timer.one_shot = true
	fire_rate_timer.autostart = false
	fire_rate_timer.one_shot= true

func reload():
	if not reload_timer.is_stopped():
		return
	reload_timer.start(reload_time)

func shoot():
	if current_ammo <= 0:
		reload()
		return
	if fire_rate_timer.is_stopped() and not can_fire:
		fire_rate_timer.start(1 / fire_rate)
		return
	elif not can_fire:
		return
	
	can_fire = false
	current_ammo -= 1
	if muzzleParticle:
		if muzzleParticle.emitting:
			muzzleParticle.restart()
		else:
			muzzleParticle.emitting = true
			muzzleParticle.restart()
		
	var startPoint = muzzlePosition.global_position
	var endPoint = startPoint + (get_global_mouse_position() - muzzlePosition.global_position).normalized() * self.range
	var space_state = get_world_2d().direct_space_state
	# use global coordinates, not local to node
	
	var query = PhysicsRayQueryParameters2D.create(startPoint,endPoint)
	var enemy_layer_number = 3
	query.collision_mask = 1 << (enemy_layer_number - 1)
	var result = space_state.intersect_ray(query)
	if result and result.collider.has_method("take_damage"):
		result.collider.take_damage(damage,global_position)
	
	var tracer_instance = TracerScene.instantiate()
	get_tree().root.add_child(tracer_instance)
	tracer_instance.setup(startPoint, endPoint, bullet_color,5)
	
	EventBus.player_ammo_changed.emit(current_ammo,mag_size)


func _on_reload_timer_timeout() -> void:
	current_ammo = mag_size
	EventBus.player_reloaded.emit(current_ammo,mag_size)


func _on_fire_rate_timer_timeout() -> void:
	can_fire = true
