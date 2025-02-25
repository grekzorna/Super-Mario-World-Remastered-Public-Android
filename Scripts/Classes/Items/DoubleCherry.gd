extends PowerUp


func _physics_process(_delta: float) -> void:
	velocity.y += 15
	move_and_slide()

func hitbox_hit(area: Area2D) -> void:
	if area.get_parent() is Player:
		if can_grab == false:
			return
		area.get_parent().double_cherry()
		queue_free()
