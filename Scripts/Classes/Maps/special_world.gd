extends MapLevel

signal secret_music_play

func _on_timer_timeout() -> void:
	music.stop()
	$Music2.play()
	secret_music_play.emit()


func _on_star_exit_activated() -> void:
	GameManager.autumn = not GameManager.autumn
	SaveManager.current_save.autumn_unlocked = true
	SaveManager.save_current_file()
