extends PlayerState

const move_speed := 125
const acceleration := 5

func enter(_msg := {}) -> void:
	player.velocity.y /= 2

func physics_update(delta: float) -> void:
	handle_movement(delta)

func update(_delta: float) -> void:
	if is_instance_valid(player.riding_cloud):
		player.riding_cloud.global_position = player.global_position
	if player.input_direction != 0:
		player.direction = player.input_direction
	player.sprite.scale.x = player.direction

func handle_movement(delta: float) -> void:
	var inputs = []
	for i in ["move_left", "move_right", "move_up", "move_down"]:
		inputs.append(CoopManager.get_player_input_str(i, player.player_id))
	var input_direction := Input.get_vector(inputs[0], inputs[1], inputs[2], inputs[3]).normalized()
	player.velocity = lerp(player.velocity, move_speed * input_direction, acceleration * delta)
	if Input.is_action_just_pressed(CoopManager.get_player_input_str("jump", player.player_id)):
		state_machine.transition_to("Normal", {"Jump"=true})
	handle_player_animations(input_direction)

func handle_player_animations(input_direction := Vector2.ZERO) -> void:
	if player.riding_yoshi:
		player.current_animation = "YoshiIdle"
	elif input_direction.y <= -0.5:
		player.current_animation = "LookUp"
	elif input_direction.y >= 0.5:
		player.current_animation = "Crouch"
	else:
		player.current_animation = "Idle"
	player.yoshi_animations.play(handle_yoshi_animation())

func handle_yoshi_animation():
	if not player.turning and player.yoshi_animation_override == "":
		player.yoshi_animations.speed_scale = clamp(abs(player.velocity.x) / 40, 1, 999)
	else:
		player.yoshi_animations.speed_scale = 1
	return "Idle"
