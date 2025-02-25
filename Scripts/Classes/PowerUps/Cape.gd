extends PowerScript

var cape_spin_meter := 0.0
var spinning := false

var cape
var spun_out := false

var heli_frames := 60
var turn_around_frames := 00

var back_anims := ["ClimbIdleBack", "ClimbMoveBack", "ClimbPunchBack"]

var front_anims := ["Dead", "FaceForward", "Victory", "YoshiFaceForward", "PBalloon", "PBalloonLow", "ClimbIdleFront",
					"ClimbMoveFront",  "ClimbPunchFront"]

var flight_direction := 1

func _ready() -> void:
	cape = player.power_sprite_extras[0]

func _physics_process(delta: float) -> void:
	cape.cape_velocity = player.velocity
	cape.spinning = player.spinning or spinning
	turn_around_frames -= 1
	heli_frames -= 1
	match player.state_machine.state.name:
		"Normal":
			main(delta)
		"Swim":
			main(delta)
		"LevelFinish":
			cutscene()
		"Freeze":
			cutscene()
		"WallRun":
			spinning = false
			player.sprinting = true
			player.spinning = false
			player.spin_attacking = false
			cape_spin_meter = 0
			handle_wall_take_off()
		_:
			pass

func main(delta) -> void:
	if cape_spin_meter <= 0.5 and spinning and turn_around_frames > 0 and (player.input_direction != flight_direction or flight_direction != player.velocity_direction) and player.input_direction != 0 and not player.is_on_floor():
		flight_direction = player.input_direction
		cape_spin_meter = 0
		player.state_machine.transition_to("CapeFly", {"DiveState": 1})
	if turn_around_frames > 0 and spinning and (player.input_direction != flight_direction or flight_direction != player.velocity_direction) and player.input_direction != 0:
		player.velocity.y = clamp(player.velocity.y, -9999, 10)
	spinning = cape_spin_meter > 0 or player.spin_jumping
	cape_spin_meter -= 3 * delta
	handle_jump_take_off()
	player.spin_attacking = spinning
	player.attacking = spinning
	if Input.is_action_just_pressed(CoopManager.get_player_input_str("run", player.player_id)) and not player.crouching:
		cape_spin()
	if ((Input.is_action_pressed(CoopManager.get_player_input_str("jump", player.player_id)) or Input.is_action_pressed(CoopManager.get_player_input_str("spin_jump", player.player_id))) or spun_out) and not player.is_on_floor():
		player.velocity.y = clamp(player.velocity.y, -9999, 60)
	if spun_out:
		if player.is_on_floor():
			spun_out = false
	player.spinning = spinning or player.spin_jumping

func handle_jump_take_off(on_floor := false) -> void:
	if (Input.is_action_just_pressed(CoopManager.get_player_input_str("jump", player.player_id)) or Input.is_action_just_pressed(CoopManager.get_player_input_str("spin_jump", player.player_id))):
		if player.sprinting:
			if player.input_direction != 0:
				flight_direction = player.input_direction
			else:
				flight_direction = player.facing_direction
			if heli_frames > 0 and not player.is_on_floor():
				player.state_machine.transition_to("CapeFly", {"Heli" = true})
			elif player.is_on_floor():
				player.state_machine.transition_to("CapeFly")
			player.spin_jumping = Input.is_action_just_pressed(CoopManager.get_player_input_str("spin_jump", player.player_id))
			if player.holding and SettingsManager.settings_file.holding_spin_jump == false:
				player.spin_jumping = false

func handle_wall_take_off() -> void:
	if Input.is_action_just_pressed(CoopManager.get_player_input_str("jump", player.player_id)) or Input.is_action_just_pressed(CoopManager.get_player_input_str("spin_jump", player.player_id)):
		await get_tree().physics_frame
		spinning = player.spin_jumping
		player.state_machine.transition_to("CapeFly")

func spin_out() -> void:
	if not spun_out:
		SoundManager.play_sfx("res://Assets/Audio/SFX/suit-remove.wav", player)
		player.state_machine.transition_to("Normal")
	spun_out = true
	player.spin_jumping = true

func cutscene() -> void:
	spinning = false
	player.spin_attacking = false
	player.spinning = false

func _exit_tree() -> void:
	player.spinning = false
	player.spin_attacking = false
	player.attacking = false

func cape_spin() -> void:
	if player.riding_yoshi:
		return
	cape_spin_meter = 1
	player.play_sfx("spin")
