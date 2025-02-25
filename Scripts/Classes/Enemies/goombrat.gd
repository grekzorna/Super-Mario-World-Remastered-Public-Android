extends Enemy

var can_hit := true
const move_speed := 40
var can_move := true

func _physics_process(delta: float) -> void:
	$LedgeDetectionCast.direction = direction
	$LedgeDetectionCast.floor_normal = get_floor_normal()
	if is_on_wall() or ($LedgeDetectionCast.is_colliding() == false and is_on_floor()):
		direction *= -1
	if can_move:
		velocity.x = move_speed * direction
	else:
		velocity.x = 0
	velocity.y += 15
	sprite.scale.x = -direction
	move_and_slide()

func damage() -> void:
	sprite.play("Die")
	$Hitbox.queue_free()
	can_move = false
	await get_tree().create_timer(0.25, false).timeout
	queue_free()
