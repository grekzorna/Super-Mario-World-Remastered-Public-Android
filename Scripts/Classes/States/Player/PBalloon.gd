extends PlayerState

var balloon_meter := 0.0

const move_speed := 75

func enter(_msg := {}) -> void:
	player.sprite_speed_scale = 1
	MusicPlayer.game.pitch_scale = 0.9
	player.sprite.speed_scale = 1
	player.can_pickup = false
	if player.riding_yoshi:
		player.yoshi_dismount()
	balloon_meter = 20
	SoundManager.play_sfx(SoundManager.balloon, player)
	player.current_animation = ""
	player.sprite.play("PBalloon")

func physics_update(delta: float) -> void:
	player.velocity = lerp(player.velocity, move_speed * get_input_vector(), delta * 5)
	balloon_meter -= 1 * delta
	if balloon_meter <= 0:
		state_machine.transition_to("Normal")
	if int(balloon_meter) <= 3:
		player.current_animation = "PBalloonLow"

func get_input_vector() -> Vector2:
	var input_vector = Vector2.ZERO
	if Input.is_action_pressed(CoopManager.get_player_input_str("move_right", player.player_id)):
		input_vector.x = 1
	elif Input.is_action_pressed(CoopManager.get_player_input_str("move_left", player.player_id)):
		input_vector.x = -1
	else:
		input_vector.x = 0
	
	if Input.is_action_pressed(CoopManager.get_player_input_str("move_up", player.player_id)):
		input_vector.y = -0.5
	elif Input.is_action_pressed(CoopManager.get_player_input_str("move_down", player.player_id)):
		input_vector.y = 2
	else:
		input_vector.y = 0
	
	input_vector.y -= 1
	return input_vector

func exit() -> void:
	player.can_pickup = true
	MusicPlayer.game.pitch_scale = 1
