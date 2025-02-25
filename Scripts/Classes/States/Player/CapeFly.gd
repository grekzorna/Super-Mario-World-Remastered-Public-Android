extends PlayerState

var ascending := false
var bouncing := false
var caught_air := false
var highest_dive := 0

var ascend_count := 78

var can_fly := false

var dive_state := 0

var dive_gravities := [3.75, 3.75, 11.25, 15, 18.75, 22.5]

var max_y_vels := [60, 180, 180, 210, 210, 240]
var min_y_vel := -210

var dive_timer := 0

var diving := false

var floor_accel := 3.75

var slope_accels := {Player.Slopes.GRADUAL: 1.875,
					 Player.Slopes.NORMAL: 3.75,
					 Player.Slopes.STEEP: 5.625,
					 Player.Slopes.VERY_STEEP: 9.375}

var gravity := 0

var fly_direction := 1

var dive_5_hit := false

var bounce_timer := 0

var oppo_action := ""

var gliding := false

func _enter_tree() -> void:
	await get_tree().physics_frame
	name = "CapeFly"
	power_state = true

func enter(msg := {}) -> void:
	player.sprite_speed_scale = 1
	player.sprite.speed_scale = 1
	player.power_script.turn_around_frames = 0
	gliding = false
	player.flags["CapeFlying"] = false
	if msg.has("Heli") == false:
		ascend_count = 78
	else:
		player.velocity.y = -50
	highest_dive = 0
	dive_state = 0
	ascending = true
	bouncing = false
	dive_timer = 8
	diving = false
	can_fly = not player.riding_yoshi and not player.holding and not player.carrying
	if msg.has("DiveState"):
		start_cape_flying(msg.get("DiveState"))

func physics_update(delta: float) -> void:
	if ascending:
		handle_ascending(delta)
	elif bouncing:
		handle_bouncing()
	else:
		handle_diving(delta)
	if Input.is_action_pressed(CoopManager.get_player_input_str("run", player.player_id)) == false:
		state_machine.transition_to("Normal")
		if not ascending and not player.is_on_floor():
			player.power_script.turn_around_frames = 30

func handle_ascending(delta) -> void:
	ascend_count -= 1
	if player.riding_yoshi:
		player.current_animation = "YoshiIdle"
	else:
		if player.spin_jumping:
			player.current_animation = "Spin"
		elif player.holding:
			player.current_animation = "HoldJump"
		elif player.carrying:
			player.current_animation = "CarryJump"
		else:
			player.current_animation = "RunJump"
	if player.yoshi_animation_override == "":
		player.yoshi_animations.play("Jump")
	player.velocity.y = move_toward(player.velocity.y, -210, 11.25)
	player.velocity.x = move_toward(player.velocity.x, 180 * player.direction, 5)
	if player.input_direction != 0:
		player.direction = player.input_direction
	player.sprite.scale.x = player.direction
	if ascend_count <= 0 or (Input.is_action_pressed(CoopManager.get_player_input_str("jump", player.player_id)) == false and Input.is_action_pressed(CoopManager.get_player_input_str("spin_jump", player.player_id)) == false):
		can_fly = not player.riding_yoshi and not player.holding and not player.carrying
		if can_fly and not player.spin_jumping:
			start_cape_flying()
		else:
			if ascend_count > 0:
				print("FuCK")
				player.power_script.heli_frames = 60
			state_machine.transition_to("Normal")

func start_cape_flying(set_dive_state := 0) -> void:
	if player.input_direction != 0:
		fly_direction = player.input_direction
	else:
		fly_direction = player.direction
	player.power_script.flight_direction = fly_direction
	player.sprite.scale.x = fly_direction
	if fly_direction == 1:
		oppo_action = "move_left"
	else:
		oppo_action = "move_right"
	player.flags["CapeFlying"] = true
	dive_state = set_dive_state
	caught_air = false
	ascending = false
	diving = true
	dive_5_hit = false

