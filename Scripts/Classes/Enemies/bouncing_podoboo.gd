extends Enemy

var direction_vector := Vector2(-1, -1)

func _physics_process(delta: float) -> void:
	if is_on_floor() or is_on_ceiling():
		direction_vector.y *= -1
	if is_on_wall():
		direction_vector.x *= -1
	velocity = 50 * direction_vector
	sprite.rotation = direction_vector.angle() + deg_to_rad(90)
	move_and_slide()
