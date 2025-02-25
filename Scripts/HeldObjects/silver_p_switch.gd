extends HeldObject


func activate() -> void:
	GameManager.current_level.silver_switch_activate()
	SoundManager.play_sfx(SoundManager.switch_activate, self)
	sprite.frame = 1
	await get_tree().create_timer(0.1, false).timeout
	queue_free()

func _on_pressbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		if not (Input.is_action_pressed("run") and not area.get_parent().holding):
			if area.get_parent().velocity.y > 50 and not held:
				activate()
