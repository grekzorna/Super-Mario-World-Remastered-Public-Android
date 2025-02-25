class_name LiquidDetector
extends Area2D

func is_in_lava() -> bool:
	set_collision_mask_value(6, false)
	set_collision_mask_value(7, true)
	return get_overlapping_bodies().is_empty() == false

func is_in_water() -> bool:
	set_collision_mask_value(7, false)
	set_collision_mask_value(6, true)
	if get_overlapping_bodies().is_empty() == false:
		pass
	return get_overlapping_bodies().is_empty() == false
