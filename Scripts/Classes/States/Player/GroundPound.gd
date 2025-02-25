extends PlayerState

var spin_amount: float = 0.0

var flipping := true

var can_land := true
@onready var puff_trail: GPUParticles2D = $"../../Particles/PuffTrail"

func enter(msg := {}) -> void:
	flipping = true
	player.sprinting = false
	player.ground_pound_land_timer = 0.2
	can_land = true
	spin_amount = 0
	player.spinning = false
	if msg.has("Instant") == false:
		player.play_sfx("kick")
		await get_tree().create_timer(0.25, false).timeout
	if state_machine.state == self:
		player.velocity.y = 275
		player.sprite.speed_scale = 5
		flipping = false

func physics_update(delta: float) -> void:
	player.sprite_speed_scale = 1
	player.sprite.speed_scale = 1
	player.velocity.y = clamp(player.velocity.y, -99999, 750)
	if Input.is_action_just_pressed(CoopManager.get_player_input_str("move_up", player.player_id)):
		state_machine.transition_to("Normal")
		return
	if flipping:
		player.current_animation = "Flip"
		player.velocity = Vector2.ZERO
		spin(delta)
	else:
		if player.is_on_floor():
			player.velocity.x = lerpf(player.velocity.x, 0, delta * 20)
			player.current_animation = "GroundPoundLand"
		else:
			player.current_animation = "GroundPoundAir"
		player.ground_pounding = true
		player.sprite.rotation = 0
		player.velocity.y += 30
	if player.is_on_floor():
		player.ground_pound_land_timer -= 1 * delta
		if player.get_floor_normal().x != 0:
			player.velocity.x = player.velocity_lerp.y * player.get_floor_normal().x
			state_machine.transition_to("Normal")
			if abs(player.velocity.x) >= 150:
				player.p_meter = player.p_max
				player.sprinting = true
			return
		hit_ground()
		if Input.is_action_just_pressed(CoopManager.get_player_input_str("jump", player.player_id)):
			state_machine.transition_to("Normal")
			player.velocity.y = -380
			puff_trail.emitting = true
			player.gravity = player.jump_gravity
			player.play_sfx("spin")
			await get_tree().create_timer(0.5, false).timeout
			puff_trail.emitting = false
		if player.ground_pound_land_timer <= 0:
			state_machine.transition_to("Normal")
	elif player.ground_pound_land_timer > 0:
		can_land = true
	if Input.is_action_just_pressed(CoopManager.get_player_input_str("dive", player.player_id)) and SettingsManager.settings_file.dive and player.can_dive:
		state_machine.transition_to("Dive")
		ParticleManager.summon_particle(ParticleManager.PUFF_SPR, player.global_position - Vector2(0, 8))
		if player.is_on_floor() == false:
			player.velocity.y = -150
		player.velocity.x = 200 * player.direction

func drill_powerup() -> void:
	if player.is_on_floor():
		if Input.is_action_pressed("move_down"):
			state_machine.transition_to("DrillBurrow")
	elif player.is_on_ceiling():
		if Input.is_action_pressed("jump") || Input.is_action_pressed("move_up"):
			state_machine.transition_to("DrillBurrow", {"Ceiling" = true})

func hit_ground() -> void:
	if can_land == false:
		return
	else:
		can_land = false
	player.ground_pound_land_timer = 0.5
	player.vibrate_controller(1, 0.25)
	player.animation_player.play("Squish")
	GameManager.shake_camera(13)
	ParticleManager.summon_particle(ParticleManager.GROUND_POUND_IMPACT, player.global_position)
	player.play_sfx("bullet")
	player.play_sfx("bump")

func spin(delta: float) -> void:
	pass

func exit() -> void:
	player.ground_pounding = false
