extends BowserBossState

func enter(_msg := {}) -> void:
	boss.get_parent().stop_music()
	boss.remove_mecha_koopas()
	boss.seen_intro = false
	boss.z_index = 0
	SoundManager.play_global_sfx(preload("res://Assets/Audio/SFX/SMW/BowserDefeat.mp3"))
	boss.defeat_particles.show()
	await get_tree().create_timer(2.5, false).timeout
	boss.defeat_particles.hide()
	boss.animations.play("Death")
	await get_tree().create_timer(0.8, false).timeout
	boss.get_parent().peach_spawn()
	boss.dead.emit()
	await boss.animations.animation_finished
	boss.queue_free()
