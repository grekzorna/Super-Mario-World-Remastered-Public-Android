extends PlayerState

var can_bounce := true

var shell_direction := 1

var can_launch := true
var slope_angle := 0.0
var upwards_slope := false
var stored_slope_velocity := 0.0
var last_floor_normal := Vector2.ZERO
@onready var shell_speed := 180
var exiting_shell := false
var can_exit := false

func _enter_tree() -> void:
	await get_tree().physics_frame
	name = "ShellSlide"
	power_state = true

func enter(_msg := {}) -> void:
	can_exit = false
	player.crouching = false
	exiting_shell = false
	power_state = true
	shell_direction = player.direction
	player.current_animation = "ShellSpinEnter"
	player.in_shell = true
	await get_tree().create_timer(0.1, false).timeout
	player.current_animation = "ShellSpinLoop"
	player.floor_constant_speed = true
	player.floor_snap_length = 12
	player.set_collision_mask_value(10, true)
	await get_tree().create_timer(0.3, false).timeout
	can_exit = true

func update(delta: float) -> void:
	player.crouching = true
	player.sprite_speed_scale = 1
	player.attacking = true
	player.spin_attacking = true



func physics_update(delta: float) -> void:
	player.skid_particles.emitting = player.is_on_floor()
	player.velocity.x = 180 * shell_direction
	if player.is_on_wall() and can_bounce:
		can_bounce = false
		player.vibrate_controller(0.5)
		SoundManager.play_sfx(SoundManager.bump, player)
		shell_direction *= -1
		for i in 4:
			await get_tree().physics_frame
		can_bounce = true
	player.direction = player.velocity_direction
	player.sprite.scale.x = player.direction
	player.velocity.y = clamp(player.velocity.y, -99999, 240)
	player.velocity.y += player.gravity
	if Input.is_action_just_pressed(CoopManager.get_player_input_str("jump", player.player_id)) and (player.is_on_floor()):
		jump()
	if Input.is_action_just_released(CoopManager.get_player_input_str("jump", player.player_id)) and not player.is_on_floor() and player.velocity.y < 0:
		player.velocity.y /= 1.25
		player.gravity = player.fall_gravity
	if player.velocity.y >= 0:
		player.gravity = player.fall_gravity
	
	if player.is_on_floor():
		can_launch = true
		if player.get_floor_normal().x == 0:
			slope_angle == 0
		elif player.get_floor_normal().x > 0:
			slope_angle = 1
		else:
			slope_angle = -1
		if slope_angle != player.direction and player.get_floor_normal().x != 0 and can_launch:
			stored_slope_velocity = -(abs(player.velocity).rotated(player.get_floor_angle()).normalized() * (player.velocity.length() * 1.5)).y - 50
		elif stored_slope_velocity != 0 and can_launch:
			slope_launch()
	elif stored_slope_velocity != 0 and can_launch:
		slope_launch()
	
	if Input.is_action_pressed(CoopManager.get_player_input_str("move_down", player.player_id)) == false and player.is_on_floor():
		exit_shell()

func exit_shell() -> void:
	if can_exit == false:
		return
	if exiting_shell:
		return
	exiting_shell = true
	player.current_animation = "ShellSpinExit"
	await get_tree().create_timer(0.05, false).timeout
	if state_machine.state == self:
		state_machine.transition_to("Normal")
	player.running = false

func slope_launch() -> void:
	if Input.is_action_pressed(CoopManager.get_player_input_str("jump", player.player_id)) == false and can_launch:
		player.velocity.y = stored_slope_velocity
		player.gravity = player.fall_gravity
		stored_slope_velocity = 0
	else:
		stored_slope_velocity = 0
		can_launch = false

func jump() -> void:
	slope_angle = 0
	SoundManager.play_sfx(SoundManager.big_jump, player)
	player.gravity = player.jump_gravity
	player.velocity.y = -250
	can_launch = false

func exit() -> void:
	player.set_collision_mask_value(10, false)
	player.floor_snap_length = 8
	player.floor_constant_speed = false
	player.in_shell = false
	player.skid_particles.emitting = false
	player.attacking = false
	player.spin_attacking = false
