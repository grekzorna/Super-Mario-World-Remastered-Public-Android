extends Enemy

@export_enum("Fast", "Slow", "Static") var speed := 0
@export var fall := false

const FAST_SPEED := 64
const SLOW_SPEED := 32

var move_speed := 0.0

var move := 0.0
var bob_rate := 4
@onready var starting_position = global_position

func _ready() -> void:
	match speed:
		0:
			move_speed = FAST_SPEED
		1:
			move_speed = SLOW_SPEED
		2:
			move_speed = 0

func _physics_process(delta: float) -> void:
	if not fall:
		move += bob_rate * delta
		global_position.x -= move_speed * delta
		global_position.y = (starting_position.y + 16) + sin(move) * bob_rate
	else:
		velocity.y += 15
		velocity.y = clamp(velocity.y, -9999, 200)
		move_and_slide()
