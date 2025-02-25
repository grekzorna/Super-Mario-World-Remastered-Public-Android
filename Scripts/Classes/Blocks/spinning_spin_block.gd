extends Node2D

var spinning := true

func _physics_process(delta: float) -> void:
	if not spinning:
		if $PlayerDetection.get_overlapping_areas().any(func(area: Area2D): return area.get_parent() is Player) == false:
			return_to_static()

func stop_spinning() -> void:
	spinning = false

func return_to_static() -> void:
	var node = load("res://Instances/Prefabs/Blocks/spin_block.tscn").instantiate()
	node.global_position = global_position
	add_sibling(node)
	queue_free()
