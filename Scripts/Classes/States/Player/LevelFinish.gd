extends PlayerState

var victory := false

var moving_victory := true

var walk_off := false

var bonus := false
@onready var black_out: AnimationPlayer = $"../../Blackout/AnimationPlayer"

func enter(msg := {}) -> void:
	player.carry_let_go()
	player.hitbox_area.monitorable = false
	player.hitbox_area.monitoring = false
	player.set_collision_mask_value(1, true)
	player.set_collision_layer_value(1, false)
	black_out.play("BlackOut")
	moving_victory = not msg.has("Boss")
	player.yoshi_animations.speed_scale = 2
	player.first_load = true
	if moving_victory:
		player.sprite.scale.x = 1
		player.direction = 1
		player.yoshi_animations.play("Move")
		if player.riding_yoshi:
			player.current_animation = "YoshiIdle"
		else:
			player.current_animation = "Walk"
	await get_tree().create_timer(7).timeout
	if moving_victory:
		victory = true
		black_out.play_backwards("BlackOut")
		player.camera.top_level = true
		player.camera.global_position = player.global_position
	await get_tree().create_timer(1).timeout
	walk_off = true
	if not moving_victory:
		victory = true
	else:
		victory = false
	player.level_finish_complete.emit()


func update(delta: float) -> void:
	player.z_index = 10

func physics_update(delta) -> void:
	player.sprite_speed_scale = 1
	if victory:
		player.velocity.x = 0
		if player.riding_yoshi:
			player.current_animation = "YoshiVictory"
		else:
			player.current_animation = "Victory"
		player.yoshi_animations.play("Idle")
		
	elif not walk_off:
		if moving_victory:
			player.velocity.x = 15
		else:
			player.velocity.x = 0
		if player.riding_yoshi:
			player.current_animation = "YoshiIdle"
		else:
			if player.is_on_floor():
				if moving_victory:
					player.current_animation = "Walk"
				else:
					player.current_animation = "Idle"
			else:
				player.current_animation = "Fall"
	else:
		player.sprite_speed_scale = abs(player.velocity.x) / 40
		player.velocity.x += 1
		player.yoshi_animations.play("Move")
		if player.riding_yoshi:
			player.current_animation = "YoshiIdle"
		else:
			player.current_animation = "Walk"
	if not moving_victory:
		player.velocity.x = 0
	player.velocity.y += 15
	player.velocity.y = clamp(player.velocity.y, -99999, 240)
