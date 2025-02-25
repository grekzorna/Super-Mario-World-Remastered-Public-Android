class_name ConditionalReplaceNode
extends Node

@export var nodes_to_delete: Array[Node] = []

func _ready() -> void:
	if condition() == false:
		queue_free()
		return
	
	for i in nodes_to_delete:
		i.queue_free()
	for i in get_children():
		i.call_deferred("reparent", (get_parent()))

func condition() -> bool:
	return true
