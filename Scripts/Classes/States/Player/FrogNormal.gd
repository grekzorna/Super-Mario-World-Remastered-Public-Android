extends PlayerState

const run_accel := 3
var can_jump := true

func physics_update(delta: float) -> void:
	player.sprite_speed_scale = 1
	if player.is_on_floor():
		player.current_animation = "Idle"
		player.velocity.x = lerpf(player.velocity.x, 0, delta * 20)
	else:
		if player.velocity.y < 0:
			player.current_animation = "Jump"
		else:
			player.current_animation = "Fall"
		player.velocity.x += (player.walk_speed * (run_accel * 3.5) * delta) * player.input_direction
		
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		if player.is_on_floor() and can_jump:
			can_jump = false
			player.velocity.y = -200
			await get_tree().create_timer(0.5, false).timeout
			can_jump = true
	if player.input_direction != 0:
		player.direction = player.input_direction
	player.sprite.scale.x = player.direction
	if Input.is_action_just_pressed("jump"):
		player.global_position.y -= 8
		state_machine.transition_to("Normal", {"Jump" = true})

	player.velocity.y += 15
	player.velocity.x = clamp(player.velocity.x, -player.walk_speed, player.walk_speed)
