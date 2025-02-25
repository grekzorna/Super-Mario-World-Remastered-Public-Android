extends Enemy

func _physics_process(delta: float) -> void:
	global_position.x += (100 * direction) * delta
