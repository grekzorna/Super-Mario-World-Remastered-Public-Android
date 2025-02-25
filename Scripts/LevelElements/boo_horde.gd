extends Node2D

const amount := 100

var scene = preload("res://Instances/Parts/horde_boo.tscn")

func _ready() -> void:
	for i in amount:
		spawn_boo()

func spawn_boo() -> void:
	randomize()
	var node = scene.instantiate()
	var spawn_position = Vector2(randf_range(-904, 904), randf_range(-96, 0))
	node.starting_position = spawn_position
	node.position = spawn_position
	add_child(node)
