extends PlayerState

func enter(_msg := {}) -> void:
	player.current_animation = "Flip"
	player.velocity.y = -player.jump_height * 1.1
	player.gravity = player.jump_gravity
	player.velocity.x = 0

func physics_update(delta: float) -> void:
	player.velocity.y += player.jump_gravity
	player.velocity.x += (player.walk_speed * (1 * 3.5) * delta) * player.input_direction
	player.velocity.x = clamp(player.velocity.x, -player.walk_speed, player.walk_speed)
	if Input.is_action_just_released("jump"):
		player.velocity.y /= 1.2
	if player.velocity.y > 0:
		state_machine.transition_to("Normal")
