extends PlayerState

var going_up := false

var y_vel := 0.0

func enter(_msg := {}) -> void:
	going_up = false
	y_vel = 180
	player.sprite.rotation_degrees = -45 * player.direction
	player.p_meter = player.p_max

func physics_update(delta: float) -> void:
	player.current_animation = "Run"
	if player.is_on_wall():
		going_up = true
		player.velocity.y = -y_vel
		player.sprite.rotation_degrees = -90 * player.direction
	elif going_up:
		wall_run_stop()
	
	if player.get_floor_normal().x == 0 and player.is_on_floor() and not going_up:
		wall_run_stop()
	
	if not going_up:
		if player.is_on_floor() == false:
			state_machine.transition_to("Normal")

	if going_up:
		if Input.is_action_just_pressed(CoopManager.get_player_input_str("jump", player.player_id)):
			jump_off()
			return
		if Input.is_action_just_pressed(CoopManager.get_player_input_str("spin_jump", player.player_id)):
			spin_jump_off()
			return
		player.velocity.x = abs(player.velocity.y) * player.direction
		player.sprite.position.x = -12 * player.direction
		player.velocity.y = move_toward(player.velocity.y, -180, 5.265)
	if player.is_on_ceiling():
		state_machine.transition_to("Normal")
		player.velocity = Vector2.ZERO

func jump_off() -> void:
	player.p_meter = player.p_max
	player.sprinting = true
	player.velocity.y = -300
	player.gravity = player.jump_gravity
	player.velocity.x = 200 * -player.direction
	player.jumped = true
	player.play_sfx("big_jump")
	await get_tree().physics_frame
	state_machine.transition_to("Normal")
	return

func spin_jump_off() -> void:
	player.p_meter = player.p_max
	player.sprinting = true
	player.spin_jumping = true
	player.velocity.y = -300
	player.gravity = player.jump_gravity
	player.velocity.x = 200 * -player.direction
	player.jumped = true
	player.play_sfx("spin")
	await get_tree().physics_frame
	state_machine.transition_to("Normal")
	return


func wall_run_stop() -> void:
	player.velocity.y = -10
	state_machine.transition_to("Normal")
	await get_tree().physics_frame
	player.velocity.x = 180 * player.direction

func exit() -> void:
	player.sprite.rotation_degrees = -45 * player.direction
	await get_tree().create_timer(0.05, false).timeout
	player.sprite.rotation = 0
	player.sprite.position.x = 0
