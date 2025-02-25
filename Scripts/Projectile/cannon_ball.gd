extends Enemy

var direction_vector := Vector2.UP

var move_speed := 100

func spawn() -> void:
	SoundManager.play_sfx(SoundManager.bullet, self)
	ParticleManager.summon_particle(preload("res://Instances/Particles/Misc/Puff.tscn"), global_position  + (direction_vector * 8))
	await get_tree().create_timer(5, false).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	global_position += (move_speed * direction_vector) * delta

func damage() -> void:
	die()
