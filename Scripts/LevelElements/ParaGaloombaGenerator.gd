extends CollisionShape2D
@onready var area: Area2D = $Area
@onready var collision_shape_2d: CollisionShape2D = $Area/CollisionShape2D

@export var entities: Array[PackedScene] = []

var spawn_timer := 0.9
@export var spawn_speed := 1.0

@export var spawn_range := 128
@export var varying_range := true
@export var spawn_height := -300
@export var varying_height := false

func _ready() -> void:
	collision_shape_2d.shape = shape.duplicate()

func _physics_process(delta: float) -> void:
	if area.get_overlapping_areas().any(is_player):
		spawn_timer += spawn_speed * delta
	if spawn_timer >= 2:
		spawn_timer = 0
		spawn_entity()

func spawn_entity() -> void:
	var node = entities.pick_random().instantiate()
	var spawn_offset := Vector2.ZERO
	spawn_offset.x += spawn_range if not varying_range else randi_range(-abs(spawn_range), abs(spawn_range))
	spawn_offset.y += spawn_height if not varying_height else randi_range(-abs(spawn_height), abs(spawn_height))
	
	node.global_position = get_viewport().get_camera_2d().get_screen_center_position() + spawn_offset
	GameManager.current_level.add_child(node)

func is_player(area: Area2D): return area.get_parent() is Player
