extends Control

var player: Player

func _ready() -> void:
	player = get_parent() as Player

func _process(delta: float) -> void:
	if player != null:
		global_position = player.get_global_transform_with_canvas().origin
		global_position = clamp(global_position, Vector2.ZERO, Vector2(1920, 1080))
