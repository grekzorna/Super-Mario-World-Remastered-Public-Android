extends Enemy

func _physics_process(delta: float) -> void:
	velocity.y += 15
	if is_on_floor():
		$Sprite.play("Stand")
	else:
		$Sprite.play("Jump")
	move_and_slide()

func damage() -> void:
	die()

func _on_timer_timeout() -> void:
	if not is_on_floor():
		return
	var target_player = CoopManager.get_closest_player(global_position)
	if target_player.global_position.y < global_position.y:
		velocity.y = -350
	else:
		velocity.y = -200
