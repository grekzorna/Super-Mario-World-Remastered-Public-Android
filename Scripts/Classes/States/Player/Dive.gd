extends PlayerState

var starting_direction := 1

var exiting := false

var physics_style := ""
var wall_hit = false
const move_speed_modifiers := {"Mario": 1, "Luigi": 0.95, "Toad": 1.25, "Toadette": 1.25}

func enter(_msg := {}) -> void:
	player.can_dive = false
	player.velocity.y /= 2
	player.spinning = false
	player.skidding = false
	player.sliding = true
	player.crouching = true
	player.can_pickup = false
	player.spin_attacking = false
	wall_hit = false
	SoundManager.play_sfx(SoundManager.kick, player)
	exiting = false
	var changing_direction := player.input_direction != player.velocity_direction
	starting_direction = player.input_direction if player.input_direction != 0 else player.direction
	player.velocity.x = abs(player.velocity.x) * starting_direction
	if abs(player.velocity.x) < 75 / 1.5 or changing_direction:
		player.velocity.x = 75 / 1.5 * starting_direction
	player.velocity.x += (135 / 1.5)* starting_direction
	player.direction = starting_direction
	if player.is_on_floor():
		player.velocity.y = -200
	player.gravity = player.fall_gravity
	

func physics_update(delta: float) -> void:
	if player.character.custom_properties.has("PhysicsStyle") and SettingsManager.settings_file.character_specific_physics and not player.riding_yoshi:
		physics_style = player.character.custom_properties.get("PhysicsStyle")
	else:
		physics_style = "Mario"
	player.gravity = player.fall_gravity
	player.sprite.scale.x = player.direction
	if player.get_floor_normal().x != 0:
		player.velocity.x += (500 * delta) * player.slope_direction
	elif player.is_on_floor():
		if not player.on_ice:
			player.velocity.x = lerpf(player.velocity.x, 0, delta)
		else:
			player.velocity.x = lerpf(player.velocity.x, 0, delta / 4)
	player.velocity.x = clamp(player.velocity.x, -200 * move_speed_modifiers[physics_style], 200 *  move_speed_modifiers[physics_style])
	if exiting:
		player.sprite_speed_scale = 1
		if player.input_direction != player.velocity_direction:
			player.velocity.x += (75 * (10) * delta) * player.input_direction
	elif not wall_hit:
		player.current_animation = "Dive"
	player.velocity.y += 15
	player.skid_particles.emitting = player.is_on_floor() and not player.on_ice
	if player.is_on_floor():
		if abs(player.velocity.x) < 50:
			state_machine.transition_to("Normal")
			return
	if (Input.is_action_just_pressed(CoopManager.get_player_input_str("jump", player.player_id))) and not exiting and player.is_on_floor():
		if player.is_on_floor():
			player.velocity.x = move_toward(player.velocity.x, (abs(player.velocity.x) * 1.3) * player.input_direction, 0.5)
		else:
			player.velocity.x = move_toward(player.velocity.x, (abs(player.velocity.x) * 0.9) * player.input_direction, 0.25)
		player.current_animation = "Flip"
		if player.is_on_floor():
			player.velocity.y = -240
		else:
			player.velocity.y = -100
		if player.holding:
			if player.is_on_floor():
				state_machine.transition_to("Normal", {"Jump" = true})
			else:
				state_machine.transition_to("Normal")
			return
		if player.power_state.hitbox_size == "Regular":
			SoundManager.play_sfx(SoundManager.big_jump, player)
		else:
			SoundManager.play_sfx(SoundManager.small_jump, player)
		SoundManager.play_sfx(SoundManager.spin, player)

		for i in 3:
			await get_tree().physics_frame
		exiting = true
		player.current_animation = "Flip"
		return
	if player.is_on_floor():
		if exiting:
			state_machine.transition_to("Normal")
			if abs(player.velocity.x) >= 150:
				player.p_meter = player.p_max
			return
	player.velocity.y = clamp(player.velocity.y, -9999, 240)
	if player.is_on_wall() and abs(player.velocity_lerp.x) > 50 and player.is_on_floor() == false and not exiting:
		player.velocity.x = -player.velocity_lerp.x / 1.5
		wall_hit = true
		exiting = true
		player.summon_flash_particle()
		SoundManager.play_sfx(SoundManager.stun, player)
		SoundManager.play_sfx(SoundManager.stomp, player)
	if abs(player.velocity.x) < 100 and exiting:
		state_machine.transition_to("Normal")
		return
	
func exit() -> void:
	player.force_crouch_check()
	player.crouching = false
	player.can_pickup = true
	player.water_skimmed = false
	player.sliding = false
	player.skid_particles.emitting = false
	player.sprite.rotation = 0
