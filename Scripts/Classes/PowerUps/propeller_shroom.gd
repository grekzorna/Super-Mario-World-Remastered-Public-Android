extends PowerUp

var move := 0.0
const move_speed := 2
@onready var sprite: AnimatedSprite2D = $Sprite

func _physics_process(delta: float) -> void:
	if velocity.y >= 0:
		move += move_speed * delta
		global_position.y += 0.5 * delta
		global_position.x += 32 * delta
		sprite.position.y = (sin(move) * (move * 5)) - 8
		velocity = Vector2.ZERO
	else:
		velocity.y += 10
		velocity.y = clamp(velocity.y, -999, 0)
	move_and_slide()
