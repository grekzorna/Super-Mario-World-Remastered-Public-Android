extends PowerUp

func _physics_process(delta: float) -> void:
	velocity.y += 15
	move_and_slide()

