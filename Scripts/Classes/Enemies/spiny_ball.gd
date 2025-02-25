extends Enemy

var can_bounce := true
const SPINY = preload("res://Instances/Prefabs/Enemies/spiny.tscn")
func _physics_process(delta: float) -> void:
	velocity.y += 15
	velocity.y = clamp(velocity.y, -999, 200)
	if is_on_floor():
		if can_bounce:
			velocity.y = -150
			velocity.x /= 2
			can_bounce = false
		else:
			spawn_spiny()
	velocity.x = lerpf(velocity.x, 0, delta)
	$Sprite.rotation_degrees += (360 * direction ) * delta
	move_and_slide()

func spawn_spiny() -> void:
	var node = SPINY.instantiate()
	node.global_position = global_position
	GameManager.current_level.add_child(node)
	queue_free()
