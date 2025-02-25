class_name ObjectReplacer
extends Node

@export var nodes_to_replace: Dictionary = {}
@export var condition := ""
@export var global := true

func _ready() -> void:
	if condition != "":
		if check_condition() == false:
			queue_free()
			return
	await get_tree().physics_frame
	if global:
		replace_nodes(GameManager.current_level)
	else:
		replace_nodes(get_parent())

func check_condition() -> bool:
	var exp = Expression.new()
	exp.parse(condition)
	return exp

func replace_nodes(root: Node) -> void:
	for i in root.get_children():
		for x in nodes_to_replace.keys():
			if i.scene_file_path == x.resource_path:
				spawn_new_node(nodes_to_replace[x], i.global_position)
				i.queue_free()

func spawn_new_node(node: PackedScene, position := Vector2.ZERO) -> void:
	var new = node.instantiate()
	new.global_position = position
	GameManager.current_level.add_child(new)
