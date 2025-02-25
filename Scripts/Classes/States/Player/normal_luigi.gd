extends PlayerState

var can_flutter := true

var min_slope_angle := deg_to_rad(10)
var flutter_meter := 1.0
var flutter_rate := 1
var flutter_boost := 20.0
var flutter_mod := 0.0

var jump_queued := false

var can_walljump := true

var skidding := false

var can_turn := false

var p_meter := 0.0
const p_max := 112.0

var facing_direction := 1

var can_sprint := false

var can_move := true

var can_yoshi_stomp := false

const walk_speed := 75.0
# When doing slope data structures: first index is ALWAYS moving down the slope. Second index is moving up slope.
const walk_slope_speeds := {Player.Slopes.GRADUAL: [75, 75],
							 Player.Slopes.NORMAL: [90, 63.75],
							 Player.Slopes.STEEP: [135, 56.25],
							Player.Slopes.VERY_STEEP: [135, 0]}

const run_speed := 135.0
const run_slope_speeds := {Player.Slopes.GRADUAL: [135, 135],
							Player.Slopes.NORMAL: [135, 116.75],
							Player.Slopes.STEEP: [135, 61],
							Player.Slopes.VERY_STEEP: [135, 0]}

const sprint_speed := 180.0
const sprint_slope_speeds := {Player.Slopes.GRADUAL: [180, 180],
								Player.Slopes.NORMAL: [180, 180],
								Player.Slopes.STEEP: [180, 180],
								Player.Slopes.VERY_STEEP: [180, 180]}

var current_slope_height := 0.0

const stand_slope_slide := {Player.Slopes.GRADUAL: 0,
							Player.Slopes.NORMAL: 0,
							Player.Slopes.STEEP: 60,
							Player.Slopes.VERY_STEEP: 120}

const sliding_accels := {0: 0,
						Player.Slopes.GRADUAL: 1.875,
						Player.Slopes.NORMAL: 3.75,
						Player.Slopes.STEEP: 5.625,
						Player.Slopes.VERY_STEEP: 9.375}

const sliding_speeds := {Player.Slopes.GRADUAL: 165,
						Player.Slopes.NORMAL: 180,
						Player.Slopes.STEEP: 240,
						Player.Slopes.VERY_STEEP: 180}

const jump_incr := 6.96
const spin_jump_incr := 7.5

const jump_height := 290.5
const spin_jump_height := 266.25

const accel := 5.265
const l_accel := 3.0

const decel := 3.0

const walk_skid := 9.375
const l_walk_skid := 5.5

const run_skid := 18.75
const l_run_skid := 10.0

const DASH_START = preload("res://Instances/Particles/Player/dash_start.tscn")

const air_accel := 5.265
const l_air_accel := 3.5

const air_back_accel := 9.375
const l_air_back_accel := 5.75
const air_run_back_accel := 18.75
const l_air_run_back_accel := 10.5

const max_fall_speed := 240.0
const l_max_fall_speed := 200.0

const l_jump_gravity := 8.0
const l_fall_gravity := 18.0

const min_slope_angle_slip := 45.0

var turning := false
var steep_sliding := false

var air_lock := false

var can_extra_move := false # Var used to dictate whether the player can do an extra move (Walljump, Groundpound and stuff)

var animation_override := ""

func enter(msg := {}) -> void:
	air_lock = msg.has("WallKick")
	if msg.has("Jump"):
		jump()
		player.crouching = false
	player.current_animation = "Idle"
	facing_direction = player.direction
	player.sprite.show()
	player.skid_sfx.play()
	player.skid_sfx.stream_paused = true

@onready var wings: AnimatedSprite2D = $"../../Yoshi/Wings"

func physics_update(delta: float) -> void:
	can_turn = player.holding or (player.riding_yoshi and not player.yoshi_tongue)
	handle_movement(delta)
	
	if player.riding_yoshi:
		handle_yoshi()
	player.direction = facing_direction
	player.current_animation = handle_animation()
	if not turning:
		player.yoshi_animations.play(handle_yoshi_animation())

