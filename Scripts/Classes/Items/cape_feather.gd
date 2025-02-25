extends PowerUp
@onready var sprite: Sprite2D = $Sprite
@onready var area_2d: Area2D = $Area2D

const fall_speed := 30
var swish : float = 0.0
const swish_speed : float = 60.0


func await_obtain() -> void:
	can_grab = false
	await self.ready
	await get_tree().create_timer(0.5, false).timeout
	can_grab = true

func _physics_process(delta: float) -> void:
	area_2d.global_position = sprite.global_position
	if velocity.y > 0:
		swish += 5 * delta
	sprite.position.x = sin(swish) * 32
	sprite.flip_h = sin(swish) < 0
	sprite.position.y = (cos(swish * 2) * 8)
	velocity.y += fall_speed
	velocity.y = clamp(velocity.y, -99999, fall_speed)
	velocity.x = lerpf(velocity.x, 0, delta * 5)
	move_and_slide()
