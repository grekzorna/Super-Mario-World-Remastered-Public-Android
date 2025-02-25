extends Node2D

@export var path: Curve2D = null
const STATIC_SNAKE_BLOCK = preload("res://Instances/Prefabs/Blocks/static_snake_block.tscn")
var front_travel_index := 0.0
var back_travel_index := 0.0
var moving := false
@export var length := 4

@onready var sfx: AudioStreamPlayer2D = $Front/SFX

@export var move_speed := 32.0

@onready var active_blocks = []
@onready var line_2d: Line2D = $Line2D
@onready var hitbox: Area2D = $Hitbox

@onready var front: StaticBody2D = $Front
@onready var back: StaticBody2D = $Back

func _ready() -> void:
	add_starting_blocks()
	
	front_travel_index = path.get_closest_offset(front.global_position)
	for i in path.get_baked_points():
		line_2d.add_point(i)

var spawn_timer := 0.0

func _physics_process(delta: float) -> void:
	spawn_timer += 1 * delta
	var current_snap = front.global_position.snapped(Vector2(16, 16)) - Vector2(8, 8)
	$Sprite2D.global_position = current_snap
	if moving:
		front_travel_index += move_speed * delta
		back_travel_index += move_speed * delta
	if front_travel_index >= path.get_baked_length():
		moving = false
		$Front/SFX.stop()
	front.global_position = (path.sample_baked(front_travel_index))
	back.global_position = (path.sample_baked(back_travel_index))

func add_starting_blocks():
	for i in length - 1:
		var node = STATIC_SNAKE_BLOCK.instantiate()
		node.position = Vector2((i + 1) * 16, 0)
		active_blocks.append(node)
		add_child(node)
		$Front.global_position.x += 16
	hitbox.position.x = ((length * 16) / 2) - 8
	$Hitbox/CollisionShape2D.shape.size.x = length * 16

func start() -> void:
	moving = true
	$Timer.start(16 / move_speed)
	sfx.play()

func spawn_blocks() -> void:
	if not moving:
		return
	var node = STATIC_SNAKE_BLOCK.instantiate()
	node.global_position = front.global_position.snapped(Vector2(8, 8))
	add_sibling(node)
	active_blocks.push_back(node)

func remove_block() -> void:
	if not moving:
		return
	active_blocks.pop_front().queue_free()


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		if area.get_parent().velocity.y > 0:
			start()
			hitbox.queue_free()