'''Im not gonna do it now, but please i beg at some point can you please fucking just refactor this code it is
	absolutely fucking atrocious, me. fucks sake, do better.'''

func handle_movement(delta: float) -> void:
	can_extra_move = not player.holding and not player.carrying and not player.riding_yoshi and not player.spin_jumping
	if player.input_direction != 0 and not player.yoshi_tongue:
		if not can_turn:
			facing_direction = player.input_direction
		elif facing_direction != player.input_direction and not turning:
			play_turn_animation(player.input_direction)
	
	if player.liquid_checker.is_in_water():
		state_machine.transition_to("Swim")
	
	player.gravity = get_gravity()
	player.velocity.y += player.gravity
	player.velocity.y = clamp(player.velocity.y, -999999, max_fall_speed)
	if player.is_on_floor():
		handle_ground_movement(delta)
	else:
		handle_air_movement(delta)

func handle_ground_movement(delta: float) -> void:
	
	handle_p_meter()
	handle_slopes()
	
	air_lock = false
	
	if can_yoshi_stomp and player.yoshi_stomp:
		yoshi_earthquake()
	
	player.crouching = Input.is_action_pressed(CoopManager.get_player_input_str("move_down", player.player_id))

	if can_sprint and player.input_direction == player.velocity_direction:
		if player.sprinting == false:
			summon_dash_particle()
		player.sprinting = true
	else:
		player.sprinting = false
	
	skidding = player.input_direction != 0 and player.input_direction != player.velocity_direction and not steep_sliding
	if player.sliding or steep_sliding:
		handle_sliding()
	elif skidding and not player.crouching:
		handle_skidding()
	elif player.input_direction != 0 and not player.crouching and can_move:
		handle_ground_acceleration()
	elif player.input_direction == 0 or player.crouching:
		handle_deceleration(delta)
	
	player.spin_jumping = false
	if Input.is_action_just_pressed(CoopManager.get_player_input_str("spin_jump", player.player_id)):
		spin_jump()
	
	if Input.is_action_just_pressed(CoopManager.get_player_input_str("jump", player.player_id)):
		queue_jump()
	if jump_queued:
		jump()
	
	if player.on_triangle_block and abs(player.velocity.x) >= run_speed:
		state_machine.transition_to("WallRun")

func handle_sliding() -> void:
	var target_accel := sliding_accels[0]
	if is_on_slope():
		var target_speed = sliding_speeds[int(current_slope_height)]
		target_accel = sliding_accels[int(current_slope_height)]
		player.velocity.x = move_toward(player.velocity.x, target_speed * player.slope_direction, target_accel)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, decel)

func handle_slopes() -> void:
	if player.is_on_floor():
		current_slope_height = get_slope_height(player.get_floor_normal())
	else:
		current_slope_height = 0
	
	steep_sliding = current_slope_height == Player.Slopes.VERY_STEEP
	
	if is_on_slope():
		player.floor_snap_length = 16
	else:
		player.floor_snap_length = 8
	
	if current_slope_height == Player.Slopes.VERY_STEEP:
		handle_sliding()
	
	if not player.sliding:
		if is_on_slope() and Input.is_action_pressed(CoopManager.get_player_input_str("move_down", player.player_id)) and not player.holding and not player.carrying and not player.riding_yoshi:
			player.sliding = true
	else:
		if abs(player.velocity.x) < 10 and not is_on_slope():
			player.sliding = false

func get_slope_height(normal := Vector2.UP) -> int:
	var slope_arr := [0, Player.Slopes.GRADUAL, Player.Slopes.NORMAL, Player.Slopes.STEEP, Player.Slopes.VERY_STEEP]
	
	var diff_arr := []
	for i in slope_arr:
		var current_slope_angle = abs(rad_to_deg(normal.angle() + deg_to_rad(90)))
		var diff = abs(current_slope_angle - i)
		diff_arr.append(diff)
	return slope_arr[diff_arr.find(diff_arr.min())]

