extends Enemy

const move_speed := 75

func _physics_process(delta: float) -> void:
	if is_on_wall() or is_on_ceiling():
		direction *= -1
	velocity.x = move_speed * direction
	velocity.y += 15
	sprite.scale.x = direction
	move_and_slide()
