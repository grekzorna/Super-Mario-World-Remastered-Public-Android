extends Node2D
signal block_hit


func _on_left_area_entered(area: Area2D) -> void:
	if check_valid(area):
		emit_signal("block_hit", "Left")


func _on_right_area_entered(area: Area2D) -> void:
	if check_valid(area):
		emit_signal("block_hit", "Right")

func check_valid(area: Area2D) -> bool:
	var valid := false
	if area.get_parent() is Shell:
		if area.get_parent().moving and area.get_parent().held == false:
			valid = true
	if area.get_parent() is Player:
		get_parent().player = area.get_parent()
		if area.get_parent().spin_attacking:
			valid = true
	
	return valid
