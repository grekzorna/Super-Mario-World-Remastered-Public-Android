extends Enemy

@export_enum("Horizontal", "Vertical") var starting_axis := 0

const move_speed := 50
var can_hit := true

func _physics_process(delta: float) -> void:
	if starting_axis == 0:
		if is_on_wall() and can_hit:
			can_hit = false
			await get_tree().create_timer(1, false).timeout
			can_hit = true
			direction *= -1
		velocity = Vector2.RIGHT * move_speed * direction
	elif starting_axis == 1:
		if (is_on_floor() or is_on_ceiling()) and can_hit:
			can_hit = false
			await get_tree().create_timer(1, false).timeout
			can_hit = true
			direction *= -1
		velocity = Vector2.UP * move_speed * direction
	move_and_slide()
