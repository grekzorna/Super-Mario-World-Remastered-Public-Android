extends Node2D

@export var item: PackedScene = null

var launch_direction := 1
var launch_height := 300
var launch_speed := 150

func spawn_item() -> void:
	var item_node = item.instantiate()
	item_node.global_position = global_position + Vector2(8 * launch_direction, 0)
	item_node.direction = launch_direction
	SoundManager.play_sfx(SoundManager.item_sprout, self)
	GameManager.current_level.call_deferred("add_child", (item_node))
	item_node.velocity = Vector2(launch_speed * launch_direction, -launch_height)


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		launch_direction = area.get_parent().direction
		spawn_item()
		queue_free()
