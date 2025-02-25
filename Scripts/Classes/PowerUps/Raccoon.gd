extends PowerScript

var tail_spin_meter := 0.0
var spinning := false

var float_meter := 0.0

var p_meter_bar: PowerUpSpriteExtra = null
var p_meter := 0
var flying := false
var can_fly := false
var fly_meter := 0.0
var can_sound := false

func _physics_process(delta: float) -> void:
	if player.power_sprite_extras.size() > 0:
		p_meter_bar = player.power_sprite_extras[0]
		match player.state_machine.state.name:
			"Normal":
				main(delta)
			"Swim":
				main(delta)
			_:
				pass

func main(delta) -> void:
	p_meter = abs(player.velocity.x / 25)
	if player.running:
		p_meter = 8
	if player.is_on_floor() and Input.is_action_pressed(CoopManager.get_player_input_str("run", player.player_id)) and can_fly:
		p_meter_bar.p_value = p_meter
	elif p_meter != 8:
		p_meter_bar.p_value = 0
	spinning = tail_spin_meter > 0
	tail_spin_meter -= 3 * delta
	float_meter -= 3 * delta
	player.spin_attacking = spinning
	player.attacking = spinning
	if flying:
		if fly_meter <= 0:
			flying = false
			player.running = false
			p_meter = 0
			player.run_jumped = false
	if player.is_on_floor():
		can_fly = true
	fly_meter -= 3 * delta
	if spinning:
		player.sprite_speed_scale = 1
	if Input.is_action_just_pressed(CoopManager.get_player_input_str("run", player.player_id)):
		tail_spin()
	if Input.is_action_just_pressed(CoopManager.get_player_input_str("jump", player.player_id)):
		if p_meter < 8:
			if player.velocity.y > 15:
				air_float()
		elif p_meter == 8 and player.is_on_floor() == false:
			air_float()
	if float_meter >= 0 and not player.is_on_floor():
		if flying:
			if player.holding:
				player.animation_override = "HoldFly"
			else:
				player.animation_override = "Fly"
			player.velocity.y = -100
		else:
			if player.holding:
				player.animation_override = "HoldFallFloat"
			elif player.carrying:
				player.animation_override = "CarryFallFloat"
			else:
				player.animation_override = "FallFloat"
		player.velocity.y = clamp(player.velocity.y, -9999, player.max_fall_speed / 8)
	elif player.animation_override.contains("Float") or player.animation_override.contains("Fly"):
		player.animation_override = ""
	player.spinning = spinning

func _exit_tree() -> void:
	player.spinning = false
	player.spin_attacking = false
	player.attacking = false

func tail_spin() -> void:
	if player.riding_yoshi:
		return
	tail_spin_meter = 0.5
	SoundManager.play_sfx(SoundManager.spin, player)

func air_float() -> void:
	if p_meter == 8 and can_fly and not player.is_on_floor() and not player.carrying:
		if not flying:
			fly_meter = 10
		flying = true
		can_fly = false
	if can_sound:
		can_sound = false
		SoundManager.play_sfx(SoundManager.spin, player)
	float_meter = 1
	await get_tree().create_timer(0.5, false).timeout
	can_sound = true
