extends Enemy

const move_speed := 32
@onready var starting_y := global_position.y
var bob := 0.0

func _physics_process(delta: float) -> void:
	global_position.x -= move_speed * delta
	bob += 4 * delta
	bob = wrap(bob, 0, PI * 2)
	global_position.y = starting_y + sin(bob) * 4
