extends Node2D

var speed := 150
var direction := -1

func _physics_process(delta: float) -> void:
	global_position.x += (speed * direction) * delta

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		area.get_parent().damage()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
