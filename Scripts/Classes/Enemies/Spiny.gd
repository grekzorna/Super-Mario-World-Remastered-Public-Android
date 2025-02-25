extends Enemy

var can_hit := true

func _physics_process(delta: float) -> void:
	sprite.scale.x = -direction
	velocity.x = 30 * direction
	velocity.y += 10
	if is_on_wall() && can_hit:
		flip_direction()
	else:
		move_and_slide()

func flip_direction() -> void:
	can_hit = false
	direction *= -1
	await get_tree().create_timer(0.1, false).timeout
	can_hit = true