func handle_diving(delta: float) -> void:
	player.sprite.offset.y = -8
	diving = Input.is_action_pressed(CoopManager.get_player_input_str(oppo_action, player.player_id)) and dive_state < 2
	if diving:
		dive_state = 0
		player.velocity.y = clamp(player.velocity.y, -999, 60)
	player.current_animation = "CapeFly" + str(dive_state + 1)
	player.power_sprite_extras[0].hide()
	player.velocity.y += dive_gravities[dive_state]
	player.velocity.y = clamp(player.velocity.y, -210, 240)
	if Input.is_action_just_pressed(CoopManager.get_player_input_str("jump", player.player_id)) and Input.is_action_pressed(CoopManager.get_player_input_str(oppo_action, player.player_id)):
		if fly_direction == 1:
			if player.velocity.x > -13:
				player.velocity.x -= 20 * fly_direction
		else:
			if player.velocity.x < 13:
				player.velocity.x -= 20 * fly_direction
	if Input.is_action_just_pressed(CoopManager.get_player_input_str(oppo_action, player.player_id)) and player.velocity.y > 0 and not player.is_on_floor():
		air_catch()
	if dive_state <= 4:
		if player.is_on_floor():
			dive_state = 2
			if player.is_on_slope():
				player.velocity.x = move_toward(player.velocity.x, 0, slope_accels[player.get_slope_height(player.get_floor_normal())])
			else:
				player.velocity.x = move_toward(player.velocity.x, 0, floor_accel)
		if abs(player.velocity.x) < 10 and player.is_on_floor():
			state_machine.transition_to("Normal")
	elif player.is_on_floor():
		dive_slam()

	if player.input_direction == fly_direction and not player.is_on_floor():
		player.velocity.x = move_toward(player.velocity.x, 180 * fly_direction, dive_state + 2)
		diving = true
	if player.velocity.y > 0:
		dive_timer -= 1
	else:
		dive_state = 0
	if dive_timer <= 0 and not player.is_on_floor():
		add_dive_state()

func handle_bouncing() -> void:
	player.current_animation = "CapeFly" + str(dive_state + 1)
	player.power_sprite_extras[0].hide()
	bounce_timer -= 1
	if bounce_timer <= 0:
		air_bounce_state_move()
	caught_air = false

func dive_slam() -> void:
	state_machine.transition_to("Normal")
	player.slam_attack()
	SoundManager.play_sfx(SoundManager.bullet, player)

func air_bounce_state_move() -> void:
	dive_state -= 1
	if not dive_5_hit:
		bounce_timer = 4
	else:
		bounce_timer = 1
	if dive_state == 0:
		if not dive_5_hit:
			dive_2_bounce()
		else:
			dive_5_bounce()

func air_catch() -> void:
	if not caught_air:
		bouncing = false
		diving = true
		dive_state = 0
		bounce_timer = 16
		return
	SoundManager.play_sfx(SoundManager.cape_fly, player)
	bouncing = true
	bounce_timer = 8

func dive_2_bounce() -> void:
	dive_5_hit = false
	diving = false
	player.velocity.y = 15
	for i in 3:
		player.velocity.y -= 45
		await get_tree().physics_frame
	if state_machine.state != self:
		state_machine.transition_to("CapeFly")
	bouncing = false

func dive_5_bounce() -> void:
	player.velocity.y = 15
	dive_5_hit = false
	for i in 7:
		player.velocity.y -= 45
		player.velocity.y = clamp(player.velocity.y, -210, 999)
		await get_tree().physics_frame
	bouncing = false
	dive_5_hit = false

func add_dive_state() -> void:
	dive_state += 1
	if not player.input_direction == fly_direction:
		dive_state = clamp(dive_state, 0, 2)
	if dive_state == 2:
		caught_air = true
	dive_state = clamp(dive_state, 0, 5)
	if dive_state == 5:
		dive_5_hit = true
	dive_timer = 8


func exit() -> void:
	player.flags["CapeFlying"] = false
	if player.power_sprite_extras.is_empty() == false:
		player.power_sprite_extras[0].show()
	player.sprite.offset.y = 1
