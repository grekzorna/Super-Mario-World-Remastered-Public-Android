extends Node2D

@export var dispenced_scene: PackedScene = null

@export var auto_spawn := true
@export var spawn_time := 1.0

@export var override_properties := {}
@export_enum("Up", "Down", "Left", "Right") var dispence_direction := "Down"#
@export var max_nodes := 3
@export var position_offset := Vector2.ZERO

var node_count := 0

var out_of_area := true

func _ready() -> void:
	$Sprite.hide()
	if auto_spawn:
		$Timer.start(spawn_time)
		await get_tree().physics_frame
		spawn_item()

func spawn_item() -> void:
	if not out_of_area:
		return
	if node_count >= max_nodes:
		return
	node_count += 1
	out_of_area = false
	var node = dispenced_scene.instantiate()
	for i in override_properties.keys():
		node.set(i, override_properties[i])
	node.tree_exited.connect(node_deleted)
	node.global_position = global_position + (get_direction_offset() * 8) + position_offset
	GameManager.current_level.add_child(node)
	dispence_tween(node)
	if auto_spawn:
		$Timer.start(spawn_time)

func node_deleted() -> void:
	node_count -= 1

func _on_timer_timeout() -> void:
	if node_count < max_nodes and out_of_area:
		spawn_item()

func dispence_tween(node: Node2D) -> void:
	var old_z = node.z_index
	var tween = create_tween()
	node.z_index = -5
	if node is CharacterBody2D:
		node.set_physics_process(false)
	if node is Enemy:
		if dispence_direction == "Right":
			node.direction = 1
		elif dispence_direction == "Left":
			node.direction = -1
	tween.tween_property(node, "global_position", (global_position - get_direction_offset() * 8) + position_offset, 0.5)
	await tween.finished
	if is_instance_valid(node):
		if node is CharacterBody2D:
			node.set_physics_process(true)
			node.velocity = Vector2.ZERO
		node.z_index = old_z

func get_direction_offset() -> Vector2:
	match dispence_direction:
		"Up":
			return Vector2.UP
		"Down":
			return Vector2.DOWN
		"Left":
			return Vector2.LEFT
		"Right":
			return Vector2.RIGHT
		_:
			return Vector2.ZERO

func _on_area_area_exited(area: Area2D) -> void:
	if area.get_parent().get_class() == dispenced_scene.instantiate().get_class():
		out_of_area = true