func is_on_slope() -> bool:
	return current_slope_height != 0

func get_slope_speed(struct := {}) -> float:
	var slope_height := int(current_slope_height)
	if player.moving_up_slope:
		return struct[slope_height][1]
	else:
		return struct[slope_height][0]

func handle_air_movement(delta: float) -> void:
	
	handle_p_meter()
	
	var air_skid = (player.input_direction != 0 and player.input_direction != player.velocity_direction and not air_lock)
	if air_skid:
		handle_air_skidding()
	elif player.input_direction != 0 and can_move:
		handle_air_acceleration()
	
	can_yoshi_stomp = true
	
	if player.is_on_wall() and SettingsManager.settings_file.wall_jump and player.input_direction != 0 and player.velocity.y > 0 and can_walljump and can_extra_move:
		state_machine.transition_to("WallSlide")
	
	if Input.is_action_just_pressed(CoopManager.get_player_input_str("move_down", player.player_id)) and SettingsManager.settings_file.ground_pound and can_extra_move:
		state_machine.transition_to("GroundPound")
	
	if Input.is_action_just_pressed(CoopManager.get_player_input_str("jump", player.player_id)):
		queue_jump()

func handle_ground_acceleration() -> void:
	var target_speed := walk_speed
	if is_on_slope():
		target_speed = get_slope_speed(walk_slope_speeds)
	if Input.is_action_pressed(CoopManager.get_player_input_str("run", player.player_id)):
		target_speed = run_speed
		if is_on_slope():
			target_speed = get_slope_speed(run_slope_speeds)
		if can_sprint:
			target_speed = sprint_speed
			if is_on_slope():
				target_speed = get_slope_speed(sprint_slope_speeds)
	player.velocity.x = move_toward(player.velocity.x, target_speed * player.input_direction, accel)

func handle_skidding() -> void:
	var target_skid := walk_skid
	if Input.is_action_pressed(CoopManager.get_player_input_str("run", player.player_id)):
		target_skid = run_skid
	player.velocity.x = move_toward(player.velocity.x, 1 * player.input_direction, target_skid)

func handle_air_acceleration() -> void:
	var target_speed := walk_speed
	if Input.is_action_pressed(CoopManager.get_player_input_str("run", player.player_id)):
		target_speed = run_speed
		if can_sprint:
			target_speed = sprint_speed
	player.velocity.x = move_toward(player.velocity.x, target_speed * player.input_direction, air_accel)

func handle_air_skidding() -> void:
	var target_skid := air_back_accel
	if Input.is_action_pressed(CoopManager.get_player_input_str("run", player.player_id)):
		target_skid = air_run_back_accel
	player.velocity.x = move_toward(player.velocity.x, 1 * player.input_direction, target_skid)

func handle_yoshi() -> void:
	if Input.is_action_just_pressed(CoopManager.get_player_input_str("spin_jump", player.player_id)):
		player.yoshi_dismount(false)
		if player.is_on_floor():
			spin_jump()
			player.velocity.x = -60 * player.direction
			player.velocity.y = -240
		else:
			player.velocity.y = -360
	if Input.is_action_just_pressed(CoopManager.get_player_input_str("run", player.player_id)):
		player.yoshi_use_tongue()

func handle_p_meter() -> void:
	if player.is_on_floor():
		if abs(player.velocity.x) >= run_speed and Input.is_action_pressed(CoopManager.get_player_input_str("run", player.player_id)):
			p_meter += 2
		else:
			p_meter -= 1
	p_meter = clamp(p_meter, 0, p_max)
	can_sprint = p_meter >= p_max

func handle_deceleration(delta: float) -> void:
	var stop_speed := 0
	if is_on_slope():
		stop_speed = stand_slope_slide[int(current_slope_height)]
	player.velocity.x = move_toward(player.velocity.x, stop_speed * player.slope_direction, decel)

