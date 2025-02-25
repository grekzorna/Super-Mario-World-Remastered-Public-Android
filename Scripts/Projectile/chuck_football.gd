extends Enemy

var bounce_index := 0

func _ready() -> void:
	velocity.y = -200
	velocity.x = 50 * direction
	await get_tree().create_timer(10, false).timeout
	ParticleManager.summon_particle(ParticleManager.PUFF_SPR, global_position)
	queue_free()

func _physics_process(delta: float) -> void:
	if is_on_wall():
		direction = get_wall_normal().x
		velocity.x = 75 * direction
	elif is_on_floor():
		if bounce_index == 0:
			velocity.y = -150
		else:
			velocity.y = -300
		$Sprite.flip_h = !$Sprite.flip_h
		bounce_index = wrap(bounce_index + 1, 0, 2)
		velocity.x = 75 * direction
	velocity.y += 10
	move_and_slide()

func damage() -> void:
	die()
