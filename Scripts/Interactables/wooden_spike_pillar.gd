extends StaticBody2D

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		if Vector2.UP.dot((area.get_parent().global_position - global_position).normalized()) > 0.5:
			if area.get_parent().riding_yoshi == false:
				area.get_parent().damage()
		else:
			area.get_parent().damage()
