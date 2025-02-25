extends PowerUp


var can_hit := true


func _physics_process(delta: float) -> void:
	velocity.y += 15
	if is_on_floor():
		velocity.x = lerpf(velocity.x, 0, delta * 10)
	move_and_slide()
