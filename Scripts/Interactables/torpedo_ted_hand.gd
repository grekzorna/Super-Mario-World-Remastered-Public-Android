extends Node2D

const TORPEDO_TED_PROJECTILE = preload("res://Instances/Prefabs/Enemies/torpedo_ted_projectile.tscn")

var direction := 1

func _physics_process(delta: float) -> void:
	var target_player: Player = CoopManager.get_closest_player(global_position)
	if target_player.global_position.x > global_position.x:
		direction = 1
	else:
		direction = -1
	$Joint.scale.x = -direction

func spawn_torpedo() -> void:
	var node = TORPEDO_TED_PROJECTILE.instantiate()
	node.global_position = global_position + Vector2(0, 16)
	node.direction = direction
	add_sibling(node) 
