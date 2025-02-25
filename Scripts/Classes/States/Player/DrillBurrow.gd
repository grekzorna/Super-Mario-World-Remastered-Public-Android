extends PlayerState

var walk_accel := 1.5
var run_accel := 5

var ceiling_burrow := false

var can_exit := false

func enter(msg := {}) -> void:
	can_exit = false
	player.crouching = true
	ceiling_burrow = msg.has("Ceiling")
	if ceiling_burrow:
		player.velocity.y = 0
	player.sprite.hide()
	player.drill_debris.flip_v = ceiling_burrow
	player.drill_debris.show()
	SoundManager.play_sfx(SoundManager.shatter)
	await get_tree().create_timer(0.2, false).timeout
	can_exit = true

func physics_update(delta: float) -> void:
	if (Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")):
		player.velocity.x += (player.walk_speed * (run_accel * 3.5) * delta) * player.input_direction
	else:
		player.velocity.x = lerpf(player.velocity.x, 0, delta * 20)
	player.velocity.x = clamp(player.velocity.x, -player.run_speed, player.run_speed)
	
	player.velocity.y += 15 * (-1 if ceiling_burrow else 1)
	
	if ceiling_burrow:
		if player.is_on_ceiling() == false:
			if can_exit:
				state_machine.transition_to("Normal")
		
		if Input.is_action_just_pressed("move_down") or Input.is_action_just_pressed("jump"):
			state_machine.transition_to("Normal")
			player.velocity.y = 100
	else:
		if can_exit:
			if not player.is_on_floor():
				state_machine.transition_to("Normal")
			if Input.is_action_just_pressed("jump"):
				state_machine.transition_to("Normal", {"Jump" = true})
				player.velocity.y = -350
			elif Input.is_action_just_pressed("move_up"):
				state_machine.transition_to("Normal")
func exit() -> void:
	player.global_position.y += 1
	player.sprite.show()
	player.drill_debris.hide()
