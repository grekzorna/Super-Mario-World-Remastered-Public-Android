extends PlayerState

var speaker: Node2D = null
var direction := 1

var desired_position := Vector2.ZERO

var moving := true

func enter(msg := {}) -> void:
	player.velocity.x = 0
	speaker = msg.get("Speaker")
	moving = true
	desired_position = Vector2(speaker.global_position.x + (32 * speaker.direction), player.global_position.y)
	camera_zoom_tween(Vector2(1.25, 1.25))
	
func camera_zoom_tween(zoom) -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(player.camera, "zoom", zoom, 0.5)


func physics_update(delta: float) -> void:
	player.sprite.scale.x = player.direction
	player.current_animation = ("Walk")
	if desired_position.x > player.global_position.x:
		direction = 1
	elif desired_position.x < player.global_position.x:
		direction = -1
	else:
		direction = -speaker.direction
		player.current_animation = "Idle"
	player.velocity += player.gravity_vector * player.gravity
	player.direction = direction
	player.global_position.x = move_toward(player.global_position.x, desired_position.x, delta * 50)

func exit() -> void:
	camera_zoom_tween(Vector2.ONE)
