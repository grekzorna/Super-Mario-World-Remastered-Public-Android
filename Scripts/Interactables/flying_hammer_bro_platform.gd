extends Node2D

const fall_speed := 30
var swish : float = 0.0
const swish_speed : float = 60.0

@onready var starting_position := global_position

func _physics_process(delta: float) -> void:
	swish += 1 * delta
	var swish_x = (starting_position.x + sin(swish) * 96) + 32
	var swish_y = starting_position.y + (cos(swish * 2) * 48)
	global_position = Vector2(swish_x, swish_y)
