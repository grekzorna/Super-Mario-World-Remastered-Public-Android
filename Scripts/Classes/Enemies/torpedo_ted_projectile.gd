extends Enemy

var move_speed := 150

func _ready() -> void:
	sprite.scale.x = -direction
	velocity.y = 50

func _physics_process(delta: float) -> void:
	velocity.y = lerpf(velocity.y, 0, delta * 5)
	velocity.x = lerpf(velocity.x, move_speed * direction, delta * 2)
	sprite.scale.x = -direction
	move_and_slide()
