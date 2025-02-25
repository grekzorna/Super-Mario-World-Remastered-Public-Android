extends CollisionShape2D
@onready var area: Area2D = $Area
@export var spawn_y_position := 0.0
var spawn_direction := -1
@export var dolphin_direction := 1
@onready var collision_shape_2d: CollisionShape2D = $Area/CollisionShape2D
var spawn_timer := 0.9
const DOLPHIN_SCENE = preload("res://Instances/Prefabs/FriendlyEntities/dolphin.tscn")

func _ready() -> void:
	collision_shape_2d.shape = shape.duplicate()

func _physics_process(delta: float) -> void:
	if area.get_overlapping_areas().any(is_player):
		spawn_timer += 1 * delta
	if spawn_timer >= 1:
		spawn_timer = 0
		spawn_entity()

func spawn_entity() -> void:
	if Dolphin.amount > 4:
		return
	var node = DOLPHIN_SCENE.instantiate()
	node.global_position = get_viewport().get_camera_2d().global_position + Vector2(280 * spawn_direction, -spawn_y_position)
	print(node.global_position)
	node.generated = true
	if dolphin_direction == -1:
		node.horizontal_move_direction = 0
	else:
		node.horizontal_move_direction = 1
	GameManager.current_level.add_child(node)

func _exit_tree() -> void:
	Dolphin.amount = 0

func is_player(area: Area2D): return area.get_parent() is Player
