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
	var tracer_instance = TracerScene.instantiate()
	get_tree().root.add_child(tracer_instance)
	tracer_instance.setup(muzzlePosition.global_position, Vector2(50,50), bullet_color,5)
