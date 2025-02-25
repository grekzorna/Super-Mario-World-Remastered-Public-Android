extends Enemy

const move_speed := 100

func _physics_process(delta: float) -> void:
	global_position.x += (move_speed * direction) * delta
