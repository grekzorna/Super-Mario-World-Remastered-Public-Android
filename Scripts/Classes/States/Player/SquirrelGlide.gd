extends PlayerState

var flying := true

func enter(_msg := {}) -> void:
	flying = true

func update(_delta: float) -> void:
	player.sprite_speed_scale = 1
	if flying:
		if player.input_direction != player.velocity_direction and player.input_direction != 0:
			player.current_animation = "GlideTurn"
		else:
			player.current_animation = "Glide"
	else:
		if player.velocity.y > 0:
			player.current_animation = "GlideFloat"

func physics_update(delta: float) -> void:
	if flying:
		player.velocity.y += 15
	else:
		player.velocity.y += 5
	player.sprite.scale.x = player.velocity_direction
	if player.input_direction != 0:
		player.velocity.x += ((player.walk_speed * player.walk_accel) * player.input_direction) * delta
	elif not flying:
		player.velocity.x = lerpf(player.velocity.x, 0, delta * 4)
	if flying:
		player.velocity.x = clamp(player.velocity.x, -player.run_speed, player.run_speed)
		player.velocity.y = clamp(player.velocity.y, -9999, player.max_fall_speed / 8)
	else:
		player.velocity.x = clamp(player.velocity.x, -player.walk_speed, player.walk_speed)
		player.velocity.y = clamp(player.velocity.y, -9999, player.max_fall_speed / 4)
	if Input.is_action_pressed("jump") == false and flying:
		state_machine.transition_to("Normal")
	if Input.is_action_just_pressed("spin_jump"):
		player.velocity.y = -200
		player.current_animation = "GlideBoost"
		flying = false
	if player.is_on_floor():
		state_machine.transition_to("Normal")
