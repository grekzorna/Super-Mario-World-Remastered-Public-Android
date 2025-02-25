extends Node2D

var active := false

func _physics_process(delta: float) -> void:
	if active:
		global_position.x += 48 * delta

func hitbox_hit(area: Area2D) -> void:
	if area.get_parent() is Player:
		if not active:
			$Animation.play("Move")
		active = true
