extends Node2D

func _ready() -> void:
	$Right.global_position.x = GameManager.current_level.camera_left_end_position
