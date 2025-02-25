extends BowserBossState

func enter(_msg := {}) -> void:
	boss.cutscene = true
	boss.can_hurt = false
	boss.bowser_sprite.play("Leave")
	await boss.bowser_sprite.animation_finished
	boss.get_parent().stop_music()
	boss.clown_car_animations.play("ZoomOut")
	SoundManager.play_ui_sound("res://Assets/Audio/SFX/SMW/BowserZoomOut.mp3")
	await get_tree().create_timer(5.5, false).timeout
	boss.get_parent().intro_music.play()
	state_machine.transition_to("Fireball")
	
