extends PlayerState

var bonus := false
var points := 0
var secret := false

func enter(msg := {}) -> void:
	player.vibrate_controller(1, 0.25)
	player.hitbox_area.monitoring = false
	player.set_collision_mask_value(1, true)
	player.set_collision_layer_value(1, false)
	player.hitbox_area.monitorable = false
	player.hitbox_area.monitoring = false
	player.spinning = false
	SoundManager.play_ui_sound(SoundManager.checkpoint)
	await CoopManager.wait_finished
	CoopManager.level_finish(bonus, points, secret)

func physics_update(delta: float) -> void:
	if player.is_on_floor() == false:
		pass
	else:
		player.current_animation = "Idle"
		player.direction = -1
		player.velocity.x = 0
	player.velocity.y += 15
	player.sprite.scale.x = player.direction
	
