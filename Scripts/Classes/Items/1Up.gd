extends PowerUp

func hitbox_hit(area: Area2D) -> void:
	if area.get_parent() is Player and can_grab:
		GameManager.add_life(1, global_position)
		area.get_parent().play_sfx("1_up")
		queue_free()

const move_speed := 50

var can_hit := true


func _physics_process(_delta: float) -> void:
	if is_on_floor():
		velocity.x = move_speed * direction
	velocity.y += 15
	if is_on_wall():
		if can_hit:
			can_hit = false
			direction *= -1
			await get_tree().create_timer(0.1, false).timeout
			can_hit = true
	move_and_slide()
