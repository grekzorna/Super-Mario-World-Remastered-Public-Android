extends Node2D

var claimed := false

@export var custom_trigger := false
@export var coin_resource: CrystalCoin = null
signal activated

@onready var coin = preload("res://Instances/Prefabs/Interactables/crystal_coin_appear_ghost.tscn")
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		if area.get_parent().ground_pounding:
			if custom_trigger:
				emit_signal("activated")
			elif not claimed:
				claimed = true
				spawn_coin(get_parent(), coin_resource)

func spawn_coin(root: Node, resource: CrystalCoin) -> void:
	var coin_node = coin.instantiate()
	coin_node.destination = global_position + Vector2(0, -64)
	coin_node.global_position = global_position
	coin_node.coin_resource = resource
	root.add_child(coin_node)

