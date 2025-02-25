class_name TriangleBlock
extends StaticBody2D

var player: Player = null

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		player = area.get_parent()
		if player.riding_yoshi:
			SoundManager.play_sfx(SoundManager.spring, self)
			player.bounce_off()
			if player.global_position.y > $Area2D.global_position.y:
				player.velocity.y -= 100
			return
		elif player.direction != scale.x:
			return
		player.on_triangle_block = true
	if area.get_parent() is Shell:
		area.get_parent().on_triangle_block = true


func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.get_parent() is Player:
		player = area.get_parent()
		player.on_triangle_block = false
	if area.get_parent() is Shell:
		area.get_parent().on_triangle_block = false
