extends Enemy

func _physics_process(delta: float) -> void:
	if is_on_wall():
		direction = get_wall_normal().x
		velocity.x = 50 * direction
	elif is_on_floor():
		SoundManager.play_sfx(SoundManager.bump, self)
		if get_floor_normal().x != 0:
			if get_floor_normal().x > 0:
				direction = 1
			else:
				direction = -1
		velocity.y = -100
		velocity.x = 50 * direction
	velocity.y += 10
	$Sprite/Animation.speed_scale = direction
	move_and_slide()
