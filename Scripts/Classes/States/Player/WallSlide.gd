extends PlayerState

var starting_direction := 1

var drop_off := 0.0



func enter(_msg := {}) -> void:
	drop_off = 0
	starting_direction = player.direction

func physics_update(delta: float) -> void:
	player.direction = -starting_direction
	player.sprite.scale.x = player.direction
	player.velocity.x = 100 * starting_direction
	player.current_animation = "WallSlide"
	player.velocity.y += 10
	player.velocity.y = clamp(player.velocity.y, -9999, 50)
	if player.input_direction != starting_direction:
		drop_off += 5 * delta
	player.skid_particles.emitting = true
	if Input.is_action_just_pressed(CoopManager.get_player_input_str("jump", player.player_id)):
		wall_kick()
	if Input.is_action_just_pressed(CoopManager.get_player_input_str("spin_jump", player.player_id)):
		wall_spin()
	
	if drop_off >= 1:
		player.velocity.x = 0
		state_machine.transition_to("Normal")
	
	if player.is_on_wall() == false:
		drop_off += 0.5
	if player.is_on_floor():
		state_machine.transition_to("Normal")

func wall_spin() -> void:
	player.vibrate_controller(1)
	state_machine.transition_to("Normal")
	player.velocity.x = 200 * ceil(player.get_wall_normal().x)
	player.velocity.y = -250
	player.run_jumped = false
	player.spinning = true
	player.spin_jumping = true
	player.gravity = player.jump_gravity
	SoundManager.play_sfx(SoundManager.big_jump, player)
	SoundManager.play_sfx(SoundManager.spin, player)
	SoundManager.play_sfx(SoundManager.stomp, player)
	ParticleManager.summon_particle(ParticleManager.PUFF_SPR, player.global_position)

func wall_kick() -> void:
	player.vibrate_controller(1)
	state_machine.transition_to("Normal", {"WallKick" = true})
	player.velocity.x = 180 * ceil(player.get_wall_normal().x)
	player.velocity.y = -250
	player.spinning = false
	player.run_jumped = false
	player.can_dive = true
	player.gravity = player.jump_gravity
	if player.power_state.hitbox_size == "Regular":
		SoundManager.play_sfx(SoundManager.big_jump, player)
	else:
		SoundManager.play_sfx(SoundManager.small_jump, player)
	SoundManager.play_sfx(SoundManager.stomp, player)
	ParticleManager.summon_particle(ParticleManager.PUFF_SPR, player.global_position)

func exit() -> void:
	player.velocity.x = 0
	player.skid_particles.emitting = false
