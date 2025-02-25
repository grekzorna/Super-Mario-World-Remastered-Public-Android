extends PlayerState

var grav := false
var animating := false

func enter(msg := {}) -> void:
	grav = msg.has("Gravity")
	animating = msg.has("Animating")
	player.skid_sfx.stop()

func physics_update(_delta: float) -> void:
	player.velocity.x = 0
	player.sprite.scale.x = player.direction
	if animating:
		pass
	elif player.riding_yoshi:
		player.current_animation = "YoshiIdle"
	else:
		if player.is_on_floor():
			player.current_animation = "Idle"
		elif player.velocity.y > 0:
			player.current_animation = "Fall"
		else:
			player.current_animation = "Jump"
	if grav:
		player.velocity.y += player.gravity
	else:
		player.velocity = Vector2.ZERO

func exit() -> void:
	player.set_collision_mask_value(1, true)
