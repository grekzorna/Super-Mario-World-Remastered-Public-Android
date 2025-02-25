extends CollisionShape2D

@onready var area: Area2D = $Area
@onready var area_shape: CollisionShape2D = $Area/Shape


@export var camera_position := Vector2.ZERO

var player: Player = null

func _ready() -> void:
	area_shape.shape = shape#
	$Sprite2D.hide()

func _process(delta: float) -> void:
	if area.get_overlapping_areas().any(is_player):
		
		player.camera.global_position = lerp(player.camera.global_position, camera_position, delta * 5)

func is_player(area: Area2D) -> bool:
	if area.get_parent() is Player:
		player = area.get_parent()
	return area.get_parent() is Player
