extends PlayerState

var drilling := false

var falling := false

func _enter_tree() -> void:
	await get_tree().physics_frame
	name = "PropellerFly"
	power_state = true

func enter(msg := {}) -> void:
	player.velocity.y = 0
	player.ground_pound_land_timer = 0
	falling = false
	player.spinning = false
	drilling = false
	if msg.has("Instant"):
		falling = true
		drilling = true
	else:
		SoundManager.play_sfx("res://Assets/Audio/SFX/PropellerFly.wav", player)
		fly_tween()

func update(delta: float) -> void:
	player.sprite_speed_scale = 1
	player.spinning = true
	player.hold_position_animations.play("Spin")
	if falling:
		if drilling:
			player.power_sprite_extras[0].sprite.speed_scale = 10
			player.current_animation = "FlyDrill"
		else:
			player.hold_position_animations.speed_scale = 0.75
			player.power_sprite_extras[0].sprite.speed_scale = 3
			if player.holding:
				player.current_animation = "HoldFlyFall"
			elif player.carrying:
				player.current_animation = "CarryFlyFall"
			else:
				player.current_animation = ("FlyFall")
	else:
		player.hold_position_animations.speed_scale = 1
		player.power_sprite_extras[0].sprite.speed_scale = 5
		player.sprite_speed_scale = abs((player.velocity.y) / 45) + 3
		if player.holding:
			player.current_animation = "HoldFlyUp"
		elif player.carrying:
			player.current_animation = "CarryFlyUp"
		else:
			player.current_animation = ("FlyUp")

func physics_update(delta: float) -> void:
	player.ground_pounding = drilling
	player.velocity.y += 5
	falling = player.velocity.y > 0
	if falling:
		if Input.is_action_pressed(CoopManager.get_player_input_str("move_down", player.player_id)):
			if not drilling:
				player.power_sprite_extras[0].fall_sfx.play()
			drilling = true
			player.velocity.y += 50
			player.velocity.y = clamp(player.velocity.y, -999999, 300)
		else:
			player.power_sprite_extras[0].fall_sfx.stop()
			drilling = false
			player.velocity.y = clamp(player.velocity.y, -999999, 100)
	
	if player.input_direction != 0:
		player.velocity.x += ((75 * 3.75) * player.input_direction) * delta
	else:
		player.velocity.x = lerpf(player.velocity.x, 0, delta * 4)
	
	if falling:
		player.velocity.x = lerpf(player.velocity.x, clamp(player.velocity.x, -75, 75), delta * 5)
	else:
		player.velocity.x = lerpf(player.velocity.x, clamp(player.velocity.x, -150, 150), delta * 5)
	
	if player.is_on_floor():
		player.ground_pound_land_timer = clamp(player.ground_pound_land_timer, 0, 1)
		player.ground_pound_land_timer -= 10 * delta
		if player.ground_pound_land_timer <= 0:
			if drilling:
				SoundManager.play_sfx(SoundManager.bullet, player)
			state_machine.transition_to("Normal")

func fly_tween() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(player, "velocity:y", -300, 0.25)


func exit() -> void:
	player.spinning = false
	player.hold_position_animations.play("RESET")
	player.power_sprite_extras[0].sprite.speed_scale = 1
	player.ground_pounding = false
