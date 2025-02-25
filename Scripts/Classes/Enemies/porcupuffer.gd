extends Enemy

var target_player: Player = null
var move_speed := 200

func _physics_process(delta: float) -> void:
	target_player = CoopManager.get_closest_player(global_position)
	if target_player.global_position.x > global_position.x:
		direction = 1
	else:
		direction = -1
	velocity.x = lerpf(velocity.x, move_speed * direction, delta / 2)
	sprite.scale.x = -direction
	move_and_slide()
