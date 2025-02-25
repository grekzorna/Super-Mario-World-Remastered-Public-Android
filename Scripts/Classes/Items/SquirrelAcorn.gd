extends PowerUp
@onready var sprite: Sprite2D = $Sprite2D

var direction := 1
var can_hit := true
const move_speed := 50

func _physics_process(delta: float) -> void:
	sprite.rotation_degrees += direction * 400 * delta
	velocity.x = move_speed * direction
	velocity.y += 15
	if is_on_wall() and can_hit:
		can_hit = false
		direction *= -1
		await get_tree().create_timer(0.1).timeout
		can_hit = true
	move_and_slide()
