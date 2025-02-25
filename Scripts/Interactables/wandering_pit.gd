extends Node2D

func _physics_process(delta: float) -> void:
	for i in $Sprite/Hitbox.get_overlapping_areas():
		if i.get_parent() is CharacterBody2D:
			if i.get_parent() is Player:
				i.get_parent().set_collision_mask_value(1, false)
			else:
				i.get_parent().set_collision_mask_value(3, false)




func _on_hitbox_area_exited(area: Area2D) -> void:
	if area.get_parent() is CharacterBody2D:
		if area.get_parent() is Player:
			area.get_parent().set_collision_mask_value(1, true)
		else:
			area.get_parent().set_collision_mask_value(3, true)
