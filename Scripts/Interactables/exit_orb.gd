extends Node2D

signal collected

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		GameManager.course_clear.level_finish()
		collected.emit()
		MusicPlayer.play_boss_defeated_theme()
		area.get_parent().state_machine.transition_to("LevelFinish")
		$Hitbox.queue_free()
		hide()
		await GameManager.course_clear.finished
		TransitionManager.transition_to_map(GameManager.current_map_path, GameManager.current_level, true)
