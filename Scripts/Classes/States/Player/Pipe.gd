extends PlayerState

var pipe_direction := "Up"

var pipe_mode = "Enter"

var current_pipe: Node = null

var pipe_position := Vector2.ZERO

var enter_speed := 0.0
const normal_speed := -60
const ground_pound_speed := -80

func enter(msg := {}) -> void:
	player.show()
	GameManager.can_pause = false
	if msg.has("Direction"):
		pipe_direction = msg.get("Direction")
	if msg.get("GroundPound"):
		enter_speed = ground_pound_speed
	else:
		enter_speed = normal_speed
	get_starting_position()
	player.add_to_game()
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	player.set_collision_layer_value(1 , false)
	player.sprite.show()
	player.release_held_object(false)
	player.carry_let_go()
	player.hitbox_area.set_deferred("monitoring", false)
	player.hitbox_area.set_deferred("monitorable", false)
	current_pipe = msg.get("Pipe")
	player.can_hurt = false
	current_pipe.pipe_used = true
	player.sprite.z_index = -5
	pipe_position = Vector2.ZERO
	if msg.has("Enter"):
		pipe_mode = "Enter"
	elif msg.has("Exit"):
		pipe_mode = "Exit"
		current_pipe.used.emit()
	get_starting_position()
	physics_update(0.0167)
	player.play_sfx("pipe")
	if pipe_mode == "Exit":
		await get_tree().create_timer(0.5).timeout
		player.z_index = 0
		if player.hitbox_area.get_overlapping_areas().any(is_water):
			state_machine.transition_to("Swim")
		else:
			state_machine.transition_to("Normal")

func get_starting_position() -> void:
	match pipe_direction:
			"Up":
				pipe_position -= (Vector2.UP * 24)
				if pipe_mode == "Exit":
					pipe_position.y -= 24
			"Down":
				if pipe_mode == "Exit":
					pipe_position += Vector2.DOWN * 32
			"Left":
				pipe_position.y += 14
				if pipe_mode == "Exit":
					pipe_position.x -= 16
				else:
					pipe_position.x += 8
			"Right":
				pipe_position.y += 14
				if pipe_mode == "Exit":
					pipe_position.x += 16
				else:
					pipe_position.x -= 8

func physics_update(delta: float) -> void:
	player.can_hurt = false
	player.z_index = -3
	if pipe_mode == "Enter":
		handle_pipe_enter(delta)
	elif pipe_mode == "Exit":
		handle_pipe_exit(delta)

func handle_pipe_enter(delta: float) -> void:
	player.velocity = Vector2.ZERO
	player.sprite_speed_scale = 1
	player.sprite.speed_scale = player.sprite_speed_scale
	if pipe_direction == "Up" or pipe_direction == "Down":
		if player.riding_yoshi:
			player.current_animation = "YoshiPipe"
			if SettingsManager.sprite_settings.yoshi == 0:
				player.yoshi_animations.play("PipeClassic")
			else:
				player.yoshi_animations.play("PipeModern")
		else:
			player.current_animation = "FaceForward"
	else:
		player.yoshi_animations.play("PipeSide")
		player.yoshi_animations.speed_scale = 1
		if player.riding_yoshi:
			player.current_animation = "YoshiCrouch"
		elif player.holding:
			player.current_animation = "HoldWalk"
		else:
			player.current_animation = "Walk"
	
	player.sprite.play(player.current_animation)
	player.direction = 1 if pipe_direction == "Right" else -1
	player.sprite.scale.x = player.direction
	
	match pipe_direction:
		"Up":
			pipe_position -= (Vector2.UP * enter_speed) * delta
		"Down":
			pipe_position -= (Vector2.DOWN * enter_speed)  * delta
		"Left":
			pipe_position -= (Vector2.LEFT * enter_speed) * delta
		"Right":
			pipe_position -= (Vector2.RIGHT * enter_speed) * delta
	player.global_position = current_pipe.global_position + pipe_position
	
func handle_pipe_exit(delta: float) -> void:
	player.velocity = Vector2.ZERO
	player.sprite.scale.x = player.direction

	player.sprite_speed_scale = 1
	player.sprite.speed_scale = player.sprite_speed_scale
	player.sprite.play(player.current_animation)
	if pipe_direction == "Up" or pipe_direction == "Down":
		if player.riding_yoshi:
			player.current_animation = "YoshiPipe"
			if SettingsManager.sprite_settings.yoshi == 0:
				player.yoshi_animations.play("PipeClassic")
			else:
				player.yoshi_animations.play("PipeModern")
		else:
			player.current_animation = "FaceForward"
	else:
		player.yoshi_animations.play("PipeSide")
		if player.riding_yoshi:
			player.current_animation = "YoshiCrouch"
		elif player.holding:
			player.current_animation = "HoldWalk"
		else:
			player.current_animation = "Walk"
	
	player.direction = -1 if pipe_direction == "Right" else 1
	
	match pipe_direction:
		"Up":
			pipe_position -= (Vector2.UP * -enter_speed) * delta
		"Down":
			pipe_position -= (Vector2.DOWN * -enter_speed)  * delta
		"Left":
			pipe_position -= (Vector2.LEFT * -enter_speed) * delta
		"Right":
			pipe_position -= (Vector2.RIGHT * -enter_speed) * delta
	if is_instance_valid(current_pipe):
		player.global_position = current_pipe.global_position + pipe_position

func is_water(area: Area2D) -> bool:
	return area.owner is WaterArea

func exit() -> void:
	player.hitbox_area.set_deferred("monitoring", true)
	player.hitbox_area.set_deferred("monitorable", true)
	GameManager.can_pause = true
	player.sprite.z_index = 2
	player.process_mode = Node.PROCESS_MODE_PAUSABLE
	player.can_hurt = true
	player.refresh_hitbox()
	if is_instance_valid(current_pipe):
		current_pipe.pipe_used = false
