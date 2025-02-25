extends Node
@onready var camera: Camera2D = $Camera

var slow_speed := 100
var fast_speed := 400

func _ready() -> void:
	get_tree().paused = true

func _process(delta: float) -> void:
	get_tree().paused = true
	var vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	camera.global_position += (vector * (fast_speed if Input.is_action_pressed("run") else slow_speed)) * delta
