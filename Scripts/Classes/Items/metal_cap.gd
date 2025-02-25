extends PowerUp

func hitbox_hit(area: Area2D) -> void:
	if can_grab == false:
		return
	elif area.get_parent() is Player:
		area.get_parent().metal_meter = 100
		area.get_parent().power_up(power)
		MusicPlayer.metal_mario()
		queue_free()
