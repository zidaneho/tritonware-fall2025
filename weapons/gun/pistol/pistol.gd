extends Gun

@export var muzzlePosition : Marker2D
@export var muzzleParticle : GPUParticles2D
const TracerScene = preload('res://weapons/gun/utils/tracer.tscn')


func shoot():
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
	var result = space_state.intersect_ray(query)
	
	var tracer_instance = TracerScene.instantiate()
	get_tree().root.add_child(tracer_instance)
	tracer_instance.setup(startPoint, endPoint, bullet_color,5)
