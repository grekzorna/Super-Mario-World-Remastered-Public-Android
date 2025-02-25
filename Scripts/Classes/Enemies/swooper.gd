extends Enemy

var can_fly := true

func _physics_process(delta: float) -> void:
	velocity.y = lerpf(velocity.y, 0, delta)
	if can_fly == false:
		velocity.x = lerpf(velocity.x, 100 * direction, delta * 2)
	sprite.scale.x = -direction
	move_and_slide()

func fly() -> void:
	can_fly = false
	sprite.play("Fly")
	SoundManager.play_sfx(SoundManager.swooper, self)
	velocity.y = 150

func damage() -> void:
	die()

func _on_player_detect_area_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		if can_fly:
			if area.get_parent().global_position.x < global_position.x:
				direction = -1
			else:
				direction = 1
			fly()