func queue_jump() -> void:
	jump_queued = true
	player.jump_buffer.start()
	await player.jump_buffer.timeout
	jump_queued = false

func jump() -> void:
	player.sliding = false
	player.velocity.y = calculate_jump_height()
	jump_queued = false
	SoundManager.play_sfx(SoundManager.big_jump, player)

func spin_jump() -> void:
	player.spin_jumping = true
	player.velocity.y = calculate_jump_height()
	player.spin_jumping = true
	SoundManager.play_sfx(SoundManager.spin, player)

func get_gravity() -> float:
	if Input.is_action_pressed(CoopManager.get_player_input_str("jump", player.player_id)) or Input.is_action_pressed(CoopManager.get_player_input_str("spin_jump", player.player_id)):
		return player.jump_gravity
	else:
		return player.fall_gravity

func calculate_jump_height() -> float: # Thanks wye love you xxx
	var base_speed := jump_height
	var base_incr := jump_incr
	if player.spin_jumping:
		base_speed = spin_jump_height
		base_incr = spin_jump_incr
	return -(base_speed + base_incr * int(abs(player.velocity.x) / 30))
	
func handle_animation(): ## UGHHHHHHHHHHHHHHHHHHHHHHH
	player.sprite.scale.x = player.direction
	if not turning and not player.spin_jumping or player.spin_attacking:
		player.sprite_speed_scale = abs(player.velocity.x) / 40
	else:
		player.sprite_speed_scale = 1
	if player.animation_override != "":
		player.sprite_speed_scale = 1
		return player.animation_override
	if player.riding_yoshi:
		if turning:
			return "YoshiTurn"
		elif player.crouching:
			return "YoshiCrouch"
		else:
			return "YoshiIdle"
	if turning:
		if player.holding:
			return "FaceForward"
	if player.sliding and not steep_sliding:
		return "Slide"
	if player.spin_jumping or player.spin_attacking:
		return "Spin"
	if player.crouching:
		if player.holding:
			return "HoldCrouch"
		return "Crouch"
	elif player.is_on_floor():
		if skidding:
			return "Skid"
		elif abs(player.velocity.x) < 10:
			if player.holding:
				return "HoldIdle"
			return "Idle"
		elif not player.sprinting:
			if player.holding:
				return "HoldMove"
			return "Walk"
		else:
			if player.holding:
				return "HoldMove"
			return "Run"
	else:
		if player.sprinting:
			if player.holding:
				return "HoldMove"
			return "RunJump"
		else:
			return "Walk"

func play_turn_animation(new_direction := 1) -> void:
	turning = true
	player.yoshi_animations.play("Turn")
	if player.riding_yoshi:
		await get_tree().create_timer(0.1, false).timeout
	await get_tree().create_timer(0.1, false).timeout
	facing_direction = new_direction
	turning = false

func summon_dash_particle() -> void:
	var node = DASH_START.instantiate()
	node.scale.x = facing_direction
	node.global_position = player.global_position
	GameManager.current_level.add_child(node)

func yoshi_earthquake() -> void:
	can_yoshi_stomp = false
	player.vibrate_controller()
	SoundManager.play_sfx(SoundManager.bullet, player)
	ParticleManager.summon_particle(ParticleManager.GROUND_POUND_IMPACT, player.global_position)

func handle_yoshi_animation():
	if not turning and player.yoshi_animation_override == "":
		player.yoshi_animations.speed_scale = clamp(abs(player.velocity.x) / 40, 1, 999)
	else:
		player.yoshi_animations.speed_scale = 1
		return player.yoshi_animation_override
	if player.is_on_floor():
		if player.crouching:
			return "Crouch"
		elif abs(player.velocity.x) < 10:
			return "Idle"
		else:
			return "Move"
	else:
		if player.velocity.y < 0:
			return "Jump"
		else:
			return "Fall"

func exit() -> void:
	pass
